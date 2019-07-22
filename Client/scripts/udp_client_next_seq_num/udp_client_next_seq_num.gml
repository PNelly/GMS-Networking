/// @description  udp_client_next_seq_num(msg_id)

// increment sequence number for this message type and return

var _msg_id = argument0;

var _map = udp_seq_num_sent_map;

_map[? _msg_id] = _map[? _msg_id] +1;

return (_map[? _msg_id]);
