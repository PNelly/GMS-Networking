/// @description  udp_host_manage_player_metadata()

// decrement player metadata update timer and 
// send out meta data bout all players
// (currently just pings)

if(udp_player_metadata_timer >= 0)
    udp_player_metadata_timer--;

if(udp_player_metadata_timer < 0){
    udp_player_metadata_timer = udp_player_metadata_interval;
    var _num_clients = ds_list_size(udp_client_list);
    if(_num_clients > 0){
        buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
        buffer_write(message_buffer,buffer_u8,_num_clients);
        var _idx, _client, _map, _ping;
        for(_idx=0;_idx<_num_clients;_idx++){
            _client = udp_client_list[| _idx];
            _map    = udp_client_maps[? _client];
            _ping   = _map[? "ping"];
            buffer_write(message_buffer,buffer_s32,_client);
            buffer_write(message_buffer,buffer_u32,_ping);
        }
        udp_host_send_all(udp_msg.udp_player_metadata,false,message_buffer);
    }
}
