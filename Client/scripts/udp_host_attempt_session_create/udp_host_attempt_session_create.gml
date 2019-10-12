/// @description  udp_host_attempt_session_create()

// begin negotiating the process of opening up a udp session for other
// players to join

if(rendevouz_id >= 0){

    if(rendevouz_state == rdvz_states.rdvz_idle && !udp_is_client()){
    
        rendevouz_state = rdvz_states.rdvz_host_init;
        show_debug_message("negotiating rdvz session create");
		
		// seek buffer to get correct sizing
		buffer_seek(message_buffer, buffer_seek_start, rdvz_header_size);
		
        rdvz_client_send(false,rdvz_msg.rdvz_new_udp_host,message_buffer);
    }

} else if (rendevouz_id < 0){

    show_debug_message("id dropped or not yet received, re-requesting");
	
	// seek buffer to get correct sizing
	buffer_seek(message_buffer, buffer_seek_start, rdvz_header_size);
	
    rdvz_client_send(false,rdvz_msg.rdvz_request_id,message_buffer);
}
