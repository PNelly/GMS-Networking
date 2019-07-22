/// @description  udp_host_next_seq_num(client_id,message_id)

// increment and return next sequence number for this message
// type and client

var _client = argument0;
var _msg_id = argument1;

// if given non client id then return placeholder value,
// placeholder usable for holepunch,
// placeholder overwritten in send all packets

if(_client == udp_non_client_id)
    return 0;

/*show_debug_message("udp_non_client_id NXT SQN, clnt "+string(_client)+
    " msg "+string(_msg_id));*/
    
var _client_map = udp_client_maps[? _client];
var _map        = _client_map[? "udp_seq_num_sent_map"];

_map[? _msg_id] = _map[? _msg_id] +1;

return (_map[? _msg_id]);
