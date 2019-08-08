/// @description  draw_default_debug()

// draw debug UI information

draw_set_color(c_white);
draw_text(32,room_height-32-0*16,"rdvz id received: "+string(debug_received_rdvz_id));
draw_text(32,room_height-32-1*16,"stress test mode: "+string(debug_stress_test));
draw_text(32,room_height-32-2*16,"invalid pkt count: "+string(debug_invalid_pkt_count));

//draw_text(32,room_height-32-32,"milliseconds u32: "+string(milliseconds_u32));
