/// @description  udp_host_game_end()

// begin moving everyone to intermediate end state and postgame state

udp_host_send_all(udp_msg.udp_game_end,true,message_buffer);
udp_state = udp_states.udp_host_game_ending;
udp_host_game_in_progress = false;

// update rdvz server if necessary
if(udp_host_allow_join_in_progress
&& ds_list_size(udp_client_list) < udp_max_clients)
    udp_host_update_rendevouz();

system_message_set("Ending Game");
show_debug_message("Ending Game");
