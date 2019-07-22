/// @description  rdvz_bring_client_up_to_speed(client_socket)

// give new client all the information about what's going on

var _client = argument0;
var _map;
var _id, _ip, _is_host, _host_port, _host_clients;
var _host_max_clients, _client_port, _in_progress;

buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);

buffer_write(message_buffer,buffer_u16,_client); // give id
buffer_write(message_buffer,buffer_u16,num_clients); // give num clients

var _clients_written = 0;
var _idx = 0;

do{
    _id = client_keys[ _idx];
    
    if(_id >= 0){
  
        _map = client_maps[? client_keys[ _idx]];
        _id                 = _map[? "socket"];
        _ip                 = _map[? "ip"];
        _is_host            = _map[? "udp_is_host"];
        _host_port          = _map[? "udp_host_port"];
        _host_clients       = _map[? "udp_host_clients"];
        _host_max_clients   = _map[? "udp_host_max_clients"];
        _client_port        = _map[? "udp_client_port"];
        _in_progress        = _map[? "udp_host_in_progress"];
        
        buffer_write(message_buffer,buffer_u16,     _id);
        buffer_write(message_buffer,buffer_string,  _ip);
        buffer_write(message_buffer,buffer_bool,    _is_host);
        buffer_write(message_buffer,buffer_s32,     _host_port);
        buffer_write(message_buffer,buffer_u8,      _host_clients);
        buffer_write(message_buffer,buffer_u8,      _host_max_clients);
        buffer_write(message_buffer,buffer_s32,     _client_port);
        buffer_write(message_buffer,buffer_bool,    _in_progress);
     
        _clients_written++;   
    }
    
    _idx++;
    
} until (_clients_written == num_clients)

rdvz_send(_client,rdvz_msg.rdvz_bring_up_to_speed,message_buffer);
