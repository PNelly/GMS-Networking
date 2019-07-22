/// @description  udp_client_define_client(id, ping, ready, username)

// intialize map fields for other another client in the session

var _id     = argument0;
var _ping   = argument1;
var _ready  = argument2;
var _name   = argument3;

var _map = ds_map_create();

ds_list_add(udp_client_list,_id);
udp_client_maps[? _id] = _map;

// set fields
_map[? "id"]            = _id;
_map[? "ping"]          = _ping;
_map[? "ready"]         = _ready;
_map[? "username"]      = _name;

// connection info for host transfers
_map[? "ip"]                    = "";
_map[? "host_port"]             = -1;
_map[? "client_port"]           = -1;
_map[? "call_response_stamp"]   = -1;
_map[? "call_response_ping"]    = -1;
_map[? "connected"]             = false;
_map[? "timeout"]               = -1;
_map[? "migration_order"]       = -1;
_map[? "dropped_host"]          = false;
