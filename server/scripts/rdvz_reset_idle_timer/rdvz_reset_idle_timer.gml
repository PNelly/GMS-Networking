/// @description  rdvz_reset_idle_timer(client)

// reset idle timer of client in question

var _client = argument0;

var _map = client_maps[? _client];

_map[? "idle_timer"] = idle_disconnect_delay;
