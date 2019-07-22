/// @description  udp_client_become_host()

// declare to other peers that this peer will be the new session host

if(udp_is_client()){

    show_debug_message("-- udp client become host --");

    // clear migration state
    migrate_state = migrate_states.none;
    migrate_timer = -1;
    migrate_verify_timer = -1;

    // change self to corresponding host state
    switch(udp_state){
        case udp_states.udp_client_lobby:
            udp_state = udp_states.udp_host_lobby;
        break;
        case udp_states.udp_client_game_init:
            udp_state = udp_states.udp_host_game_init;
        break;
        case udp_states.udp_client_game:
            udp_state = udp_states.udp_host_game;
        break;
        case udp_states.udp_client_game_ending:
            udp_state = udp_states.udp_host_game_ending;
        break;
        case udp_states.udp_client_game_post:
            udp_state = udp_states.udp_host_game_post;
        break;
    }
    
    // demote previous host into client data structures
    udp_client_demote_host();
    
    // alter variables encountered in client reset
    udp_host_id = udp_id;
    udp_host_to_join = -1;
    udp_host_to_join_ip = "";
    udp_host_to_join_port = -1;
    udp_host_ip = "";
    udp_client_host_port = -1;
    udp_hole_punch_timer = -1;
    udp_client_cleanup_packets();

    // remove self from client data structures    
    var _self_map = udp_client_maps[? udp_id];
    ds_map_destroy(_self_map);
    ds_map_delete(udp_client_maps, udp_id);
    ds_list_delete(
        udp_client_list,
        ds_list_find_index(
            udp_client_list,
            udp_id
        )
    );
  
    // perform actions consistent with initializing new host session
    udp_host_init_timers();
    udp_host_init_self_metadata();
    
    // re-label session id
    udp_session_id = udp_host_generate_session_id();
    
    // bring id distribution up to speed
    udp_host_get_unique_client_id();
      
    // determine game in progress
    switch(udp_state){
    
        case udp_states.udp_host_game_init:
        case udp_states.udp_host_game:
            udp_host_game_in_progress = true;
        break;
        
        case udp_states.udp_host_lobby:
        case udp_states.udp_host_game_ending:
        case udp_states.udp_host_game_post:
            udp_host_game_in_progress = false;
        break;
    }
    
    // iterate over client data re-organizing it in host format
    var _idx, _client, _map;
    var _num_clients = ds_list_size(udp_client_list);
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        
        // remove keys specific to client peer to peer
        ds_map_delete(_map, "call_response_ping");
        ds_map_delete(_map, "connected");
        ds_map_delete(_map, "dropped_host");
        
        udp_host_init_client(
            _client,
            _map,
            _map[? "ip"],
            _map[? "client_port"],
            _map[? "username"]
        );
    }
    
    // alert all peers that migration has occured
    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_s32,udp_id);
    buffer_write(message_buffer,buffer_string,udp_session_id);
    udp_host_send_all(udp_msg.udp_migrate_new_host,false,message_buffer);
    
    // unready all clients in lobby state
    udp_host_unready_all_clients();
    
    // connect with rendevouz server if appropriate
    if(_num_clients < udp_max_clients
    && rendevouz_state == rdvz_states.rdvz_none
    && (
            udp_state == udp_states.udp_host_lobby
         ||(
                udp_state == udp_states.udp_host_game
             && udp_host_allow_join_in_progress
            )         
       )
    ){
        if(rdvz_connect()){
            // previous client will have no rdvz id
            // so will be re-routed to an id request
            udp_host_attempt_session_create();
        }
    }
}
