/// @description  udp_host_init_session()

// setup after successful creation of udp session

show_debug_message("UDP host ping received by server");
show_debug_message("UDP session created");
system_message_set("UDP session created");
rendevouz_state = rdvz_states.rdvz_host;
udp_state = udp_states.udp_host_lobby;

udp_session_id = udp_host_generate_session_id();
    
show_debug_message("created session id "+string(udp_session_id));
    
udp_id = 0;
udp_host_id = udp_id;

udp_host_init_timers();
udp_host_init_self_metadata();

// trigger update to other rendevouz clients
udp_host_update_rendevouz();
