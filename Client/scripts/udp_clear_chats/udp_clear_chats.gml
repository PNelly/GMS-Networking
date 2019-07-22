/// @description  udp_clear_chats()

// memory cleanup for chats

var _i, _map;

while(ds_list_size(udp_chat_list) > 0){

    _i = ds_list_size(udp_chat_list)-1;
    _map = udp_chat_list[| _i];
    
    ds_map_clear(_map);
    ds_map_destroy(_map);
    ds_list_delete(udp_chat_list,_i);

}
