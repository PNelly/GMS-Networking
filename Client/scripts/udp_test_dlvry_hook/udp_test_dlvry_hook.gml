/// udp_test_dlvry_hook()

// contrived scenario to test delivery and progress hook features

show_debug_message("&& Test Delivery Hook &&");

var _num_bytes		= 2000000;
var _bytes_written	= 0;
var _short_string	= "s";
var _hook_map_short, _hook_map_long;

if( (udp_is_host() && ds_list_size(udp_client_list) > 0) || udp_is_client() ){

	_hook_map_short = ds_map_create();
	
	_hook_map_short[? "script"]		= udp_test_dlvry_hook_dialogue;
	_hook_map_short[? "arguments"]	= 1;
	_hook_map_short[? 0]			= "short string delivery hook executed!";
	
	buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
	buffer_write(message_buffer,buffer_string,_short_string);
	
	if(udp_is_host())
		udp_host_send(
			udp_client_list[| 0],
			udp_msg.udp_dummy_message,
			true,
			message_buffer,
			_hook_map_short
		);
		
	if(udp_is_client())
		udp_client_send(
			udp_msg.udp_dummy_message,
			true,
			message_buffer,
			_hook_map_short
		);
		
	_hook_map_long = ds_map_create();
	
	_hook_map_long[? "script"]		= udp_test_dlvry_hook_dialogue;
	_hook_map_long[? "arguments"]	= 1;
	_hook_map_long[? 0]				= "long packet hook executed!";
	
	buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
	
	for(;_bytes_written<_num_bytes;++_bytes_written)
		buffer_write(message_buffer,buffer_u8,irandom(255));
	
	if(udp_is_host())
		debug_hook_test_trk_map = udp_host_send(
			udp_client_list[| 0],
			udp_msg.udp_dummy_message,
			true,
			message_buffer,
			_hook_map_long
		);
		
	if(udp_is_client())
		debug_hook_test_trk_map = udp_client_send(
			udp_msg.udp_dummy_message,
			true,
			message_buffer,
			_hook_map_long
		);
}