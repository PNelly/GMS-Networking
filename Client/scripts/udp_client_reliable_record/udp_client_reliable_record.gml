/// @description  udp_client_reliable_record(packet_id,buffer)

// adds packet properties to data structures and sets resend timer

var _packet_id = argument0;
var _msg_id    = argument1;
var _buffer    = argument2;

var _size = buffer_get_size(_buffer);
var _store_buffer = buffer_create( _size, buffer_fixed, 1);

buffer_copy(_buffer,0,_size,_store_buffer,0);

var _packet_map = ds_map_create();

_packet_map[? "id"]     = _packet_id;
_packet_map[? "msg_id"] = _msg_id;
_packet_map[? "buffer"] = _store_buffer;

if(udp_ping > 0)
    _packet_map[? "resend_timer"] = ceil( udp_ping * udp_reliable_resend_factor );
if(udp_ping == 0)
    _packet_map[? "resend_timer"] = udp_reliable_resend_default;

ds_list_add(udpr_sent_list,_packet_id);
ds_map_add(udpr_sent_maps,_packet_id,_packet_map);

show_debug_message("client documented sending of udpr: "+string(_packet_id));
