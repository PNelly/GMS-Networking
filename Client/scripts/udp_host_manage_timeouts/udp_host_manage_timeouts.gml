/// @description  udp_host_manage_timeouts()

// decrement and observe timeouts for all active clients and disconnect
// any that hit zero

if(ds_list_size(udp_client_list) > 0){
    var _id, _map, _idx;
    for(_idx=0;_idx<ds_list_size(udp_client_list);_idx++){
        _id     = udp_client_list[| _idx];
        _map    = udp_client_maps[? _id];
        _map[? "timeout"] = _map[? "timeout"] -1;
        if(_map[? "timeout"] < 0){
        
            show_debug_message("client: "+string(_id)+" timed out");
            udp_host_disconnect_client(_id);
            _idx--;
            
        }
    }
}
