/// @description  udp_client_send(message_id,use_reliable,buffer)

// send udp message to the session host

var _msg_id         = argument0;
var _is_reliable    = argument1;
var _buffer         = argument2;
var _total_size		= buffer_tell(_buffer);

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
		
} else {
	
	// break message up into multiple reliable chunks for reconstruction
	
	var _data_remaining = _total_size - udp_header_size;
	
	var _udplrg_id		= udp_client_next_lrgpkt_id();
	var _udplrg_idx		= 1;
	var _udplrg_num		= (_data_remaining % udp_max_data_size == 0)
						? (_data_remaining / udp_max_data_size)
						: (1 + floor(_data_remaining / udp_max_data_size));
	
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
	}
}
    
// reset keep alive sent timer, since we've just sent a packet
udp_keep_alive_timer = udp_get_keep_alive_time();

