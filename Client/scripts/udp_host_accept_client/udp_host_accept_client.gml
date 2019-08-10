/// @description  udp_host_accept_client(ip from, port from)

// received hole punch or keep alive packet from a client
// which may not be 'permanent' yet
// evaluate and move if necessary

// returns whether the sender was an expected joiner

var _ip     = argument0;
var _port   = argument1;

var _key, _map, _client_ip, _client_port;
var _new_id, _new_client_map;

var _idx;

show_debug_message("UDP HOST ACCEPT CLIENT");

for(_idx=0;_idx<ds_list_size(udp_hole_punch_list);_idx++){

    _key = udp_hole_punch_list[| _idx];
    
    // Continue if this client exists in the hole punch structures
    if(ds_map_exists(udp_hole_punch_maps,_key)){
    
        _map = udp_hole_punch_maps[? _key];
        _client_ip = _map[? "ip"];
        _client_port = _map[? "client_port"];
        
        // Verify match
        if(_client_ip == _ip && _client_port == _port){
            
            _new_id = udp_host_get_unique_client_id();
            ds_list_add(udp_client_list,_new_id);
            var _new_client_map = ds_map_create();
            udp_client_maps[? _new_id] = _new_client_map;
            
            udp_host_init_client(
                _new_id,
                _new_client_map, 
                _ip, 
                _port, 
                ""
            );
            
            show_debug_message("new client assigned id of: "+string(_new_id));
            
            // remove the client from the hole punch structures
            ds_map_clear(_map) 
            ds_map_destroy(_map);
            ds_map_delete(udp_hole_punch_maps,_key);
            ds_list_delete(udp_hole_punch_list,ds_list_find_index(udp_hole_punch_list,_key));
            
            // send new client its id
            buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
            buffer_write(message_buffer,buffer_u16,_new_id);
            udp_host_send(_new_id,udp_msg.udp_tell_client_id,true,message_buffer,-1,true);
                                    
            // inform rendevouz server about num clients
            if(rendevouz_state == rdvz_states.rdvz_host)
                udp_host_update_rendevouz();
            
            // inform clients of new arrival
            if(udp_state == udp_states.udp_host_lobby)
                udp_host_refresh_lobby();
                 
            if(udp_state == udp_states.udp_host_game){
                udp_host_client_join_in_progress(_new_id);
                
                // drop rdvz server if clients maxed out
                if(ds_list_size(udp_client_list) == udp_max_clients)
                    rdvz_disconnect();
            }
            
            // terminate loop since we found what we were looking for
            return true;
        }
        
        return false;
    } else {
        return false;
    }
}
