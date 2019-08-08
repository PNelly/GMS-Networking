/// @description udp_host_lrgpkt_manage_outbound()

// meter out sending of large packets over the course of several frames
// by limiting outbound bytes to a reasonable speed

if(!udp_is_host()) exit;

var _bytes_sent		= 0;
var _pkts_sent		= 0;
var _idx_client		= 0;
var _num_clients	= ds_list_size(udp_client_list);
var _client_map, _client;

var _base_microseconds = get_timer();

for(;_idx_client<_num_clients;++_idx_client){

	_client		= udp_client_list[| _idx_client];
	_client_map = udp_client_maps[? _client];
	
	//show_debug_message("host managing large outbounds for client "+string(_client));
	
	var _udplrg_outbound_list = _client_map[? "udplrg_outbound_list"];
	var _udplrg_outbound_map  = _client_map[? "udplrg_outbound_map"];
	
	var _idx_outbound = 0;
	var _num_outbound = ds_list_size(_udplrg_outbound_list);
	
	for(;_idx_outbound<_num_outbound;++_idx_outbound){
		
		var _udplrg_id	= _udplrg_outbound_list[| _idx_outbound];
		var _trk_map	= _udplrg_outbound_map[? _udplrg_id];
		
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
			
			var _udpr_id = udp_host_write_header(
				_frag_buffer,
				_client,
				_trk_map[? "udplrg_msg_id"],
				true,
				_udplrg_id,
				_trk_map[? "udplrg_idx_sent"],
				_trk_map[? "udplrg_num"],
				_frag_size
			);
			
			udp_host_reliable_record(_client,_udpr_id,_frag_buffer,_frag_size);
			
			udp_send_packet(
				udp_host_socket,
				_client_map[? "ip"],
				_client_map[? "client_port"],
				_frag_buffer
			);
			
			// reset this clients keep alive packet send timer,
			// since we've just sent a packet
			_client_map[? "keep_alive_timer"] = udp_get_keep_alive_time();
			
			var _subtract = _frag_size -udp_header_size;
			
			_trk_map[? "data_remaining"] = (_trk_map[? "data_remaining"] -_subtract);
			
			_bytes_sent += _frag_size;
			_pkts_sent  += 1;
			
			if(_bytes_sent >= udplrg_max_bytes_per_frame
			|| _pkts_sent  >= udplrg_max_packets_per_frame){
				/*if(_bytes_sent >= udplrg_max_bytes_per_frame)
					show_debug_message("exceeded bytes per frame");
				if(_pkts_sent  >= udplrg_max_packets_per_frame)
					show_debug_message("exceeded packets per frame");*/
				break;
			}
		}
		
		if(_bytes_sent >= udplrg_max_bytes_per_frame
		|| _pkts_sent  >= udplrg_max_packets_per_frame)
			break;
	}
	
	if(_bytes_sent >= udplrg_max_bytes_per_frame
	|| _pkts_sent  >= udplrg_max_packets_per_frame)
		break;
}

/*if(_bytes_sent > 0)
		show_debug_message("*^&$# "+string(get_timer()-_base_microseconds)+" elapsed"
		+" packets sent "+string(_pkts_sent)+" bytes sent "+string(_bytes_sent)
	);*/