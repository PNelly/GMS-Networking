/// @description  rdvz_send(client,message_id,buffer)

var _client = argument0;
var _msg_id = argument1;
var _buffer = argument2;

// Write Header Info
buffer_seek(_buffer,buffer_seek_start,0);
// not a udp message, clients expect boolean in all packet headers
buffer_write(_buffer,buffer_bool,false);
buffer_write(_buffer,buffer_u16,_msg_id);

tcp_send_packet(_client,_buffer);
