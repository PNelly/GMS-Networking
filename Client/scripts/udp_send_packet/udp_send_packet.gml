/// @description  udp_send_packet(socket, url, port, buffer)

// exists to eliminate repeated use of buffer get size() elsewhere

var _socket = argument0;
var _url    = argument1;
var _port   = argument2;
var _buffer = argument3;

var _size   = buffer_get_size(_buffer);

network_send_udp(_socket,_url,_port,_buffer,_size);
