/// @description  udp_client_remove_client(client_id)

// remove client that left from client data structures

var _client = argument0;

if(ds_map_exists(udp_client_maps, _client)){

    var _map = udp_client_maps[? _client];
    ds_map_clear(_map);
    ds_map_destroy(_map);
    ds_list_delete(
        udp_client_list,
        ds_list_find_index(
            udp_client_list,
            _client
        )
    );
    ds_map_delete(udp_client_maps, _client);
}
