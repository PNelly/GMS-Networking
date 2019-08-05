/// @description  udp_client_reliable_acknowledged(packet_id)

// removes this packet from sent list and sent map
// freeing up id and preventing extra sends

var _packet_id  = argument0;
var _map        = udpr_sent_maps[? _packet_id];

// if map is undefined it means receipt of this packet
// has already been acknowledged

if(is_undefined(_map)){
	
    show_debug_message("client received redundant ack of udpr: "+string(_packet_id));
    exit;
}


show_debug_message("client received acknowledgement of reliable packet: "+string(_packet_id));

var _store_buffer = _map[? "buffer"];
buffer_delete(_store_buffer);

ds_map_clear(_map);
ds_map_destroy(_map);
ds_map_delete(udpr_sent_maps,_packet_id);

ds_list_delete(udpr_sent_list, ds_list_find_index( udpr_sent_list, _packet_id ));

// managing tracking of large packet receipts

// reliable packets will only sometimes map to large packet transmissions
if(!ds_map_exists(udplrg_sent_udpr_map,_packet_id))
	exit;

var _udplrg_id	= udplrg_sent_udpr_map[? _packet_id];
var _trk_map	= udplrg_sent_map[? _udplrg_id];
var _pkt_list	= _trk_map[? "udpr_list"];

show_debug_message("removed pkt "+string(_packet_id)+" from lrg pkt tracking "+string(_udplrg_id));

ds_list_delete(
	_pkt_list,
	ds_list_find_index(
		_pkt_list,
		_packet_id
	)
);

ds_map_delete(udplrg_sent_udpr_map,_packet_id);

if(ds_list_empty(_pkt_list)){

	show_debug_message("client confirmed receipt of udplrg id "+string(_udplrg_id));

	_trk_map[? "udplrg_received"] = true;
	
	ds_list_destroy(_pkt_list);
	ds_map_destroy(_trk_map);
	ds_map_delete(udplrg_sent_map,_udplrg_id);
	ds_list_delete(
		udplrg_sent_list,
		ds_list_find_index(
			udplrg_sent_list,
			_udplrg_id
		)
	);
}