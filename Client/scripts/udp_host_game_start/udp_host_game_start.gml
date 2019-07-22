/// @description  udp_host_game_start()

system_message_set("Starting Game");
udp_state = udp_states.udp_host_game;

// reset all client init flags
var _num_clients = ds_list_size(udp_client_list);
var _idx, _client, _map;

for(_idx=0;_idx<_num_clients;_idx++){
    _client = udp_client_list[| _idx];
    _map    = udp_client_maps[? _client];
    _map[? "game_init_complete"] = false;
}

// rest implementation specific
