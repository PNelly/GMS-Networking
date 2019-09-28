/// @description  udp_host_pass_ingame_disconnect(client_id)

// pass along to remaining clients that a client has disconnected

var _client = argument0;

if(udp_is_host()){

    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_s32,_client);
    udp_host_send_all(udp_msg.udp_client_left,true,message_buffer,true);
}
