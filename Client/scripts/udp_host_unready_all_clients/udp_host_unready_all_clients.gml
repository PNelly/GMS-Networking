/// @description  udp_host_unready_all_clients()

// helper method for resetting ready status in lobby

if(!udp_is_host()) exit;

var _idx, _client, _map;
var _num_clients = ds_list_size(udp_client_list);

for(_idx=0;_idx<_num_clients;++_idx){

    _client = udp_client_list[| _idx];
    _map    = udp_client_maps[? _client];
    
    _map[? "ready"] = false;
}

udp_host_send_all(udp_msg.udp_host_unready_all,true,message_buffer);
