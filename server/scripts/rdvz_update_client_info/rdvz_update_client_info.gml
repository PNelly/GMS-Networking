/// @description  rdvz_update_client_info(clientid)

// updates all clients on this client's fields,
// including that client

var _id = argument0;

var _map, _ip, _is_host, _host_port, _host_clients, _host_max_clients, _client_port;
var _in_progress;

_map                = client_maps[? _id];
_ip                 = _map[? "ip"];
_is_host            = _map[? "udp_is_host"];
_host_port          = _map[? "udp_host_port"];
_host_clients       = _map[? "udp_host_clients"];
_host_max_clients   = _map[? "udp_host_max_clients"];
_client_port        = _map[? "udp_client_port"];
_in_progress        = _map[? "udp_host_in_progress"];

buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);

buffer_write(message_buffer,buffer_u16,     _id);
buffer_write(message_buffer,buffer_string,  _ip);
buffer_write(message_buffer,buffer_bool,    _is_host);
buffer_write(message_buffer,buffer_s32,     _host_port);
buffer_write(message_buffer,buffer_u8,      _host_clients);
buffer_write(message_buffer,buffer_u8,      _host_max_clients);
buffer_write(message_buffer,buffer_s32,     _client_port);
buffer_write(message_buffer,buffer_bool,    _in_progress);

var _clients_told = 0;
var _idx = 0;
var _client;
do{
    _client = client_keys[ _idx];
    if(_client >= 0){
        rdvz_send(_client,rdvz_msg.rdvz_client_update_info,message_buffer);
        _clients_told++;
    }
    
    _idx++;
    
} until (_clients_told == num_clients)

