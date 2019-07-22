/// @description  rdvz_disconnect

// drop the connection to the rendevouz server
// either backing out of the game or joined a udp session

network_destroy(rdvz_client_socket);
rdvz_client_socket = -1;
rdvz_client_port = -1;
rendevouz_state = rdvz_states.rdvz_none;
rendevouz_id = -1;

rdvz_clear_client_properties();

show_debug_message("disconnecting from rendevouz server");

// debug
debug_received_rdvz_id = false;
