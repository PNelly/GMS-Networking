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
