/// @description  udp_host_next_reliable_id(udp_client)

// returns next available packet identifier and updates

var _client     = argument0;
var _client_map = udp_client_maps[? _client];
var _sent_list  = _client_map[? "udpr_sent_list"];
var _sent_map   = _client_map[? "udpr_sent_maps"];
var _udpr_id    = _client_map[? "udpr_next_id"];
var _next_id    = _udpr_id +1;

if(_next_id > unsigned_16_max)
        _next_id =1;

while(ds_map_exists(_sent_map,_next_id)){
    _next_id++;
    if(_next_id > unsigned_16_max)
        _next_id =1;
}

_client_map[? "udpr_next_id"] = _next_id;

return _udpr_id;
