/// @description  define_network_peer(network_list, network_map, id, ip, udp_host_port, host_clients, host_max_clients, udp_client_port, game_in_progress)

// define a new network peer either for the rendevouz server or the local network

var _net_list           = argument0;
var _net_map            = argument1;
var _id                 = argument2;
var _ip                 = argument3;
var _is_host            = argument4;
var _host_port          = argument5;
var _host_clients       = argument6;
var _host_max_clients   = argument7;
var _client_port        = argument8;
var _in_progress        = argument9;

var _map = ds_map_create();

ds_list_add(_net_list, _id);
ds_map_add(_net_map, _id, _map);

_map[? "socket"]                = _id;
_map[? "ip"]                    = _ip;
_map[? "udp_is_host"]           = _is_host;
_map[? "udp_host_port"]         = _host_port;
_map[? "udp_host_clients"]      = _host_clients;
_map[? "udp_host_max_clients"]  = _host_max_clients;
_map[? "udp_client_port"]       = _client_port;
_map[? "udp_host_in_progress"]  = _in_progress;
