/// @description  udp_host_manage_client_game_inits(sender_udp_id)

// update client that finished game init, then
// review whether all clients are prepared to move into the game
// if they are, then move into the game

var _sender_udp_id = argument0;
var _map;

if(ds_map_exists(udp_client_maps,_sender_udp_id)){
    _map = udp_client_maps[? _sender_udp_id];
    _map[? "game_init_complete"] = true;
} else {
    exit;
}

var _num_clients = ds_list_size(udp_client_list);
var _idx, _client, _initd;

for(_idx=0;_idx<_num_clients;_idx++){
    _client = udp_client_list[| _idx];
    _map    = udp_client_maps[? _client];
    _initd  = _map[? "game_init_complete"];
    
    if(!_initd) exit;
}

// Once everyone's initialized tell them to advance into the game
udp_host_send_all(udp_msg.udp_game_start,true,message_buffer);
udp_host_game_start();
