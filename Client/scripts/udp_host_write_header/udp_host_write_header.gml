/// @description  udp_host_write_header(buffer,client,message_id,is_reliable)

// eliminates code duplication that existed between udp_host_send
// and udp_host_manage_holepunch

var _buffer      = argument0;
var _client      = argument1;
var _msg_id      = argument2;
var _is_reliable = argument3;
var _udpr_id;

buffer_seek(_buffer,buffer_seek_start,0);
buffer_write(_buffer,buffer_bool,true); // is udp (true)
buffer_write(_buffer,buffer_u16,_msg_id);
buffer_write(_buffer,buffer_u32,buffer_checksum(udp_header_size,_buffer));
buffer_write(_buffer,buffer_s32,udp_id);
buffer_write(_buffer,buffer_u32,udp_host_next_seq_num(_client,_msg_id));

if(_is_reliable) _udpr_id = udp_host_next_reliable_id(_client);
    else _udpr_id = 0;
    
buffer_write(_buffer,buffer_u16,_udpr_id);

return _udpr_id;
