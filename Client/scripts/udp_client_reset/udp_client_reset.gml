/// @description  udp_client_reset

// wipe all client udp fields
input_state = input_states.input_none;
udp_state = udp_states.udp_none;
udp_session_id = "";
udp_id = -1;
udp_max_clients = udp_max_clients_default;

udp_public_ip = "";
udp_public_host_port = -1;
udp_public_client_port = -1;

udp_migration_broadcast_timer = -1;
udp_peer_call_timer = -1;
udp_client_host_call_response_stamp = -1;
udp_client_host_call_response_ping = -1;

migrate_state = migrate_states.none;
migrate_timer = -1;

udp_host_id = -1;
udp_host_to_join = -1;
udp_host_to_join_ip = "";
udp_host_to_join_port = -1;
udp_host_ip = "";
udp_client_host_port = -1;
udp_hole_punch_timer = -1;
udp_ping = 100;
udp_clear_chats();

udp_client_cleanup_packets();
udp_client_wipe_clients();
ds_map_clear(udp_host_map);

