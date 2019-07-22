/// @description  udp_host_manage_pings()

// decrement ping request timer and send round trip
// ping request when timer bottoms out

if(udp_ping_timer >= 0)
    udp_ping_timer--;

if(udp_ping_timer < 0){
    udp_ping_timer = udp_ping_interval;
    var _num_clients = ds_list_size(udp_client_list);
    if(_num_clients > 0){
    
        buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
        buffer_write(message_buffer,buffer_u32, milliseconds_u32);
        udp_host_send_all(udp_msg.udp_ping_request,false,message_buffer);
    
    }
}
