/// @description  set_network_username(username)

// wrapper script to set username string

var _input = argument0;
var _name = string_copy(_input,0,network_username_max_length);

network_username = _name;
