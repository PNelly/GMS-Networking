/// @description  valid_packet(source_ip, source_port, related_socket, buffer)

// check packet meta data and contents against expected values to determine
// whether it should be processed at all

var _ip     = argument0;
var _port   = argument1;
var _socket = argument2;
var _buffer = argument3;

var _valid_rdvz_meta = false;
var _valid_udp_meta  = false;
var _valid_meta_data = false;

// first bytes needed to distinguish lan broadcast from a session host packet
var _bool_u8;
var _msg_id;
var _lan_broadcast;
var _peer_to_peer;

if(buffer_get_size(_buffer) == 0)
	return false;

buffer_seek(_buffer,buffer_seek_start,0);

_bool_u8    = buffer_read(_buffer,buffer_u8);
_msg_id     = buffer_read(_buffer,buffer_u16);

_lan_broadcast = (
                    (_socket == broadcast_socket)
                 &&
                     (
                        _msg_id == udp_msg.udp_host_lan_broadcast
                      ||_msg_id == udp_msg.udp_idle_lan_broadcast
                      ||_msg_id == udp_msg.udp_migration_meta_host
                      ||_msg_id == udp_msg.udp_migration_meta_client
                     )
                 );

_peer_to_peer = (
                          _msg_id == udp_msg.udp_peer_call
                        ||_msg_id == udp_msg.udp_peer_response
                        ||_msg_id == udp_msg.udp_migrate_lost_host
                        ||_msg_id == udp_msg.udp_migrate_new_host
                     );
                 
// verify metadata 
_valid_rdvz_meta = (_ip == rendevouz_ip && _port == rendevouz_tcp_port);

if(!udp_is_host()){    
    _valid_udp_meta =((_ip == udp_host_to_join_ip && _port == udp_host_to_join_port)
                    ||(_ip == udp_host_ip && _port == udp_client_host_port)
                    || _lan_broadcast
                    || _peer_to_peer);

} else {

    var _idx, _map, _num;
    
    _num = ds_list_size(udp_client_list);
    
    for(_idx=0;_idx<_num;_idx++){ // check clients
    
        _map = udp_client_maps[? udp_client_list[| _idx]];
        
        if(_socket == udp_host_socket
        && _map[? "ip"] == _ip
        && _map[? "client_port"] == _port){
            
            _valid_udp_meta = true;
            break;
        
        } else if (_socket == udp_client_socket
        && _map[? "ip"] == _ip
        && _map[? "host_port"] == _port
        && _peer_to_peer){
        
            _valid_udp_meta = true;
            break;
        }
    }
    
    if(!_valid_udp_meta){
    
        _num = ds_list_size(udp_hole_punch_list);
        
        for(_idx=0;_idx<_num;_idx++){ // check hole punch
        
            _map = udp_hole_punch_maps[? udp_hole_punch_list[| _idx]];
            
            if(_map[? "ip"] == _ip && _map[? "client_port"] == _port){
                _valid_udp_meta = true;
                break;   
            }
        }
    }
    
    if(!_valid_udp_meta){
        if(_lan_broadcast) // check if broadcast
            _valid_udp_meta = true;
    }
}

_valid_meta_data = (_valid_rdvz_meta || _valid_udp_meta);

// verify contents

var _checksumA  = -1;
var _checksumB  = -2;
var _udplrg_len = buffer_peek(_buffer,udp_header_offset_udplrg_len,buffer_u16);

var _valid_bool        = false;
var _valid_rdvz_msg_id = false;
var _valid_udp_msg_id  = false;
var _valid_msg_id      = false;
var _valid_checksum    = false;

_valid_bool = (_bool_u8 == 0 || _bool_u8 == 1);

if(_bool_u8 == 1){ // is udp and contains checksum
    _checksumA  = buffer_read(_buffer,buffer_u32);
	_checksumB  = buffer_checksum(udp_header_size,_buffer,_udplrg_len);
    _valid_checksum = (_checksumA == _checksumB);
} else if (_bool_u8 == 0){
    _valid_checksum = true; // no checksum on tcp
}


_valid_rdvz_msg_id = (_msg_id >= rdvz_msg.rdvz_msg_enum_start
                    &&_msg_id <= rdvz_msg.rdvz_msg_enum_end);
_valid_udp_msg_id  = (_msg_id >= udp_msg.udp_msg_enum_start
                    &&_msg_id <= udp_msg.udp_msg_enum_end);
                    
_valid_msg_id = (_valid_rdvz_msg_id || _valid_udp_msg_id);



// verify consistency between socket and message id
var _consistent_rdvz = false;
var _consistent_udp  = false;
var _consistent      = false;

_consistent_rdvz = (_valid_rdvz_msg_id && _socket == rdvz_client_socket);
_consistent_udp  = (_valid_udp_msg_id  
                    &&(_socket == udp_client_socket || _socket == udp_host_socket || _socket == broadcast_socket));
_consistent      = (_consistent_rdvz || _consistent_udp);

// Lookout for bad information from rdvz server and re-establish connection
if(_socket == rdvz_client_socket && _port == 0){
    system_message_set("got bad data from meetup server, attempting reconnect");
    rdvz_client_setup_reconnect();
    return false;
}

// check flags and save packet if it doesn't make sense (Have to remove above return statement)
if(!_valid_meta_data || !_valid_bool || !_valid_msg_id || !_consistent || !_valid_checksum){

    var _time = current_time;
    
    var _note_string = "Invalid packet detected by rdvz_id "+string(rendevouz_id)+" udp_id "+string(udp_id)+"#"
        +"valid rdvz meta "+string(_valid_rdvz_meta)+" valid udp meta "+string(_valid_udp_meta)
            +" consistent rdvz "+string(_consistent_rdvz)+" consistent udp "+string(_consistent_udp)+"#"
        +"udp is host "+string(udp_is_host())+" rdvz_client_socket "+string(rdvz_client_socket)
            +" udp_host_socket "+string(udp_host_socket)+" udp_client_socket "+string(udp_client_socket)+"#"
        +"event ip "+string(_ip)+" event port "+string(_port)+" event socket "+string(_socket)+"#"
        +"stated bool "+string(_bool_u8)+" stated message "+string(_msg_id)+"#"
        +"checksum A +"+string(_checksumA)+" checksum B "+string(_checksumB)
        +"###";
        
    if(udp_is_client()){
        _note_string += "client additional: #"
            +"host to join ip "+string(udp_host_to_join_ip)+"#"
            +"host to join port "+string(udp_host_to_join_port)+"#"
            +"host ip "+string(udp_host_ip)+"#"
            +"host port "+string(udp_client_host_port);
    } else if (udp_is_host()){
        _note_string += "host additional: #";
        
        var _idx, _client, _map, _num;
        _num = ds_list_size(udp_client_list);
        for(_idx=0;_idx<_num;++_idx){
            _client = udp_client_list[| _idx];
            _map    = udp_client_maps[? _client];
            _note_string += "client "+string(_client)
                +" ip "+string(_map[? "ip"])
                +" cport "+string(_map[? "client_port"])
                +" hport "+string(_map[? "host_port"])
                +" puIp "+string(_map[? "public_ip"])
                +" puCp "+string(_map[? "public_client_port"])
                +" puHp "+string(_map[? "public_host_port"])
                +"#";
        }
        var _num_hp = ds_list_size(udp_hole_punch_list);
        for(_idx=0;_idx<_num_hp;++_idx){
            _map = udp_hole_punch_maps[? udp_hole_punch_list[| _idx]];
            _note_string += "hp num "+string(_idx)
                +" ip "+string(_map[? "ip"])
                +" cport "+string(_map[? "client_port"]);
        }
    } else if (rendevouz_state == rdvz_states.rdvz_join_hole_punching){
        _note_string += "joining HP additional: #"
            +"host to join ip "+string(udp_host_to_join_ip)+"#"
            +"host to join port "+string(udp_host_to_join_port)+"#"
            +"host ip "+string(udp_host_ip)+"#"
            +"host port "+string(udp_client_host_port);
    }
        
    if(debug_save_invalid_pkt){
        buffer_save(_buffer,"badbuffer"+string(_time));
        var _note_file = file_text_open_write("BadBufferNote"+string(_time));
        file_text_write_string(_note_file,_note_string);
        file_text_close(_note_file);
    }
    
    if(debug_show_invalid_pkt)
        show_message_async(_note_string);
        
    return false;
}

return true;




