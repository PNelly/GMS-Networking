/// @description  rdvz_clear_client_properties()
var _num_clients = ds_list_size(rdvz_client_list);
var _map;
var _client;

var _idx;

// clear WAN clients
for(_idx=0;_idx<_num_clients;_idx++){

    _client = rdvz_client_list[| _idx];
    _map    = rdvz_client_maps[? _client];
    ds_map_destroy(_map);
    ds_map_delete(rdvz_client_maps,_client);
}

ds_map_clear(rdvz_client_maps);
ds_list_clear(rdvz_client_list);

// clear LAN clients
var _num_lan = ds_list_size(lan_list);

for(_idx=0;_idx<_num_lan;++_idx){

    _client = lan_list[| _idx];
    _map    = lan_maps[? _client];
    ds_map_destroy(_map);
    ds_map_delete(lan_maps,_client);
    
}

ds_map_clear(lan_maps);
ds_list_clear(lan_list);

