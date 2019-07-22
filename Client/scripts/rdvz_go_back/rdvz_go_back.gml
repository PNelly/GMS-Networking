/// @description  rdvz_go_back()

// go to previous area of rendevouz process

if(rendevouz_state == rdvz_states.rdvz_idle){
    rdvz_disconnect();
}

if(rendevouz_state == rdvz_states.rdvz_reconnect){
    rendevouz_state = rdvz_states.rdvz_none;
}

if(rendevouz_state == rdvz_states.rdvz_join_pinging_udp){
    rendevouz_state = rdvz_states.rdvz_idle;
    udp_client_reset();
}
