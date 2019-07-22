/// @description  udp_host_cancel_session()

// drops all udp clients, tells rdvz server, and goes back to rendevouz
// idle state


if(rendevouz_state == rdvz_states.rdvz_host_init
|| rendevouz_state == rdvz_states.rdvz_host_pinging_udp
|| rendevouz_state == rdvz_states.rdvz_host){
   
    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
    
    if(rendevouz_state == rdvz_states.rdvz_host)
        rdvz_client_send(false,rdvz_msg.rdvz_udp_host_cancel,message_buffer);

    rendevouz_state = rdvz_states.rdvz_idle;
    
    // reset all host variables and structures
    udp_host_reset(); 

} else if(rendevouz_state == rdvz_states.rdvz_none){
    if(udp_state == udp_states.udp_host_lobby
    || udp_state == udp_states.udp_host_game_init
    || udp_state == udp_states.udp_host_game
    || udp_state == udp_states.udp_host_game_ending
    || udp_state == udp_states.udp_host_game_post){
    
        udp_host_reset();
        rdvz_client_setup_reconnect();
    
    }
}
