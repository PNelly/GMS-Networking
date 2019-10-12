/// @description  tcp_send_packet(socket,buffer)

// exists to eliminate repetive use of buffer get size() elsewhere

var _socket = argument0;
var _buffer = argument1;

network_send_packet(_socket,_buffer,buffer_tell(_buffer));