/// @description  udp_host_reliable_received(client_id,packet_id,udplrg_id,udplrg_idx)

// documents receipt of this packet and sends acknowledgement to client
// if this packet has already been received resend acknowledgement

// returns true if packet already received and false if new packet

var _client_id	= argument0;
var _packet_id	= argument1;
var _udplrg_id	= argument2;
var _udplrg_idx = argument3;

var _client_map     = udp_client_maps[? _client_id];
var _rcvd_map       = _client_map[? "udpr_rcvd_map"];
var _rcvd_list      = _client_map[? "udpr_rcvd_list"];

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);

buffer_write(message_buffer,buffer_u16,_packet_id);
buffer_write(message_buffer,buffer_u16,_udplrg_id);
buffer_write(message_buffer,buffer_u16,_udplrg_idx);

udp_host_send(_client_id,udp_msg.udp_reliable_acknowledge,false,message_buffer,-1);

if(ds_map_exists(_rcvd_map,_packet_id)){

	return true;
	
} else {

	_rcvd_map[? _packet_id] = current_time;
	ds_list_add(_rcvd_list, _packet_id);
	
	return false;
}