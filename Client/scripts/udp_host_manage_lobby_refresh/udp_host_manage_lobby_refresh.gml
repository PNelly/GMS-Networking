/// @description  udp_host_manage_lobby_refresh()

// decrement timer for periodic information refreshes to the clients in the
// udp session lobby

if(ds_list_size(udp_client_list) > 0){

    if(udp_host_lobby_refresh_timer >= 0)
        udp_host_lobby_refresh_timer--;
        
    if(udp_host_lobby_refresh_timer < 0){
        udp_host_refresh_lobby();
    }
}
