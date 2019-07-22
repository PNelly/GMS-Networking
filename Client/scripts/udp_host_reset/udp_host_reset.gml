/// @description  udp_host_reset()

// clears all udp host related fields

// disconnect and cleanup packet info for all clients
if(udp_host_exit_kills_session){

    var _client;
    var _map, _idx;
    
    while(!ds_list_empty(udp_client_list)){
        _client = udp_client_list[| 0];
        _map    = udp_client_maps[? _client];
        udp_host_disconnect_client(_client);
        show_debug_message("disconnecting client: "+string(_client));
    }
}

// reset host variables
input_state = input_states.input_none;
udp_state = udp_states.udp_none;
udp_id = -1;
udp_session_id = "";
udp_host_id = -1;

udp_public_ip = "";
udp_public_host_port = -1;
udp_public_client_port = -1;

udp_next_client_id = 1;

udp_host_lobby_refresh_timer    = -1;
udp_migration_broadcast_timer   = -1;
udp_peer_call_timer             = -1;

udp_host_migration_stats_request_timer = -1;

migrate_state = migrate_states.none;
migrate_timer = -1;

udp_max_clients = udp_max_clients_default;
udp_host_game_in_progress = false;
udp_clear_chats();

ds_map_clear(udp_host_map);

// wipe client meta data
ds_list_clear(udp_client_list);
ds_map_clear(udp_client_maps);
