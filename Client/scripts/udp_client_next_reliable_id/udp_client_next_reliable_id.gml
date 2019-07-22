/// @description  udp_client_next_reliable_id()

// gets next available packet identifier and updates

var _udpr_id = udpr_next_id;
var _next_id = _udpr_id +1;

while(ds_map_exists(udpr_sent_maps,_next_id)){
    _next_id++;
    if( _next_id > unsigned_16_max )
        _next_id = 1;
}

udpr_next_id = _next_id;

return _udpr_id;
