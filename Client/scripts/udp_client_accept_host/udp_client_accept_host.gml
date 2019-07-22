/// @description  udp_client_accept_host(ip, port)

// received hole punch or keep alive packet from host
// that is not yet in stable host variables
// evaluate and move

var _ip     = argument0;
var _port   = argument1;

if(rendevouz_state != rdvz_states.rdvz_join_hole_punching)
    exit;

if(_ip != udp_host_to_join_ip || _port != udp_host_to_join_port)
    exit; // unrecognized sender

show_debug_message("UDP CLIENT ACCEPT HOST");

udp_state               = udp_states.udp_client_lobby;
udp_host_ip             = udp_host_to_join_ip;
udp_client_host_port    = udp_host_to_join_port;
udp_host_to_join_ip     = "";
udp_host_to_join_port   = -1;

udp_client_init_timers();

// give username to host
buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,network_username);
udp_client_send(udp_msg.udp_username,true,message_buffer);

// share public facing connection info
udp_client_share_connection_params();

// discnnect from rdvz server
rdvz_disconnect();
