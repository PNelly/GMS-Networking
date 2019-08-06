/// @description  define_messages()

// declare message tags for tcp and udp communication

// rdvz given tags 0->999, udp given tags 1000->65535

enum rdvz_msg { // -- // Have to Match in Rdvz Server Enum // -- //

    // min and max for filtering
    rdvz_msg_enum_start						= 0,
    rdvz_msg_enum_end						= 21,
    
    // message ids
    
    // specific client connection related
    rdvz_tell_new_id						= 0,
    rdvz_tcp_keep_alive						= 1,
    rdvz_tcp_keep_alive_acknowledge			= 2,
    rdvz_request_id							= 3,
    rdvz_idle_disconnect					= 4,
    
    // Facilitating Hole Punching
    rdvz_new_udp_host						= 5,
    rdvz_new_udp_client						= 6,
    rdvz_request_udp_ping					= 7,
    rdvz_udp_ping_host_w_host_socket		= 8,
    rdvz_udp_ping_host_w_client_socket		= 9,
    rdvz_udp_ping_client_w_host_socket		= 10,
    rdvz_udp_ping_client_w_client_socket	= 11,
    rdvz_udp_acknowledge					= 12,
    rdvz_udp_host_cancel					= 13,
    rdvz_udp_hole_punch_request				= 14,
    rdvz_udp_hole_punch_notice				= 15,
    rdvz_udp_hole_punch_rejected			= 16,
    
    // informational
    rdvz_client_connected					= 17,
    rdvz_client_disconnected				= 18,
    rdvz_client_update_info					= 19,
    rdvz_bring_up_to_speed					= 20,
    rdvz_udp_host_update_rdvz				= 21

}

enum udp_msg {

    // min and max for filtering
    udp_msg_enum_start          = 1000,
    udp_msg_enum_end            = 1033,

    // message ids
    udp_hole_punch              = 1000,
    udp_keep_alive              = 1001,
    udp_disconnect_instruction  = 1002,
    udp_ping_request            = 1003,
    udp_ping_acknowledge        = 1004,
    udp_reliable_acknowledge    = 1005,
    udp_tell_client_id          = 1006,
    udp_refresh_lobby           = 1007,
    udp_chat                    = 1008,
    udp_ready                   = 1009,
    udp_host_unready_all        = 1010,
    udp_username                = 1011,
    udp_connection_params       = 1012,
    udp_migration_meta_host     = 1013,
    udp_migration_meta_client   = 1014,
    udp_peer_call               = 1015,
    udp_peer_response           = 1016,
    udp_migration_stats_request = 1017,
    udp_migration_stats_info    = 1018,
    udp_migration_order         = 1019,
    udp_client_left             = 1020,
    udp_game_init               = 1021,
    udp_game_init_complete      = 1022,
    udp_game_start              = 1023,
    udp_game_client_joined      = 1024,
    udp_game_bring_to_speed     = 1025,
    udp_game_end                = 1026,
    udp_return_to_lobby         = 1027,
    udp_player_metadata         = 1028,
    udp_idle_lan_broadcast      = 1029,
    udp_host_lan_broadcast      = 1030,
    udp_migrate_lost_host       = 1031,
    udp_migrate_new_host        = 1032,
	udp_dummy_message			= 1033
}
