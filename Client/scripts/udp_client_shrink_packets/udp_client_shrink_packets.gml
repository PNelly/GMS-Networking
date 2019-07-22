/// @description  udp_client_shrink_packets()

// iterate over all stored outbound reliable packets
// "compressing" both packet id's and sequence numbers
// into the space 0->N, and resetting associated counters

// intended for use when a new host takes over

if(!udp_is_client()) exit;

show_debug_message("-- udp client shrink packets --");

var _idx, _packet, _map, _buffer, _msg_idx;

var _udpr_offset = udp_header_size - buffer_sizeof(buffer_u16);
var _sqn_offset  = udp_header_size -(buffer_sizeof(buffer_u16) + buffer_sizeof(buffer_u32));

var _num_reliable   = ds_list_size(udpr_sent_list);
var _sort_grid      = ds_grid_create(2,_num_reliable);

/*
    Shrink Reliable Packet Ids
*/
    show_debug_message(" -- enumerating reliables -- ");
// enumerate packets in grid by id
for(_idx=0;_idx<_num_reliable;++_idx){

    _packet = udpr_sent_list[| _idx];
    _map    = udpr_sent_maps[? _packet];
    
    _sort_grid[# 0, _idx] = _packet;
    _sort_grid[# 1, _idx] = _map;
    
    show_debug_message("found pkt "+string(_packet)+" w map "+string(_map));
}

// sort reliable packets ascending by old ids
ds_grid_sort(_sort_grid, 0, true);

// enumerate over packets as new key space
for(_idx=0;_idx<_num_reliable;++_idx){

    // delete map packet from old key position
    ds_map_delete(udpr_sent_maps, _sort_grid[# 0, _idx]);
    // add packet map to new key position
    ds_map_add(udpr_sent_maps, _idx, _sort_grid[# 1, _idx]);
    
    show_debug_message("mvd pkt "
        +string(_sort_grid[# 0, _idx])
        +" to "+string(_idx));
}

// re-list keys
ds_list_clear(udpr_sent_list);

for(_idx=0;_idx<_num_reliable;++_idx){

    ds_list_add(udpr_sent_list, _idx);
}

// replace values within buffers
for(_idx=0;_idx<_num_reliable;++_idx){

    _packet = udpr_sent_list[| _idx];
    _map    = udpr_sent_maps[? _packet];
    
    _buffer = _map[? "buffer"];
    
    buffer_poke(_buffer,_udpr_offset,buffer_u16,_packet);
    
    show_debug_message("replaced pkt "
        +string(_packet)+"'s buffer w "
        +string(_packet));
}

// reset udpr id counter
// assigned before increment so set one ahead of count
udpr_next_id = _num_reliable + 1;

/*
    Shrink Packet Sequence Numbers
*/

var _msg_count;
var _msg_list = ds_list_create();

var _first = udp_msg.udp_msg_enum_start;
var _last  = udp_msg.udp_msg_enum_end;

for(_msg_idx=_first;_msg_idx<=_last;++_msg_idx){

    // collect instances of this message type
    ds_list_clear(_msg_list);

    for(_idx=0;_idx<_num_reliable;++_idx){
    
        _packet = udpr_sent_list[| _idx];
        _map    = udpr_sent_maps[? _packet];
        
        if(_map[? "msg_id"] == _msg_idx){
            ds_list_add(_msg_list, _map);
            show_debug_message("found map "
                +string(_map)+" for msg id "
                +string(_msg_idx));
        }
    }
    
    // place in grid and sort by sqn
    ds_grid_resize(_sort_grid, 2, ds_list_size(_msg_list));

    for(_idx=0;_idx<ds_list_size(_msg_list);++_idx){
    
        _map    = _msg_list[| _idx];
        _buffer = _map[? "buffer"];
        
        _sort_grid[# 0, _idx] = buffer_peek(_buffer,_sqn_offset,buffer_u32);
        _sort_grid[# 1, _idx] = _map;
        
        show_debug_message("read sqn "
            +string(_sort_grid[# 0, _idx])
            +" from map "+string(_map));
    }
    
    ds_grid_sort(_sort_grid, 0, true);
    
    // enumerate as new sequence numbers
    for(_idx=0;_idx<ds_list_size(_msg_list);++_idx){
    
        _map    = _sort_grid[# 1, _idx];
        _buffer = _map[? "buffer"];
        
        buffer_poke(_buffer,_sqn_offset,buffer_u32,_idx);
        
        show_debug_message("wrote sqn "
            +string(_idx)+" to map "
            +string(_map));
    }
    
    // reset sequence counter for this message type
    // incrememted before use, so want equal to number of messages
    udp_seq_num_sent_map[? _msg_idx] = ds_list_size(_msg_list);
}

// cleanup

ds_list_destroy(_msg_list);
ds_grid_destroy(_sort_grid);
