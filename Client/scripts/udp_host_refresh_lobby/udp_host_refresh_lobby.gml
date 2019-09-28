/// @description  udp_host_refresh_lobby

// bring all udp session clients up to speed on lobby state


// write out host information
buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,udp_session_id);
buffer_write(message_buffer,buffer_u8,udp_max_clients);
buffer_write(message_buffer,buffer_s32,udp_id);
buffer_write(message_buffer,buffer_string,udp_host_map[? "username"]);

// write out client information
var _num_clients = ds_list_size(udp_client_list);

var _client_id, _client_map;
var _idx, _ping, _ready, _name;

buffer_write(message_buffer,buffer_u8,_num_clients);

for(_idx=0;_idx<_num_clients;_idx++){ 

    _client_id  = udp_client_list[| _idx];
    _client_map = udp_client_maps[? _client_id];
    _ping       = _client_map[? "ping"];
    _ready      = _client_map[? "ready"];
    _name       = _client_map[? "username"];
    
    buffer_write(message_buffer,buffer_s32, _client_id);
    buffer_write(message_buffer,buffer_u16, _ping)
    buffer_write(message_buffer,buffer_bool,_ready);
    buffer_write(message_buffer,buffer_string,_name);
}

show_debug_message("host refresh lobby - buffer size "+string(buffer_tell(message_buffer)));

udp_host_send_all(udp_msg.udp_refresh_lobby,true,message_buffer,true);

// reset refresh timer
udp_host_lobby_refresh_timer = udp_host_lobby_refresh_interval;


