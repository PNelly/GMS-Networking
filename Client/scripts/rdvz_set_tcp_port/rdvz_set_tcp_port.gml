/// @description  rdvz_set_tcp_port(port_string)

var _port = real (string_digits( string( argument0 ) ) );

if(_port >= 0 && _port <= 65535 && _port != rendevouz_udp_port){
    rendevouz_tcp_port = _port;
    system_message_set("meetup server tcp port set to: "+string(_port));
} else {
    if(_port < 0 || _port > 65535)
        system_message_set("port must be between 0 and 65536");
    if(_port == rendevouz_udp_port)
        system_message_set("tcp port cannot be the same as udp port");
}
