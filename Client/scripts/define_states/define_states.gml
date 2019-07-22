/// @description  define_states()

// declare different states for state machines

// rendevouz server
enum rdvz_states {

    rdvz_none,
    rdvz_idle,
    rdvz_reconnect,
    rdvz_host_init,
    rdvz_host_pinging_udp,
    rdvz_host,
    rdvz_join_init,
    rdvz_join_pinging_udp,
    rdvz_join_awaiting_hole_punch,
    rdvz_join_hole_punching
}

// udp session
enum udp_states {

    udp_none,
    udp_host_lobby,
    udp_client_lobby,
    udp_host_game_init,
    udp_client_game_init,
    udp_host_game,
    udp_client_game,
    udp_host_game_ending,
    udp_client_game_ending,
    udp_host_game_post,
    udp_client_game_post
}

// input states
enum input_states {

    input_none,
    input_set_rdvz_ip,
    input_set_rdvz_tcp_port,
    input_set_rdvz_udp_port,
    input_set_username,
    input_host_set_max_clients,
    input_host_kick_client,
    input_client_set_host,
    input_typing_chat
}

enum migrate_states {

    none,
    client_to_host_verifying,
    client_to_client_verifying,
    host_to_client_migrating
}
