/// @description  udp_host_client_join_in_progress(client_id)

// bring new arrival up to speed and inform other clients of
// new arrival

var _new_client = argument0;

    // bring new client up to speed

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,udp_session_id);
buffer_write(message_buffer,buffer_u8,udp_max_clients);
buffer_write(message_buffer,buffer_s32,udp_id);
buffer_write(message_buffer,buffer_string,udp_host_map[? "username"]);

buffer_write(message_buffer,buffer_s32,_new_client);

var _num_clients = ds_list_size(udp_client_list);
var _idx, _id, _map, _ping, _name;

buffer_write(message_buffer,buffer_u8,_num_clients);

for(_idx=0;_idx<_num_clients;_idx++){

    _id         = udp_client_list[| _idx];
    _map        = udp_client_maps[? _id];
    _ping       = _map[? "ping"];
    _name       = _map[? "username"];
    
    buffer_write(message_buffer,buffer_s32,_id);
    buffer_write(message_buffer,buffer_u16,_ping);
    buffer_write(message_buffer,buffer_string,_name);
}

udp_host_send(_new_client,udp_msg.udp_game_bring_to_speed,true,message_buffer);
