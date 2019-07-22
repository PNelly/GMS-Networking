/// @description  rdvz_client_manage_holepunch()

// send hole punch packets at desired UDP host to try and join session

if(udp_hole_punch_timer >= 0)
    --udp_hole_punch_timer;

show_debug_message("udp_hole_punch_timer: "+string(udp_hole_punch_timer)+" interval "+string(udp_hole_punch_interval));
show_debug_message("mod interval: "+string(udp_hole_punch_timer % udp_hole_punch_interval));
    
if(udp_hole_punch_timer > 0){
    if(udp_hole_punch_timer % udp_hole_punch_interval == 0){
        udp_client_write_header(message_buffer,udp_msg.udp_hole_punch,false);
        udp_send_packet(udp_client_socket,udp_host_to_join_ip,udp_host_to_join_port,message_buffer);
    }
} else {
    show_debug_message("client hole punch timeout");
    system_message_set("hole punch failed");
    udp_client_hole_punch_fail_reset();
}


/*if(udp_hole_punch_timer >= 0)
    udp_hole_punch_timer--;

if(udp_hole_punch_timer >= 0 
&&(udp_hole_punch_timer % udp_hole_punch_interval) == 0){
    udp_client_write_header(message_buffer,udp_msg.udp_hole_punch,false);
    udp_send_packet(udp_client_socket,udp_host_to_join_ip,udp_host_to_join_port,message_buffer);
} else { // hole punch timeout
    show_debug_message("client hole punch timeout");
    system_message_set("hole punch failed");
    udp_client_hole_punch_fail_reset();
}*/
