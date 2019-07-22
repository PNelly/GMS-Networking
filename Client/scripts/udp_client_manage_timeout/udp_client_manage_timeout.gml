/// @description  udp_client_manage_timeout()

// decrement timeout and abandon udp session if hits bottom

if(!udp_is_client()) exit;

if(migrate_state != migrate_states.none) exit;

if(udp_connection_timer >= 0)
    udp_connection_timer--;

if(udp_connection_timer < 0){
    
    show_debug_message("connection timed out");
    udp_client_migrate_verify();
}
