/// @description  udp_client_migrate_verify

// first stage of migration after (perceived) detection of host drop

if(udp_is_client()){

    show_debug_message("Client Migrate Verify");

    // set timer to 1 to initiate packet send on first pass
    migrate_timer           = migrate_timeout;
    migrate_verify_timer    = 1;

    if(udp_client_is_next_host())
        migrate_state = migrate_states.client_to_host_verifying;
    else
        migrate_state = migrate_states.client_to_client_verifying;
}
