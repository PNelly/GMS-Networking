/// @description  udp_host_distribute_new_client(new_client_id)

// inform other clients about a new client
// joining a game in progress

var _client = argument0;
var _map, _id, _ping, _name;

_map    = udp_client_maps[? _client];
_id     = _map[? "id"];
_ping   = _map[? "ping"];
_name   = _map[? "username"];

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_s32,_id);
buffer_write(message_buffer,buffer_u16,_ping);
buffer_write(message_buffer,buffer_string,_name);

udp_host_send_all(udp_msg.udp_game_client_joined,true,message_buffer,true);
