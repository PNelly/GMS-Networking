/// @description  rdvz_client_write_header(message_id, buffer)

var _is_udp     = argument0;
var _msg_id     = argument1;
var _buffer     = argument2;

buffer_seek(_buffer,buffer_seek_start,0);
buffer_write(_buffer,buffer_bool,_is_udp);
buffer_write(_buffer,buffer_u16,_msg_id);
