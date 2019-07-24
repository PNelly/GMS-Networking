/// udp_host_lrgpkt_assemble(sender_udp_id,udplrg_id,seek_position)

//show_debug_message("== HOST PACKET ASSEMBLY ==");

var _sender_udp_id	= argument0;
var _udplrg_id		= argument1;
var _seek_pos		= argument2;

var _client_map			= udp_client_maps[? _sender_udp_id];
var _udplrg_rcvd_map	= _client_map[? "udplrg_rcvd_map"];
var _msg_map			= _udplrg_rcvd_map[? _udplrg_id];
var _frag_map			= _msg_map[? "udplrg_pkt_map"];
var _frag_list			= _msg_map[? "udplrg_pkt_list"];

ds_list_sort(_frag_list,true);

var _size		= 0;
var _list_idx	= 0;
var _num  = _msg_map[? "udplrg_num"];
var _udplrg_idx, _buff, _add;

for(;_list_idx<_num;++_list_idx){

	_udplrg_idx	= _frag_list[| _list_idx];
	_buff		= _frag_map[? _udplrg_idx];
	
	_add		= (_udplrg_idx > 1)
				? buffer_get_size(_buff) -udp_header_size
				: buffer_get_size(_buff);
			
	_size		+= _add;
	
	/*show_debug_message(
		"udplrg idx "+string(_udplrg_idx)
		+" udplrg add size "+string(_add)
	);*/
}

//show_debug_message("host udplrg asm size "+string(_size));

var _asm_buffer = buffer_create(_size,buffer_fixed,1);

var _src_offset = 0;
var _asm_offset = 0;

for(_list_idx=0;_list_idx<_num;++_list_idx){

	_udplrg_idx	= _frag_list[| _list_idx];
	_buff		= _frag_map[? _udplrg_idx];
	
	var _bytes	= (_udplrg_idx > 1) 
				? (buffer_get_size(_buff) -udp_header_size)
				: (buffer_get_size(_buff));
	
	_src_offset = (_udplrg_idx > 1) ? udp_header_size : 0;
	
	buffer_copy(
		_buff,
		_src_offset,
		_bytes,
		_asm_buffer,
		_asm_offset
	);
	
	/*show_debug_message(
		"asm copy src offset "+string(_src_offset)
		+" bytes "+string(_bytes)
		+" asm offset "+string(_asm_offset)
	);*/
	
	_asm_offset += _bytes;
}

_msg_map[? "udplrg_asm_buffer"] = _asm_buffer;
_msg_map[? "udplrg_complete"]	= true;

buffer_seek(_asm_buffer,buffer_seek_start,_seek_pos);

return _asm_buffer;