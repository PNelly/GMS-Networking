/// @description  udp_client_send(message_id,use_reliable,buffer,delivery_hook)

// send udp message to the session host

var _msg_id         = argument0;
var _is_reliable    = argument1;
var _buffer         = argument2;
var _hook			= argument3;
var _total_size		= buffer_tell(_buffer);

var _trk_map		= -1;
var _hook_key		= -1;
var _has_hook		= (
						ds_exists(_hook,ds_type_map) 
						&& (
							_is_reliable 
							|| (_total_size > udp_max_transmission_unit)
							)
					  );

if(_total_size <= udp_max_transmission_unit){

	// send single message

	var _udpr_id = udp_client_write_header(
		_buffer, 
		_msg_id, 
		_is_reliable,
		0, 1, 1,
		_total_size
	);
	
	udp_send_packet(udp_client_socket,udp_host_ip,udp_client_host_port,_buffer);

	if(_is_reliable)
	    udp_client_reliable_record(_udpr_id,_msg_id,_buffer);
	
	if(_has_hook)
		_hook_key = "udpr_id_"+string(_udpr_id);
		
} else {
	
	// break message up into multiple reliable chunks for reconstruction
	
	var _data_remaining = _total_size - udp_header_size;
	
	var _udplrg_id		= udp_client_next_lrgpkt_id();
	var _udplrg_idx		= 1;
	var _udplrg_num		= (_data_remaining % udp_max_data_size == 0)
						? (_data_remaining / udp_max_data_size)
						: (1 + floor(_data_remaining / udp_max_data_size));
	
	// initialize component tracking data
	
	udplrg_sent_map[? _udplrg_id]	= ds_map_create();
	
	_trk_map						= udplrg_sent_map[? _udplrg_id];
	_trk_map[? "udplrg_received"]	= false;
	_trk_map[? "udplrg_num"]		= _udplrg_num;
	_trk_map[? "udplrg_progress"]	= 0;
	_trk_map[? "udpr_list"]			= ds_list_create();
	
	// setup delivery hook if applicable
	
	if(_has_hook)
		_hook_key = "udplrg_id_"+string(_udplrg_id);
	
	// fracture and send
	
	for(;_udplrg_idx <= _udplrg_num; ++_udplrg_idx){
	
		var _frag_size	= (_data_remaining > udp_max_data_size)
						? udp_max_transmission_unit
						: _data_remaining + udp_header_size;
						
		var _frag_buffer		= buffer_create(_frag_size,buffer_fixed,1);
		var _frag_data_bytes	= _frag_size -udp_header_size;
	
		var _data_seek = udp_header_size + (_udplrg_idx -1) * udp_max_data_size;
		
		/*show_debug_message(
			"udplrg idx "+string(_udplrg_idx)
			+" data remaining "+string(_data_remaining)
			+" udplrg num "+string(_udplrg_num)
			+" frag size "+string(_frag_size)
			+" frag data bytes "+string(_frag_data_bytes)
			+" data seek "+string(_data_seek)
		);*/
		
		buffer_copy(
			_buffer,
			_data_seek,
			_frag_data_bytes,
			_frag_buffer,
			udp_header_size
		);
		
		var _udpr_id = udp_client_write_header(
			_frag_buffer,
			_msg_id,
			true,
			_udplrg_id,
			_udplrg_idx,
			_udplrg_num,
			_frag_size
		);
		
		udp_client_reliable_record(_udpr_id,_msg_id,_frag_buffer);
		udp_send_packet(udp_client_socket,udp_host_ip,udp_client_host_port,_frag_buffer);
	
		_data_remaining -= (_frag_size -udp_header_size);
		
		// add reliable packet to tracking for this large message
		
		ds_list_add(_trk_map[? "udpr_list"], _udpr_id);
		udplrg_sent_udpr_map[? _udpr_id] = _udplrg_id;
	}
}

// tag delivery hook

if(_has_hook){
	ds_list_add(udp_dlvry_hooks_list,_hook_key);
	udp_dlvry_hooks_map[? _hook_key] = _hook;
}
    
// reset keep alive sent timer, since we've just sent a packet
udp_keep_alive_timer = udp_get_keep_alive_time();

// return tracking map if applicable
if(_trk_map > 0)
	return _trk_map;