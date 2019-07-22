/// @description  udp_client_check_takeover()

// if backup host, see if conditions met to declare self new session host

if(udp_is_client()
&& udp_client_is_next_host()
&& migrate_state == migrate_states.client_to_host_verifying){

    // if more than half of peers have dropped host that will be considered
    // sufficient to take the session over
    
    var _idx, _client, _map;
    var _count = 0;

    var _num_clients = ds_list_size(udp_client_list);
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        
        if(_map[? "dropped_host"])
            ++_count;
    }
    
    show_debug_message("received dropped host notice from "
        +string(_count)+" of "+string(_num_clients)+" session clients");
    
    if(_count >= ceil(_num_clients/2)){
    
        udp_client_become_host();
    }
}
