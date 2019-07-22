/// @description  udp_host_send_disconnect_notice(client_id)

// sends packet with disconnect notice to client

var _client = argument0;

udp_host_send(_client,udp_msg.udp_disconnect_instruction,false,message_buffer);
