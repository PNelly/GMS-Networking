/// @description udp_client_reset_timeout()

if(!udp_is_client()) exit;

udp_connection_timer = udp_connection_timeout;