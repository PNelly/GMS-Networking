/// @description  rdvz_client_manage_reconnect()

// decrement reconnect timer and connect when hits zero

if(rdvz_reconnect_timer > 0)
    rdvz_reconnect_timer--;
    
if(rdvz_reconnect_timer == 0){
    rdvz_reconnect_timer = -1;
    rdvz_connect();
}
