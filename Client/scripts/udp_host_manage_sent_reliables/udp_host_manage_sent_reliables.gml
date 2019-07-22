/// @description  udp_host_manage_sent_reliables()

// loops through all stored packets of all clients
// decrementing resend timers and resending packets when necessary

var _num_clients = ds_list_size(udp_client_list);
var _client_id, _client_map, _num_packets, _packet_list, _packet_maps;
var _packet_id, _this_packet_map, _buffer;
var _ip, _port;

var _idx1, _idx2;

for(_idx1=0;_idx1<_num_clients;_idx1++){

    _client_id  = udp_client_list[| _idx1];
    _client_map = udp_client_maps[? _client_id];
    
    _ip          = _client_map[? "ip"];
    _port        = _client_map[? "client_port"];
    _ping        = _client_map[? "ping"];
    _packet_list = _client_map[? "udpr_sent_list"];
    _packet_maps = _client_map[? "udpr_sent_maps"];
    _num_packets = ds_list_size(_packet_list);
    
    for(_idx2=0;_idx2<_num_packets;_idx2++){
    
        _packet_id = _packet_list[| _idx2];
        _this_packet_map = _packet_maps[? _packet_id];
        _this_packet_map[? "resend_timer"] = _this_packet_map[? "resend_timer"] -1;
        
        if(_this_packet_map[? "resend_timer"] < 0){
            _buffer = _this_packet_map[? "buffer"];
            udp_send_packet(udp_host_socket,_ip,_port,_buffer);
            if(_ping > 0)
                _this_packet_map[? "resend_timer"] = ceil( _ping * udp_reliable_resend_factor);
            if(_ping == 0)
                _this_packet_map[? "resend_timer"] = udp_reliable_resend_default;
                
            //show_debug_message("host resent udpr: "+string(_packet_id)+" to client: "+string(_client_id));
        }
    
    }

}
