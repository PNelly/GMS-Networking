/// @description  udp_avg_peer_ping()

// compute average of pings between this machine
// and all other machines in the udp session

if(udp_is_host() || udp_is_client()){

    var _num_clients = ds_list_size(udp_client_list);
    var _client, _map, _idx;
    var _sum    = 0;
    var _num    = 0;
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        
        if(udp_is_client()){
            if(_map[? "connected"]){
                ++_num;
                _sum += _map[? "call_response_ping"];
            }
        } else if (udp_is_host()){
            ++_num;
            _sum += _map[? "ping"];
        }
    }
    
    // host has all session peer pings
    // stored in client maps, clients need
    // to add session ping with host as well
    
    if(udp_is_client()){
        ++_num;
        _sum += udp_ping;
    }

    if(_num > 0)
        return round((_sum / _num));
    else
        return -1;
}

return -1;
