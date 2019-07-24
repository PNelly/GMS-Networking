/// @description  udp_client_next_lrgpkt_id()

// gets next available large, fragmented packet identifier and updates

var _udplrg_id = udplrg_next_id;
var _next_id   = _udplrg_id +1;

if(_next_id > unsigned_16_max)
	_next_id = 1;
	
udplrg_next_id = _next_id;

return _udplrg_id;