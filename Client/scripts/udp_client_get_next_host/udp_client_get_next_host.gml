/// @description  udp_client_get_next_host()

// iterate over client data structure to find
// which client is the next backup host

var _idx, _client, _map;
var _min, _min_id;
var _min_default = 999999999;

var _num_clients = ds_list_size(udp_client_list);

_min    = _min_default;
_min_id = -1;

for(_idx=0;_idx<_num_clients;++_idx){

    _client = udp_client_list[| _idx];
    _map    = udp_client_maps[? _client];
    
    if(_map[? "migration_order"] < _min){
        _min    = _map[? "migration_order"];
        _min_id = _client;
    }
}

return (_min_id);
