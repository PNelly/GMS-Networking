/// @description  rdvz_handle_network_actions

// process any connections, disconnections, or data transfers

var _type               = async_load[? "type"];
var _socket             = async_load[? "id"];
var _ip                 = async_load[? "ip"];
var _port               = async_load[? "port"];

switch (_type) {

    case network_type_connect:
    
        var _socket_id = async_load[? "socket"];
        var _new_client_map    = ds_map_create();
        
        ds_map_add(client_maps,_socket_id,_new_client_map);
        rdvz_add_client_key(_socket_id);
        
        num_clients++;
        
        _new_client_map[? "socket"]                 = _socket_id;
        _new_client_map[? "ip"]                     = _ip;
        _new_client_map[? "udp_is_host"]            = false;
        _new_client_map[? "udp_host_port"]          = -1;
        _new_client_map[? "udp_host_clients"]       = 0;
        _new_client_map[? "udp_host_max_clients"]   = udp_max_clients_default;
        _new_client_map[? "udp_host_in_progress"]   = false;
        _new_client_map[? "udp_client_port"]        = -1;
        _new_client_map[? "idle_timer"]             = idle_disconnect_delay;
        
        // bring new client up to speed
        rdvz_bring_client_up_to_speed(_socket_id);
        
        // tell existing clients about new client
        buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
        buffer_write(message_buffer,buffer_u16,_socket_id);
        buffer_write(message_buffer,buffer_string,_ip);
        
        var _client;
        var _idx = 0;
        var _clients_told = 0;
        do {
            _client = client_keys[ _idx];
            if(_client >= 0 && _client != _socket_id){
                rdvz_send(_client,rdvz_msg.rdvz_client_connected,message_buffer);
                _clients_told++;
            }
            
            _idx++;
            
        } until (_clients_told == num_clients -1)
    
    break;
    
    case network_type_disconnect:
    
        var _socket_id = async_load[? "socket"];
        var _lost_client_map = client_maps[? _socket_id];
        
        ds_map_destroy(_lost_client_map);
        ds_map_delete(client_maps,_socket_id);
        rdvz_remove_client_key(_socket_id);
        num_clients--;
        
        show_debug_message("client "+string(_socket_id)+" disconnected");
        
        // tell remaining clients about disconnection
        buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
        buffer_write(message_buffer,buffer_u16,_socket_id);
        var _clients_told = 0;
        var _idx = 0;
        var _client;
        do{
            _client = client_keys[ _idx];
            if(_client >= 0){
                rdvz_send(_client,rdvz_msg.rdvz_client_disconnected,message_buffer);
                _clients_told++;
            }
            
            _idx++;
            
        } until(_clients_told == num_clients);
        
    break;
    
    case network_type_data:
    
        var _buffer = async_load[? "buffer"];
        var _size   = async_load[? "size"];
        
        rdvz_received_packet(_socket,_ip,_port,_buffer,_size);
    
    break;


}
