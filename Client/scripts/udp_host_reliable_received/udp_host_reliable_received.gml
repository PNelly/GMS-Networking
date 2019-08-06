/// @description  udp_host_reliable_received(client_id,packet_id)

// documents receipt of this packet and sends acknowledgement to client
// if this packet has already been received resend acknowledgement

// returns true if packet already received and false if new packet

var _client_id = argument0;
var _packet_id = argument1;

var _client_map     = udp_client_maps[? _client_id];
var _rcvd_map       = _client_map[? "udpr_rcvd_map"];
var _rcvd_list      = _client_map[? "udpr_rcvd_list"];

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_u16,_packet_id);
udp_host_send(_client_id,udp_msg.udp_reliable_acknowledge,false,message_buffer,-1);

if(ds_map_exists(_rcvd_map,_packet_id)){

	return true;
	
} else {

	_rcvd_map[? _packet_id] = current_time;
	ds_list_add(_rcvd_list, _packet_id);
	
	return false;
}

/*if( ds_map_exists(_rcvd_map, _packet_id)){

    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_u16,_packet_id);
    udp_host_send(_client_id,udp_msg.udp_reliable_acknowledge,false,message_buffer,-1);
    
    //show_debug_message("host redundant receipt of udpr: "+string(_packet_id)+" from client: "+string(_client_id));
    
    return true;

} else {

    ds_map_add(_rcvd_map,_packet_id,current_time); // not going across network
    ds_list_add(_rcvd_list,_packet_id);
    
    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_u16,_packet_id);
    udp_host_send(_client_id,udp_msg.udp_reliable_acknowledge,false,message_buffer,-1);
    
    //show_debug_message("host new receipt of udpr: "+string(_packet_id)+" from client: "+string(_client_id));
    
    return false;

}*/
