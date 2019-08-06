/// @description  udp_host_reliable_acknowledged(client_id,packet_id)

// removes this packet from sent list and sent map
// freeing up id and preventing extra sends

var _client_id = argument0;
var _packet_id = argument1;

/*show_debug_message("starting reliable acknowledge, client: "+string(_client_id)+" packet: "+string(_packet_id));
var _idx;
for(_idx=0;_idx<ds_list_size(udp_client_list);_idx++){
    show_debug_message("clients present: "+string(udp_client_list[| _idx]));
}*/

if(!ds_map_exists(udp_client_maps,_client_id)){
    show_debug_message("invalid client in udp_host_reliable_ack: "+string(_client_id));
    exit;
}


var _client_map     = udp_client_maps[? _client_id];
var _udpr_sent_list = _client_map[? "udpr_sent_list"];
var _udpr_sent_maps = _client_map[? "udpr_sent_maps"];
var _map            = _udpr_sent_maps[? _packet_id];

/*show_debug_message("is_undf udp_client_maps[? _client_id]: "
    +string(is_undefined(udp_client_maps[? _client_id]))
    +" is_undf _client_map[? 'udpr_sent_list']: "
    +string(is_undefined(_client_map[? "udpr_sent_list"]))
    +" in_undf _client_map[? 'udpr_sent_maps']: "
    +string(is_undefined(_client_map[? "udpr_sent_maps"]))
    +" _udpr_sent_maps[? _packet_id]: "
    +string(is_undefined(_udpr_sent_maps[? _packet_id])));*/

// if map is undefined it means this packet has already been acknowledged
if(is_undefined(_map)){
    show_debug_message("udp host received redundant ack of udpr: "+string(_packet_id)+" from client: "+string(_client_id));
    exit;
}

var _udp_dlvry_hooks_map  = _client_map[? "udp_dlvry_hooks_map"];
var _udp_dlvry_hooks_list = _client_map[? "udp_dlvry_hooks_list"];
var _hook_map;

//show_debug_message("udp host received new ack of udpr: "+string(_packet_id)+" from client: "+string(_client_id));

var _store_buffer = _map[? "buffer"];
buffer_delete(_store_buffer);

ds_map_clear(_map);
ds_map_destroy(_map);
ds_map_delete(_udpr_sent_maps,_packet_id);

ds_list_delete(_udpr_sent_list, ds_list_find_index(_udpr_sent_list,_packet_id));

// check if delivery hook exists for this single packet
var _key = "udpr_id_"+string(_packet_id);

if(ds_map_exists(_udp_dlvry_hooks_map,_key)){
	_hook_map = _udp_dlvry_hooks_map[? _key];
	udp_delivery_hook(
		_hook_map,
		_key,
		_udp_dlvry_hooks_map,
		_udp_dlvry_hooks_list
	);
}

	// ## manage tracking of large packet receipts ## //

var _udplrg_sent_list		= _client_map[? "udplrg_sent_list"];
var _udplrg_sent_map		= _client_map[? "udplrg_sent_map"];
var _udplrg_sent_udpr_map	= _client_map[? "udplrg_sent_udpr_map"];

// reliable packets will only sometimes map to large packet transmissions
if(!ds_map_exists(_udplrg_sent_udpr_map,_packet_id))
	exit;
	
var _udplrg_id	= _udplrg_sent_udpr_map[? _packet_id];
var _trk_map	= _udplrg_sent_map[? _udplrg_id];
var _pkt_list	= _trk_map[? "udpr_list"];

//show_debug_message("removed pkt "+string(_packet_id)+" from lrg pkt tracking "+string(_udplrg_id));

// record delivery of this packet by removing it from list of fragments to deliver
ds_list_delete(
	_pkt_list,
	ds_list_find_index(
		_pkt_list,
		_packet_id
	)
);

ds_map_delete(_udplrg_sent_udpr_map,_packet_id);

// update delivery progress
var _udplrg_num = _trk_map[? "udplrg_num"];
var _delivered  = _udplrg_num -ds_list_size(_pkt_list);

_trk_map[? "udplrg_progress"] = _delivered / _udplrg_num;

//show_debug_message("udplrg id "+string(_udplrg_id)+" progress "+string(_trk_map[? "udplrg_progress"]));

// check if delivery completed
if(ds_list_empty(_pkt_list)){

	show_debug_message("host confirmed receipt of udplrg id "+string(_udplrg_id));
	_trk_map[? "udplrg_received"] = true;
	
	ds_list_destroy(_pkt_list);
	ds_map_destroy(_trk_map);
	ds_map_delete(_udplrg_sent_map, _udplrg_id);
	ds_list_delete(
		_udplrg_sent_list,
		ds_list_find_index(
			_udplrg_sent_list,
			_udplrg_id
		)
	);
	
	// check if delivery hook exists for this large packet
	var _key = "udplrg_id_"+string(_udplrg_id);
	
	if(ds_map_exists(_udp_dlvry_hooks_map,_key)){
		_hook_map = _udp_dlvry_hooks_map[? _key];
		udp_delivery_hook(
			_hook_map,
			_key,
			_udp_dlvry_hooks_map,
			_udp_dlvry_hooks_list
		);
	}
}