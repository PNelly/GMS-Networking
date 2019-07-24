/// udp_client_lrgpkt_assemble(udplrg_id,seek_position)

//show_debug_message("== CLIENT PACKET ASSEMBLY ==");

var _udplrg_id	= argument0;
var _seek_pos	= argument1;

var _msg_map	= udplrg_rcvd_map[? _udplrg_id];
var _frag_map	= _msg_map[? "udplrg_pkt_map"];
var _frag_list	= _msg_map[? "udplrg_pkt_list"];

ds_list_sort(_frag_list,true);

var _size		= 0;
var _list_idx	= 0;
var _num  = _msg_map[? "udplrg_num"];
var _udplrg_idx, _buff, _add;

for(;_list_idx<_num;++_list_idx){
	
	_udplrg_idx	= _frag_list[| _list_idx];
	_buff		= _frag_map[? _udplrg_idx];
	
	_add		= (_udplrg_idx > 1)
				? (buffer_get_size(_buff) -udp_header_size)
				: buffer_get_size(_buff);
				
	_size		+= _add;
}

var _asm_buffer = buffer_create(_size,buffer_fixed,1);

var _src_offset = 0;
var _asm_offset = 0;

for(_list_idx=0;_list_idx<_num;++_list_idx){

	_udplrg_idx	= _frag_list[| _list_idx];
	_buff		= _frag_map[? _udplrg_idx];
	
	var _bytes	= (_udplrg_idx > 1) 
				? buffer_get_size(_buff) -udp_header_size 
				: buffer_get_size(_buff);
				
	_src_offset = (_udplrg_idx > 1) ? udp_header_size : 0;
	
	buffer_copy(
		_buff,
		_src_offset,
		_bytes,
		_asm_buffer,
		_asm_offset
	);
	
	_asm_offset += _bytes;
}

_msg_map[? "udplrg_asm_buffer"] = _asm_buffer;
_msg_map[? "udplrg_complete"]	= true;

buffer_seek(_asm_buffer,buffer_seek_start,_seek_pos);

return _asm_buffer;