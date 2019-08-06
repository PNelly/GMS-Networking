/// @description  udp_client_manage_sent_reliables()

// loops through all stored reliable packets decrementing timers
// and resending packets when necessary

var _size = ds_list_size(udpr_sent_list);
var _id, _map, _buffer;

var _idx;

for(_idx=0;_idx<_size;_idx++){

    _id     = udpr_sent_list[| _idx];
    _map    = udpr_sent_maps[? _id];
    _map[? "resend_timer"] = _map[? "resend_timer"] -1;
    
    if(_map[? "resend_timer"] < 0){
        _buffer = _map[? "buffer"];
        udp_send_packet(udp_client_socket,udp_host_ip,udp_client_host_port,_buffer);
        if(udp_ping > 0)
            _map[? "resend_timer"] = ceil( udp_ping * udp_reliable_resend_factor);
        if(udp_ping == 0)
            _map[? "resend_timer"] = udp_reliable_resend_default;
            
        //show_debug_message("client resent reliable packet: "+string(_id));
    }    

}
