/// @description  udp_init_seq_numbers(seq_numbers_map)

// initializes all sequence number key value pairs to zero
// this will make first received packets valid

var _map    = argument0;
var _first  = udp_msg.udp_msg_enum_start;
var _last   = udp_msg.udp_msg_enum_end;

var _idx;

for(_idx =_first; _idx<=_last; _idx++){
    _map[? _idx] = 0;
}
