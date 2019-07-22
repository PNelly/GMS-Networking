/// @description  rdvz_client_setup_reconnect()

// break connection to rdvz server and set reconnction timer
// when bad meta data is received from the server

rdvz_disconnect();
rdvz_reconnect_timer = irandom_range(0, rdvz_reconnect_delay_cap);
rendevouz_state = rdvz_states.rdvz_reconnect;
