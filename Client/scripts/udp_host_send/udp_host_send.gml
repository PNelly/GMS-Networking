/// @description  udp_host_send(client_id,message_id,use_reliable,buffer)

var _client      = argument0;
var _msg_id      = argument1;
var _is_reliable = argument2;
var _buffer      = argument3;

if(!ds_map_exists(udp_client_maps,_client)) exit;

var _map    = udp_client_maps[? _client];
var _ip     = _map[? "ip"];
var _port   = _map[? "client_port"];

buffer_seek(_buffer,buffer_seek_start,0);

var _udpr_id, _time_stamp;

// Write Header Information
_udpr_id = udp_host_write_header(_buffer,_client,_msg_id,_is_reliable);

if(_is_reliable)
    udp_host_reliable_record(_client,_udpr_id,_buffer);
    
udp_send_packet(udp_host_socket,_ip,_port,_buffer);

// reset this clients keep alive packet send timer,
// since we've just sent a packet
_map[? "keep_alive_timer"] = udp_get_keep_alive_time();
