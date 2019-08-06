/// @description  udp_client_new_host(new_host_id)

// re-arrange host and client data to accomodate change in session ownership

if(!udp_is_client()) exit;

var _new_host_id    = argument0;
var _new_session_id = argument1;

if(!ds_map_exists(udp_client_maps,_new_host_id)) exit;

show_debug_message("received new host dictation from "+string(_new_host_id));

var _client_to_host_map = udp_client_maps[? _new_host_id];

// zero out migration state if applicable
if(migrate_state != migrate_states.none){
    migrate_state = migrate_states.none;
    migrate_timer = -1;
    migrate_verify_timer = -1;
}

// change session id
udp_session_id = _new_session_id;

// demote previous host to peer data
udp_client_demote_host();

// promote given peer data to host parameters
udp_host_id                 = _new_host_id;
udp_host_ip                 = _client_to_host_map[? "ip"];
udp_client_host_port        = _client_to_host_map[? "host_port"];
udp_client_host_client_port = _client_to_host_map[? "client_port"];
udp_host_map[? "username"]  = _client_to_host_map[? "username"];

// delete new host from client structures
ds_map_destroy(_client_to_host_map);
ds_map_delete(udp_client_maps, _new_host_id);
ds_list_delete(
    udp_client_list,
    ds_list_find_index(
        udp_client_list,
        _new_host_id
    )
);

// reset outbound packet sequencers and identifiers
udp_client_shrink_packets();

// reset inbound packet sequencers
udp_init_seq_numbers(udp_seq_num_rcvd_map);

// re-share connection parameters
udp_client_share_connection_params();

// clear inbound reliable packets
ds_map_clear(udpr_rcvd_map);
ds_list_clear(udpr_rcvd_list);

// wipe any large packet transfers
udp_client_lrgpkt_clean(false);
udplrg_next_id = 1;

// clear packet hooks
var _idx, _key, _map;

for(_idx=0;_idx<ds_list_size(udp_dlvry_hooks_list);++_idx){

	_key = udp_dlvry_hooks_list[| _idx];
	_map = udp_dlvry_hooks_map[? _key];
	
	ds_map_destroy(_map);
}

ds_list_clear(udp_dlvry_hooks_list);
ds_map_clear(udp_dlvry_hooks_map);