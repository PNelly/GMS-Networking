/// @description  udp_host_begin_game_init()

// check ready conditions and move everyone into game init state

if(udp_state != udp_states.udp_host_lobby) exit;

if(udp_host_enforce_ready_ups){

    var _num_clients = ds_list_size(udp_client_list);
    var _idx, _client, _map, _ready;
    
    for(_idx=0;_idx<_num_clients;_idx++){
        
        _client = udp_client_list[| _idx];
        _map    = udp_client_maps[? _client];
        _ready  = _map[? "ready"];
        
        if(!_ready) exit;
    
    }
}

// tell clients to advance to init stage
udp_host_send_all(udp_msg.udp_game_init,true,message_buffer);
udp_state = udp_states.udp_host_game_init;
udp_host_game_in_progress = true;
system_message_set("Game Initializing");
input_state = input_states.input_none;

// reset all client ready flags
for(_idx=0;_idx<_num_clients;_idx++){

    _client = udp_client_list[| _idx];
    _map    = udp_client_maps[? _client];
    _map[? "ready"] = false;
    
}

// drop or don't drop connection to rdvz server
if(!udp_host_allow_join_in_progress){
    rdvz_disconnect();
} else {
    if(ds_list_size(udp_client_list) == udp_max_clients){
        rdvz_disconnect();
    } else {
        udp_host_update_rendevouz();
    }
}

// setup implementation specifc parameters that need to be
// decided before a game can start - by default there are
// no such parameters and process can proceeed

// if no clients then move to game state
if(ds_list_size(udp_client_list) == 0)
    udp_host_game_start(); 
