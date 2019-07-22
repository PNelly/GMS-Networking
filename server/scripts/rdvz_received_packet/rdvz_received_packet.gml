/// @description  rdvz_received_packet(client,ip,port,buffer,size)

var _client = argument0;
var _ip     = argument1;
var _port   = argument2;
var _buffer = argument3;
var _size   = argument4;
 
buffer_seek(_buffer,buffer_seek_start,0);

var _is_udp     = buffer_read(_buffer,buffer_bool);
var _message_id = buffer_read(_buffer,buffer_u16);

if(_is_udp){

    switch (_message_id){
    
        case rdvz_msg.rdvz_udp_ping_client_w_host_socket:
        case rdvz_msg.rdvz_udp_ping_client_w_client_socket:
            // UDP Packet, TCP id's won't apply
            // read TCP id from the datagram
            // capture public facing port numbers
            var _rdvz_id = buffer_read(_buffer,buffer_u16);
            var _map = client_maps[? _rdvz_id];
            
            if(!is_undefined(_map)){
                
                if(_message_id == rdvz_msg.rdvz_udp_ping_client_w_host_socket)
                    _map[? "udp_host_port"] = _port;
                    
                if(_message_id == rdvz_msg.rdvz_udp_ping_client_w_client_socket)
                    _map[? "udp_client_port"] = _port;               

                // only acknowledge once both host and client
                // socket information has been captured
                if(_map[? "udp_host_port"] > 0 && _map[? "udp_client_port"] > 0){
                
                    show_debug_message("tell id "+string(_rdvz_id)+" pub hp "
                        +string(_map[? "udp_host_port"])+" pub cp "
                        +string(_map[? "udp_client_port"]));
                
                    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                    buffer_write(message_buffer,buffer_string,  _map[? "ip"]);
                    buffer_write(message_buffer,buffer_s32,     _map[? "udp_host_port"]);
                    buffer_write(message_buffer,buffer_s32,     _map[? "udp_client_port"]);
                
                    rdvz_send(_rdvz_id,rdvz_msg.rdvz_udp_acknowledge,message_buffer);
                }
             }
        break;
    
        case rdvz_msg.rdvz_udp_ping_host_w_host_socket:
        case rdvz_msg.rdvz_udp_ping_host_w_client_socket:
            // UDP Packet, TCP id's won't apply
            // read TCP id from the datagram
            // capture public facing port numbers
            var _rdvz_id = buffer_read(_buffer,buffer_u16);
            var _map = client_maps[? _rdvz_id];
            
            if(!is_undefined(_map)){
                
                if(_message_id == rdvz_msg.rdvz_udp_ping_host_w_host_socket)
                    _map[? "udp_host_port"] = _port;
                    
                if(_message_id == rdvz_msg.rdvz_udp_ping_host_w_client_socket)
                    _map[? "udp_client_port"] = _port;

                // only acknowledge once both host and client
                // socket information has been captured
                if(_map[? "udp_host_port"] > 0 && _map[? "udp_client_port"] > 0){
                    
                    _map[? "udp_is_host"]       = true;
                    _map[? "udp_host_clients"]  = 0;
                    
                    show_debug_message("tell id "+string(_rdvz_id)+" pub hp "
                        +string(_map[? "udp_host_port"])+" pub cp "
                        +string(_map[? "udp_client_port"]));
                    
                    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                    buffer_write(message_buffer,buffer_string,  _map[? "ip"]);
                    buffer_write(message_buffer,buffer_s32,     _map[? "udp_host_port"]);
                    buffer_write(message_buffer,buffer_s32,     _map[? "udp_client_port"]);
                    
                    rdvz_send(_rdvz_id,rdvz_msg.rdvz_udp_acknowledge,message_buffer);
                    rdvz_update_client_info(_rdvz_id);
                }
            }
        break;
    
    }

} else { // -- // TCP Packets, nearly everything // -- //

    switch (_message_id){
    
        case rdvz_msg.rdvz_new_udp_host:
            // request UDP ping to rendevouz server
            rdvz_send(_client,rdvz_msg.rdvz_request_udp_ping,message_buffer);
            
            rdvz_reset_idle_timer(_client);
        break;
        
        case rdvz_msg.rdvz_udp_host_cancel:
        
            _map = client_maps[? _client];
            _map[? "udp_is_host"] = false;
            
            // update clients on host cancel
            rdvz_update_client_info(_client);
            
            rdvz_reset_idle_timer(_client);
        break;
        
        case rdvz_msg.rdvz_new_udp_client:
            // request UDP ping to rendevouz server
            rdvz_send(_client,rdvz_msg.rdvz_request_udp_ping,message_buffer);
            
            rdvz_reset_idle_timer(_client);
        break;
        
        
        case rdvz_msg.rdvz_udp_hole_punch_request:
        
            rdvz_reset_idle_timer(_client);
        
            // Player wants to join a UDP host
            
            var _desired_host       = buffer_read(_buffer,buffer_u16);
            
            var _reject             = true;
            
            show_debug_message("received HP request from client: "+string(_client)+" to host: "+string(_desired_host));
            
            if(ds_exists(client_maps[? _desired_host], ds_type_map)
             &&ds_exists(client_maps[? _client], ds_type_map)){
            
                var _host_map           = client_maps[? _desired_host];
                var _client_map         = client_maps[? _client];
                
                var _is_host            = _host_map[? "udp_is_host"];
                var _host_clients       = _host_map[? "udp_host_clients"];
                var _host_max_clients   = _host_map[? "udp_host_max_clients"];
                var _host_ip            = _host_map[? "ip"];
                var _host_port          = _host_map[? "udp_host_port"];
                
                var _client_ip          = _client_map[? "ip"];
                var _client_port        = _client_map[? "udp_client_port"];
                
                // validate host params
                if(_is_host 
                && _host_port >= ephemeral_min 
                && _host_port <= ephemeral_max 
                && _host_clients < _host_max_clients){
                
                    show_debug_message("sending notice from client "
                        +string(_client)+" to host "
                        +string(_desired_host));
                    
                    _reject = false;
                    
                    // inform host and give info
                    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                    buffer_write(message_buffer,buffer_u16, _client);
                    buffer_write(message_buffer,buffer_string,_client_ip);
                    buffer_write(message_buffer,buffer_s32,_client_port);
                    rdvz_send(_desired_host,rdvz_msg.rdvz_udp_hole_punch_notice,message_buffer);
                    
                    // inform client and give info
                    buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                    buffer_write(message_buffer,buffer_string,_host_ip);
                    buffer_write(message_buffer,buffer_s32,_host_port);
                    rdvz_send(_client,rdvz_msg.rdvz_udp_hole_punch_notice,message_buffer);
                    
                }
            }
            
            if(_reject){
            
                show_debug_message("invalid HP request, rejecting");
                buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
                rdvz_send(_client,rdvz_msg.rdvz_udp_hole_punch_rejected,message_buffer);
            }
        
            
        break;
        
        case rdvz_msg.rdvz_udp_hole_punch_rejected:
            // udp host rejected a client hole punch request
            show_debug_message("received HP rejection notice from a UDP host");
            var _rejected_client = buffer_read(_buffer,buffer_u16);
            buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
            rdvz_send(_rejected_client,rdvz_msg.rdvz_udp_hole_punch_rejected,message_buffer);
        break;
        
        case rdvz_msg.rdvz_udp_host_update_rdvz:
        
            // udp host updating the rendevouz server on num players
            var _num_clients = buffer_read(_buffer,buffer_u8);
            var _max_clients = buffer_read(_buffer,buffer_u8);
            var _in_progress = buffer_read(_buffer,buffer_bool);
            
            var _map = client_maps[? _client];
            _map[? "udp_host_clients"] = _num_clients;
            _map[? "udp_host_max_clients"] = _max_clients;
            _map[? "udp_host_in_progress"] = _in_progress;
            
            rdvz_update_client_info(_client);
            
        break;
        
        case rdvz_msg.rdvz_tcp_keep_alive:
            // simply respond to keep alive packet request
            rdvz_send(_client,rdvz_msg.rdvz_tcp_keep_alive_acknowledge,message_buffer);
        
        break;
        
        case rdvz_msg.rdvz_request_id:
        
            // simply fire back with client id
            show_debug_message("responding to lost id request");
            buffer_seek(message_buffer,buffer_seek_start,rdvz_header_size);
            buffer_write(message_buffer,buffer_u16,_client);
            rdvz_send(_client,rdvz_msg.rdvz_tell_new_id,message_buffer);
            
        break;
    
        default:
        
        break;
        
    }
}
