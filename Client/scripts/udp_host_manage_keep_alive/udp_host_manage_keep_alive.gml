/// @description  udp_host_manage_keep_alive()

// decrement each client's keep alive timer and send
// keep alive packet to any that hits -1

var _num_clients = ds_list_size(udp_client_list);
var _idx, _id, _map, _timer;

if(_num_clients > 0){
    for(_idx=0;_idx<_num_clients;_idx++){
        _id     = udp_client_list[| _idx];
        _map    = udp_client_maps[? _id];
        _map[? "keep_alive_timer"] = _map[? "keep_alive_timer"] -1;
        if(_map[? "keep_alive_timer"] < 0){
            _map[? "keep_alive_timer"] = udp_get_keep_alive_time();
            udp_host_send(_id,udp_msg.udp_keep_alive,false,message_buffer,-1);
        }        
    }    
}

/*
if(udp_keep_alive_timer >= 0)
    udp_keep_alive_timer--;

if(udp_keep_alive_timer < 0){
    udp_keep_alive_timer = irandom_range(udp_keep_alive_interval,udp_keep_alive_interval*2);
    
    var _num_clients = ds_list_size(udp_client_list);
    
    if(_num_clients > 0){
        udp_host_send_all(udp_msg.udp_keep_alive,false,message_buffer);
    }
        
}*/

