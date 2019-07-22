/// @description  udp_client_wipe_clients()

//  cleans out data structures holding information on other clients
//  in the udp session

var _num = ds_list_size(udp_client_list);
var _key, _map;

var _idx;

for(_idx=0;_idx<_num;_idx++){

    _key = udp_client_list[| _idx];
    _map = udp_client_maps[? _key];
    
    ds_map_clear(_map);
    ds_map_destroy(_map);
    ds_map_delete(udp_client_maps,_key);

}

ds_map_clear(udp_client_maps);
ds_list_clear(udp_client_list);
