/// @description  udp_host_manage_migration_order()

// compute order that udp clients will serve as backup hosts
// and share with all session members

if(udp_is_host()){

    var _compute = false;

    if(udp_host_migration_order_timer >= 0){
        --udp_host_migration_order_timer;
        if(udp_host_migration_order_timer < 0)
            _compute = true;
    }
    
    if(!_compute) exit;

    var _num_clients = ds_list_size(udp_client_list);
    
    if(_num_clients > 0){

        // assign host migration order to session clients
        // according to whether they're connected to all
        // peers and by ordinal average latency with peers
    
        var _remaining_clients = ds_list_create();
        
        ds_list_copy(_remaining_clients, udp_client_list);
        
        var _idx, _client, _map;
        var _compare_client, _compare_map, _num_gtr;
        var _sorted = 0;
        
        while(ds_list_size(_remaining_clients) > 0){
            
            _client = _remaining_clients[| 0];
            _map    = udp_client_maps[? _client];
            
            if(!_map[? "peer_connected"]){
            
                _map[? "migration_order"] = -1;
                ds_list_delete(_remaining_clients, 0);
                
                continue;
            }
            
            _num_gtr = 0;
            
            for(_idx=0;_idx<_num_clients;++_idx){
            
                _compare_client = udp_client_list[| _idx];
                _compare_map    = udp_client_maps[? _compare_client];
                
                if(_compare_map[? "peer_connected"]){
                    if(_map[? "peer_avg_ping"] > _compare_map[? "peer_avg_ping"])
                        ++_num_gtr;
                }
            }
            
            _map[? "migration_order"] = _sorted + _num_gtr;
            
            ds_list_delete(_remaining_clients, 0);
            
            ++_sorted;
            
            show_debug_message("### Assigned Client "+string(_client)
                +" With Avg Lat "+string(_map[? "peer_avg_ping"])
                +" Migration Order "+string(_map[? "migration_order"])
                +" ###");
        }
        
        ds_list_destroy(_remaining_clients);   
        
        // transmit migration order to session clients
        
        if(_sorted > 0){
        
            buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
            
            buffer_write(message_buffer, buffer_u8, _num_clients);
            
            for(_idx=0;_idx<_num_clients;++_idx){
            
                _client = udp_client_list[| _idx];
                _map    = udp_client_maps[? _client];
                
                buffer_write(message_buffer,buffer_s32, _client);
                buffer_write(message_buffer,buffer_s16, _map[? "migration_order"]);
            }
            
            udp_host_send_all(udp_msg.udp_migration_order, true, message_buffer);
        }
    }
}
