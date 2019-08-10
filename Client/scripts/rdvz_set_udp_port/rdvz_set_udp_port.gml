/// @description  rdvz_set_udp_port(port_string)

var _port = real (string_digits( string( argument0 ) ) );

if(_port >= 0 && _port <= 65535 && _port != rendevouz_udp_port){
    rendevouz_udp_port = _port;
    system_message_set("meetup server udp port set to: "+string(_port));
} else {
    if(_port < 0 || _port > 65535)
        system_message_set("port must be between 0 and 65535");
    if(_port == rendevouz_tcp_port)
        system_message_set("udp port cannot be the same as tcp port");
}
