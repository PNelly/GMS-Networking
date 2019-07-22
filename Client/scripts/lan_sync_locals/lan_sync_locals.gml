/// @description  lan_sync_locals()

// copy data about lan peers into rendevouz data structures

if(rendevouz_state != rdvz_states.rdvz_none){

    //show_debug_message("lan sync locals");

    var _idx, _rdvz_id, _rdvz_map, _local_map;
    
    // move local info to rdvz info
    var _num_rdvz  = ds_list_size(rdvz_client_list);

    for(_idx = 0; _idx < _num_rdvz; ++_idx){
    
        _rdvz_id = rdvz_client_list[| _idx];
        
        if(ds_map_exists(lan_maps, _rdvz_id)
         &&ds_map_exists(rdvz_client_maps, _rdvz_id)){
         
            _rdvz_map  = rdvz_client_maps[? _rdvz_id];
            _local_map = lan_maps[? _rdvz_id];
            
            _rdvz_map[? "ip"]               = _local_map[? "ip"];
            _rdvz_map[? "udp_host_port"]    = _local_map[? "udp_host_port"];
            _rdvz_map[? "udp_client_port"]  = _local_map[? "udp_client_port"];
            
            /*show_debug_message("lan sync local peer "+string(_rdvz_id)
                +" ip "+string(_rdvz_map[? "ip"])
                +" port "+string(_rdvz_map[? "udp_client_port"]));*/
                
            if(is_undefined(_rdvz_map[? "udp_client_port"]))
                show_debug_message("UNDEFINED PORT");
        }
    }
}
