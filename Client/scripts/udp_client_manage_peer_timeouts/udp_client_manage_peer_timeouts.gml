/// @description  udp_client_manage_peer_timeouts()

// monitor call and response connection state
// with udp session peers

if(udp_is_client()){

    var _num_clients = ds_list_size(udp_client_list);
    var _idx, _client, _map;
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        
        if(_map[? "timeout"] >= 0){
            _map[? "timeout"] = _map[? "timeout"] -1;
            if(_map[? "timeout"] < 0){
                show_debug_message("### P2P "+string(udp_id)
                    +" -> "+string(_client)+" Timed Out ###");
                _map[? "connected"] = false;
                udp_client_share_migration_stats();
            }
        }
    }
}
