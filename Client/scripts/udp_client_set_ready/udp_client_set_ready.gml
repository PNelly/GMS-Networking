/// @description  udp_client_set_ready

// wrapper script to send ready up message to host

show_debug_message("client set ready");

if(udp_state == udp_states.udp_client_lobby){

    var _map = udp_client_maps[? udp_id];
    _map[? "ready"] = !_map[? "ready"];
    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_bool,_map[? "ready"]);
    udp_client_send(udp_msg.udp_ready,true,message_buffer);
}

