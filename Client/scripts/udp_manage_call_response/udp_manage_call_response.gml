/// @description  udp_manage_call_response()

// maintain peer to peer connections between all players so that
// machines are ready in the event of a host migration

var _send_call = false;

if(udp_peer_call_timer >= 0){
    --udp_peer_call_timer;
    if(udp_peer_call_timer < 0){
        _send_call = true;
        udp_peer_call_timer = udp_peer_call_delay;
    }
}

if(!_send_call) exit;

if(udp_is_host() || udp_is_client){

    var _time_stamp = milliseconds_u32;

    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
    buffer_write(message_buffer,buffer_s32, udp_id);
    buffer_write(message_buffer,buffer_u32, _time_stamp);
    
    if(udp_is_host()){
    
        udp_host_write_header(
            message_buffer,
            udp_non_client_id,
            udp_msg.udp_peer_call,
            false
        );
    
    } else if (udp_is_client()){
    
        udp_client_write_header(
            message_buffer,
            udp_msg.udp_peer_call,
            false
        );
    }
    
    // clients will need to send to host separately
    
    if(udp_is_client()){
    
        udp_send_packet(
            udp_host_socket,
            udp_host_ip,
            udp_client_host_client_port,
            message_buffer
        );
            
        udp_client_host_call_response_stamp = _time_stamp;
        
        /*show_debug_message("client sent peer call to host at port "
            +string(udp_client_host_client_port)+" with stamp "
            +string(_time_stamp));*/
    }
    
    // client and host will rotate through full
    // list of session clients
    
    var _num_clients = ds_list_size(udp_client_list);
    var _idx, _client, _map, _ip, _port;
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];        
    
        if(udp_is_host() && _map[? "host_port"] > 0){
        
            // host distributes from client socket to
            // all peer host sockets
        
            udp_send_packet(
                udp_client_socket,
                _map[? "ip"], 
                _map[? "host_port"],
                message_buffer
            );
            
            _map[? "call_response_stamp"] = _time_stamp;
            
            /*show_debug_message("host sent peer call to "
                +string(_client)+" at port "
                +string(_map[? "host_port"])+" with stamp "
                +string(_time_stamp));*/
            
        } else if (udp_is_client() && _map[? "ip"] != ""){
            
            // don't send to self
            if(_client == udp_id)
                continue;
        
            if(_map[? "client_port"] > 0)
                udp_send_packet(
                    udp_host_socket,
                    _map[? "ip"],
                    _map[? "client_port"],
                    message_buffer
                );
                
            if(_map[? "host_port"] > 0)
                udp_send_packet(
                    udp_client_socket,
                    _map[? "ip"],
                    _map[? "host_port"],
                    message_buffer
                );
                
            _map[? "call_response_stamp" ] = _time_stamp;
            
            /*show_debug_message("client sent peer call to "
                +string(_client)+" at host port "
                +string(_map[? "host_port"])+" and client port "
                +string(_map[? "client_port"])+" with stamp "
                +string(_time_stamp));*/
        }
    }
}
