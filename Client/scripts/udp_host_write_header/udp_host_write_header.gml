/// @description  udp_host_write_header(buffer,client,message_id,is_reliable,udplrg_id,udplrg_idx,udplrg_num,udplrg_frag_len)

// eliminates code duplication that existed between udp_host_send
// and udp_host_manage_holepunch

var _buffer      = argument0;
var _client      = argument1;
var _msg_id      = argument2;
var _is_reliable = argument3;
var _udplrg_id   = argument4;
var _udplrg_idx  = argument5;
var _udplrg_num  = argument6;
var _udplrg_len  = argument7;

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

buffer_write(_buffer,buffer_u16,_udplrg_id);
buffer_write(_buffer,buffer_u16,_udplrg_idx);
buffer_write(_buffer,buffer_u16,_udplrg_num);
buffer_write(_buffer,buffer_u16,_udplrg_len);

return _udpr_id;
