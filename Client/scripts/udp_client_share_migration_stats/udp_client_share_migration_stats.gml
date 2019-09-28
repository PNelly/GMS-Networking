/// @description  udp_client_share_migration_stats()

// share connection and avg latency parameters with udp session host

if(udp_is_client()){

    var _connected  = udp_client_all_peers_connected();
    var _avg_ping   = udp_avg_peer_ping();
    
    buffer_seek(message_buffer, buffer_seek_start, udp_header_size);
    buffer_write(message_buffer, buffer_bool, _connected);
    buffer_write(message_buffer, buffer_u16, _avg_ping);
    
    udp_client_send(udp_msg.udp_migration_stats_info, true, message_buffer, -1, true); 
}
