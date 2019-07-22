/// @description  udp_client_manage_migrate_timeout

// countdown until chance to move hosts has expired and session connection
// is considered lost

if(udp_is_client() && migrate_state != migrate_states.none){

    if(migrate_timer >= 0)
        --migrate_timer;
 
    if(migrate_timer < 0){
        show_debug_message("migration timer expired, session lost");
        udp_client_reset();
        if(rendevouz_state == rdvz_states.rdvz_none)
            rdvz_connect();
    }                 
}
