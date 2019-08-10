/// @description  udp_host_send_chat(chat_string)

// pass out new chat to all clients and add to own chat reel

var _chat = string( argument0 );

if(_chat == "") exit; // don't send empty

show_debug_message("host chat: "+string(_chat));

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
// need to send udp id in message body because chat could have come
// from somewhere else, udp client will read to see
buffer_write(message_buffer,buffer_s32,udp_id);
buffer_write(message_buffer,buffer_string,_chat);

udp_host_send_all(udp_msg.udp_chat,true,message_buffer,true);
udp_add_chat(udp_id,_chat);


