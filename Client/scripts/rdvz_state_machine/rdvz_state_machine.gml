/// @description  rdvz_state_machine

// choose appropriate actions depending on rendevouz state

switch(rendevouz_state){

    case rdvz_states.rdvz_none:
        // Do Nothing
    break;
    
    case rdvz_states.rdvz_reconnect:
        rdvz_client_manage_reconnect();
    break;

    case rdvz_states.rdvz_idle:
        lan_manage_broadcast();
        rdvz_manage_keep_alive();
        rdvz_manage_timeout(); 
    break;
    
    case rdvz_states.rdvz_join_init:
        rdvz_manage_keep_alive();
        rdvz_manage_timeout();
    break;
    
    case rdvz_states.rdvz_join_awaiting_hole_punch:
        rdvz_manage_keep_alive();
        rdvz_manage_timeout();
    break;

    case rdvz_states.rdvz_host_pinging_udp:
        rdvz_host_manage_udp_ping();
        rdvz_manage_keep_alive();
        rdvz_manage_timeout();
    break;
    
    case rdvz_states.rdvz_join_pinging_udp:
        rdvz_client_manage_udp_ping();
        rdvz_manage_keep_alive();
        rdvz_manage_timeout();
    break;
    
    case rdvz_states.rdvz_join_hole_punching:
        rdvz_client_manage_holepunch();
        rdvz_manage_keep_alive();
        rdvz_manage_timeout();
    break;
       
    case rdvz_states.rdvz_host:
        lan_manage_broadcast();
    break;
}
