/// udp_delivery_hook(hook_map,key,udp_hooks_map,udp_hooks_list)

// execute delivery hook as recorded when associated message was sent

var _hook_map		= argument0;
var _key			= argument1;
var _udp_hooks_map	= argument2;
var _udp_hooks_list = argument3;

var _script			= _hook_map[? "script"];
var _arguments		= _hook_map[? "arguments"];
var _m				= _hook_map;

show_debug_message("### udp delivery hook ###");
show_debug_message("script: "+string(_script)+" "+string(_arguments));

switch(_arguments){

	case 0:
		script_execute(_script);
	break;
	
	case 1:
		script_execute(_script,_m[? 0]);
	break;
	
	case 2:
		script_execute(_script,_m[? 0],_m[? 1]);
	break;
	
	case 3:
		script_execute(_script,_m[? 0],_m[? 1],_m[? 2]);
	break;
	
	case 4:
		script_execute(_script,_m[? 0],_m[? 1],_m[? 2],_m[? 3]);
	break;
	
	case 5:
		script_execute(_script,_m[? 0],_m[? 1],_m[? 2],_m[? 3],_m[? 4]);
	break;
	
	case 6:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[? 2], _m[? 3], 
			_m[? 4], _m[? 5]
		);
	break;
	
	case 7:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[? 2], _m[? 3],
			_m[? 4], _m[? 5], _m[? 6]
		);
	break;
	
	case 8:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[? 2], _m[? 3],
			_m[? 4], _m[? 5], _m[? 6], _m[? 7]
		);
	break;
	
	case 9:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[? 2], _m[? 3], 
			_m[? 4], _m[? 5], _m[? 6], _m[? 7], 
			_m[? 8]
		);
	break;
	
	case 10:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[? 2], _m[? 3], 
			_m[? 4], _m[? 5], _m[? 6], _m[? 7], 
			_m[? 8], _m[? 9]
		);
	break;
	
	case 11:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[?  2], _m[? 3],
			_m[? 4], _m[? 5], _m[?  6], _m[? 7],
			_m[? 8], _m[? 9], _m[? 10]
		);
	break;
	
	case 12:
		script_execute(_script,
			_m[? 0], _m[? 1], _m[?  2], _m[?  3],
			_m[? 4], _m[? 5], _m[?  6], _m[?  7],
			_m[? 8], _m[? 9], _m[? 10], _m[? 11]
		);
	break;
	
	case 13:
		script_execute(_script,
			_m[?  0], _m[? 1], _m[?  2], _m[?  3],
			_m[?  4], _m[? 5], _m[?  6], _m[?  7],
			_m[?  8], _m[? 9], _m[? 10], _m[? 11],
			_m[? 12]
		);
	break;
	
	case 14:
		script_execute(_script,
			_m[?  0], _m[?  1], _m[?  2], _m[?  3],
			_m[?  4], _m[?  5], _m[?  6], _m[?  7],
			_m[?  8], _m[?  9], _m[? 10], _m[? 11],
			_m[? 12], _m[? 13]
		);
	break;
	
	case 15:
		script_execute(_script,
			_m[?  0], _m[?  1], _m[?  2], _m[?  3],
			_m[?  4], _m[?  5], _m[?  6], _m[?  7],
			_m[?  8], _m[?  9], _m[? 10], _m[? 11],
			_m[? 12], _m[? 13], _m[? 14]
		);
	break;
	
	case 16:
		script_execute(_script,
			_m[?  0], _m[?  1], _m[?  2], _m[?  3],
			_m[?  4], _m[?  5], _m[?  6], _m[?  7],
			_m[?  8], _m[?  9], _m[? 10], _m[? 11],
			_m[? 12], _m[? 13], _m[? 14], _m[? 15]
		);
	break;
}

// clean up
ds_map_destroy(_hook_map);
ds_map_delete(_udp_hooks_map,_key);
ds_list_delete(
	_udp_hooks_list,
	ds_list_find_index(
		_udp_hooks_list,
		_key
	)
);