/// @description  rdvz_client_send(is_udp, message_id, buffer)

// send a packet from rendevouz client to the rendevouz server

var _is_udp     = argument0;
var _msg_id     = argument1;
var _buffer     = argument2;

rdvz_client_write_header(_is_udp,_msg_id,_buffer);

if(!_is_udp)
    tcp_send_packet(rdvz_client_socket,_buffer);
else {
        
    if(rendevouz_state == rdvz_states.rdvz_host_pinging_udp){
        if(_msg_id == rdvz_msg.rdvz_udp_ping_host_w_host_socket)
            udp_send_packet(udp_host_socket,rendevouz_ip,rendevouz_udp_port,_buffer);
        else if (_msg_id == rdvz_msg.rdvz_udp_ping_host_w_client_socket)
            udp_send_packet(udp_client_socket,rendevouz_ip,rendevouz_udp_port,_buffer);
    }
    
    if(rendevouz_state == rdvz_states.rdvz_join_pinging_udp){
        if(_msg_id == rdvz_msg.rdvz_udp_ping_client_w_host_socket)
            udp_send_packet(udp_host_socket,rendevouz_ip,rendevouz_udp_port,_buffer);
        else if (_msg_id == rdvz_msg.rdvz_udp_ping_client_w_client_socket)
            udp_send_packet(udp_client_socket,rendevouz_ip,rendevouz_udp_port,_buffer);
    }
}
