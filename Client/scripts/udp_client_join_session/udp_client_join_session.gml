/// @description  udp_join_session(host_rendevouz_id)

// begins process of a udp client joining a udp game session

udp_host_to_join = -1;

if(rendevouz_id < 0 && rendevouz_state != rdvz_states.rdvz_none){

    show_debug_message("id got dropped, requesting new rdvz id");
    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
    rdvz_client_send(false,rdvz_msg.rdvz_request_id,message_buffer);
    exit;
}

if(rendevouz_state == rdvz_states.rdvz_idle && rendevouz_id >= 0){
    
    var _desired_host = argument0;

    // validate host and whether session does exist
    if(ds_map_exists(rdvz_client_maps,_desired_host)){
    
        udp_host_to_join        = _desired_host;
    
        var _map                = rdvz_client_maps[? udp_host_to_join];
        
        var _is_host            = _map[? "udp_is_host"];
        var _port               = _map[? "udp_host_port"];
        var _host_clients       = _map[? "udp_host_clients"];
        var _host_max_clients   = _map[? "udp_host_max_clients"];
    
        if(_is_host
        && _port >= ephemeral_min 
        && _port <= ephemeral_max 
        && _host_clients < _host_max_clients){
        
            show_debug_message("attempting to join udp host: "+string(udp_host_to_join));
            
            // inform server via tcp that this peer will be a new udp client
            rendevouz_state = rdvz_states.rdvz_join_init;
            buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
            rdvz_client_send(false,rdvz_msg.rdvz_new_udp_client,message_buffer);
            
        } else {
            var _note = "host "+string(_desired_host)+" did not qualify#";
            _note += "_is_host "+string(_is_host)+" _port "+string(_port)
                +" _host_clients "+string(_host_clients)
                +" _host_max_clients "+string(_host_max_clients);
            show_message_async(_note);
        }
    } else {
        show_message_async("host "+string(_desired_host)+" not present in maps");
        clear_input();
    }
}
