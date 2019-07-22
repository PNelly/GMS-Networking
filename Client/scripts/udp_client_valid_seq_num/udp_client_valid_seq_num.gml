/// @description  udp_client_valid_seq_num(message_id,sequence_number)

// determines whether this is a new packet for the given message
// or a packet that has arrived out of order

// if it is a new message then sequence number will be updated

// if gap is sufficienty large indicates that sequence number
// counter on sender has overflowed

var _msg_id     = argument0;
var _new_sqn    = argument1;

var _map        = udp_seq_num_rcvd_map;

if(!ds_map_exists(_map,_msg_id))
    return false;

var _old_sqn    = _map[? _msg_id];

var _diff       = _new_sqn -_old_sqn;

var _cond1      = (_diff > 0);
var _cond2      = false;

if( (_diff < 0) && (abs(_diff) > unsigned_32_max/2))
    _cond2      = true;

/*show_debug_message("clnt sqn check, msg_id "+string(_msg_id)+" old "
    +string(_old_sqn)+" new "+string(_new_sqn)+" diff "+string(_diff)
    +" cond1 "+string(_cond1)+" cond2 "+string(_cond2));*/
    
if(_cond1 || _cond2){
    _map[? _msg_id] = _new_sqn;
    return true;
} else {
    return false;
}
