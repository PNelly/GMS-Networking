/// @description  rdvz_manage_timeout()

// decrement timeout tracker disconnect if falls to zero

if(rdvz_connection_timer >= 0)
    rdvz_connection_timer--;

if(rdvz_connection_timer < 0){
    show_debug_message("connection to rendevouz server timed out");
    system_message_set("connection to server timed out");
    rdvz_disconnect();
}
