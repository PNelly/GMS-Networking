/// @description  udp_is_host()

// returns whether this machine is a udp host or not

switch (udp_state){

    case udp_states.udp_host_lobby:
    case udp_states.udp_host_game_init:
    case udp_states.udp_host_game:
    case udp_states.udp_host_game_ending:
    case udp_states.udp_host_game_post:
    
        return true;
    break;
    
    default:
        return false;
}
