/// @description  udp_host_init_client(id, ip, port, username)

// initialize fields for a client

var _id         = argument0;
var _client_map = argument1;
var _ip         = argument2;
var _port       = argument3;
var _username   = argument4;

_client_map[? "id"]                     = _id;
_client_map[? "ip"]                     = _ip;
_client_map[? "client_port"]            = _port;
_client_map[? "host_port"]              = -1;
_client_map[? "public_ip"]              = "";
_client_map[? "public_client_port"]     = -1;
_client_map[? "public_host_port"]       = -1;
_client_map[? "call_response_stamp"]    = -1;
_client_map[? "peer_connected"]         = false;
_client_map[? "peer_avg_ping"]          = -1;
_client_map[? "migration_order"]        = -1;
_client_map[? "timeout"]                = udp_connection_timeout;
_client_map[? "keep_alive_timer"]       = udp_keep_alive_interval;
_client_map[? "ping"]                   = 100;
_client_map[? "ready"]                  = false;
_client_map[? "username"]               = _username;
_client_map[? "game_init_complete"]     = false;
_client_map[? "udpr_next_id"]           = 1;
_client_map[? "udpr_sent_list"]         = ds_list_create();
_client_map[? "udpr_sent_maps"]         = ds_map_create();
_client_map[? "udpr_rcvd_list"]         = ds_list_create();
_client_map[? "udpr_rcvd_map"]          = ds_map_create();
_client_map[? "udp_seq_num_sent_map"]   = ds_map_create();
_client_map[? "udp_seq_num_rcvd_map"]   = ds_map_create();
_client_map[? "udplrg_rcvd_list"]		= ds_list_create();
_client_map[? "udplrg_rcvd_map"]		= ds_map_create();
_client_map[? "udplrg_sent_udpr_map"]	= ds_map_create();
_client_map[? "udplrg_sent_map"]		= ds_map_create();
_client_map[? "udplrg_sent_list"]		= ds_list_create();
_client_map[? "udplrg_next_id"]			= 1;

udp_init_seq_numbers(_client_map[? "udp_seq_num_sent_map"]);
udp_init_seq_numbers(_client_map[? "udp_seq_num_rcvd_map"]);
