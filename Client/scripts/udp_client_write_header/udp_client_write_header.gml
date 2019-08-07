/// @description  udp_client_write_header(buffer,message_id,reliable,udplrg_id,udplrg_idx,udplrg_num,udplrg_len)

// construct packet header, eliminates code duplication
// that existed in client udp packets and hole punch packets

var _buffer      = argument0;
var _msg_id      = argument1;
var _is_reliable = argument2;
var _udplrg_id   = argument3;
var _udplrg_idx  = argument4;
var _udplrg_num  = argument5;
var _udplrg_len  = argument6;

buffer_seek(_buffer,buffer_seek_start,0);
buffer_write(_buffer,buffer_bool,true); // is udp (true)
buffer_write(_buffer,buffer_u16,_msg_id);
buffer_write(_buffer,buffer_u32,buffer_checksum(udp_header_size,_buffer,_udplrg_len));
buffer_write(_buffer,buffer_s32,udp_id);
buffer_write(_buffer,buffer_u32,udp_client_next_seq_num(_msg_id));

if(_is_reliable) _udpr_id = udp_client_next_reliable_id();
    else _udpr_id = 0;
    
buffer_write(_buffer,buffer_u16,_udpr_id);

buffer_write(_buffer,buffer_u16,_udplrg_id);
buffer_write(_buffer,buffer_u16,_udplrg_idx);
buffer_write(_buffer,buffer_u16,_udplrg_num);
buffer_write(_buffer,buffer_u16,_udplrg_len);

return _udpr_id;
