/// @description  udp_client_share_connection_params()

// give public facing ip & port info to host for distribution

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,udp_public_ip);
buffer_write(message_buffer,buffer_s32,udp_public_host_port);
buffer_write(message_buffer,buffer_s32,udp_public_client_port);

udp_client_send(udp_msg.udp_connection_params,true,message_buffer,-1);
