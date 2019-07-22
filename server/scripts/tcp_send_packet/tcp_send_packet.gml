/// @description  tcp_send_packet(socket,buffer)

var _socket = argument0;
var _buffer = argument1;

network_send_packet(_socket,_buffer,buffer_get_size(_buffer));
