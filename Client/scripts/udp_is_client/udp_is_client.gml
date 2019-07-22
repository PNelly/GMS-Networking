/// @description  udp_is_client()

// returns whether this machine is a client or not

switch (udp_state){

    case udp_states.udp_client_lobby:
    case udp_states.udp_client_game_init:
    case udp_states.udp_client_game:
    case udp_states.udp_client_game_ending:
    case udp_states.udp_client_game_post:
    
        return true;
    break;

    default:
        return false;
}
