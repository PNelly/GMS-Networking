/// udp_host_lrgpkt_rcvd(sender_udp_id,udplrg_id,udplrg_idx,udplrg_num,udplrg_len,buffer)

var _sender_udp_id	= argument0;
var _udplrg_id		= argument1;
var _udplrg_idx		= argument2;
var _udplrg_num		= argument3;
var _udplrg_len		= argument4;
var _buffer			= argument5;

if(!ds_map_exists(udp_client_maps,_sender_udp_id)) return false;

/*show_debug_message("udp_host_lrgpkt_rcvd "
	+" sender "+string(_sender_udp_id)
	+" udplrg id "+string(_udplrg_id)
	+" udplrg idx "+string(_udplrg_idx)
	+" udplrg num "+string(_udplrg_num)
	+" udplrg len "+string(_udplrg_len)
);*/

var _client_map			= udp_client_maps[? _sender_udp_id];
var _udplrg_rcvd_list	= _client_map[? "udplrg_rcvd_list"];
var _udplrg_rcvd_map	= _client_map[? "udplrg_rcvd_map"];

var _frag_buffer		= buffer_create(_udplrg_len,buffer_fixed,1);

buffer_copy(_buffer,0,_udplrg_len,_frag_buffer,0);

var _msg_map;

if(ds_map_exists(_udplrg_rcvd_map,_udplrg_id)){
	
	//show_debug_message("new fragment for existing message");
	
	// add new fragment and evaluate completeness //
	
	_msg_map = _udplrg_rcvd_map[? _udplrg_id];
	
	ds_list_add(_msg_map[? "udplrg_pkt_list"], _udplrg_idx);
	ds_map_add( _msg_map[? "udplrg_pkt_map"],  _udplrg_idx, _frag_buffer);
	
	var _target_total = 0;
	var _packet_total = 0;
	var _n, _idx;
	
	for(_n=1;_n<=_msg_map[? "udplrg_num"];++_n)
		_target_total += _n;
	
	for(_idx=0;_idx < ds_list_size(_msg_map[? "udplrg_pkt_list"]);++_idx)
		_packet_total += ds_list_find_value(_msg_map[? "udplrg_pkt_list"],_idx);
		
	//show_debug_message("target total "+string(_target_total)+" packet total "+string(_packet_total));
		
	return (_packet_total == _target_total) ? true : false;	
	
} else {
	
	//show_debug_message("new lrg message");
	
	// create entry for new large packet assembly //

	_msg_map						= ds_map_create();
	_msg_map[? "udplrg_complete"]	= false;
	_msg_map[? "udplrg_num"]		= _udplrg_num;
	_msg_map[? "udplrg_pkt_list"]	= ds_list_create();
	_msg_map[? "udplrg_pkt_map"]	= ds_map_create();
	_msg_map[? "udplrg_asm_buffer"] = undefined;
	
	ds_list_add(_msg_map[? "udplrg_pkt_list"], _udplrg_idx);
	ds_map_add( _msg_map[? "udplrg_pkt_map"],  _udplrg_idx, _frag_buffer);

	ds_list_add(_udplrg_rcvd_list,_udplrg_id);
	ds_map_add( _udplrg_rcvd_map, _udplrg_id,_msg_map);
	
	return (_udplrg_num == 1) ? true : false;
}