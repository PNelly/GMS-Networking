/// @description  rdvz_add_client_key(key)

// add a new key into the key array

var _new_client = argument0;
var _idx;

for(_idx=0;_idx<max_clients;_idx++){

    if(client_keys[ _idx] < 0){
        client_keys[@ _idx] = _new_client;
        break;
    }
}
