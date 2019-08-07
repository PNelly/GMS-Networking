/// @description udp_host_reset_client_timeout(client)

if(!udp_is_host()) exit;

var _client	= argument0;
var _client_map;

if(ds_map_exists(udp_client_maps,_client)){

	_client_map = udp_client_maps[? _client];
	_client_map[? "timeout"] = udp_connection_timeout;
}