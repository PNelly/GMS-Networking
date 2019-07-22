/// @description  rdvz_remove_client_key

// delete a client key from the client key array

var _client = argument0;
var _idx = 0;

while(client_keys[ _idx] != _client){
    _idx++;
}

client_keys[@ _idx] = -1;
