/// @description  udp_host_next_lrgpkt_id(udp_client)

// returns next available large packet identifier and updates

var _client		= argument0;
var _client_map	= udp_client_maps[? _client];
var _sent_map	= _client_map[? "udplrg_sent_map"];
var _udplrg_id  = _client_map[? "udplrg_next_id"];
var _next_id	= _udplrg_id +1;

if(_next_id > unsigned_16_max)
	_next_id = 1;
	
while(ds_map_exists(_sent_map,_next_id)){
    _next_id++;
    if(_next_id > unsigned_16_max)
        _next_id = 1;
}
	
_client_map[? "udplrg_next_id"] = _next_id;

return _udplrg_id;