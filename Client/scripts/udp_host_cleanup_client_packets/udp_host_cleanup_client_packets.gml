/// @description  udp_host_cleanup_client_packets(id)

// cleanup all memory associated with a a client's udp packets
// reliable sending, receiving, and sequence number tracking
// large packets

var _client = argument0;

// detect invalid client number
if(!ds_map_exists(udp_client_maps,_client))
    exit;

// reliable and sequencing

var _client_map     = udp_client_maps[? _client];
var _udpr_sent_list = _client_map[? "udpr_sent_list"];
var _udpr_sent_maps = _client_map[? "udpr_sent_maps"];
var _udpr_rcvd_list = _client_map[? "udpr_rcvd_list"];
var _udpr_rcvd_map  = _client_map[? "udpr_rcvd_map"];
var _udp_sqn_sent   = _client_map[? "udp_seq_num_sent_map"];
var _udp_sqn_rcvd   = _client_map[? "udp_seq_num_rcvd_map"];

var _key, _map, _buffer;
var _idx;

for(_idx=0;_idx<ds_list_size(_udpr_sent_list);_idx++){

    _key = _udpr_sent_list[| _idx];
    _map = _udpr_sent_maps[? _key];
    _buffer = _map[? "buffer"];
    buffer_delete(_buffer);
    ds_map_clear(_map);
    ds_map_destroy(_map);

}

ds_map_destroy(_udpr_sent_maps);
ds_list_destroy(_udpr_sent_list);
ds_map_destroy(_udpr_rcvd_map);
ds_list_destroy(_udpr_rcvd_list);

ds_map_clear(_udp_sqn_sent);
ds_map_clear(_udp_sqn_rcvd);
ds_map_destroy(_udp_sqn_sent);
ds_map_destroy(_udp_sqn_rcvd);

// large packets
udp_host_lrgpkt_clean(_client,false);