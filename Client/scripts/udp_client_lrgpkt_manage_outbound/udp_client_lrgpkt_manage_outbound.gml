/// udp_client_lrgpkt_manage_outbound()

// meter out sending of large packets over the course of several frames
// by limiting outbound bytes to a reasonable speed

if(!udp_is_client()) exit;

var _idx		= 0;
var _num		= ds_list_size(udplrg_outbound_list);
var _bytes_sent = 0;
var _pkts_sent  = 0;
var _udplrg_id, _trk_map;

var _base_microseconds = get_timer();

for(;_idx<_num;++_idx){
	
	_udplrg_id	= udplrg_outbound_list[| _idx];
	_trk_map	= udplrg_outbound_map[? _udplrg_id];
	
	for(;
		_trk_map[? "udplrg_idx_sent"] <= _trk_map[? "udplrg_num"];
		_trk_map[? "udplrg_idx_sent"]  = _trk_map[? "udplrg_idx_sent"] +1
	){
	
		var _frag_size	= (_trk_map[? "data_remaining"] > udp_max_data_size)
						? udp_max_transmission_unit
						: _trk_map[? "data_remaining"] + udp_header_size;
						
		var _frag_buffer		= buffer_create(_frag_size,buffer_fixed,1);
		var _frag_data_bytes	= _frag_size -udp_header_size;
		
		var _data_seek	= udp_header_size 
						+ (_trk_map[? "udplrg_idx_sent"] -1) * udp_max_data_size;
						
		buffer_copy(
			_trk_map[? "udplrg_buffer"],
			_data_seek,
			_frag_data_bytes,
			_frag_buffer,
			udp_header_size
		);
		
		var _udpr_id = udp_client_write_header(
			_frag_buffer,
			_trk_map[? "udplrg_msg_id"],
			true,
			_udplrg_id,
			_trk_map[? "udplrg_idx_sent"],
			_trk_map[? "udplrg_num"],
			_frag_size
		);
		
		udp_client_reliable_record(_udpr_id, _trk_map[? "udplrg_msg_id"], _frag_buffer, _frag_size);
		
		// seek buffer to ensure correct outbound sizing
		
		buffer_seek(_frag_buffer,buffer_seek_start,_frag_size);
		
		udp_send_packet(udp_client_socket,udp_host_ip,udp_client_host_port,_frag_buffer);
		
		// reset keep alive sent timer, since we've just sent a packet
		udp_keep_alive_timer = udp_get_keep_alive_time();
		
		var _subtract = _frag_size -udp_header_size;
		
		_trk_map[? "data_remaining"] = (_trk_map[? "data_remaining"] -_subtract);
		
		_bytes_sent += _frag_size;
		_pkts_sent  += 1;
		
		if(_bytes_sent >= udplrg_max_bytes_per_frame
		|| _pkts_sent  >= udplrg_max_packets_per_frame){
			if(_bytes_sent >= udplrg_max_bytes_per_frame)
				show_debug_message("exceeded bytes per frame");
			if(_pkts_sent  >= udplrg_max_packets_per_frame)
				show_debug_message("exceeded packets per frame");
			break;
		}
	}
	
	if(_bytes_sent >= udplrg_max_bytes_per_frame
	|| _pkts_sent  >= udplrg_max_packets_per_frame)
		break;
}

if(_bytes_sent > 0)
	show_debug_message("*^&$# "+string(get_timer()-_base_microseconds)+" elapsed"
		+" packets sent "+string(_pkts_sent)+" bytes sent "+string(_bytes_sent)
	);