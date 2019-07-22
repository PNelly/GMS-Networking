/// @description  rdvz_default_draw

// draw client information to the screen

draw_set_color(c_white);

var _x = 32;
var _y = 32;

draw_text(_x,_y,string_hash_to_newline("clients in rendevouz lobby: "+string(num_clients)));

var _clients_drawn = 0;
var _client;
var _idx = 0;

do{
    _client = client_keys[ _idx];
    if(_client >= 0){

        var _map                = client_maps[? _client];
        var _ip                 = _map[? "ip"];
        var _is_host            = _map[? "udp_is_host"];
        var _host_port          = _map[? "udp_host_port"];
        var _host_clients       = _map[? "udp_host_clients"];
        var _host_max_clients   = _map[? "udp_host_max_clients"];
        var _client_port        = _map[? "udp_client_port"];
        var _idle_time          = _map[? "idle_timer"];
        
        if(_is_host)
            draw_text(_x,_y+40+20*_clients_drawn,string_hash_to_newline("id: "+string(_client)+" ip: "+string(_ip)+" hp: "+string(_host_port)+"cp: "+string(_client_port)+" players: "+string(_host_clients+1)+"/"+string(_host_max_clients+1)));
        else
            draw_text(_x,_y+40+20*_clients_drawn,string_hash_to_newline("id: "+string(_client)+" ip: "+string(_ip)+" hp: "+string(_host_port)+"cp: "+string(_client_port)+" idle: "+string(_idle_time)));

        _clients_drawn++;
    }
    
    _idx++;
    
} until (_clients_drawn == num_clients);

