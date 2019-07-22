/// @description  udp_host_disconnect_client(client_id)

// go through all the steps of removing a client from communications and
// data structures

if(!udp_is_host())
    exit;

var _client = argument0;

if(!ds_map_exists(udp_client_maps,_client)){
    show_debug_message("invalid client: "+string(_client)+" passed to udp_host_disconnect_client()");
    exit;
}

show_debug_message("disconnecting client "+string(_client));

udp_host_send_disconnect_notice(_client);
udp_host_cleanup_client_packets(_client);
udp_host_delete_client(_client);

if(rendevouz_state == rdvz_states.rdvz_host)
    udp_host_update_rendevouz();

// inform other clients of departure
udp_host_pass_disconnect(_client);
    
if(udp_state == udp_states.udp_host_lobby && ds_list_size(udp_client_list) > 0){
    udp_host_refresh_lobby();
}
