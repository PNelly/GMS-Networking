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
		
		while(!ds_list_empty(_pkt_list)){
		
			var _pos		= 0;
			var _udplrg_idx = _pkt_list[| _pos];
			var _buff		= _pkt_map[? _udplrg_idx];
			
			buffer_delete( _buff);
			ds_map_delete( _pkt_map,_udplrg_idx);
			ds_list_delete(_pkt_list,_pos);
			
			//show_debug_message("deleted idx "+string(_udplrg_idx)+" for lrgpkt id "+string(_udplrg_id));
		}
		
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

// sent large packets, need to clear nested lists

var _udplrg_sent_map	= _client_map[? "udplrg_sent_map"];
var _udplrg_sent_list	= _client_map[? "udplrg_sent_list"];

for(_idx=0;_idx<ds_list_size(_udplrg_sent_list);++_idx){

	var _udplrg_id	= _udplrg_sent_list[| _idx];
	var _trk_map	= _udplrg_sent_map[? _udplrg_id];

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
			
		ds_list_delete(_udplrg_sent_list,_idx);
		ds_map_destroy(_trk_map);
		ds_map_delete(_udplrg_sent_map,_udplrg_id);
		
		--_idx;
		
		show_debug_message("removed");
	}
}