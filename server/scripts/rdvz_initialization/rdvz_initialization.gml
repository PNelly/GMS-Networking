/// @description  rdvz_initialization()

// define variables and begin running the server
    
    // -- // Define Messages // -- //
    
enum rdvz_msg { // -- // Has to match Game Client Enum // -- //

    // min and max for filtering
    rdvz_msg_enum_start     = 0,
    rdvz_msg_enum_end       = 21,
    
    // message ids
    
    // specific client connection related
    rdvz_tell_new_id                = 0,
    rdvz_tcp_keep_alive             = 1,
    rdvz_tcp_keep_alive_acknowledge = 2,
    rdvz_request_id                 = 3,
    rdvz_idle_disconnect            = 4,
    
    // Facilitating Hole Punching
    rdvz_new_udp_host       = 5,
    rdvz_new_udp_client     = 6,
    rdvz_request_udp_ping   = 7,
    rdvz_udp_ping_host_w_host_socket = 8,
    rdvz_udp_ping_host_w_client_socket = 9,
    rdvz_udp_ping_client_w_host_socket = 10,
    rdvz_udp_ping_client_w_client_socket = 11,
    rdvz_udp_acknowledge    = 12,
    rdvz_udp_host_cancel    = 13,
    rdvz_udp_hole_punch_request     = 14,
    rdvz_udp_hole_punch_notice      = 15,
    rdvz_udp_hole_punch_rejected    = 16,
    
    // informational
    rdvz_client_connected           = 17,
    rdvz_client_disconnected        = 18,
    rdvz_client_update_info         = 19,
    rdvz_bring_up_to_speed          = 20,
    rdvz_udp_host_update_rdvz       = 21

}

    // -- // Server Variables // -- //
    
// general
buffer_refresh_timer = -1;
buffer_refresh_interval = ceil(room_speed / 10);
idle_disconnect_delay = room_speed * 60 * 5; // five minute idle

// network
rdvz_tcp_port = 4643;
rdvz_udp_port = 4644;
max_clients = 100;
num_clients = 0;
udp_max_clients_default = 7; // compare with client
udp_max_clients = 7;
rdvz_header_size = buffer_sizeof(buffer_bool)
    +buffer_sizeof(buffer_u16);
    
ephemeral_min = 49152;
ephemeral_max = 65535;

rdvz_tcp_socket = -1;
rdvz_udp_socket = -1;

// data structures
client_keys[0]              = -1;
client_keys[max_clients-1]  = -1;
client_maps = ds_map_create();
message_buffer_size = 5 * buffer_sizeof(buffer_u16);
message_buffer = buffer_create(16,buffer_grow,message_buffer_size);

var _idx;
for(_idx=0;_idx<max_clients;_idx++){
    client_keys[@ _idx] = -1;
}


    // -- // Begin Running the Server // -- //

    
var _attempts = 0;
var _max_attempts = 10;

while(rdvz_tcp_socket < 0 && _attempts < _max_attempts){
    rdvz_tcp_socket = network_create_server(network_socket_tcp,rdvz_tcp_port,max_clients);
    _attempts++;
}

if(_attempts == _max_attempts && rdvz_tcp_socket < 0)
    show_debug_message("failed to create tcp server");
if(rdvz_tcp_socket >= 0)
    show_debug_message("tcp socket create: "+string(rdvz_tcp_socket));

_attempts = 0;

while(rdvz_udp_socket < 0 && _attempts < _max_attempts){
    rdvz_udp_socket = network_create_server(network_socket_udp,rdvz_udp_port,100);
    _attempts++;
}

if(_attempts == _max_attempts && rdvz_udp_socket < 0)
    show_debug_message("failed to create udp server");
if(rdvz_udp_socket >= 0)
    show_debug_message("udp socket create: "+string(rdvz_udp_socket));
    
    // shutdown if server creation failed
if(rdvz_tcp_socket < 0 || rdvz_udp_socket < 0){
    show_debug_message("failed to start sever");
    game_end();
}
