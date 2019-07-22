/// @description  udp_add_chat(sender_id,chat_string)

// puts chat string into list of maps and manages storage of entries

var _sender     = argument0;
var _chat       = string(argument1);

var _map = ds_map_create();

_map[? "sender"] = _sender;
_map[? "string"] = _chat;

ds_list_insert(udp_chat_list,0,_map);

var _num = ds_list_size(udp_chat_list);

if(_num > udp_chat_cap){
    ds_map_destroy( udp_chat_list[| _num-1] );
    ds_list_delete( udp_chat_list,_num-1);
}


