/// @description  udp_client_send(message_id,use_reliable,buffer)

// send udp message to the session host

var _msg_id         = argument0;
var _is_reliable    = argument1;
var _buffer         = argument2;

var _udpr_id;

_udpr_id = udp_client_write_header(_buffer,_msg_id,_is_reliable);
udp_send_packet(udp_client_socket,udp_host_ip,udp_client_host_port,_buffer);

if(_is_reliable)
    udp_client_reliable_record(_udpr_id,_msg_id,_buffer);
    
// reset keep alive sent timer, since we've just sent a packet
udp_keep_alive_timer = udp_get_keep_alive_time();

