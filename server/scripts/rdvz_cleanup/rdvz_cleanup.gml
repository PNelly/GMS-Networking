/// @description  rdvz_cleanup()

// clear out any allocated memory

// buffers
buffer_delete(message_buffer);

// remove client properties
var _client, _map;
var _clients_removed = 0;
var _idx = 0;

while(_clients_removed < num_clients){

    _client = client_keys[ _idx];
    if(_client >= 0){
        _map = client_maps[? _client];
        ds_map_destroy(_map);
        ds_map_delete(client_maps,_client);
        _clients_removed++;
    }
}

// remove client meta structures
//ds_list_destroy(client_list);
ds_map_destroy(client_maps);

// remove network structures
network_destroy(rdvz_tcp_socket);
