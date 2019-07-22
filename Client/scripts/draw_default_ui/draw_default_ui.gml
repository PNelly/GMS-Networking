/// @description  draw_default_ui()

// text information for keyboard interface with system

draw_set_color(c_white);
draw_set_halign(fa_left);

var _x = 32;
var _y = 32;

var _line = 20;
var _output_y = _y+3*_line;
var _input_y = _output_y+_line;

if(system_message != "")
    draw_text(_x,_output_y,string_hash_to_newline(system_message));

switch(input_state){

    case input_states.input_none:
        switch(rendevouz_state){
            case rdvz_states.rdvz_none:
                if(udp_state == udp_states.udp_none){
                    draw_text(_x,_input_y,string_hash_to_newline("<E> connect to meetup server"));
                    draw_text(_x,_input_y+20,string_hash_to_newline("<N> set username"));
                    draw_text(_x,_input_y+40,string_hash_to_newline("<I> rdvz ip | <T> rdvz tcp port | <U> rdvz udp port"));
                }
            break;
            
            case rdvz_states.rdvz_idle:
                draw_text(_x,_input_y,string_hash_to_newline("<H> host session | <J> join session | <Esc> disconnect"));
            break;
            
            case rdvz_states.rdvz_reconnect:
                draw_text(_x,_input_y,string_hash_to_newline("<Esc> Cancel"));
            break;
        }
        
        switch(udp_state){
            case udp_states.udp_host_lobby:
                draw_text(_x,_input_y,string_hash_to_newline("<M> max clients | <K> kick | <S> start | <C> chat | <Esc> cancel"));
            break;
            
            case udp_states.udp_client_lobby:
                draw_text(_x,_input_y,string_hash_to_newline("<C> chat | <R> change ready | <Esc> leave session"));
            break;
            
            case udp_states.udp_host_game_post:
                draw_text(_x,_input_y,string_hash_to_newline("<C> chat | <Esc> disband session | <L> lobby return"));
            break;
            
            case udp_states.udp_client_game_post:
                draw_text(_x,_input_y,string_hash_to_newline("<C> chat | <Esc> leave session"));
            break;
        }
    break;
    
    case input_states.input_set_username:
        draw_text(_x,_input_y,string_hash_to_newline("New username: "+keyboard_string));
    break;
    
    case input_states.input_set_rdvz_ip:
        draw_text(_x,_input_y,string_hash_to_newline("Meetup server IP > " +keyboard_string));
    break;
    
    case input_states.input_set_rdvz_tcp_port:
        draw_text(_x,_input_y,string_hash_to_newline("Meetup server tcp port > "+keyboard_string));
    break;
    
    case input_states.input_set_rdvz_udp_port:
        draw_text(_x,_input_y,string_hash_to_newline("Meetup server udp port > "+keyboard_string));
    break;
    
    case input_states.input_host_set_max_clients:
        draw_text(_x,_input_y,string_hash_to_newline("Max clients > " +keyboard_string));
    break;
    
    case input_states.input_host_kick_client:
        draw_text(_x,_input_y,string_hash_to_newline("Client to kick > " +keyboard_string));
    break;
    
    case input_states.input_client_set_host:
        draw_text(_x,_input_y,string_hash_to_newline("Id of host to join > " +keyboard_string));
    break;
    
    case input_states.input_typing_chat:
        draw_text(_x,_input_y,string_hash_to_newline("Chat > " +keyboard_string));
    break;

}

switch(rendevouz_state){

    case rdvz_states.rdvz_none:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: disconnected"));
    break;
    
    case rdvz_states.rdvz_reconnect:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: attempting reconnect "+string(rdvz_reconnect_timer)));
    break;

    case rdvz_states.rdvz_idle:
        var _num_clients = ds_list_size(rdvz_client_list);
        draw_text(_x,_y,string_hash_to_newline("rdvz state: connected, idle"));
        draw_text(_x,_y+_line,string_hash_to_newline("my username: "+string(network_username)+" rdvz id: "+string(rendevouz_id)+" clients online: "+string(_num_clients)));
        
        var _idx;
        for(_idx=0;_idx<_num_clients;_idx++){
    
            var _id   = rdvz_client_list[| _idx];
            var _map  = rdvz_client_maps[? _id];
            var _ip                 = _map[? "ip"];
            var _is_host            = _map[? "udp_is_host"];
            var _client_port        = _map[? "udp_client_port"];
            var _host_port          = _map[? "udp_host_port"];
            var _host_clients       = _map[? "udp_host_clients"];
            var _host_max_clients   = _map[? "udp_host_max_clients"];
            
            if(_id == rendevouz_id) draw_set_color(c_aqua);
                else draw_set_color(c_white);
            
            if(_is_host)
                draw_text(_x,_y+100+20*_idx,string_hash_to_newline("id: "+string(_id)+" ip: "+string(_ip)+" hp: "+string(_host_port)+" cp: "+string(_client_port)+" players: "+string(_host_clients+1)+"/"+string(_host_max_clients+1)));
            else
                draw_text(_x,_y+100+20*_idx,string_hash_to_newline("id: "+string(_id)+" ip: "+string(_ip)+" hp: "+string(_host_port)+" cp: "+string(_client_port)));
        }
    
    break;
    
    case rdvz_states.rdvz_join_init:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: join init"));
    break;
    
    case rdvz_states.rdvz_join_pinging_udp:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: pinging udp"));
    break;
    
    case rdvz_states.rdvz_join_awaiting_hole_punch:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: waiting for hole punch notice"));
    break;
    
    case rdvz_states.rdvz_join_hole_punching:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: hole punching"));
    break;
    
    case rdvz_states.rdvz_host_init:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: host init"));
    break;
    
    case rdvz_states.rdvz_host_pinging_udp:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: host pinging udp"));
    break;
    
    case rdvz_states.rdvz_host:
        draw_text(_x,_y,string_hash_to_newline("rdvz state: udp host"));
    break;

}

switch(udp_state){

    case udp_states.udp_host_lobby:
        // draw client info
        var _udp_clients = ds_list_size(udp_client_list);
        draw_text(_x + room_width/2 ,_y,string_hash_to_newline("udp state: udp host lobby"));
        draw_text(_x,_y+_line,string_hash_to_newline("rdvz id: "+string(rendevouz_id)));
        draw_text(_x,_y+2*_line,string_hash_to_newline("session id: "+string(udp_session_id)));
        
        draw_set_color(c_aqua);
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])));
        draw_set_color(c_white);
        
        var _id, _map, _ip, _client_port, _host_port;
        var _ping, _ka_timer, _name, _idx;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
            _id             = udp_client_list[| _idx];
            _map            = udp_client_maps[? _id];
            _ip             = _map[? "ip"];
            _client_port    = _map[? "client_port"];
            _host_port      = _map[? "host_port"];
            _ping           = _map[? "ping"];
            _name           = _map[? "username"];
            _ka_timer       = _map[? "keep_alive_timer"];
            _ready          = _map[? "ready"];
            
            //draw_text(_x,_y+140+20*_idx,string(_name)+" id: "+string(_id)+" ip: "+string(_ip)+" port: "+string(_port)+" ping: "+string(_ping)+" ka timer: "+string(_ka_timer));
            draw_text(_x,_y+140+20*_idx,string_hash_to_newline("id: "+string(_id)+" "+string(_name)+" ping: "+string(_ping)+" hp: "+string(_host_port)));
            
            draw_set_halign(fa_right);
                if(_ready){
                    draw_set_color(c_lime);
                    draw_text(room_width-_x,y+140+20*_idx,string_hash_to_newline("ready"));
                } else {
                    draw_set_color(c_orange);
                    draw_text(room_width-_x,y+140+20*_idx,string_hash_to_newline("not ready"));
                }
            draw_set_halign(fa_left);
            
            draw_set_color(c_white); 
        
        }
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
        
    case udp_states.udp_client_lobby:
        // draw client info
        draw_text(_x + room_width/2,_y,string_hash_to_newline("udp state: udp client lobby"));
        draw_text(_x + room_width/2,_y+_line,string_hash_to_newline("my udp id: "+string(udp_id)+" ping: "+string(udp_ping)));
        draw_text(_x,_y+2*_line,string_hash_to_newline("session id: "+string(udp_session_id)));
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])+" ping: "+string(udp_ping)+" cp: "+string(udp_client_host_client_port)));
        
        var _udp_clients = ds_list_size(udp_client_list);
        var _id, _map, _ping, _ready, _name,_idx;
        var _host_port, _client_port;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
        
            _id             = udp_client_list[| _idx];
            _map            = udp_client_maps[? _id];
            _ping           = _map[? "ping"];
            _ready          = _map[? "ready"];
            _name           = _map[? "username"];
            _host_port      = _map[? "host_port"];
            _client_port    = _map[? "client_port"];
            
            if(_id == udp_id)
                draw_set_color(c_aqua);
            else
                draw_set_color(c_white);
            
            draw_set_halign(fa_left);
                draw_text(_x,_y+140+20*_idx,string_hash_to_newline(string(_name)+" id: "+string(_id)+"  ping: "+string(_ping)+" hp: "+string(_host_port)+" cp: "+string(_client_port)));
            
            draw_set_halign(fa_right);
                if(_ready){
                    draw_set_color(c_lime);
                    draw_text(room_width-_x,y+140+20*_idx,string_hash_to_newline("ready"));
                } else {
                    draw_set_color(c_orange);
                    draw_text(room_width-_x,y+140+20*_idx,string_hash_to_newline("not ready"));
                }
            draw_set_halign(fa_left);
            
            draw_set_color(c_white); 
        }
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_host_game_init:
        var _udp_clients = ds_list_size(udp_client_list);
        draw_text(_x + room_width/2 ,_y,string_hash_to_newline("udp state: udp host game init"));
        draw_text(_x,_y+_line,string_hash_to_newline("rdvz id: "+string(rendevouz_id)));
        
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_client_game_init:
        draw_text(_x + room_width/2,_y,string_hash_to_newline("udp state: udp client game init"));
        draw_text(_x + room_width/2,_y+_line,string_hash_to_newline("my udp id: "+string(udp_id)+" ping: "+string(udp_ping)));
    
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_host_game:
        var _udp_clients = ds_list_size(udp_client_list);
        draw_text(_x + room_width/2 ,_y,string_hash_to_newline("udp state: udp host game"));
        draw_text(_x,_y+_line,string_hash_to_newline("rdvz id: "+string(rendevouz_id)));
        
        // player info
        draw_set_color(c_aqua);
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])));
        draw_set_color(c_white);
        
        var _id, _map, _ip, _client_port, _host_port;
        var _ping, _ka_timer, _name, _idx;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
        
            _id             = udp_client_list[| _idx];
            _map            = udp_client_maps[? _id];
            _ip             = _map[? "ip"];
            _client_port    = _map[? "client_port"];
            _host_port      = _map[? "host_port"];
            _ping           = _map[? "ping"];
            _name           = _map[? "username"];
            _ka_timer       = _map[? "keep_alive_timer"];
            _ready          = _map[? "ready"];
            
            //draw_text(_x,_y+140+20*_idx,string(_name)+" id: "+string(_id)+" ip: "+string(_ip)+" port: "+string(_port)+" ping: "+string(_ping)+" ka timer: "+string(_ka_timer));
            draw_text(_x,_y+140+20*_idx,string_hash_to_newline(string(_name)+" ping: "+string(_ping)));
        
        }
        
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_client_game:
        draw_text(_x + room_width/2,_y,string_hash_to_newline("udp state: udp client game"));
        draw_text(_x + room_width/2,_y+_line,string_hash_to_newline("my udp id: "+string(udp_id)+" ping: "+string(udp_ping)));
    
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])+" ping: "+string(udp_ping)));
        
        // player info
        var _udp_clients = ds_list_size(udp_client_list);
        var _id, _map, _ping, _ready, _name,_idx;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
        
            _id     = udp_client_list[| _idx];
            _map    = udp_client_maps[? _id];
            _ping   = _map[? "ping"];
            _ready  = _map[? "ready"];
            _name   = _map[? "username"];
            
            if(_id == udp_id)
                draw_set_color(c_aqua);
            else
                draw_set_color(c_white);
            
            draw_text(_x,_y+140+20*_idx,string_hash_to_newline(string(_name)+" id: "+string(_id)+"  ping: "+string(_ping)));
            
            draw_set_color(c_white);

        }
        
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_host_game_post:
        var _udp_clients = ds_list_size(udp_client_list);
        draw_text(_x + room_width/2 ,_y,string_hash_to_newline("udp state: udp host post game"));
        draw_text(_x,_y+_line,string_hash_to_newline("rdvz id: "+string(rendevouz_id)));
        
        // player info
        draw_set_color(c_aqua);
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])));
        draw_set_color(c_white);
        
        var _id, _map, _ip, _client_port, _host_port; 
        var _ping, _ka_timer, _name, _idx;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
        
            _id             = udp_client_list[| _idx];
            _map            = udp_client_maps[? _id];
            _ip             = _map[? "ip"];
            _host_port      = _map[? "host_port"];
            _client_port    = _map[? "client_port"];
            _ping           = _map[? "ping"];
            _name           = _map[? "username"];
            _ka_timer       = _map[? "keep_alive_timer"];
            
            draw_text(_x,_y+140+20*_idx,string_hash_to_newline(string(_name)+" ping: "+string(_ping)));
        
        }
        
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;
    
    case udp_states.udp_client_game_post:
        draw_text(_x + room_width/2,_y,string_hash_to_newline("udp state: udp client post game"));
        draw_text(_x + room_width/2,_y+_line,string_hash_to_newline("my udp id: "+string(udp_id)+" ping: "+string(udp_ping)));
    
        draw_text(_x,_y+120,string_hash_to_newline("host: "+string(udp_host_map[? "username"])+" ping: "+string(udp_ping)));
        
        // player info
        var _udp_clients = ds_list_size(udp_client_list);
        var _id, _map, _ping, _ready, _name,_idx;
        
        for(_idx=0;_idx<_udp_clients;_idx++){
            _id     = udp_client_list[| _idx];
            _map    = udp_client_maps[? _id];
            _ping   = _map[? "ping"];
            _name   = _map[? "username"];
            
            if(_id == udp_id)
                draw_set_color(c_aqua);
            else
                draw_set_color(c_white);
            
            draw_text(_x,_y+140+20*_idx,string_hash_to_newline(string(_name)+" id: "+string(_id)+"  ping: "+string(_ping)));
            
            draw_set_color(c_white);

        }
        
        // draw chats
        var _map,_chat;
        draw_set_color(c_white);
        for(_idx=0;_idx<5;_idx++){
            _map = udp_chat_list[| _idx];
            if(!is_undefined(_map)){
                _chat = _map[? "string"];
                draw_text(_x,room_height*(2/3)+20*_idx,string_hash_to_newline(_chat));
            }
        }
    break;

}

