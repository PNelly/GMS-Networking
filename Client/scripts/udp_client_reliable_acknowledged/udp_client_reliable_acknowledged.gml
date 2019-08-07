/// @description  udp_client_reliable_acknowledged(packet_id,udplrg_id,udplrg_idx)

// removes this packet from sent list and sent map
// freeing up id and preventing extra sends

var _packet_id		= argument0;
var _udplrg_id		= argument1;
var _udplrg_idx		= argument2;
var _map			= udpr_sent_maps[? _packet_id];
var _hook_map;

// if map is undefined it means receipt of this packet
// has already been acknowledged

if(is_undefined(_map)){
	
    //show_debug_message("client received redundant ack of udpr: "+string(_packet_id));
    exit;
}


//show_debug_message("client received acknowledgement of reliable packet: "+string(_packet_id));

var _store_buffer = _map[? "buffer"];
buffer_delete(_store_buffer);

ds_map_clear(_map);
ds_map_destroy(_map);
ds_map_delete(udpr_sent_maps,_packet_id);

ds_list_delete(udpr_sent_list, ds_list_find_index( udpr_sent_list, _packet_id ));

// check if delivery hook exists for this single packet

var _key = "udpr_id_"+string(_packet_id);

if(ds_map_exists(udp_dlvry_hooks_map,_key)){
	_hook_map = udp_dlvry_hooks_map[? _key];
	udp_delivery_hook(
		_hook_map,
		_key,
		udp_dlvry_hooks_map,
		udp_dlvry_hooks_list
	);
}

	// ## managing tracking of large packet receipts ## //

if(!ds_map_exists(udplrg_outbound_map,_udplrg_id))
	exit;
	
var _trk_map	= udplrg_outbound_map[? _udplrg_id];
var _idx_list	= _trk_map[? "udplrg_cnf_list"];

// remove index from list of packets to be confirmed

ds_list_delete(
	_idx_list,
	ds_list_find_index(
		_idx_list,
		_udplrg_idx
	)
);

// update progress tracking

var _udplrg_num = _trk_map[? "udplrg_num"];
var _delivered  = _udplrg_num -ds_list_size(_idx_list)

_trk_map[? "udplrg_progress"] = _delivered / _udplrg_num;

// check if completed

if(ds_list_empty(_idx_list)){

	_trk_map[? "udplrg_received"] = true;
	
	// delivery action hook if applicable

	var _key = "udplrg_id_"+string(_udplrg_id);
	
	if(ds_map_exists(udp_dlvry_hooks_map,_key)){
		_hook_map = udp_dlvry_hooks_map[? _key];
		udp_delivery_hook(
			_hook_map,
			_key,
			udp_dlvry_hooks_map,
			udp_dlvry_hooks_list
		);
	}	
	
	// clean up
	
	ds_list_destroy(_idx_list);
	if(buffer_exists(_trk_map[? "udplrg_buffer"]))
		buffer_delete(_trk_map[? "udplrg_buffer"]);
	ds_map_destroy(_trk_map);
	ds_map_delete(udplrg_outbound_map,_udplrg_id);
	ds_list_delete(
		udplrg_outbound_list,
		ds_list_find_index(
			udplrg_outbound_list,
			_udplrg_id
		)
	);
}