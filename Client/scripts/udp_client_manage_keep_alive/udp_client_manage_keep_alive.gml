/// @description  udp_client_manage_keep_alive()

// decrement KA timer and send KA packets to the UDP host

if(udp_keep_alive_timer >= 0)
    udp_keep_alive_timer--;

if(udp_keep_alive_timer < 0){
    udp_keep_alive_timer = udp_get_keep_alive_time();
    udp_client_send(udp_msg.udp_keep_alive,false,message_buffer);
}
