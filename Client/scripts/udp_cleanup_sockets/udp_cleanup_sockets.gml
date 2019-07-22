/// @description  udp_cleanup_play_sockets()

// shutdown host and client udp socket

if(udp_client_socket >= 0){
    network_destroy(udp_client_socket);
    udp_client_socket = -1;
}

if(udp_host_socket >= 0){
    network_destroy(udp_host_socket);
    udp_host_socket = -1;
}

if(broadcast_socket >= 0){
    network_destroy(broadcast_socket);
    broadcast_socket = -1;
}
