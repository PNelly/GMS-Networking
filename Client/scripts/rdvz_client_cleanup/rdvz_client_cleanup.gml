/// @description  rdvz_client_cleanup()

var _key, _map, _idx;

udp_cleanup_sockets();

network_destroy(rdvz_client_socket);

buffer_delete(message_buffer);

rdvz_clear_client_properties();

// information on other clients in rdvz lobby
ds_list_destroy(rdvz_client_list);
ds_map_destroy(rdvz_client_maps);
ds_list_destroy(lan_list);
ds_map_destroy(lan_maps);

// udp chat reel
udp_clear_chats();
ds_list_destroy(udp_chat_list);

// udp host client tracking
ds_list_destroy(udp_client_list);
ds_map_destroy(udp_client_maps);
// host meta data
ds_map_destroy(udp_host_map);

// client udp packets, reliable and timestamps
udp_client_cleanup_packets();

ds_list_destroy(udpr_sent_list);
ds_map_destroy(udpr_sent_maps);
ds_list_destroy(udpr_rcvd_list);
ds_map_destroy(udpr_rcvd_map);

ds_map_destroy(udp_seq_num_sent_map);
ds_map_destroy(udp_seq_num_rcvd_map);

ds_list_destroy(udplrg_rcvd_list);
ds_map_destroy(udplrg_rcvd_map);
ds_list_destroy(udplrg_outbound_list);
ds_map_destroy(udplrg_outbound_map);

ds_list_destroy(udp_dlvry_hooks_list);
ds_map_destroy(udp_dlvry_hooks_map);

// UDP Host Hole Punching Structures
for(_idx=0;_idx<ds_list_size(udp_hole_punch_list);_idx++){

    _key = udp_hole_punch_list[| _idx];
    _map = udp_hole_punch_maps[? _key];
    ds_map_destroy(_map);
}
ds_map_destroy(udp_hole_punch_maps);
ds_list_destroy(udp_hole_punch_list);

