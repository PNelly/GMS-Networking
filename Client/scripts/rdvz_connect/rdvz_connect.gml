/// @description  rdvz_connect()

// attempt to connect to the rendevouz server

if(rendevouz_state == rdvz_states.rdvz_none || rendevouz_state == rdvz_states.rdvz_reconnect){

    system_message_set("attempting to connect");
    
    // ensure udp setup correctly before connecting
    var _udp_result = false;
    
    if(!udp_sockets_initialized()){
        _udp_result = udp_create_sockets();
    } else {
        _udp_result = true;
    }
    
    if(!_udp_result){
        show_debug_message("udp setup failed, aborting rendevouz connect");
        exit;
    }

    // attempt rendevouz connect
    if(rdvz_client_socket >= 0){
        network_destroy(rdvz_client_socket);
        rdvz_client_socket = -1;
    }
    
    var _attempts = 0;
    var _max_attempts = 10;
    
    while(rdvz_client_socket < 0 && _attempts < _max_attempts){
        rdvz_client_port = irandom_range(non_broadcast_min,non_broadcast_max)
        rdvz_client_socket = network_create_socket_ext(network_socket_tcp,rdvz_client_port);
        _attempts++;
    }
    
    if(_attempts == _max_attempts && rdvz_client_socket < 0)
        show_debug_message("failed to create a socket");
    if(rdvz_client_socket >= 0)
        show_debug_message("created socket "+string(rdvz_client_socket)+" on port: "+string(rdvz_client_port));
    
        
    var _rdvz_result = -1;
    _attempts = 0;
    while(_rdvz_result < 0 && _attempts < _max_attempts){
        _rdvz_result = network_connect(rdvz_client_socket,rendevouz_ip,rendevouz_tcp_port);
        _attempts++;
    }
    
    if(_attempts == _max_attempts && _rdvz_result < 0){
        show_debug_message("failed to connect to rendevouz server");
        system_message_set("failed to connect");
        rdvz_disconnect(); // reset variables
    }
        
    if(_udp_result && _rdvz_result >= 0){
        rendevouz_state = rdvz_states.rdvz_idle;
        rdvz_connection_timer = rdvz_connection_timeout;
        rdvz_keep_alive_timer = rdvz_keep_alive_interval;
        lan_broadcast_timer = lan_broadcast_delay;
        show_debug_message("connected to rendevouz server");
        system_message_set("connected to rendevouz server");
        
        return true;
        
        // ???
        exit; // don't want to trigger join code block (rdvz state coincidence)
    }
    
    return false;
}
