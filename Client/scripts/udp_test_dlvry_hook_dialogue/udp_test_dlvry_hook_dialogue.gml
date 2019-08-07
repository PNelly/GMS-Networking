/// @description udp_test_dlvry_hook_dialogue(string,time_start)

var _message	= argument0;
var _time_start = argument1;
var _time		= current_time -_time_start;

show_message_async(_message+" - delivered in "+string(_time)+" milliseconds");