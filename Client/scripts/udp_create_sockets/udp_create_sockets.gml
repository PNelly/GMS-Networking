/// @description  udp_create_sockets()

// initialize udp host, client, and broadcast sockets

// returns success / failure

var _attempts = 0;
var _max_attempts = 10;

udp_cleanup_sockets();

// client socket

while(udp_client_socket < 0 && _attempts < _max_attempts){
    do { udp_client_port = irandom_range(non_broadcast_min, non_broadcast_max); }
        until(  udp_client_port > 0
            &&  udp_client_port != rdvz_client_port
            &&  udp_client_port != udp_host_socket_port)
            
    udp_client_socket = network_create_socket_ext(network_socket_udp, udp_client_port);
    ++_attempts;
}

if(_attempts >= _max_attempts && udp_client_socket < 0){
    show_debug_message("failed to create udp client socket");
    udp_cleanup_sockets();
    return false;
}

if(udp_client_socket >= 0){
    show_debug_message("created client udp socket: "+string(udp_client_socket)+" on port "+string(udp_client_port));
}

// host socket

_attempts = 0;

while(udp_host_socket < 0 && _attempts < _max_attempts){
    do { udp_host_socket_port = irandom_range(non_broadcast_min, non_broadcast_max); }
        until(  udp_host_socket_port > 0
            &&  udp_host_socket_port != rdvz_client_port
            &&  udp_host_socket_port != udp_client_port)
            
    udp_host_socket = network_create_socket_ext(network_socket_udp, udp_host_socket_port);
    ++_attempts;
}

if(_attempts >= _max_attempts && udp_host_socket < 0){
    show_debug_message("failed to create udp host socket");
    udp_cleanup_sockets();
    return false;
}

if(udp_host_socket >= 0){
    show_debug_message("created udp host socket: "+string(udp_host_socket)+" on port: "+string(udp_host_socket_port));
}

// lan broadcast socket

var _attempt_port = broadcast_min;

while(broadcast_socket < 0 && _attempt_port <= broadcast_max){
    broadcast_socket = network_create_socket_ext(network_socket_udp, _attempt_port);
    ++_attempt_port;
}

if(broadcast_socket < 0){
    show_debug_message("failed to create broadcast socket");
    udp_cleanup_sockets();
    return false;
} else {
    show_debug_message("created broadcast socket");
}

show_debug_message("created all udp sockets");

return true;
