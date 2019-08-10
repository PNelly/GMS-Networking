/// @description  udp_client_reliable_received(packet_id,udplrg_id,udplrg_idx)

// documents receipt of this packet and sends acknowledgement to host
// if this packet has already been received resend acknowledgement

// returns true if packet already received and false if new packet

var _packet_id	= argument0;
var _udplrg_id	= argument1;
var _udplrg_idx = argument2;
var _redundant  = ds_map_exists(udpr_rcvd_map,_packet_id);

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);

buffer_write(message_buffer,buffer_u16,_packet_id);
buffer_write(message_buffer,buffer_u16,_udplrg_id);
buffer_write(message_buffer,buffer_u16,_udplrg_idx);

udp_client_send(udp_msg.udp_reliable_acknowledge,false,message_buffer,-1, true);

if(!_redundant){
	
	ds_list_add(udpr_rcvd_list,_packet_id);
	ds_map_add( udpr_rcvd_map, _packet_id, current_time);
}

return _redundant;