/// @description  get_default_input()

// default script that maps all inputs to arbitrary keyboard keys

// map all inputs to some default keyboard keys

var _input_chat               = keyboard_check_pressed(ord("C"));
var _input_rdvz_connect       = keyboard_check_pressed(ord("E"));
var _input_force_takeover     = keyboard_check_pressed(ord("F"));
var _input_create_session     = keyboard_check_pressed(ord("H"));
var _input_set_rdvz_ip        = keyboard_check_pressed(ord("I"));
var _input_join_session       = keyboard_check_pressed(ord("J"));
var _input_kick_client        = keyboard_check_pressed(ord("K"));
var _input_ready              = keyboard_check_pressed(ord("R"));
var _input_start_game         = keyboard_check_pressed(ord("S"));
var _input_set_rdvz_tcp_port  = keyboard_check_pressed(ord("T"));
var _input_set_rdvz_udp_port  = keyboard_check_pressed(ord("U"));
var _input_lobby_return       = keyboard_check_pressed(ord("L"));
var _input_set_max_clients    = keyboard_check_pressed(ord("M"));
var _input_set_username       = keyboard_check_pressed(ord("N"));
var _input_test_dlvry_hook	  = keyboard_check_pressed(ord("P"));
var _input_host_end_game      = keyboard_check_pressed(ord("Q"));

var _input_go_back            = keyboard_check_pressed(vk_escape);
var _input_toggle_stress_test = keyboard_check_pressed(vk_f1);
var _input_execute            = keyboard_check_pressed(vk_enter);

// call method with appropriate argument

if(_input_execute)              process_input(inputs.input_execute);
if(_input_set_username)         process_input(inputs.input_set_username);
if(_input_set_rdvz_ip)          process_input(inputs.input_set_rdvz_ip);
if(_input_set_rdvz_tcp_port)    process_input(inputs.input_set_rdvz_tcp_port);
if(_input_set_rdvz_udp_port)    process_input(inputs.input_set_rdvz_udp_port);
if(_input_set_max_clients)      process_input(inputs.input_set_max_clients);
if(_input_kick_client)          process_input(inputs.input_kick_client);
if(_input_create_session)       process_input(inputs.input_create_session);
if(_input_join_session)         process_input(inputs.input_join_session);
if(_input_ready)                process_input(inputs.input_ready);
if(_input_start_game)           process_input(inputs.input_start_game);
if(_input_host_end_game)        process_input(inputs.input_end_game);
if(_input_lobby_return)         process_input(inputs.input_lobby_return);
if(_input_chat)                 process_input(inputs.input_chat);
if(_input_rdvz_connect)         process_input(inputs.input_rdvz_connect);
if(_input_force_takeover)       process_input(inputs.input_force_takeover);
if(_input_go_back)              process_input(inputs.input_go_back);
if(_input_toggle_stress_test)   process_input(inputs.input_toggle_stress_test);
if(_input_test_dlvry_hook)		process_input(inputs.input_test_dlvry_hook);


