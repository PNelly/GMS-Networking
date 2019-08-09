/// @description  udp_host_manage_holepunch()

// iterate through hole punch data structures and send hole punch packets
// to any new clients trying to join session

if(udp_host_game_in_progress && !udp_host_allow_join_in_progress)
    exit;

if(ds_list_size(udp_hole_punch_list) > 0){

    // Need to conform to expected header format
    udp_host_write_header(
		message_buffer,
		udp_non_client_id,
		udp_msg.udp_hole_punch,
		false,
		0, 1, 1,
		udp_header_size
	);
    
    var _key, _map, _ip, _port, _idx;
	
    for(_idx=0;_idx<ds_list_size(udp_hole_punch_list);_idx++){
		
        _key  = udp_hole_punch_list[| _idx];                             
        _map  = udp_hole_punch_maps[? _key];
        _ip   = _map[? "ip"];
        _port = _map[? "client_port"];
        _map[? "timeout"] = _map[? "timeout"] -1;
		
        if(_map[? "timeout"] >= 0){
			
            if(_map[? "timeout"] % udp_hole_punch_interval == 0)
                udp_send_packet(udp_host_socket,_ip,_port,message_buffer);
				
        } else { // hole punch timeout, remove this client from HP structures
			
            ds_map_destroy(_map);
            ds_map_delete(udp_hole_punch_maps,_key);
            ds_list_delete(udp_hole_punch_list, _idx);
            _idx--;
        }
    }
}
