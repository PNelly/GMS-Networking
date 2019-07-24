/// @description  lan_manage_broadcast()

// rotate through broadcast ports sending a packet to each one
// host will include same information transferred by rdvz server

var _send_broadcast = false;

if(lan_broadcast_timer >= 0){
    lan_broadcast_timer--;
    if(lan_broadcast_timer < 0){
        _send_broadcast = true;
        lan_broadcast_timer = lan_broadcast_delay;
    }   
}

if(!_send_broadcast) exit;
    
var _ready = false;
var _socket;

var _lobby_host = !udp_host_allow_join_in_progress && udp_state == udp_states.udp_host_lobby;
var _game_host  = udp_host_allow_join_in_progress && udp_is_host();

if(rendevouz_state == rdvz_states.rdvz_host && (_lobby_host || _game_host)){

    buffer_seek(message_buffer, buffer_seek_start, udp_header_size);
    buffer_write(message_buffer, buffer_u16,    rendevouz_id);
    buffer_write(message_buffer, buffer_u16,    udp_host_socket_port);
    buffer_write(message_buffer, buffer_u8,     ds_list_size(udp_client_list));
    buffer_write(message_buffer, buffer_u8,     udp_max_clients);
    buffer_write(message_buffer, buffer_bool,   udp_host_game_in_progress);
    
    udp_host_write_header(
        message_buffer, 
        udp_non_client_id, 
        udp_msg.udp_host_lan_broadcast, 
        false,
		0, 1, 1,
		buffer_tell(message_buffer)
    );
    
    _socket = udp_host_socket;
    
    _ready = true;
    
} else if (udp_state == udp_states.udp_none && rendevouz_state != rdvz_states.rdvz_none){

    buffer_seek(message_buffer, buffer_seek_start, udp_header_size);
    buffer_write(message_buffer, buffer_u16, rendevouz_id);
    buffer_write(message_buffer, buffer_u16, udp_client_port);

    udp_client_write_header(
        message_buffer, 
        udp_msg.udp_idle_lan_broadcast, 
        false,
		0, 1, 1,
		buffer_tell(message_buffer)
    );
    
    _socket = udp_client_socket;
    
    _ready = true;
}

if(_ready){

    var _size = buffer_get_size(message_buffer);
    var _port;
    
    for(_port = broadcast_min; _port <= broadcast_max; ++_port){
    
        network_send_broadcast(_socket, _port, message_buffer, _size);
    }
}
