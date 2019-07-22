/// @description  udp_client_cleanup_packets

// wipe reliable packet structures

show_debug_message("udp client cleanup packets");

var _num_packets = ds_list_size(udpr_sent_list);
var _id, _map, _buffer;

var _idx;

// clean up stored sent packets
for(_idx=0;_idx<_num_packets;_idx++){

    _id = udpr_sent_list[| _idx];
    _map = udpr_sent_maps[? _id];
    _buffer = _map[? "buffer"];
    
    buffer_delete(_buffer);
    ds_map_clear(_map);
    ds_map_destroy(_map);
}

// cleanup sequence numbers
ds_map_clear(udp_seq_num_sent_map);
ds_map_clear(udp_seq_num_rcvd_map);
udp_init_seq_numbers(udp_seq_num_sent_map);
udp_init_seq_numbers(udp_seq_num_rcvd_map);

// wipe macro structures
ds_map_clear(udpr_sent_maps);
ds_list_clear(udpr_sent_list);
ds_map_clear(udpr_rcvd_map);
ds_list_clear(udpr_rcvd_list);

