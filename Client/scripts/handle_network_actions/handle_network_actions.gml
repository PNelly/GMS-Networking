/// @description  handle_network_actions()

// facilitates network event for this architecture

var _type       = async_load[? "type"];
var _socket_id  = async_load[? "id"];
var _ip         = async_load[? "ip"];
var _port       = async_load[? "port"];

var _buffer, _size;

switch (_type) {

    case network_type_connect:
        exit;
    break;
    
    case network_type_disconnect:
        exit;
    break;
    
    case network_type_data:
        _buffer     = async_load[? "buffer"];
        _size       = async_load[? "size"];
        received_packet(_buffer,_size,_ip,_port,_socket_id);
    break;
    
    case network_type_non_blocking_connect:
        exit;
    break;

}
