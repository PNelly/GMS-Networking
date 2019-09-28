/// @description  udp_host_send(client_id,message_id,use_reliable,buffer,delivery_hook,has_payload)

var _client			= argument0;
var _msg_id			= argument1;
var _is_reliable	= argument2;
var _buffer			= argument3;
var _hook			= argument4;
var _has_payload	= argument5;

// if no payload seek to header end to get correct buffer sizing

if(!_has_payload) buffer_seek(_buffer,buffer_seek_start,udp_header_size);

var _total_size		= buffer_tell(_buffer);

var _trk_map		= -1;
var _hook_key		= -1;
var _has_hook		= (
						ds_exists(_hook,ds_type_map)
						&& (
							_is_reliable
							|| (_total_size > udp_max_transmission_unit)
							)
					  );

if(!ds_map_exists(udp_client_maps,_client)) exit;

var _map    = udp_client_maps[? _client];
var _ip     = _map[? "ip"];
var _port   = _map[? "client_port"];

if(_total_size <= udp_max_transmission_unit){

	var _udpr_id = udp_host_write_header(
		_buffer,
		_client,
		_msg_id,
		_is_reliable,
		0, 1, 1,
		_total_size
	);

	if(_is_reliable)
	    udp_host_reliable_record(_client,_udpr_id,_buffer,_total_size);
		
	if(_has_hook)
		_hook_key = "udpr_id_"+string(_udpr_id);
    
	udp_send_packet(udp_host_socket,_ip,_port,_buffer);
	
	// reset this clients keep alive packet send timer,
	// since we've just sent a packet
	_map[? "keep_alive_timer"] = udp_get_keep_alive_time();
	
} else {

	// break message into chunks and queue for frame-metered delivery and reconstruction
	
	var _data_remaining = _total_size - udp_header_size;
	
	var _udplrg_id		= udp_host_next_lrgpkt_id(_client);
	var _udplrg_idx		= 1;
	var _udplrg_num		= (_data_remaining % udp_max_data_size == 0)
						? (_data_remaining / udp_max_data_size)
						: (1 + floor(_data_remaining / udp_max_data_size));

	// delivery action hook if applicable
	
	if(_has_hook)
		_hook_key = "udplrg_id_"+string(_udplrg_id);

	// state tracking for this large packet //
	
	var _udplrg_outbound_map	= _map[? "udplrg_outbound_map"];
	var _udplrg_outbound_list	= _map[? "udplrg_outbound_list"];
	
	var _udplrg_buffer	= buffer_create(_total_size,buffer_fixed,1);
	buffer_copy(_buffer,0,_total_size,_udplrg_buffer,0);
	
	_trk_map			= ds_map_create();
	
	ds_list_add(_udplrg_outbound_list, _udplrg_id);
	_udplrg_outbound_map[? _udplrg_id] = _trk_map;
	
	_trk_map[? "data_remaining"]	= _data_remaining;
	_trk_map[? "udplrg_msg_id"]		= _msg_id;
	_trk_map[? "udplrg_buffer"]		= _udplrg_buffer;
	_trk_map[? "udplrg_received"]	= false;
	_trk_map[? "udplrg_num"]		= _udplrg_num;
	_trk_map[? "udplrg_idx_sent"]	= _udplrg_idx;
	_trk_map[? "udplrg_cnf_list"]	= ds_list_create();
	_trk_map[? "udplrg_progress"]	= 0;
	_trk_map[? "time_start"]		= current_time;
	
	for(;_udplrg_idx<_udplrg_num;++_udplrg_idx)
		ds_list_add(_trk_map[? "udplrg_cnf_list"],_udplrg_idx);
}

// tag delivery hook
if(_has_hook){

	var _udp_dlvry_hooks_list	= _map[? "udp_dlvry_hooks_list"];
	var _udp_dlvry_hooks_map	= _map[? "udp_dlvry_hooks_map"];
	
	ds_list_add(_udp_dlvry_hooks_list,_hook_key);
	_udp_dlvry_hooks_map[? _hook_key] = _hook;
}

// return tracking map if applicable
if(_trk_map > 0)
	return _trk_map;