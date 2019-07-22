/// @description  lan_sync_rdvz()

// remove any local network hosts that do not appear in rendevouz list

if(rendevouz_state != rdvz_states.rdvz_none){

    var _idx, _rdvz_id, _rdvz_map, _local_map;
    
    var _num_local = ds_list_size(lan_list);
    
    for(_idx = 0; _idx < _num_local; ++_idx){
    
        _rdvz_id = lan_list[| _idx];
        
        if(!ds_map_exists(rdvz_client_maps, _rdvz_id)
          &&ds_map_exists(lan_maps, _rdvz_id)){
          
            _local_map = lan_maps[? _rdvz_id];
            ds_map_clear(_local_map);
            ds_map_destroy(_local_map);
            ds_list_delete(lan_list, ds_list_find_index(lan_list, _rdvz_id));
            ds_map_delete(lan_maps, _rdvz_id);
            
            show_debug_message("lan sync rdvz deleted host "+string(_rdvz_id));
        }
    }
}
