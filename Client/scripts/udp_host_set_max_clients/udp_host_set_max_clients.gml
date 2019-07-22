/// @description  udp_host_set_max_clients(num_clients)

// change the amount of clients allowed and disconnect any extras

if(udp_state != udp_states.udp_host_lobby) exit;

var _new_num = argument0;
var _old_num = udp_max_clients;

if(_new_num <= 0) exit;

if(_new_num > udp_max_clients_cap)
    udp_max_clients = udp_max_clients_cap;
else if(_new_num > 0 && _new_num <= udp_max_clients_cap)
    udp_max_clients = _new_num;

// TODO: Communicate this change to the server

if(_new_num < ds_list_size(udp_client_list)){

    var _client, _map;
    var _idx;
    
    while( ds_list_size(udp_client_list) > _new_num){
    
        _client = udp_client_list[| ds_list_size(udp_client_list)-1];
        _map    = udp_client_maps[? _client];
        
        udp_host_disconnect_client(_client);
    
    }
    
    udp_host_refresh_lobby();

}

if(_new_num != _old_num)
    udp_host_update_rendevouz();
