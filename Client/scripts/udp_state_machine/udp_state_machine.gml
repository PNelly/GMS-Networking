/// @description  udp_state_machine()

// execute stepwise actions according to UDP state

// all host or client udp session states
if(udp_is_host() || udp_is_client()){

    udp_manage_migration_broadcast();
    udp_manage_call_response();
}

// all host states
if(udp_is_host()){

    udp_host_manage_keep_alive();
    udp_host_manage_timeouts();
    udp_host_manage_pings();
    udp_host_manage_sent_reliables();
    udp_host_manage_received_reliables();
    udp_host_manage_migration_stats_request();
    udp_host_manage_migration_order();
	udp_host_lrgpkt_manage_outbound();
}

// all client states
if(udp_is_client()){

    udp_client_manage_keep_alive();
    udp_client_manage_timeout();
    udp_client_manage_peer_timeouts();
    udp_client_manage_sent_reliables();
    udp_client_manage_received_reliables();
    udp_client_manage_migrate_verify();
    udp_client_manage_migrate_timeout();
	udp_client_lrgpkt_manage_outbound();
}

// actions that are state specific

switch(udp_state){
    
    case udp_states.udp_host_lobby:
        udp_host_manage_holepunch();
        udp_host_manage_lobby_refresh();
    break;
    
    case udp_states.udp_host_game_init:
        udp_host_manage_player_metadata();
    break;
    
    case udp_states.udp_host_game:
        udp_host_manage_holepunch();
        udp_host_manage_player_metadata();
    break;
    
    case udp_states.udp_host_game_ending:
        udp_host_manage_game_ending();
        udp_host_manage_player_metadata();
    break;
    
    case udp_states.udp_client_game_ending:
        udp_client_manage_game_ending();
    break;
    
    case udp_states.udp_host_game_post:
        udp_host_manage_player_metadata();
    break;
}
