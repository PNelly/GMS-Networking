/// @description  udp_host_valid_seq_num(client,message_id,sequence_number)

// determines whether this is a new packet for the given message type
// or a packet that has arrived out of order

// if it is a new message then sequence number will be updated

// if sufficiently large gap indicates u32 sequence number
// has overflowed on sender side

var _client     = argument0;
var _msg_id     = argument1;
var _new_sqn    = argument2;

var _client_map = udp_client_maps[? _client];

if(!ds_map_exists(udp_client_maps,_client)){
    show_debug_message("&&& client absent "+string(_client)+" msg id "+string(_msg_id)+" sqn "+string(_new_sqn));
    show_message_async("&&& client absent "+string(_client)+" msg id "+string(_msg_id)+" sqn "+string(_new_sqn));
}
if(!ds_exists(_client_map,ds_type_map)){
    show_debug_message("&&& client map does not exist");
    show_message_async("&&& client map does not exist");
}
    
var _map        = _client_map[? "udp_seq_num_rcvd_map"];

var _old_sqn    = _map[? _msg_id];

var _diff       = _new_sqn -_old_sqn;

var _cond1      = (_diff > 0);
var _cond2      = false;

if( (_diff < 0) && (abs(_diff) > unsigned_32_max/2))
    _cond2      = true;
    
if(_msg_id == udp_msg.udp_ready)
    show_debug_message("udp ready, old sqn "+string(_old_sqn)+" new sqn "+string(_new_sqn)+" cond1 "+string(_cond1)+" cond2 "+string(_cond2));
    
if(_cond1 || _cond2){
    _map[? _msg_id] = _new_sqn;
    return true;
} else {
    return false;
}
