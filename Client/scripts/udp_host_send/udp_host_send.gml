/// @description  udp_host_send(client_id,message_id,use_reliable,buffer)

var _client      = argument0;
var _msg_id      = argument1;
var _is_reliable = argument2;
var _buffer      = argument3;
var _total_size  = buffer_tell(_buffer);

if(!ds_map_exists(udp_client_maps,_client)) exit;

var _map    = udp_client_maps[? _client];
var _ip     = _map[? "ip"];
var _port   = _map[? "client_port"];

if(_total_size <= udp_max_transmission_unit){

	var _udpr_id = udp_host_write_header(
		_buffer,
		_client,
		_msg_id,
		_is_reliable,
		0, 1, 1,
		_total_size
	);

	if(_is_reliable)
	    udp_host_reliable_record(_client,_udpr_id,_buffer);
    
	udp_send_packet(udp_host_socket,_ip,_port,_buffer);
	
} else {
	
	// break message up into multiple reliable chunks for reconstruction
	
	var _data_remaining = _total_size - udp_header_size;
	
	var _udplrg_id		= udp_host_next_lrgpkt_id(_client);
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
		
		var _udpr_id = udp_host_write_header(
			_frag_buffer,
			_client,
			_msg_id,
			true,
			_udplrg_id,
			_udplrg_idx,
			_udplrg_num,
			_frag_size
		);
		
		udp_host_reliable_record(_client,_udpr_id,_frag_buffer);
		udp_send_packet(udp_host_socket,_ip,_port,_frag_buffer);
		
		_data_remaining -= (_frag_size -udp_header_size);
	}
}

// reset this clients keep alive packet send timer,
// since we've just sent a packet
_map[? "keep_alive_timer"] = udp_get_keep_alive_time();