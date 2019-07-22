/// @description  define_debug

// declare variables and structures needed for debug shortcuts

debug_received_rdvz_id = false;
debug_stress_test = false;
debug_stress_test_interval_max = room_speed * 10;
debug_stress_test_interval_min = 1;
debug_stress_test_timer = -1;
debug_error_message = -1;
debug_show_invalid_pkt = true;
debug_save_invalid_pkt = false;

// notes
// tcp timeout will currently shutdown the client
