/// @description  draw_default_debug()

// draw debug UI information

draw_set_color(c_white);
draw_text(32,room_height-32,string_hash_to_newline("rdvz id received: "+string(debug_received_rdvz_id)));
draw_text(32,room_height-32-16,string_hash_to_newline("stress test mode: "+string(debug_stress_test)));
//draw_text(32,room_height-32-32,"milliseconds u32: "+string(milliseconds_u32));
