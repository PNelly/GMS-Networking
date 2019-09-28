/// @description  udp_client_begin_game_init()

// setup implementation specific parameters that have to be decided
// before a game can start, then inform the host that process is complete

udp_state = udp_states.udp_client_game_init;
system_message_set("Game Initializing");

// by default, nothing to be done, and no information to add,
// so tell host that we're ready to move on

// include username so it doens't get lost with out of order packets
buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,network_username);
udp_client_send(udp_msg.udp_game_init_complete,true,message_buffer,-1,true);
