/// udp_test_dlvry_hook()

// contrived scenario to test delivery and progress hook features

show_debug_message("&& Test Delivery Hook &&");

var _num_bytes		= 1000000;
var _bytes_written	= 0;
var _short_string	= "s";
var _hook_map_short, _hook_map_long;

if( (udp_is_host() && ds_list_size(udp_client_list) > 0) || udp_is_client() ){

	// short packet test //

	_hook_map_short = ds_map_create();
	
	_hook_map_short[? "script"]		= udp_test_dlvry_hook_dialogue;
	_hook_map_short[? "arguments"]	= 2;
	_hook_map_short[? 0]			= "short string delivery hook executed!";
	_hook_map_short[? 1]			= 0;
	
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
	
	// very long packet test //
	
	buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
	
	for(;_bytes_written<_num_bytes;++_bytes_written)
		buffer_write(message_buffer,buffer_u8,irandom(255));

	if(udp_is_host()){
		
		show_debug_message("== setting up large packets ==");
		show_debug_message("number of clients "+string(ds_list_size(udp_client_list)));
		
		var _idx = 0;
		
		for(;_idx<ds_list_size(udp_client_list);++_idx){
		
			var _client		= udp_client_list[| _idx];
			var _client_map = udp_client_maps[? _client];
			var _hook_map = ds_map_create();
			
			show_debug_message("idx "+string(_idx)
				+" client "+string(_client)
				+" client map "+string(_client_map)
			);
			
			_client_map[? "debug_hook_test_trk_map"] =
				udp_host_send(
					_client,
					udp_msg.udp_dummy_message,
					true,
					message_buffer,
					_hook_map
				);
			
			var _base_time = ds_map_find_value(
				_client_map[? "debug_hook_test_trk_map"],
				"time_start"
			);
			
			_hook_map[? "script"]		= udp_test_dlvry_hook_dialogue;
			_hook_map[? "arguments"]	= 2;
			_hook_map[? 0]				= "long pkt hook for client "+string(_client);
			_hook_map[? 1]				= _base_time;
		}
	}
		
	if(udp_is_client()){
		
		_hook_map_long = ds_map_create();
		
		debug_hook_test_trk_map = udp_client_send(
			udp_msg.udp_dummy_message,
			true,
			message_buffer,
			_hook_map_long
		);

		_hook_map_long[? "script"]		= udp_test_dlvry_hook_dialogue;
		_hook_map_long[? "arguments"]	= 2;
		_hook_map_long[? 0]				= "long packet hook executed!";
		_hook_map_long[? 1]				= debug_hook_test_trk_map[? "time_start"];
	}
}