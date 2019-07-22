/// @description  udp_client_manage_received_reliables()

// iterates over received reliable packet ids, examining how much
// time has passed since they were received. Once a sufficient
// amount of time has passed that id will be freed and recognized
// as a new arrival the next time it is seen

var _num = ds_list_size(udpr_rcvd_list);
var _idx, _packet, _time;

for(_idx=0;_idx<_num;_idx++){

    _packet = udpr_rcvd_list[| _idx];
    _time   = udpr_rcvd_map[? _packet];
    
    if( (current_time -_time)> udp_reliable_rcvd_free_interval ){ // div 1000 for milliseconds
        //show_debug_message("client freeing reliable packet "+string(_packet));
        ds_map_delete(udpr_rcvd_map,_packet);
        ds_list_delete(udpr_rcvd_list,_idx);
        _num--;
        _idx--;
    }
}
