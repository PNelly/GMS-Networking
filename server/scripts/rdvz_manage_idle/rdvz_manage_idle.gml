/// @description  rdvz_manage_idle()

// track idle time of players and send disconnect message when necessary

var _idx = 0;
var _clients_updated = 0;
var _client, _map, _time;

do{
    _client = client_keys[ _idx];
    if(_client >= 0){
        _map = client_maps[? _client];
        if(!is_undefined(_map)){
            _map[? "idle_timer"] = _map[? "idle_timer"] -1;
            if(_map[? "idle_timer"] < 0){
               rdvz_send(_client,rdvz_msg.rdvz_idle_disconnect,message_buffer);
            }
        }
        _clients_updated++;
    }
    
    _idx++;
    
} until (_clients_updated == num_clients)

