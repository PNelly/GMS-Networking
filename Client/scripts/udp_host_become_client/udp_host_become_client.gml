/// @description  udp_host_become_client()

// migrate this session host to client state

var _new_host       = argument0;
var _new_session_id = argument1;

if(udp_is_host()){

    show_debug_message("-- udp host become client --");
    
    // clear migration state
    migrate_state = migrate_states.none;
    migrate_timer = -1;
    migrate_verify_timer = -1;
    
    // change session id
    udp_session_id = _new_session_id;
    
    // cleanup packets before modifying data structures
    var _idx, _client, _map;
    var _num_clients = ds_list_size(udp_client_list);
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        udp_host_cleanup_client_packets(_client);
    }
    
    
    for(_idx=0;_idx<_num_clients;++_idx){
        
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        
        ds_map_delete(_map,"public_ip");
        ds_map_delete(_map,"public_client_port");
        ds_map_delete(_map,"public_host_port");
        ds_map_delete(_map,"peer_connected");
        ds_map_delete(_map,"peer_avg_ping");
        ds_map_delete(_map,"keep_alive_timer");
        ds_map_delete(_map,"game_init_complete");
        ds_map_delete(_map,"udpr_next_id");
        ds_map_delete(_map,"udpr_sent_list");
        ds_map_delete(_map,"udpr_sent_maps");
        ds_map_delete(_map,"udpr_rcvd_list");
        ds_map_delete(_map,"udpr_rcvd_maps");
        ds_map_delete(_map,"udp_seq_num_sent_map");
        ds_map_delete(_map,"udp_seq_num_rcvd_map");
		ds_map_delete(_map,"udplrg_rcvd_list");
		ds_map_delete(_map,"udplrg_rcvd_map");
		ds_map_delete(_map,"udplrg_outbound_list");
		ds_map_delete(_map,"udplrg_outbound_map");
		ds_map_delete(_map,"udplrg_next_id");
		ds_map_delete(_map,"udp_dlvry_hooks_list");
		ds_map_delete(_map,"udp_dlvry_hooks_map");
    }
        
    // change self to corresponding client state
    switch(udp_state){
        case udp_states.udp_host_lobby:
            udp_state = udp_states.udp_client_lobby;
        break;
        case udp_states.udp_host_game_init:
            udp_state = udp_states.udp_client_game_init;
        break;
        case udp_states.udp_host_game:
            udp_state = udp_states.udp_client_game;
        break;
        case udp_states.udp_host_game_ending:
            udp_state = udp_states.udp_client_game_ending;
        break;
        case udp_states.udp_host_game_post:
            udp_state = udp_states.udp_client_game_post;
        break;
    }
    
    // drop connection to rdvz server
    if(rendevouz_state != rdvz_states.rdvz_none)
        rdvz_disconnect();

    // add self to client data structures
    var _new_host_map   = udp_client_maps[? _new_host];
    
    udp_client_define_client(
        udp_id,
        _new_host_map[? "ping"],
        false,
        network_username
    );
    
    // set client specific keys for self
    var _self_map = udp_client_maps[? udp_id];
    
    _self_map[? "ip"]           = udp_public_ip;
    _self_map[? "host_port"]    = udp_public_host_port;
    _self_map[? "client_port"]  = udp_public_client_port;
    
    // set variables appropriate for new client
    udp_client_init_timers();
    udp_client_cleanup_packets();
    
    udp_host_id                 = _new_host;
    udp_host_ip                 = _new_host_map[? "ip"];
    udp_client_host_port        = _new_host_map[? "host_port"];
    udp_client_host_client_port = _new_host_map[? "client_port"];
    udp_host_map[? "username"]  = _new_host_map[? "username"];
    
    udp_client_host_call_response_stamp = -1;
    udp_client_host_call_response_ping  = -1;
    
    // move new host out of client data structures
    ds_map_destroy(_new_host_map);
    ds_map_delete(udp_client_maps,_new_host);
    ds_list_delete(
        udp_client_list,
        ds_list_find_index(
            udp_client_list,
            _new_host
        )
    );
       
    // alter variables encountered in a host reset
    udp_next_client_id                      = 1;
    udp_host_lobby_refresh_timer            = -1;
    udp_host_migration_stats_request_timer  = -1;
    udp_host_game_in_progress               = false;
    
    // share connection params as if new client
    udp_client_share_connection_params();
}
