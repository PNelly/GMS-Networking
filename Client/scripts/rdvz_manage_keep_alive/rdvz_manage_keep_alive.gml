/// @description  rdvz_manage_keep_alive()

// decrement KA timer and send KA requests to the rdvz server

if(rdvz_keep_alive_timer >= 0)
    rdvz_keep_alive_timer--;

if(rdvz_keep_alive_timer < 0){
    rdvz_keep_alive_timer = rdvz_get_keep_alive_time();
    show_debug_message("rdvz client sent keep alive packet");
    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
    rdvz_client_send(false,rdvz_msg.rdvz_tcp_keep_alive,message_buffer);

}
