/// udp_client_lrgpkt_rcvd(udplrg_id,udplrg_idx,udplrg_num,buffer)

var _udplrg_id		= argument0;
var _udplrg_idx		= argument1;
var _udplrg_num		= argument2;
var _udplrg_len		= argument3;
var _buffer			= argument4;

var _frag_buffer	= buffer_create(_udplrg_len,buffer_fixed,1);

buffer_copy(_buffer,0,_udplrg_len,_frag_buffer,0);

var _msg_map;

if(ds_map_exists(udplrg_rcvd_map,_udplrg_id)){
	
	// add new fragment and evaluate completeness //
	
	_msg_map = udplrg_rcvd_map[? _udplrg_id];
	
	ds_list_add(_msg_map[? "udplrg_pkt_list"], _udplrg_idx);
	ds_map_add( _msg_map[? "udplrg_pkt_map"],  _udplrg_idx, _frag_buffer);
	
	var _target_total = 0;
	var _packet_total = 0;
	var _n, _idx;
	
	for(_n=1;_n<=_msg_map[? "udplrg_num"];++_n)
		_target_total += _n;
	
	for(_idx=0;_idx < ds_list_size(_msg_map[? "udplrg_pkt_list"]);++_idx)
		_packet_total += ds_list_find_value(_msg_map[? "udplrg_pkt_list"],_idx);
		
	return (_packet_total == _target_total) ? true : false;
	
} else {

	// create entry for new large packet assembly //

	_msg_map						= ds_map_create();
	_msg_map[? "udplrg_complete"]	= false;
	_msg_map[? "udplrg_num"]		= _udplrg_num;
	_msg_map[? "udplrg_pkt_list"]	= ds_list_create();
	_msg_map[? "udplrg_pkt_map"]	= ds_map_create();
	_msg_map[? "udplrg_asm_buffer"] = undefined;
	
	ds_list_add(_msg_map[? "udplrg_pkt_list"], _udplrg_idx);
	ds_map_add( _msg_map[? "udplrg_pkt_map"],  _udplrg_idx, _frag_buffer);

	ds_list_add(udplrg_rcvd_list,_udplrg_id);
	ds_map_add( udplrg_rcvd_map,_udplrg_id,_msg_map);
	
	return (_udplrg_num == 1) ? true : false;
}