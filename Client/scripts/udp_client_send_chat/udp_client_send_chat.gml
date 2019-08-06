/// @description  udp_client_send_chat(chat_string)

// send along chat message as reliable udp packet

var _chat = string( argument0 );

if(_chat == "") exit; // don't send empty

show_debug_message("client chat: "+string(_chat));

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_string,_chat);
udp_client_send(udp_msg.udp_chat,true,message_buffer,-1);