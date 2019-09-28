/// @description  udp_host_share_connection_params()

// distribute public facing connection info of all clients to all clients

if(udp_is_host()){

    var _num_clients = ds_list_size(udp_client_list);
    var _num_entries = _num_clients + 1;
    
    var _client_id, _client_map;
    var _public_ip, _public_host_port, _public_client_port;
    var _idx;
    
    buffer_seek(message_buffer,buffer_seek_start,udp_header_size);

    buffer_write(message_buffer,buffer_u8,_num_entries);
    
    buffer_write(message_buffer,buffer_s32,udp_id);
    buffer_write(message_buffer,buffer_string,udp_public_ip);
    buffer_write(message_buffer,buffer_s32,udp_public_host_port);
    buffer_write(message_buffer,buffer_s32,udp_public_client_port);
    
    for(_idx=0;_idx<_num_clients;++_idx){
    
        _client_id  = udp_client_list[| _idx];
        _client_map = udp_client_maps[? _client_id];
        
        _public_ip          = _client_map[? "public_ip"];
        _public_host_port   = _client_map[? "public_host_port"];
        _public_client_port = _client_map[? "public_client_port"];
        
        buffer_write(message_buffer,buffer_s32,_client_id);
        buffer_write(message_buffer,buffer_string,_public_ip);
        buffer_write(message_buffer,buffer_s32,_public_host_port);
        buffer_write(message_buffer,buffer_s32,_public_client_port);
    }
    
    udp_host_send_all(udp_msg.udp_connection_params,true,message_buffer,true);
}
