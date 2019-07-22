/// @description  udp_host_update_rendevouz

// give rendevouz server up to date information about this udp session

buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
buffer_write(message_buffer,buffer_u8, ds_list_size(udp_client_list) );
buffer_write(message_buffer,buffer_u8, udp_max_clients);
buffer_write(message_buffer,buffer_bool,udp_host_game_in_progress);
rdvz_client_send(false,rdvz_msg.rdvz_udp_host_update_rdvz,message_buffer);

