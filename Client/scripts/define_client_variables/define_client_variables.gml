 /// define_client_variables

// define vars and data structures needed for rendouz interaction and udp
// interaction

// BEWARE OF VARIABLES THAT ARE SHARED WITH THE RENDEVOUZ SERVER

network_set_config(network_config_connect_timeout,1000);

// Rendevouz Server Related and General Use
ephemeral_min = 49152;
ephemeral_max = 65535;
broadcast_num = 16;
broadcast_max = ephemeral_max;
broadcast_min = broadcast_max -broadcast_num;
non_broadcast_min  = ephemeral_min;
non_broadcast_max  = broadcast_min -1;
unsigned_16_max = 65535;
unsigned_32_max = 4294967295;
signed_32_max = 2147483647;
milliseconds_reference = current_time;
milliseconds_elapsed = 0;
milliseconds_u32 = milliseconds_elapsed mod unsigned_32_max;
system_message = "";
system_message_timer = -1;
system_message_delay = room_speed * 2;

network_username_max_length = 16;
network_username = string_copy(
                   sha1_string_unicode(string(irandom(100))),
                   0, network_username_max_length);

message_buffer_size = 256;
message_buffer = buffer_create(message_buffer_size,buffer_grow,1);

// IMPLEMENTATION SPECIFIC VARIABLES
rendevouz_ip = "192.168.1.5";
//rendevouz_ip = "127.0.0.1";
rendevouz_tcp_port = 4643;
rendevouz_udp_port = 4644;
udp_host_enforce_ready_ups = true;
udp_host_allow_join_in_progress = true;
udp_max_clients_cap = 23; // Totally Arbitrary
udp_max_clients_default = 7; // Totally Arbitrary
udp_host_exit_kills_session = false;
udp_max_transmission_unit = 1350; // max bytes per packet
//udp_max_transmission_unit = 40;

// rdvz header <udp (bool) | msg_id (u16) >
rdvz_header_size = buffer_sizeof(buffer_bool) 
                    +buffer_sizeof(buffer_u16);
// udp header //
// <is udp (bool) | msg_id (u16) | checksum (u32)
// udp_id (s32) | seq num (u32) | udpr id (u16)
// udplrg id (u16) | udplrg idx (u16) | udplrg num (u16)
// udplrg frag len (u16) >
udp_header_size = buffer_sizeof(buffer_bool)	// is udp
               +buffer_sizeof(buffer_u16)		// msg id
               +buffer_sizeof(buffer_u32)		// checksum
               +buffer_sizeof(buffer_s32)		// udp id
               +buffer_sizeof(buffer_u32)		// seq num
               +buffer_sizeof(buffer_u16)		// udpr id
			   +buffer_sizeof(buffer_u16)		// udplrg id
			   +buffer_sizeof(buffer_u16)		// udplrg idx
			   +buffer_sizeof(buffer_u16)		// udplrg num
			   +buffer_sizeof(buffer_u16);		// udplrg frag len
			   
udp_header_offset_is_udp		= 0;
udp_header_offset_msg_id		= udp_header_offset_is_udp		+buffer_sizeof(buffer_bool);
udp_header_offset_checksum		= udp_header_offset_msg_id		+buffer_sizeof(buffer_u16);
udp_header_offset_udp_id		= udp_header_offset_checksum	+buffer_sizeof(buffer_u32);
udp_header_offset_sqn			= udp_header_offset_udp_id		+buffer_sizeof(buffer_s32);
udp_header_offset_udpr_id		= udp_header_offset_sqn			+buffer_sizeof(buffer_u32);
udp_header_offset_udplrg_id		= udp_header_offset_udpr_id		+buffer_sizeof(buffer_u16);
udp_header_offset_udplrg_idx	= udp_header_offset_udplrg_id	+buffer_sizeof(buffer_u16);
udp_header_offset_udplrg_num	= udp_header_offset_udplrg_idx	+buffer_sizeof(buffer_u16);
udp_header_offset_udplrg_len	= udp_header_offset_udplrg_num	+buffer_sizeof(buffer_u16);

udp_max_data_size				= udp_max_transmission_unit - udp_header_size;
udplrg_max_bits_per_sec			= 3000000;
udplrg_max_bytes_per_frame		= floor(udplrg_max_bits_per_sec / 8 / room_speed);
udplrg_max_packets_per_sec		= 1000;
udplrg_max_packets_per_frame	= floor(udplrg_max_packets_per_sec / room_speed);

rdvz_client_port = -1;
rdvz_client_socket = -1;
rdvz_client_list = ds_list_create();
rdvz_client_maps = ds_map_create();
// for local network
broadcast_socket = -1;
lan_list  = ds_list_create();
lan_maps  = ds_map_create();
lan_broadcast_timer = -1;
lan_broadcast_delay = room_speed;

rendevouz_state = rdvz_states.rdvz_none;
rendevouz_id = -1;
rdvz_keep_alive_timer = -1;
rdvz_keep_alive_interval = room_speed * 10;
rdvz_connection_timer = -1;
rdvz_connection_timeout = room_speed * 30;
rdvz_udp_ping_timeout = room_speed * 5;
rdvz_udp_ping_timer = -1;
rdvz_reconnect_timer = -1;
rdvz_reconnect_delay_cap = room_speed * 2;

// udp client and host (1)
input_state = input_states.input_none;
udp_state = udp_states.udp_none;
udp_id = -1;
udp_session_id = "";
udp_migration_broadcast_timer = -1;
udp_migration_broadcast_delay = room_speed * 2;
udp_peer_call_timer = -1;
udp_peer_call_delay = room_speed;

// self referential connection info for sharing
udp_public_ip = "";
udp_public_host_port = -1;
udp_public_client_port = -1;

// udp client specific
udp_client_socket = -1;
udp_client_port = -1;
udp_host_to_join = -1;
udp_host_to_join_ip = "";
udp_host_to_join_port = -1;
udp_host_ip = "";
udp_client_host_port = -1;
udp_client_host_client_port = -1;
udp_client_host_call_response_stamp = -1;
udp_client_host_call_response_ping = -1;
udp_host_id = -1;
udp_ping = 100;

    // client sequence numbers
udp_seq_num_sent_map = ds_map_create();
udp_seq_num_rcvd_map = ds_map_create();
udp_init_seq_numbers(udp_seq_num_sent_map);
udp_init_seq_numbers(udp_seq_num_rcvd_map);
    // client reliable udp
udpr_sent_list	= ds_list_create();
udpr_sent_maps	= ds_map_create();
udpr_rcvd_map	= ds_map_create();
udpr_rcvd_list	= ds_list_create();
udpr_next_id	= 1;
	// client large packet management
udplrg_rcvd_list		= ds_list_create();
udplrg_rcvd_map			= ds_map_create();
udplrg_outbound_list	= ds_list_create();
udplrg_outbound_map		= ds_map_create();
udplrg_next_id			= 1;

	// client delivery hooks
udp_dlvry_hooks_list = ds_list_create();
udp_dlvry_hooks_map  = ds_map_create();

// udp host specific
udp_host_socket_port = -1; // name clash between host and client needs fixed
udp_host_socket = -1;
udp_max_clients = udp_max_clients_default;
udp_next_client_id = 1;
udp_non_client_id = -1;
udp_hole_punch_list = ds_list_create();
udp_hole_punch_maps = ds_map_create();
udp_host_lobby_refresh_interval = room_speed*5;
udp_host_lobby_refresh_timer = -1;
udp_host_game_in_progress = false;
udp_host_migration_stats_request_timer = -1;
udp_host_migration_stats_request_interval = room_speed * 7;
udp_host_migration_order_timer = -1;
udp_host_migration_order_delay = ceil(0.33 * udp_host_migration_stats_request_interval);
    // host reliable udp inits handled in udp host accept client()
    // host sequence number inits handled in udp host accept client()

// udp client and host (2)
udp_client_list = ds_list_create();
udp_client_maps = ds_map_create();
udp_host_map    = ds_map_create();
udp_hole_punch_pkt_per_sec = 5;
udp_hole_punch_interval = ceil(room_speed / udp_hole_punch_pkt_per_sec);
udp_hole_punch_timeout  = udp_hole_punch_interval * udp_hole_punch_pkt_per_sec * 5; // ~5 seconds
udp_hole_punch_timer    = -1;
udp_connection_timeout = room_speed*5;
udp_connection_timer = -1;
udp_keep_alive_interval = room_speed;
udp_keep_alive_timer = -1;
udp_ping_interval = room_speed*3;
udp_ping_timer = -1;
udp_reliable_resend_factor = 1.20;
udp_reliable_resend_default = ceil(room_speed / 5);
udp_reliable_rcvd_free_interval = 5*1000*udp_connection_timeout/room_speed; // milliseconds
udp_player_metadata_timer = -1;
udp_player_metadata_interval = room_speed * 3;
buffer_refresh_timer = -1;
buffer_refresh_interval = ceil(room_speed / 10);

udp_chat_list = ds_list_create();
udp_chat_cap  = 100;

// migration specific
migrate_state = migrate_states.none;
migrate_timeout = room_speed*5;
migrate_timer = -1;
migrate_verify_timer = -1;
migrate_verify_interval = ceil(room_speed/7);
