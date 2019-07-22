/// @description  udp_client_reliable_received(packet_id)

// documents receipt of this packet and sends acknowledgement to host
// if this packet has already been received resend acknowledgement

// returns true if packet already received and false if new packet

var _packet_id = argument0;



if( ds_map_exists(udpr_rcvd_map,_packet_id)){

    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_u16,_packet_id);
    udp_client_send(udp_msg.udp_reliable_acknowledge,false,message_buffer);
    
    //show_debug_message("client redundant receipt of udpr: "+string(_packet_id));
    
    return true;

} else {

    ds_list_add(udpr_rcvd_list,_packet_id);
    ds_map_add(udpr_rcvd_map,_packet_id,current_time);
    
    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_u16,_packet_id);
    udp_client_send(udp_msg.udp_reliable_acknowledge,false,message_buffer);
    
    //show_debug_message("client new receipt of udpr: "+string(_packet_id));
    
    return false;

}
