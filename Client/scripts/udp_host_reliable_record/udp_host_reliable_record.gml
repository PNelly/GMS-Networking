/// @description  udp_host_reliable_record(client_id,packet_id,buffer)

var _client_id	= argument0;
var _packet_id	= argument1;
var _buffer		= argument2;
var _size		= argument3;

var _client_map     = udp_client_maps[? _client_id];
var _packet_list    = _client_map[? "udpr_sent_list"];
var _packet_maps    = _client_map[? "udpr_sent_maps"];
var _ping           = _client_map[? "ping"];

var _store_buffer = buffer_create(_size,buffer_fixed,1);

buffer_copy(_buffer,0,_size,_store_buffer,0);

var _this_packet_map			= ds_map_create();
_this_packet_map[? "id"]		= _packet_id;
_this_packet_map[? "buffer"]	= _store_buffer;

if(_ping > 0)
    _this_packet_map[? "resend_timer"] = ceil( _ping * udp_reliable_resend_factor );
if(_ping == 0)
    _this_packet_map[? "resend_timer"] = irandom(2 * udp_reliable_resend_default);
    
ds_list_add(_packet_list,_packet_id);
ds_map_add(_packet_maps,_packet_id,_this_packet_map);

//show_debug_message("host sent udpr: "+string(_packet_id)+" to client: "+string(_client_id));


