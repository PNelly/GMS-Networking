/// @description  udp_client_demote_host()

// copy host player data into client data structures

var _self_map       = udp_client_maps[? udp_id];
var _old_host_ping  = _self_map[? "ping"];
var _old_host_id    = udp_host_id;

udp_client_define_client(
    _old_host_id,
    _old_host_ping,
    false,
    udp_host_map[? "username"]
);

var _host_to_client_map = udp_client_maps[? _old_host_id];

_host_to_client_map[? "ip"]             = udp_host_ip;
_host_to_client_map[? "host_port"]      = udp_client_host_port;
_host_to_client_map[? "client_port"]    = udp_client_host_client_port;
