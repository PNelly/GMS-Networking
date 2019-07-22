/// @description  udp_host_manage_migration_stats_request()

// issue requests to session clients at intervals to retrieve
// their average ping with the other session peers

if(!udp_is_host()) exit;

var _send_request = false;

if(udp_host_migration_stats_request_timer >= 0){
    --udp_host_migration_stats_request_timer;
    if(udp_host_migration_stats_request_timer < 0){
        _send_request = true;
        udp_host_migration_stats_request_timer = udp_host_migration_stats_request_interval;
    }
}

if(!_send_request) exit;

show_debug_message("udp host sent migration stats request to clients");

udp_host_send_all(udp_msg.udp_migration_stats_request, true, message_buffer);

