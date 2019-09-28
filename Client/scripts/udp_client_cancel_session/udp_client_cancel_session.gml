/// @description  udp_client_cancel_session()

// backs this client out of joined udp session to the rendevouz server lobby

if(udp_is_client()){

    show_debug_message("client leaving udp session");

    udp_client_send(udp_msg.udp_disconnect_instruction,false,message_buffer,-1,false);
    
    udp_client_reset(); // state change occurs within
    
    if(rendevouz_state == rdvz_states.rdvz_none)
        rdvz_connect();

}
