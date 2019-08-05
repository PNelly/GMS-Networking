/// udp_client_lrgpkt_clean(retain_incomplete)

// deallocate large packet memory

var _retain_incomplete = argument0;

var _idx, _udplrg_id, _msg_map;

show_debug_message("== Client Large Packet Clean ==");

for(_idx=0;_idx<ds_list_size(udplrg_rcvd_list);++_idx){

	_udplrg_id	= udplrg_rcvd_list[| _idx];
	_msg_map	= udplrg_rcvd_map[? _udplrg_id];
	
	var _complete = _msg_map[? "udplrg_complete"];
	var _remove   = (_complete || !_retain_incomplete);
	
	show_debug_message("Remove: "+string(_remove)+" lrgid: "+string(_udplrg_id));
	
	if(_remove){
	
		var _pkt_list = _msg_map[? "udplrg_pkt_list"];
		var _pkt_map  = _msg_map[? "udplrg_pkt_map"];
		
		while(!ds_list_empty(_pkt_list)){
		
			var _pos		= 0;
			var _udplrg_idx = _pkt_list[| _pos];
			var _buff		= _pkt_map[? _udplrg_idx];
			
			buffer_delete(_buff);
			ds_map_delete(_pkt_map,_udplrg_idx);
			ds_list_delete(_pkt_list,_pos);
			
			show_debug_message("deleted idx "+string(_udplrg_idx)+" for lrgpkt id "+string(_udplrg_id));
		}
		
		buffer_delete(_msg_map[? "udplrg_asm_buffer"]);
		
		ds_map_destroy( _pkt_map);
		ds_list_destroy(_pkt_list);
		
		ds_map_delete(udplrg_rcvd_map,_udplrg_id);
		ds_map_destroy(_msg_map);
		
		ds_list_delete(udplrg_rcvd_list,_idx);
		--_idx;
		
		show_debug_message("deleted asm buffer and descrmented loop counter");
	}
}

// sent large packets, need to clear nested lists

for(_idx=0;_idx<ds_list_size(udplrg_sent_list);++_idx){

	var _udplrg_id	= udplrg_sent_list[| _idx];
	var _trk_map	= udplrg_sent_map[? _udplrg_id];
	
	var _received	= _trk_map[? "udplrg_received"];
	var _remove		= (_received || !_retain_incomplete);
	
	show_debug_message("udplrg sent list idx "+string(_idx)
		+" id "+string(_udplrg_id)
		+" rcvd "+string(_received)
		+" remove "+string(_remove)
	);
	
	if(_remove){
	
		if(ds_exists(_trk_map[? "udpr_list"],ds_type_list))
			ds_list_destroy(_trk_map[? "udpr_list"]);
			
		ds_list_delete(udplrg_sent_list,_idx);
		ds_map_destroy(_trk_map);
		ds_map_delete(udplrg_sent_map,_udplrg_id);
		
		--_idx;
		
		show_debug_message("removed");
	}
}