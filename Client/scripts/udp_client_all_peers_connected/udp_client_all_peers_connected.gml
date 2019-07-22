/// @description  udp_client_all_peers_connected()

// indicates whether this client has been able to
// establish call and response with all of its
// sessions peers

if(udp_is_client()){

    var _num_clients = ds_list_size(udp_client_list);
    var _idx, _client, _map;
    
    for(_idx=0;_idx<_num_clients;++_idx){

        _client = udp_client_list[| _idx];
        
        if(_client != udp_id){
        
            _map    = udp_client_maps[? _client];
        
            if(!_map[? "connected"]){
                show_debug_message("Client "+string(udp_id)
                    +" does not have connection with client "+string(_client));
                return false;
            }
        }
    }

    show_debug_message("Client "+string(udp_id)+"has connections with all peers");
    return true;
}
