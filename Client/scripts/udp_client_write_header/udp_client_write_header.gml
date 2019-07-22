/// @description  udp_client_write_header(buffer,message_id,reliable)

// construct packet header, eliminates code duplication
// that existed in client udp packets and hole punch packets

var _buffer      = argument0;
var _msg_id      = argument1;
var _is_reliable = argument2;

buffer_seek(_buffer,buffer_seek_start,0);
buffer_write(_buffer,buffer_bool,true); // is udp (true)
buffer_write(_buffer,buffer_u16,_msg_id);
buffer_write(_buffer,buffer_u32,buffer_checksum(udp_header_size,_buffer));
buffer_write(_buffer,buffer_s32,udp_id);
buffer_write(_buffer,buffer_u32,udp_client_next_seq_num(_msg_id));

if(_is_reliable) _udpr_id = udp_client_next_reliable_id();
    else _udpr_id = 0;
    
buffer_write(_buffer,buffer_u16,_udpr_id);

return _udpr_id;
