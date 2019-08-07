/// udp_host_lrgpkt_clean(client,retain_incomplete)

// deallocate large packet tracking memory for client

var _client				= argument0;
var _retain_incomplete	= argument1;

var _client_map			= udp_client_maps[? _client];

show_debug_message("== Host Large Packet Clean ==");

if(is_undefined(_client_map)) exit;

// received large packets

var _udplrg_rcvd_list		= _client_map[? "udplrg_rcvd_list"];
var _udplrg_rcvd_map		= _client_map[? "udplrg_rcvd_map"];

var _idx, _udplrg_id, _msg_map;

for(_idx=0;_idx<ds_list_size(_udplrg_rcvd_list);++_idx){

	_udplrg_id	= _udplrg_rcvd_list[| _idx];
	_msg_map	= _udplrg_rcvd_map[? _udplrg_id];
	
	var _complete	= _msg_map[? "udplrg_complete"];
	var _remove		= (_complete || !_retain_incomplete); 
	
	show_debug_message("remove: "+string(_remove)+" lrgid: "+string(_udplrg_id)+" for client "+string(_client));
	
	if(_remove){
	
		var _pkt_list = _msg_map[? "udplrg_pkt_list"];
		var _pkt_map  = _msg_map[? "udplrg_pkt_map"];
		
		var _pos = 0;
		
		for(;_pos<ds_list_size(_pkt_list);++_pos){
		
			var _udplrg_idx = _pkt_list[| _pos];
			var _buff		= _pkt_map[? _udplrg_idx];
			
			if(buffer_exists(_buff)){
				buffer_delete( _buff);
				//show_debug_message("%%% deleted idx "+string(_udplrg_idx)+" for lrgpkt id "+string(_udplrg_id));
			} else {
				show_debug_message("%%% _buff "+string(_buff)
					+" udplrg idx "+string(_udplrg_idx)
					+" udplrg id "+string(_udplrg_id)
				);
			}
		}
		
		ds_list_clear(_pkt_list);
		ds_map_clear( _pkt_map);
		
		// asm buffer may not exist if a packet was not assembled before clean script
		if(ds_map_exists(_msg_map,"udplrg_asm_buffer"))
			if(buffer_exists(_msg_map[? "udplrg_asm_buffer"]))
				buffer_delete(_msg_map[? "udplrg_asm_buffer"]);
		
		ds_map_destroy( _pkt_map);
		ds_list_destroy(_pkt_list);
		
		ds_map_delete( _udplrg_rcvd_map,_udplrg_id);
		ds_map_destroy(_msg_map);
		
		ds_list_delete(_udplrg_rcvd_list,_idx);
		--_idx;
		
		show_debug_message("deleted asm buffer and decremented loop counter");
	}
}

// outbound large packets

var _udplrg_outbound_map	= _client_map[? "udplrg_outbound_map"];
var _udplrg_outbound_list	= _client_map[? "udplrg_outbound_list"];

for(_idx=0;_idx<ds_list_size(_udplrg_outbound_list);++_idx){

	var _udplrg_id	= _udplrg_outbound_list[| _idx];
	var _trk_map	= _udplrg_outbound_map[? _udplrg_id];

	var _received	= _trk_map[? "udplrg_received"];
	var _remove		= (_received || !_retain_incomplete);
	
	show_debug_message("udplrg sent list idx "+string(_idx)
		+" id "+string(_udplrg_id)
		+" rcvd "+string(_received)
		+" remove "+string(_remove)
	);
	
	if(_remove){
	
		if(ds_exists(_trk_map[? "udplrg_cnf_list"],ds_type_list))
			ds_list_destroy(_trk_map[? "udplrg_cnf_list"]);
			
		if(buffer_exists(_trk_map[? "udplrg_buffer"]))
			buffer_delete(_trk_map[? "udplrg_buffer"]);
			
		ds_list_delete(_udplrg_outbound_list,_idx);
		ds_map_destroy(_trk_map);
		ds_map_delete(_udplrg_outbound_map,_udplrg_id);
		
		--_idx;
		
		show_debug_message("removed");
	}
}