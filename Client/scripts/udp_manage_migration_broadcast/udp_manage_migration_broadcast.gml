/// @description  udp_manage_migration_broadcast()

// share local port and ip information with session
// peers that may exist on the local network

var _send_broadcast = false;

if(udp_migration_broadcast_timer >= 0){
    --udp_migration_broadcast_timer;
    if(udp_migration_broadcast_timer < 0){
        _send_broadcast = true;
        udp_migration_broadcast_timer = udp_migration_broadcast_delay;
    }
}

if(!_send_broadcast) exit;

if(udp_is_host() || udp_is_client()){

    // difficult to untangle neatly consolidate broadcast code
    // so the four permutations are managed explicitly

    var _size, _port;
    
    if(udp_is_host()){
            
        // all clients will already have correct ip and port config
        // for host socket of session host - only client data required
            
        buffer_seek(message_buffer,buffer_seek_start, udp_header_size);
        buffer_write(message_buffer,buffer_string,udp_session_id);
        buffer_write(message_buffer,buffer_s32, udp_id);
        buffer_write(message_buffer,buffer_bool, udp_is_host());
        buffer_write(message_buffer,buffer_u16, udp_client_port);
        
        udp_host_write_header(
            message_buffer,
            udp_non_client_id,
            udp_msg.udp_migration_meta_client,
            false
        );
        
        _size = buffer_get_size(message_buffer);
        
        for(_port = broadcast_min; _port <= broadcast_max; ++_port)
            network_send_broadcast(udp_client_socket, _port, message_buffer, _size);
          
    } else if (udp_is_client()){
    
        buffer_seek(message_buffer,buffer_seek_start, udp_header_size);
        buffer_write(message_buffer,buffer_string,udp_session_id);
        buffer_write(message_buffer,buffer_s32, udp_id);
        buffer_write(message_buffer,buffer_bool, udp_is_host());
        buffer_write(message_buffer,buffer_u16, udp_host_socket_port);
        
        udp_client_write_header(
            message_buffer,
            udp_msg.udp_migration_meta_host,
            false
        );
        
        _size = buffer_get_size(message_buffer);
        
        for(_port = broadcast_min; _port <= broadcast_max; ++_port)
            network_send_broadcast(udp_host_socket, _port, message_buffer, _size);
            
        buffer_seek(message_buffer,buffer_seek_start, udp_header_size);
        buffer_write(message_buffer,buffer_string,udp_session_id);
        buffer_write(message_buffer,buffer_s32, udp_id);
        buffer_write(message_buffer,buffer_bool, udp_is_host());
        buffer_write(message_buffer,buffer_u16, udp_client_port);
        
        udp_client_write_header(
            message_buffer,
            udp_msg.udp_migration_meta_client,
            false
        );
        
        _size = buffer_get_size(message_buffer);
        
        for(_port = broadcast_min; _port <= broadcast_max; ++_port)
            network_send_broadcast(udp_client_socket, _port, message_buffer, _size);
    }
}
