/// @description  udp_host_send_all(message_id,use_reliable,buffer)

// send the same packet to all clients

var _msg_id         = argument0;
var _is_reliable    = argument1;
var _buffer         = argument2;

var _num_clients = ds_list_size(udp_client_list);
var _idx, _client;

for(_idx=0;_idx<_num_clients;++_idx){

	_client = udp_client_list[| _idx];
	
	udp_host_send(_client,_msg_id,_is_reliable,_buffer,-1);
}