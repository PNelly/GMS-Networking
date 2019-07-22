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

//show_debug_message("udp host received new ack of udpr: "+string(_packet_id)+" from client: "+string(_client_id));

var _store_buffer = _map[? "buffer"];
buffer_delete(_store_buffer);

ds_map_clear(_map);
ds_map_destroy(_map);
ds_map_delete(_udpr_sent_maps,_packet_id);

ds_list_delete(_udpr_sent_list, ds_list_find_index(_udpr_sent_list,_packet_id));


