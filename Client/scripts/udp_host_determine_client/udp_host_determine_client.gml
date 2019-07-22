 /// udp_host_determine_client(ip,port)

// when udp host receives a client id of -1
// (meaing an id hasn't been given to that client yet)
// this script will determine which client it is and
// return its integer id, then resend client id to the client

// if it isn't found probably indicates new client trying to join

var _ip     = argument0;
var _port   = argument1;

var _key, _map, _client_ip, _client_port, _client_id;

var _idx;

for(_idx=0;_idx<ds_list_size(udp_client_list);_idx++){

    _key = udp_client_list[| _idx];
    _map = udp_client_maps[? _key];
    _client_ip      = _map[? "ip"];
    _client_port    = _map[? "client_port"];
    _client_id      = _map[? "id"];
    
    if(_client_ip == _ip && _client_port == _port){
        return _client_id;
    }
}

// couldn't find client, probably a new arrival
return -1;
