/// @description  udp_host_delete_client(id)

// remove the client from the client list and maps

var _client = argument0;

var _map = udp_client_maps[? _client];

ds_map_clear(_map);
ds_map_destroy(_map);
ds_map_delete(udp_client_maps,_client);
ds_list_delete(
    udp_client_list,
    ds_list_find_index(
        udp_client_list,
        _client
    )
);
