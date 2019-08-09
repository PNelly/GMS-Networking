/// @description  rdvz_host_manage_udp_ping()

// send udp packets to rdvz server so it can collect port/ip information

// UDP's to rdvz server don't get UDP session header

if(rdvz_udp_ping_timer >= 0)
    rdvz_udp_ping_timer--;

if(rdvz_udp_ping_timer < 0){
    rendevouz_state = rdvz_states.rdvz_idle;
    if(udp_state != udp_states.udp_host_game)
        udp_host_reset();
    if(udp_state == udp_states.udp_host_game)
        rdvz_disconnect();
} else {

    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
	
    buffer_write(message_buffer,buffer_u16,rendevouz_id);

    rdvz_client_send(true, rdvz_msg.rdvz_udp_ping_host_w_host_socket,message_buffer);
    rdvz_client_send(true, rdvz_msg.rdvz_udp_ping_host_w_client_socket,message_buffer);
}
