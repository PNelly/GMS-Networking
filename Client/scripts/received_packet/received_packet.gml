/// @description  received_packet(buffer,size,ip,port,socket)

var _buffer = argument0;
var _size   = argument1;
var _ip     = argument2;
var _port   = argument3;
var _socket = argument4;


var _is_udp, _msg_id, _checksum, _udpr_id, _sqn;
var _udpr_received, _valid_sqn, _sender_udp_id;
var _udplrg_id, _udplrg_idx, _udplrg_num, _udplrg_len;
var _lrgpkt_rcvd, _udp_has_payload, _sender_udp_id_non_neg;

        // -- // Check Packet Integrity // -- //
        
if(!valid_packet(_ip,_port,_socket,_buffer)) exit;
        
        // -- // Read Packet Header // -- //

buffer_seek(_buffer,buffer_seek_start,0);

_is_udp     = buffer_read(_buffer,buffer_bool);
_msg_id     = buffer_read(_buffer,buffer_u16);
        
if(_is_udp){ // only udp messages contain these header fields

    _checksum			= buffer_read(_buffer,buffer_u32);
    _sender_udp_id		= buffer_read(_buffer,buffer_s32);
    _sqn				= buffer_read(_buffer,buffer_u32);
    _udpr_id			= buffer_read(_buffer,buffer_u16);
	
	_udplrg_id			= buffer_read(_buffer,buffer_u16);
	_udplrg_idx			= buffer_read(_buffer,buffer_u16);
	_udplrg_num			= buffer_read(_buffer,buffer_u16);
	_udplrg_len			= buffer_read(_buffer,buffer_u16);
	
    _udpr_received		= false;
    _valid_sqn			= false;
    _lrgpkt_rcvd		= false;
	
	_udp_has_payload	= (buffer_get_size(_buffer) > udp_header_size);
	
	_sender_udp_id_non_neg = (_sender_udp_id >= 0);
	
    /*
        following checks will prevent a crash in udp_host_valid_sqn,
        need to be absorbed into valid packet somehow
    */
    
    // ignore self-referential packets (can happen in broadcasts)
    if(_sender_udp_id_non_neg
    && _sender_udp_id == udp_id
    && (udp_is_host() || udp_is_client())) exit;
      
    // ignore migration broadcasts from non clients
    // (confusion can occur around disconnects)
    if(_msg_id == udp_msg.udp_migration_meta_client
    || _msg_id == udp_msg.udp_migration_meta_host){
        if(_sender_udp_id_non_neg){
            if(udp_is_host() && !ds_map_exists(udp_client_maps,_sender_udp_id))
                exit;
            if(udp_is_client()
            &&!ds_map_exists(udp_client_maps, _sender_udp_id) 
            && _sender_udp_id != udp_host_id)
                exit;
        }
    }
    
    // if host, ignore lan broadcasts from other hosts //
	
    if(udp_is_host() && _msg_id == udp_msg.udp_host_lan_broadcast)
        exit;
    
    if(udp_is_host()){
		
        if(!_sender_udp_id_non_neg){
            _sender_udp_id  = udp_host_determine_client(_ip,_port);
			_sender_udp_id_non_neg = (_sender_udp_id >= 0);
		}
		
        if(_sender_udp_id_non_neg){ // only call udpr & stamp methods for accepted udp clients
            _valid_sqn      = udp_host_valid_seq_num(_sender_udp_id,_msg_id,_sqn);
            if(_udpr_id != 0)      
                _udpr_received  = udp_host_reliable_received(_sender_udp_id,_udpr_id,_udplrg_id,_udplrg_idx);
        }
		
    } else {
        _valid_sqn     = udp_client_valid_seq_num(_msg_id,_sqn);
        if(_udpr_id != 0)    
            _udpr_received  = udp_client_reliable_received(_udpr_id,_udplrg_id,_udplrg_idx);
    }
	
	// handle large messages arriving piecemeal //
	
	if(_udplrg_id > 0){
		if(udp_is_host()){
			
			if(udp_host_lrgpkt_rcvd(_sender_udp_id,_udplrg_id,_udplrg_idx,_udplrg_num,_udplrg_len,_buffer)){
				_buffer = udp_host_lrgpkt_assemble(_sender_udp_id,_udplrg_id,buffer_tell(_buffer));
				_lrgpkt_rcvd = true;
			} else {
				udp_host_reset_client_timeout(_sender_udp_id);
				exit;
			}
				
		} else if(udp_is_client()){
			
			if(udp_client_lrgpkt_rcvd(_udplrg_id,_udplrg_idx,_udplrg_num,_udplrg_len,_buffer)){
				_buffer = udp_client_lrgpkt_assemble(_udplrg_id,buffer_tell(_buffer));
				_lrgpkt_rcvd = true;
			} else {
				udp_client_reset_timeout();
				exit;
			}
				
		} else {
			
			exit;	
		}
	}
	
} else { 
	
	// TCP communications with rendevouz server //
	
    _sqn        = -1;
    _udpr_id    = -1;
}

    // -- // End Packet Header // -- //


// Read packet body and determine action to be taken //
    // -- // Handle TCP Messages from the Rendeouvz Server // -- //
if(!_is_udp){

    // - // Actions for all TCP packets // -- //
    
    // Receipt of any packet indicates connection still alive
    // (any packet is a keep alive packet)
    rdvz_connection_timer = rdvz_connection_timeout;
    rdvz_keep_alive_timer = rdvz_get_keep_alive_time();
 
  
    switch(_msg_id){
    
        // Being brought up to speed by server on connection
        case rdvz_msg.rdvz_bring_up_to_speed:
        
            rdvz_clear_client_properties();
            
            var _id, _ip, _is_host, _host_port, _host_clients; 
            var _host_max_clients, _client_port, _map;
            var _in_progress;
            var _num;
            
            rendevouz_id = buffer_read(_buffer,buffer_u16);
            _num         = buffer_read(_buffer,buffer_u16);
            
            debug_received_rdvz_id = true; // debug
            
            // read and define properties of all clients including self
            var _idx;
            for(_idx=0;_idx<_num;_idx++){
            
                _id                 = buffer_read(_buffer,buffer_u16);
                _ip                 = buffer_read(_buffer,buffer_string);
                _is_host            = buffer_read(_buffer,buffer_bool);
                _host_port          = buffer_read(_buffer,buffer_s32);
                _host_clients       = buffer_read(_buffer,buffer_u8);
                _host_max_clients   = buffer_read(_buffer,buffer_u8);
                _client_port        = buffer_read(_buffer,buffer_s32);
                _in_progress        = buffer_read(_buffer,buffer_bool);
                
                define_network_peer(rdvz_client_list, rdvz_client_maps,
                    _id, _ip, _is_host, _host_port, _host_clients, _host_max_clients,
                    _client_port, _in_progress);
            }
            
            // UDP Host reconnecting to allow in progress joins
            
            if(udp_state == udp_states.udp_host_game
            && udp_host_allow_join_in_progress){
                udp_host_attempt_session_create();
            }
        
        break;
        
        // being told about a new client connected to the rdvz server
        case rdvz_msg.rdvz_client_connected:
        
            var _id, _ip, _map;
            _id  = buffer_read(_buffer,buffer_u16);
            _ip  = buffer_read(_buffer,buffer_string);
            
            // initialize other client fields
            define_network_peer(rdvz_client_list, rdvz_client_maps,
                _id, _ip, false, -1, 0, 0, -1, false);

        break;
        
        // being told about a client disconnecting from the rdvz server
        case rdvz_msg.rdvz_client_disconnected:
        
            var _id     = buffer_read(_buffer,buffer_u16);
            
            if(ds_map_exists(rdvz_client_maps,_id)){
                var _map    = rdvz_client_maps[? _id];
            
                ds_map_delete(rdvz_client_maps,_id);
                ds_map_clear(_map);
                ds_map_destroy(_map);
            
                var _idx = ds_list_find_index(rdvz_client_list,_id);
                ds_list_delete(rdvz_client_list, _idx);
                
                // remove client from lan peers
                lan_sync_rdvz();
            }
        
        break;
        
        // being updated on the status of a client
        case rdvz_msg.rdvz_client_update_info:
        
            var _id     = buffer_read(_buffer,buffer_u16);
            var _map, _ip, _is_host, _host_port, _host_clients;
            var _host_max_clients, _client_port, _in_progress;
            
            // read and overwrite this rdvz client's properties
            _ip                 = buffer_read(_buffer,buffer_string);
            _is_host            = buffer_read(_buffer,buffer_bool);
            _host_port          = buffer_read(_buffer,buffer_s32);
            _host_clients       = buffer_read(_buffer,buffer_u8);
            _host_max_clients   = buffer_read(_buffer,buffer_u8);
            _client_port        = buffer_read(_buffer,buffer_s32);
            _in_progress        = buffer_read(_buffer,buffer_bool);
            
            if(!ds_map_exists(rdvz_client_maps,_id)){
                // create other client
                define_network_peer(rdvz_client_list, rdvz_client_maps,
                    _id, _ip, _is_host, _host_port, _host_clients, _host_max_clients,
                    _client_port, _in_progress);
            } else { // just overwrite
                _map = rdvz_client_maps[? _id];
                _map[? "ip"]                    = _ip;
                _map[? "udp_is_host"]           = _is_host;
                _map[? "udp_host_port"]         = _host_port;
                _map[? "udp_host_clients"]      = _host_clients;
                _map[? "udp_host_max_clients"]  = _host_max_clients;
                _map[? "udp_client_port"]       = _client_port;
                _map[? "udp_host_in_progress"]  = _in_progress;
            }
            
            // stay up to date with local network hosts
            lan_sync_rdvz();
            
        break;       
        
        // Receiving ID from Rendevouz Server
        case rdvz_msg.rdvz_tell_new_id:
            rendevouz_id = buffer_read(_buffer,buffer_u16);
            show_debug_message("received my rdvz id: "+string(rendevouz_id));
            debug_received_rdvz_id = true; // debug
            
            // re-negotiating after a client migration
            if(rendevouz_state == rdvz_states.rdvz_idle
            && ds_list_size(udp_client_list) < udp_max_clients
            &&  (
                    udp_state == udp_states.udp_host_lobby
                 ||(
                        udp_state == udp_states.udp_host_game
                     && udp_host_allow_join_in_progress
                    )
                )
            ){
                udp_host_attempt_session_create();
            }
            
        break;
    
        
        // Rendevouz Server Ready to Collect UDP port/ip
        case rdvz_msg.rdvz_request_udp_ping:
            show_debug_message("UDP ping requested");
            if(rendevouz_state == rdvz_states.rdvz_host_init){
                rendevouz_state = rdvz_states.rdvz_host_pinging_udp;
                rdvz_udp_ping_timer = rdvz_udp_ping_timeout;   
            }
                
            if(rendevouz_state == rdvz_states.rdvz_join_init){
                rendevouz_state = rdvz_states.rdvz_join_pinging_udp;
                rdvz_udp_ping_timer = rdvz_udp_ping_timeout;
            }
        break;
        
        
        // Rendevouz Server receieved UDP ping
        case rdvz_msg.rdvz_udp_acknowledge:
        
            if(rendevouz_state == rdvz_states.rdvz_host_pinging_udp
            || rendevouz_state == rdvz_states.rdvz_join_pinging_udp){
            
                udp_public_ip           = buffer_read(_buffer,buffer_string);
                udp_public_host_port    = buffer_read(_buffer,buffer_s32);
                udp_public_client_port  = buffer_read(_buffer,buffer_s32);
                
                show_debug_message("received public ip "+string(udp_public_ip)
                    +" public host port "+string(udp_public_host_port)
                    +" public client port "+string(udp_public_client_port));
            }
        
            if(rendevouz_state == rdvz_states.rdvz_host_pinging_udp){
            
                if(udp_state == udp_states.udp_none){
                    udp_host_init_session();
                } else if (udp_is_host()){
                    rendevouz_state = rdvz_states.rdvz_host;
                    udp_host_update_rendevouz();
                }
            }
            
            if(rendevouz_state == rdvz_states.rdvz_join_pinging_udp){
                show_debug_message("UDP client ping received by server - awaiting HP notice");
                system_message_set("waiting for hole punch go ahead");
                rendevouz_state = rdvz_states.rdvz_join_awaiting_hole_punch;
                // send hole punch request
                buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                buffer_write(message_buffer,buffer_u16,udp_host_to_join);
                rdvz_client_send(false,rdvz_msg.rdvz_udp_hole_punch_request,message_buffer);
                
            }
        break;
        
        
        // Rendevouz Server says Hole Punch Time
        case rdvz_msg.rdvz_udp_hole_punch_notice:
            show_debug_message("received hole punch notice");
            system_message_set("received hole punch notice");
            
            if(rendevouz_state == rdvz_states.rdvz_host){
                  
                if(((udp_state == udp_states.udp_host_lobby)
                  ||(udp_state == udp_states.udp_host_game && udp_host_allow_join_in_progress)
                   ) && ds_list_size(udp_client_list) < udp_max_clients){
                   
                    // add this client to hole punch structures
                    var _key = get_timer();
                    var _map = ds_map_create();
                    
                    var _hp_client      = buffer_read(_buffer,buffer_u16);
                    var _hp_client_ip   = buffer_read(_buffer,buffer_string);
                    var _hp_client_port = buffer_read(_buffer,buffer_u16);
                    
                    // if this client is a LAN peer overwrite IP & Port
                    var _local_map;
                    
                    if(ds_map_exists(lan_maps, _hp_client)){
                        _local_map = lan_maps[? _hp_client];
                        show_debug_message("HOST OVERWRITING WITH LOCAL");
                        show_debug_message("prev ip "+string(_hp_client_ip)+" prev port "+string(_hp_client_port));
                        show_debug_message("new ip "+string(_local_map[? "ip"])+" new port "+string(_local_map[? "udp_client_port"]));
                        _hp_client_ip   = _local_map[? "ip"];
                        _hp_client_port = _local_map[? "udp_client_port"];
                        show_debug_message("overwrote rdvz HP data with LAN peer info");
                    }
                    
                    ds_list_add(udp_hole_punch_list,_key);
                    udp_hole_punch_maps[? _key] = _map;
                    _map[? "key"]               = _key;
                    _map[? "ip"]                = _hp_client_ip;
                    _map[? "client_port"]       = _hp_client_port;
                    _map[? "timeout"]           = udp_hole_punch_timeout;
                    
                    system_message_set("host received hole punch notice");
                    
                } else {
                            
                    // reject this hole punch notice
                    var _asking_client = buffer_read(_buffer,buffer_u16);
                    
                    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                    buffer_write(message_buffer,buffer_u16,_asking_client);
                    rdvz_client_send(false,rdvz_msg.rdvz_udp_hole_punch_rejected,message_buffer);
                    
                    show_debug_message("host rejecting hole punch");
                }
            }
            
            if(rendevouz_state == rdvz_states.rdvz_join_awaiting_hole_punch){
                // begin hole punch process
                var _hp_host_ip = buffer_read(_buffer, buffer_string);
                var _hp_host_port = buffer_read(_buffer, buffer_s32);
                // if this host is a LAN peer overwrite IP & Port
                var _local_map;
                if(ds_map_exists(lan_maps, udp_host_to_join)){
                    _local_map = lan_maps[? udp_host_to_join];
                    show_debug_message("CLIENT OVERWRITING WITH LOCAL");
                    show_debug_message("prev ip "+string(_hp_host_ip)+" prev port "+string(_hp_host_port));
                    show_debug_message("new ip "+string(_local_map[? "ip"])+" new port "+string(_local_map[? "udp_host_port"]));
                    _hp_host_ip = _local_map[? "ip"];
                    _hp_host_port = _local_map[? "udp_host_port"];
                    show_debug_message("overwrote rdvz HP data with LAN peer info");
                }
                udp_host_to_join_ip = _hp_host_ip;
                udp_host_to_join_port = _hp_host_port;
                rendevouz_state = rdvz_states.rdvz_join_hole_punching;
                udp_hole_punch_timer = udp_hole_punch_timeout;
                show_debug_message("client beginning hole punch");
                system_message_set("beginning hole punch");
            }
        
        break;
        
        
        // Client denied permission to hole punch into UDP session
        case rdvz_msg.rdvz_udp_hole_punch_rejected:
            if(rendevouz_state == rdvz_states.rdvz_join_awaiting_hole_punch || rendevouz_state == rdvz_states.rdvz_join_hole_punching){
                show_debug_message("hole punch rejected for selected host");
                system_message_set("hole punch was rejected");
                udp_client_hole_punch_fail_reset();
            }
        break;
        
        // player being disconnected for idling for too long
        case rdvz_msg.rdvz_idle_disconnect:
            if(rendevouz_state == rdvz_states.rdvz_idle){
                system_message_set("disconnecting for being idle");
                show_debug_message("disconnected for being idle");
                rdvz_disconnect();
            }
        break;
        
        
        // Client Receieved KA Packet from Rendevouz Server
        case rdvz_msg.rdvz_tcp_keep_alive_acknowledge:
        
            // Do Nothing    
        
        break;
        
        default:
            // Do Nothing
        break;
    }
}


    // -- // Handle all UDP messages from UDP sessions // -- //
if(_is_udp){


    
    
    // - // Actions for all UDP packets // -- //
    
    // Receipt of any non broadcast packet indicates connection still alive
    // (any packet is a keep alive packet)
    // Likewise, receipt of any non broadcast packet indicates successful
    // setup (any packet is a hole punch packet)
    // Last, bail out if sender isn't recognized
    
    if(_socket != broadcast_socket){
        if(udp_is_host()){
        
            if(ds_map_exists(udp_client_maps,_sender_udp_id)){
				
				udp_host_reset_client_timeout(_sender_udp_id);
				
            } else {
				
                var _joining = udp_host_accept_client(_ip, _port);
				
                if(!_joining){ 
                    show_debug_message("host unrecognized sender");
                    exit; // unrecognized sender
                }
            }
            
        } else {
        
            if(rendevouz_state == rdvz_states.rdvz_join_hole_punching){
                if(_ip == udp_host_to_join_ip && _port == udp_host_to_join_port)
                    udp_client_accept_host(_ip, _port);
            }
            
            if(udp_is_client()){
            
                if(_ip == udp_host_ip && _port == udp_client_host_port){
                
                    udp_client_reset_timeout();
                    
                } else {
                
                    // check peer to peer exceptions
                    if(_msg_id != udp_msg.udp_peer_call
                    && _msg_id != udp_msg.udp_peer_response
                    && _msg_id != udp_msg.udp_migrate_lost_host
                    && _msg_id != udp_msg.udp_migrate_new_host){
                    
                        show_debug_message("client unrecognized sender");
                        exit;
                    }
                } 
            }
        }
    }
    
    // -- // Actions for Specific UDP packets // -- //

    switch(_msg_id){
    
        // Prospective Player Received LAN Host Broadcast
        case udp_msg.udp_host_lan_broadcast:
            if(rendevouz_state != rdvz_states.rdvz_none && _udp_has_payload){
                // don't care about sqn or reliable since no established cnxn
                
                // record broadcast info into data structure of local network hosts
                var _rdvz_id        = buffer_read(_buffer, buffer_u16);
                var _host_port      = buffer_read(_buffer, buffer_u16);
                var _clients        = buffer_read(_buffer, buffer_u8);
                var _max_clients    = buffer_read(_buffer, buffer_u8);
                var _in_progress    = buffer_read(_buffer, buffer_bool);
                var _map;
                
                //show_debug_message("host broadcast from "+string(_rdvz_id)+" ip "+string(_ip)+" rcvd port "+string(_port)+" msg port "+string(_host_port));
            
                if(!ds_map_exists(lan_maps, _rdvz_id)){
                    define_network_peer(lan_list, lan_maps,
                        _rdvz_id, _ip, true, _port, 
                        _clients, _max_clients, -1, _in_progress);
                }
                
                _map = lan_maps[? _rdvz_id];
                
                if(!ds_exists(_map, ds_type_map)){
                    var _note = "in received host broadcast";
                    _note = "lan map does not exists for id "+string(_rdvz_id)+"#";
                    _note += "lan maps: #";
                    var _idx, _map;
                    for(_idx=0;_idx<ds_list_size(lan_list);++_idx){
                        _map = lan_maps[? lan_list[| _idx]];
                        _note += "id "+string(lan_list[| _idx])
                            +" map "+string(_map)+" ip "+string(_map[? "ip"])
                            +" is host "+string(_map[? "udp_is_host"])
                            +" hport "+string(_map[? "udp_host_port"]);
                    }
                    show_message_async(_note);
                }
                
                _map[? "ip"] = _ip;
                _map[? "udp_is_host"] = true;
                _map[? "udp_host_port"] = _host_port;
                _map[? "udp_host_clients"] = _clients;
                _map[? "udp_host_max_clients"] = _max_clients;
                _map[? "udp_host_in_progress"] = _in_progress;
                
                //show_debug_message("_map: "+string(_map)+" lan_maps: "+string(lan_maps));
                
                lan_sync_locals();
            }
        break;
        
        // Prospective Player Received LAN Idle Broadcast
        case udp_msg.udp_idle_lan_broadcast:
            if(rendevouz_state != rdvz_states.rdvz_none && _udp_has_payload){
                // record broadcast info into data structure of lan members
                
                var _rdvz_id        = buffer_read(_buffer, buffer_u16);
                var _client_port    = buffer_read(_buffer, buffer_u16);
                var _map;
                
                //show_debug_message("received a peer broadcast from id: "+string(_rdvz_id));
            
                if(!ds_map_exists(lan_maps, _rdvz_id)){
                    define_network_peer(lan_list, lan_maps,
                        _rdvz_id, _ip, false, -1, 0, 0, -1, false);
                }
                
                _map = lan_maps[? _rdvz_id];
                //show_debug_message("_map: "+string(_map)+" lan_maps: "+string(lan_maps));
                
                if(!ds_exists(_map, ds_type_map)){
                    var _note = "in received idle broadcast";
                    _note += "lan map does not exists for id "+string(_rdvz_id)+"#";
                    _note += "lan maps: #";
                    var _idx, _map;
                    for(_idx=0;_idx<ds_list_size(lan_list);++_idx){
                        _map = lan_maps[? lan_list[| _idx]];
                        _note += "id "+string(lan_list[| _idx])
                            +" map "+string(_map)+" ip "+string(_map[? "ip"])
                            +" is host "+string(_map[? "udp_is_host"])
                            +" cport "+string(_map[? "udp_client_port"]);
                    }
                    show_message_async(_note);
                }                
                
                _map[? "ip"] = _ip;
                _map[? "udp_client_port"] = _client_port;
                _map[? "udp_is_host"] = false;
                _map[? "udp_host_clients"] = 0;
                _map[? "udp_host_max_clients"] = 0;
                _map[? "udp_host_in_progress"] = false;
                
                lan_sync_locals();
            }
        break;
        
        case udp_msg.udp_migration_meta_host:
        case udp_msg.udp_migration_meta_client:
        
            if((udp_is_host() || udp_is_client()) && _udp_has_payload){
            
                var _session_id         = buffer_read(_buffer,buffer_string);
                var _broadcaster_id     = buffer_read(_buffer,buffer_s32);
                var _broadcaster_host   = buffer_read(_buffer,buffer_bool);
                var _local_port         = buffer_read(_buffer,buffer_u16);
                
                if(_session_id == udp_session_id){
                
                    var _map;
                    
                    if(udp_is_client()){
                    
                        if(_broadcaster_host){
                        
                            // clients will already have correct ip and host port
                            // for session host - only client port info is needed              
                        
                            if(_msg_id == udp_msg.udp_migration_meta_client){
                                udp_client_host_client_port = _local_port;
                                show_debug_message("rcvd udpm client bc from host local port "+string(_local_port));
                            }                            
                            
                        } else if(ds_map_exists(udp_client_maps, _broadcaster_id)) {
                        
                            // clients require all port and ip info of other clients
                            
                            _map = udp_client_maps[? _broadcaster_id];
                            
                            _map[? "ip"] = _ip;
                            
                            if(_msg_id == udp_msg.udp_migration_meta_client){
                                _map[? "client_port"] = _local_port;
                                show_debug_message("rcvd udpm client bc from "
                                    +string(_broadcaster_id)+" local port "
                                    +string(_local_port));
                            } else if(_msg_id == udp_msg.udp_migration_meta_host){
                                _map[? "host_port"] = _local_port;
                                show_debug_message("rcvd udpm host bc from "
                                    +string(_broadcaster_id)+" local port "
                                    +string(_local_port));
                            }
                            
                        }
                    
                    } else if (udp_is_host() && ds_map_exists(udp_client_maps, _broadcaster_id)){
                    
                        // host will already have correct ips and client ports
                        // for session clients - only host port info required
                    
                        _map = udp_client_maps[? _broadcaster_id];
                        
                        if(_msg_id == udp_msg.udp_migration_meta_host){
                            _map[? "host_port"] = _local_port;
                            show_debug_message("rcvd udpm host bc from "+string(_broadcaster_id)
                                +" local port "+string(_local_port));
                        }
                    }
                }
            }
        
        break;
    
        // Client or Host Received Hole Punch Packet
        case udp_msg.udp_hole_punch:
            if(rendevouz_state == rdvz_states.rdvz_join_hole_punching){
                show_debug_message("received hole punch packet from host");
                system_message_set("received hole punch packet from host");
                udp_client_accept_host(_ip, _port);
            }
            
            if(rendevouz_state == rdvz_states.rdvz_host){
                show_debug_message("received hole punch packet from client");
                system_message_set("received hole punch packet from client");
                udp_host_accept_client(_ip, _port);
            }
        break;
    
        
        // Client or Host Received Keep Alive Packet (Deprecated)
        case udp_msg.udp_keep_alive:
            
            // Do Nothing
        
        break;
    
        
        // Client Being kicked or Host Receiving Notice of Client Leaving
        case udp_msg.udp_disconnect_instruction:
        
            // in lobby
            if(udp_state == udp_states.udp_host_lobby){
                
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                    udp_host_disconnect_client(_sender_udp_id);
                }
            }
            
            if(udp_state == udp_states.udp_client_lobby){
                show_debug_message("received disconnect packet");
                system_message_set("host disconnected");
                udp_client_reset(); // udp state change occurs within
        
                if(rendevouz_state == rdvz_states.rdvz_none)
                    rdvz_client_setup_reconnect();
            }
            
            // in game
            if(udp_state == udp_states.udp_host_game_init
            || udp_state == udp_states.udp_host_game){
            
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                
                    udp_host_disconnect_client(_sender_udp_id);
                    
                    if(rendevouz_state == rdvz_states.rdvz_none
                    && udp_host_allow_join_in_progress){
                        rdvz_connect();
                    }
                }
            }
            
            if(udp_state == udp_states.udp_client_game_init
            || udp_state == udp_states.udp_client_game){
                udp_client_reset();
                
                if(rendevouz_state == rdvz_states.rdvz_none)
                    rdvz_client_setup_reconnect();
            }
            
            // post game
            if(udp_state == udp_states.udp_host_game_ending
            || udp_state == udp_states.udp_host_game_post){
            
                if(ds_map_exists(udp_client_maps,_sender_udp_id))
                    udp_host_disconnect_client(_sender_udp_id);

            }
            
            if(udp_state == udp_states.udp_client_game_ending
            || udp_state == udp_states.udp_client_game_post){
                udp_client_reset();
                
                if(rendevouz_state == rdvz_states.rdvz_none)
                    rdvz_client_setup_reconnect();
            }
            
        break;
        
        
        // Client Received Ping Request from Host
        case udp_msg.udp_ping_request:
            if(udp_is_client()){
                if(_valid_sqn){
                    var _time = buffer_read(_buffer,buffer_u32);
                    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
                    buffer_write(message_buffer,buffer_u32, _time);
                    udp_client_send(udp_msg.udp_ping_acknowledge,false,_buffer,-1);
                }
            }
        
        break;
        
        
        // Received Ping Callback from Client
        case udp_msg.udp_ping_acknowledge:
            if(udp_is_host() && _udp_has_payload){
                
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                    var _timeA = buffer_read(_buffer,buffer_u32);
                    var _timeB = milliseconds_u32;
                    var _ping  = _timeB - _timeA;
                    if(_ping >= 0){
                        var _map = udp_client_maps[? _sender_udp_id];
                        _map[? "ping"] = _ping;
                    }
                }
            
            }
        break;
        
        
        // Receieved Client ID from UDP Host
        case udp_msg.udp_tell_client_id:
            if(udp_state == udp_states.udp_client_lobby
            || udp_state == udp_states.udp_client_game_init
            || udp_state == udp_states.udp_client_game){
                
                if(!_udpr_received && _udp_has_payload)
                    udp_id = buffer_read(_buffer,buffer_u16);
            }
        break;
        
        
        // Received Acknowledgement of a Reliable Packet
        case udp_msg.udp_reliable_acknowledge:
		
			if((udp_is_host() || udp_is_client()) && _udp_has_payload){
			
				var _ack_id		= buffer_read(_buffer,buffer_u16);
				var _udplrg_id	= buffer_read(_buffer,buffer_u16);
				var _udplrg_idx = buffer_read(_buffer,buffer_u16);
				
				if(udp_is_client())
					udp_client_reliable_acknowledged(_ack_id,_udplrg_id,_udplrg_idx);
				else if(udp_is_host() && _sender_udp_id_non_neg)
					udp_host_reliable_acknowledged(_sender_udp_id,_ack_id,_udplrg_id,_udplrg_idx);
			}
		
        break;
        
        
        // Received Refreshed Lobby State
        case udp_msg.udp_refresh_lobby:
            if(udp_state == udp_states.udp_client_lobby){
                  
				/*if(!_udpr_received && _valid_sqn){
					if(!_udp_has_payload)
						show_message_async("no payload in lobby refresh, buffer size "
							+string(buffer_get_size(_buffer))+" buffer tell "
							+string(buffer_tell(_buffer))
						);
				}*/
				  
                if(!_udpr_received && _valid_sqn && _udp_has_payload){
                
					show_debug_message("refresh -- buffer size "
						+string(buffer_get_size(_buffer))
						+" buffer tell "+string(buffer_tell(_buffer))
					);
				
                    udp_session_id              = buffer_read(_buffer,buffer_string);
                    udp_max_clients             = buffer_read(_buffer,buffer_u8);
                    show_debug_message("received session id "+string(udp_session_id));
                    // get host information
                    udp_host_id                 = buffer_read(_buffer,buffer_s32);
                    udp_host_map[? "username"]  = buffer_read(_buffer,buffer_string);
                
                    // get client information
                
                    var _num_clients = buffer_read(_buffer,buffer_u8);
                    var _id, _ping, _ready, _name, _map;
                    
                    var _idx;
                    for(_idx=0;_idx<_num_clients;_idx++){
                    
                        _id     = buffer_read(_buffer,buffer_s32);
                        _ping   = buffer_read(_buffer,buffer_u16);
                        _ready  = buffer_read(_buffer,buffer_bool);
                        _name   = buffer_read(_buffer,buffer_string);
                        
						show_debug_message("refresh id "+string(_id)
							+" ping "+string(_ping)
							+" ready "+string(_ready)
							+" name "+string(_name)
						);
						
                        if(!ds_map_exists(udp_client_maps,_id)){
                            udp_client_define_client(_id,_ping,_ready,_name);
                        } else {
                            //show_debug_message("refresh lobby id "+string(_id));
                            _map = udp_client_maps[? _id];
                            if(!ds_exists(_map,ds_type_map))
                                show_message_async("no map for client "+string(_id)+" key exists? "+string(ds_map_exists(udp_client_maps,_id)));
                            _map[? "ping"]      = _ping;
                            _map[? "ready"]     = _ready;
                            _map[? "username"]  = _name;
                        }
                        
                        // get this client's ping out of the list
                        if(_id == udp_id)
                            udp_ping = _ping;
                    
                    }
                }
            }
        break;
        
        
        // Received a Chat String
        case udp_msg.udp_chat:
            if(udp_is_host()){
                
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                    if(!_udpr_received && _udp_has_payload){
                        var _chat = buffer_read(_buffer,buffer_string);
                        // pass along to other clients, need to include id of original sender
                        buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
                        buffer_write(message_buffer,buffer_s32,_sender_udp_id);
                        buffer_write(message_buffer,buffer_string,_chat);
                        udp_host_send_all(udp_msg.udp_chat,true,message_buffer);
                        udp_add_chat(_sender_udp_id,_chat);
                    }
                }
            }
            
            if(udp_is_client() && _udp_has_payload){
                
                var _chat_sender_udp_id = buffer_read(_buffer,buffer_s32);
                var _chat = buffer_read(_buffer,buffer_string);
                if(!_udpr_received){
                    udp_add_chat(_chat_sender_udp_id,_chat);
                }
            }
        break;
        
        // Received Username
        case udp_msg.udp_username:
        
			if(_udp_has_payload){

	            if(udp_state == udp_states.udp_host_lobby){
	                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
	                    if(!_udpr_received){
	                        var _name = buffer_read(_buffer,buffer_string);
	                        var _map  = udp_client_maps[? _sender_udp_id];
	                        _map[? "username"] = _name;
								show_debug_message("host received name "+string(_name)+" from client "+string(_sender_udp_id));
	                        udp_host_refresh_lobby();
	                    }
	                }
	            }
            
	            if(udp_state == udp_states.udp_host_game){
	                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
	                    if(!_udpr_received){
	                        var _name = buffer_read(_buffer,buffer_string);
	                        var _map  = udp_client_maps[? _sender_udp_id];
	                        _map[? "username"] = _name;
								show_debug_message("host received name "+string(_name)+" from client "+string(_sender_udp_id));
	                        buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
	                        buffer_write(message_buffer,buffer_s32,_sender_udp_id);
	                        buffer_write(message_buffer,buffer_string,_name);
	                        udp_host_send_all(udp_msg.udp_username,true,message_buffer);  
	                    }
	                }
	            }
            
	            if(udp_state == udp_states.udp_client_game){
	                var _client = buffer_read(_buffer,buffer_s32);
	                var _name   = buffer_read(_buffer,buffer_string);
						show_debug_message("client received name "+string(_name)+" from host for client "+string(_client));
	                var _map = udp_client_maps[? _client];
	                if(!is_undefined(_map))
	                    _map[? "username"] = _name;
	            }
			}
            
        break;
        
        // received peer connection info
        case udp_msg.udp_connection_params:
        
            if(udp_is_host() && !_udpr_received && _valid_sqn && _udp_has_payload){
                
                var _public_ip          = buffer_read(_buffer,buffer_string);
                var _public_host_port   = buffer_read(_buffer,buffer_s32);
                var _public_client_port = buffer_read(_buffer,buffer_s32);
                
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                
                    var _map = udp_client_maps[? _sender_udp_id];
                    
                    _map[? "public_ip"]             = _public_ip;
                    _map[? "public_host_port"]      = _public_host_port;
                    _map[? "public_client_port"]    = _public_client_port;
                    
                    if(_map[? "host_port"] < 0)
                        _map[? "host_port"] = _map[? "public_host_port"];
                    
                    show_debug_message("udp host received connection params "
                        +"from client "+string(_sender_udp_id)+" ip "+string(_public_ip)
                        +" host port "+string(_public_host_port)+" client port "
                        +string(_public_client_port));
                    
                    udp_host_share_connection_params();
                }
            }
            
            if(udp_is_client() && !_udpr_received && _valid_sqn && _udp_has_payload){
            
                var _num_entries = buffer_read(_buffer,buffer_u8);
                var _udp_id, _map;
                var _public_ip, _public_host_port, _public_client_port;
                var _idx;
                
                for(_idx=0;_idx<_num_entries;++_idx){
                
                    _udp_id                 = buffer_read(_buffer,buffer_s32);
                    _public_ip              = buffer_read(_buffer,buffer_string);
                    _public_host_port       = buffer_read(_buffer,buffer_s32);
                    _public_client_port     = buffer_read(_buffer,buffer_s32);
                    
                    // first entry is udp host data
                    
                    if(_idx == 0){
                    
                        // client will already have correct host ip and
                        // correct port for host's host socket
                    
                        udp_client_host_client_port = _public_client_port;
                        
                        show_debug_message("udp client received connection params for "
                            +" (host) "+string(udp_host_id)+" ip "+string(_public_ip)
                            +" host port "+string(_public_host_port)+" client port "
                            +string(_public_client_port));
                        
                    } else if(ds_map_exists(udp_client_maps,_udp_id)){
                    
                        // other entries all relate to other clients
                        // screen against default values as these will reappear
                        // after a migration
                        
                        _map = udp_client_maps[? _udp_id];
                        
                        if(_public_ip != "")
                            _map[? "ip"]            = _public_ip;
                        if(_public_host_port > 0)
                            _map[? "host_port"]     = _public_host_port;
                        if(_public_client_port > 0)
                            _map[? "client_port"]   = _public_client_port;
                        
                        show_debug_message("udp client received connection params for "
                            +" client "+string(_udp_id)+" ip "+string(_public_ip)
                            +" host port "+string(_public_host_port)+" client port "
                            +string(_public_client_port));
                    }
                }
            }
        
        break;
        
        // received peer connection call for call & response
        case udp_msg.udp_peer_call:
        
            if((udp_is_host() || udp_is_client()) && _udp_has_payload){
            
                var _sender     = buffer_read(_buffer, buffer_s32);
                var _time_stamp = buffer_read(_buffer, buffer_u32);
                
                var _socket_name = "";
                
                if(_socket == udp_client_socket)
                    _socket_name = "client socket";
                else if (_socket == udp_host_socket)
                    _socket_name = "host socket";
                
                show_debug_message("received peer call on "+string(_socket_name)
                    +" from "+string(_sender)+" with stamp "+string(_time_stamp));
                
                buffer_seek(message_buffer, buffer_seek_start,udp_header_size);
                buffer_write(message_buffer,buffer_s32,udp_id);
                buffer_write(message_buffer,buffer_u32,_time_stamp);
                
                if(udp_is_host() && _socket == udp_client_socket){
                
                    udp_host_write_header(
                        message_buffer,
                        udp_non_client_id,
                        udp_msg.udp_peer_response,
                        false,
						0, 1, 1,
						buffer_tell(message_buffer)
                    );
                
                } else if (udp_is_client()){
                
                    udp_client_write_header(
                        message_buffer,
                        udp_msg.udp_peer_response,
                        false,
						0, 1, 1,
						buffer_tell(message_buffer)
                    );
                }
                
                var _map;
                var _ip         = "";
                var _peer_port  = -1;
                
                if(ds_map_exists(udp_client_maps, _sender)){
                
                    _map    = udp_client_maps[? _sender];
                    
                    if(ds_exists(_map, ds_type_map)){
                    
                        _ip     = _map[? "ip"];
                        
                        if(_socket == udp_host_socket)
                            _peer_port = _map[? "client_port"];
                        else if (_socket == udp_client_socket)
                            _peer_port = _map[? "host_port"];
                    }
                        
                } else if (udp_is_client() && _sender == udp_host_id){
                
                    _ip         = udp_host_ip;
                    _peer_port  = udp_client_host_client_port;
                }
                
                if(_ip != "" && _peer_port > 0)
                    udp_send_packet(_socket, _ip, _peer_port, message_buffer);
            }
        
        break;
        
        // received peer connection response for call & response
        case udp_msg.udp_peer_response:
        
            if((udp_is_host() || udp_is_client()) && _udp_has_payload){
            
                var _sender     = buffer_read(_buffer,buffer_s32);
                var _time_stamp = buffer_read(_buffer,buffer_u32);
                
                var _socket_name = "";
                
                if(_socket == udp_client_socket)
                    _socket_name = "client socket";
                else if (_socket == udp_host_socket)
                    _socket_name = "host socket";
                
                show_debug_message("received peer response on "+string(_socket_name)
                    +" from "+string(_sender)+" with time stamp "+string(_time_stamp));
                
                if(ds_map_exists(udp_client_maps, _sender)){
                
                    var _map    = udp_client_maps[? _sender];
                    
                    if(ds_exists(_map,ds_type_map)){
                    
                        if(_time_stamp == _map[? "call_response_stamp"]){
                            _map[? "call_response_ping"] = milliseconds_u32 -_time_stamp;
                            _map[? "connected"]          = true;
                            _map[? "timeout"]            = udp_connection_timeout;
                            show_debug_message("Client "+string(udp_id)+" is connected to "
                                +string(_sender));
                        }
                    }
                                    
                } else if (udp_is_client() && _sender == udp_host_id){
                
                    if(_time_stamp == udp_client_host_call_response_stamp)
                        udp_client_host_call_response_ping = milliseconds_u32 -_time_stamp;
                }
            }
        
        break;
        
        // backup host receiving notice that peer dropped host connection
        case udp_msg.udp_migrate_lost_host:
        
			if(_udp_has_payload){
		
	            var _peer_id = buffer_read(_buffer,buffer_s32);
        
	            if(udp_is_client() 
	            && udp_client_is_next_host()){
                
	                if(!ds_map_exists(udp_client_maps,_peer_id)) exit;
                    
	                var _map = udp_client_maps[? _peer_id];
                                            
	                if(migrate_state == migrate_states.client_to_host_verifying){
                
	                    show_debug_message("Received dropped host notice from: "+string(_peer_id));
                
	                    _map[? "dropped_host"] = true;
                  
	                    udp_client_check_takeover();
	                }
	            }
            
	            if(udp_is_host()){
            
	                buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
	                buffer_write(message_buffer,buffer_s32,udp_id);
	                buffer_write(message_buffer,buffer_string,udp_session_id);
	                udp_host_send(_peer_id,udp_msg.udp_migrate_new_host,false,message_buffer,-1);
	            }
			}
        
        break;
        
        // client receiving notice that a session peer is taking over as host
        case udp_msg.udp_migrate_new_host:
        
            if((udp_is_host() || udp_is_client()) && _udp_has_payload){
            
                var _new_host_id    = buffer_read(_buffer,buffer_s32);
                var _new_session_id = buffer_read(_buffer,buffer_string);
                
                if(udp_is_client()){
                    udp_client_new_host(_new_host_id, _new_session_id);
                } else if (udp_is_host()){
                    udp_host_become_client(_new_host_id, _new_session_id);
                }
            
            }
        
        break;
        
        // Received request for peer connection stats
        case udp_msg.udp_migration_stats_request:
            if(udp_is_client()){
                if(!_udpr_received && _valid_sqn)
                    udp_client_share_migration_stats();
            }
        break;
        
        // Host received peer connection stats from client
        case udp_msg.udp_migration_stats_info:
            if(udp_is_host()){
            
                if(!_udpr_received && _valid_sqn && _udp_has_payload){
            
                    var _connected  = buffer_read(_buffer,buffer_bool);
                    var _avg_ping   = buffer_read(_buffer,buffer_u16);
                    
                    if(ds_map_exists(udp_client_maps, _sender_udp_id)){
                    
                        var _map = udp_client_maps[? _sender_udp_id];
                        
                        _map[? "peer_connected"]    = _connected;
                        _map[? "peer_avg_ping"]     = _avg_ping;
                        
                        show_debug_message("client "+string(_sender_udp_id)
                            +" sent peer connect state "+string(_connected)
                            +" average ping "+string(_avg_ping));
                        
                        // (re)set timer to distibute refreshed migration order
                        
                        udp_host_migration_order_timer = udp_host_migration_order_delay;
                    }
                }
            }
        break;
        
        // Client receiving migration order from host
        case udp_msg.udp_migration_order:
            if(udp_is_client()){
                if(!_udpr_received && _valid_sqn && _udp_has_payload){
                
                    var _idx, _client, _map, _migration_order;
                
                    // wipe previous migration orders
                    
                    for(_idx=0;_idx<ds_list_size(udp_client_list);++_idx){
                    
                        _client = udp_client_list[| _idx];
                        _map    = udp_client_maps[? _client];
                        
                        _map[? "migration_order"] = -1;
                    }
                    
                    // install new migration orders
                    
                    var _num_entries = buffer_read(_buffer,buffer_u8);
                    
                    for(_idx=0;_idx<_num_entries;++_idx){
                    
                        _client             = buffer_read(_buffer,buffer_s32);
                        _migration_order    = buffer_read(_buffer,buffer_s16);
                        
                        if(ds_map_exists(udp_client_maps, _client)){
                        
                            _map = udp_client_maps[? _client];
                            _map[? "migration_order"] = _migration_order;
                            
                            show_debug_message("### Client "+string(_client)
                                +" Migration Order "+string(_migration_order)
                                +" ###");
                        }
                    }
                }
            }
        break;
        
        // Received client ready or unready
        case udp_msg.udp_ready:
            if(udp_state == udp_states.udp_host_lobby){
                if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                    if(!_udpr_received && _valid_sqn && _udp_has_payload){
                        var _ready  = buffer_read(_buffer,buffer_bool);
                        var _map    = udp_client_maps[? _sender_udp_id];
                        _map[? "ready"] = _ready;
                        udp_host_refresh_lobby();
                    }
                }
            }
        break;
        
        // Received unready all notice from host
        case udp_msg.udp_host_unready_all:
            if(!_udpr_received && _valid_sqn && _udp_has_payload){
                if(udp_state == udp_states.udp_client_lobby){
                
                    var _idx, _client, _map;
                    var _num_clients = ds_list_size(udp_client_list);
                    
                    for(_idx=0;_idx<_num_clients;++_idx){
                    
                        _client = udp_client_list[| _idx];
                        _map    = udp_client_maps[? _client];
                        
                        _map[? "ready"] = false;
                    }
                }
            }
        break;
        
        // Received game init message
        case udp_msg.udp_game_init:
            if(!_udpr_received && _valid_sqn && _udp_has_payload){
                if(udp_state == udp_states.udp_client_lobby){
                    udp_client_begin_game_init();
                }
            }
        break;
        
        // client is finished initalizing
        case udp_msg.udp_game_init_complete:
            if(!_udpr_received && _valid_sqn && _udp_has_payload){
            
                // new client joining game in progress
                if(udp_state == udp_states.udp_host_game){
                    if(ds_map_exists(udp_client_maps,_sender_udp_id)){
                    
                        var _name   = buffer_read(_buffer,buffer_string);
                        var _map    = udp_client_maps[? _sender_udp_id];
                        _map[? "username"] = _name;
                        
                        udp_host_distribute_new_client(_sender_udp_id);
                        udp_host_send(_sender_udp_id,udp_msg.udp_game_start,true,message_buffer,-1);
                    }
                }
            
                // all players initializing simultaneously
                if(udp_state == udp_states.udp_host_game_init){
                    udp_host_manage_client_game_inits(_sender_udp_id);
                }
            }
        break;
        
        // Client receiving notice to start game
        case udp_msg.udp_game_start:
            if(!_udpr_received && _valid_sqn && _udp_has_payload){
                if(udp_state == udp_states.udp_client_game_init){
                    udp_client_game_start();
                }
            }
        break;
        
        // Client receiving notice of departure of other client
        case udp_msg.udp_client_left:
            if(!_udpr_received && _valid_sqn && _udp_has_payload){
                if(udp_is_client()){
                    var _client = buffer_read(_buffer,buffer_s32);
                    udp_client_remove_client(_client);
                }
            }
        break;
        
        // Client joining in progress receiving game state
        case udp_msg.udp_game_bring_to_speed:
            if(udp_state == udp_states.udp_client_lobby){
                if(!_udpr_received && _valid_sqn && _udp_has_payload){
                
                    udp_session_id              = buffer_read(_buffer,buffer_string);
                    udp_max_clients             = buffer_read(_buffer,buffer_u8);
                    show_debug_message("received session id "+string(udp_session_id));
                    // get host information
                    udp_host_id                 = buffer_read(_buffer,buffer_s32);
                    udp_host_map[? "username"]  = buffer_read(_buffer,buffer_string);
                
                    // get client information
                    udp_client_wipe_clients();
                    
                    var _this_id = buffer_read(_buffer,buffer_s32);
                    
                    if(udp_id < 0)
                        udp_id = _this_id;
                
                    var _num_clients = buffer_read(_buffer,buffer_u8);
                    var _id, _ping, _name;
                    
                    var _idx;
                    for(_idx=0;_idx<_num_clients;_idx++){
                    
                        _id     = buffer_read(_buffer,buffer_s32);
                        _ping   = buffer_read(_buffer,buffer_u16);
                        _name   = buffer_read(_buffer,buffer_string);
                        
                        if(_id == udp_id) _name = network_username;
                        
                        udp_client_define_client(_id,_ping,false,_name);
                    
                    }
                    
                    // start init phase
                    udp_client_begin_game_init();
                }
            }
        break;
        
        // Existing client being told about a new in game arrival
        case udp_msg.udp_game_client_joined:
            if(udp_state == udp_states.udp_client_game){
                if(!_udpr_received && _valid_sqn && _udp_has_payload){
                    
                    var _id, _ping, _name;
                    
                    _id     = buffer_read(_buffer, buffer_s32);
                    _ping   = buffer_read(_buffer, buffer_u16);
                    _name   = buffer_read(_buffer, buffer_string);
                
                    udp_client_define_client(_id,_ping,false,_name);
                    
                    // Implementation dependent other stuff below?
                }
            }
        break;
        
        // Game is over one way or another
        case udp_msg.udp_game_end:
            if(udp_state == udp_states.udp_client_game){
                if(!_udpr_received && _valid_sqn){
                    udp_state = udp_states.udp_client_game_ending;
                }
            }
        break;
        
        // Return to lobby from post game
        case udp_msg.udp_return_to_lobby:
            if(udp_state == udp_states.udp_client_game_post){
                if(!_udpr_received && _valid_sqn){
                    udp_state = udp_states.udp_client_lobby;
                }
            }
        break;
        
        // Client receiving update about other players' metadata
        case udp_msg.udp_player_metadata:
            if(udp_state == udp_states.udp_client_game_init
            || udp_state == udp_states.udp_client_game
            || udp_state == udp_states.udp_client_game_ending
            || udp_state == udp_states.udp_client_game_post){
            
                if(_valid_sqn && _udp_has_payload){
                
                    var _num_clients = buffer_read(_buffer,buffer_u8);
                    var _idx, _client, _map, _ping;
                    
                    for(_idx=0;_idx<_num_clients;_idx++){
                    
                        _client = buffer_read(_buffer,buffer_s32);
                        
                        if(ds_map_exists(udp_client_maps,_client)){
                            _map    = udp_client_maps[? _client];
                            _ping   = buffer_read(_buffer,buffer_u32);
                            _map[? "ping"] = _ping;
                        } else {
                            continue;
                        }
                    }
                }
            }
        break;
		
		case udp_msg.udp_dummy_message:
			// Do Nothing
		break;
        
        default:
            // Do Nothing
        break;
    }
	
	// clean up memory allocated to large udp message receipt //
	
	if(_lrgpkt_rcvd){
		
		if(udp_is_host())
			udp_host_lrgpkt_clean(_sender_udp_id,true);
		else if (udp_is_client())
			udp_client_lrgpkt_clean(true);
	}
}
