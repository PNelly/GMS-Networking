/// @description  udp_host_send_all(message_id,use_reliable,buffer)

// send the same packet to all clients

var _msg_id         = argument0;
var _is_reliable    = argument1;
var _buffer         = argument2;

var _num_clients = ds_list_size(udp_client_list);
var _idx, _client;

for(_idx=0;_idx<_num_clients;++_idx){

	_client = udp_client_list[| _idx];
	
	udp_host_send(_client,_msg_id,_is_reliable,_buffer,-1);
}


/*var _client, _map, _port, _ip, _udpr_id, _udpr_offset, _sqn_offset, _sqn;

// use zero just to supply argument, used within script to fetch
// a udpr id, but it will not be fetched with argument false, and
// field will be overwritten below

udp_host_write_header(_buffer,udp_non_client_id,_msg_id,false);

// calculate offsets for udpr id and sequence number
_udpr_offset = udp_header_offset_udpr_id;
_sqn_offset  = udp_header_offset_sqn;

if(!_is_reliable){ // non reliable packet
    _udpr_id = 0;
    buffer_seek(_buffer,buffer_seek_start,_udpr_offset);
    buffer_write(_buffer,buffer_u16,_udpr_id);
    for(_idx=0;_idx<_num_clients;_idx++){
        _client     = udp_client_list[| _idx];
        _map        = udp_client_maps[? _client];
        _ip         = _map[? "ip"];
        _port       = _map[? "client_port"];
        // splice in appropriate sequence number for client
        _sqn        = udp_host_next_seq_num(_client,_msg_id);
        //show_debug_message("host fetched sqn "+string(_sqn)+" clnt "+string(_client)+" mid "+string(_msg_id));
        buffer_poke(_buffer,_sqn_offset,buffer_u32,_sqn);
        udp_send_packet(udp_host_socket,_ip,_port,_buffer);
    }
} else { // reliable packet
    for(_idx=0;_idx<_num_clients;_idx++){
        _client     = udp_client_list[| _idx];
        _map        = udp_client_maps[? _client];
        _ip         = _map[? "ip"];
        _port       = _map[? "client_port"];
        // splice in appropriate sequence number for client
        _sqn        = udp_host_next_seq_num(_client,_msg_id);
        //show_debug_message("host fetched sqn "+string(_sqn)+" clnt "+string(_client)+" mid "+string(_msg_id));
        buffer_poke(_buffer,_sqn_offset,buffer_u32,_sqn);
        // splice in appropriate udpr id for client
        _udpr_id    = udp_host_next_reliable_id(_client);
        buffer_poke(_buffer,_udpr_offset,buffer_u16,_udpr_id);
        udp_host_reliable_record(_client,_udpr_id,_buffer);
        udp_send_packet(udp_host_socket,_ip,_port,_buffer);
    }
}

// reset each client's keep alive packet timer
for(_idx=0;_idx<_num_clients;_idx++){
    _client     = udp_client_list[| _idx];
    _map        = udp_client_maps[? _client];
    _map[? "keep_alive_timer"] = irandom_range(udp_keep_alive_interval,udp_keep_alive_interval*2);
}*/