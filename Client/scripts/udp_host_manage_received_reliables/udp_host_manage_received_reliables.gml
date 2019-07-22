/// @description  udp_host_manage_received_reliables()

// iterates over received reliable packet ids, examining how much
// time has passed since they were received. Once a sufficient
// amount of time has passed that id will be freed and recognized
// as a new arrival the next time it is seen

var _num_clients = ds_list_size(udp_client_list);
var _client_map, _idx1, _idx2, _client;
var _udpr_rcvd_map, _udpr_rcvd_list;
var _num_packets, _packet, _time;

for(_idx1=0;_idx1<_num_clients;_idx1++){

    _client         = udp_client_list[| _idx1];
    _client_map     = udp_client_maps[? _client];
    _udpr_rcvd_list = _client_map[? "udpr_rcvd_list"];
    _udpr_rcvd_map  = _client_map[? "udpr_rcvd_map"];
    _num_packets    = ds_list_size(_udpr_rcvd_list);
    
    for(_idx2=0;_idx2<_num_packets;_idx2++){
    
        _packet = _udpr_rcvd_list[| _idx2];
        _time   = _udpr_rcvd_map[? _packet];
        
        if( (current_time -_time) > udp_reliable_rcvd_free_interval){ // 1000 for milliseconds
            //show_debug_message("host freeing reliable packet "+string(_packet)+" from client "+string(_client));
            ds_map_delete(_udpr_rcvd_map, _packet);
            ds_list_delete(_udpr_rcvd_list, _idx2);
            _num_packets--;
            _idx2--;
        }
    }
    
}
