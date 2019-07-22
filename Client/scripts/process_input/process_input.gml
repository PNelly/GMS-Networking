/// @description  process_input(input_enum)

// evaluate an input command and execute it
var _input = argument0;


    // -- // go back command // -- //
    
    
if(_input == inputs.input_go_back){
    switch(input_state){
        case input_states.input_none:
            // scripts already contain udp/rdvz state checks
            rdvz_go_back();
            udp_host_cancel_session();
            udp_client_cancel_session();
        break;
        
        default:
            input_state = input_states.input_none;
            keyboard_string = "";
        break;
    
    }
    
    exit;
}


    //  -- // commands from input none // -- //
    // Enter an active input state or execute a one input command
    
    
if(input_state == input_states.input_none){
    switch(_input){      
        case inputs.input_set_rdvz_ip:
            show_debug_message("input set rdvz ip");
            if(rendevouz_state == rdvz_states.rdvz_none
            && udp_state == udp_states.udp_none){
                input_state = input_states.input_set_rdvz_ip;
            }
        break;
        
        case inputs.input_rdvz_connect:
            if(rendevouz_state == rdvz_states.rdvz_none
            && udp_state == udp_states.udp_none){
                show_debug_message("input rdvz connect");
                rdvz_connect();
            }
        break;
        
        case inputs.input_chat:
            if(udp_state == udp_states.udp_host_lobby
            || udp_state == udp_states.udp_client_lobby
            || udp_state == udp_states.udp_host_game_init
            || udp_state == udp_states.udp_client_game_init
            || udp_state == udp_states.udp_host_game
            || udp_state == udp_states.udp_client_game
            || udp_state == udp_states.udp_host_game_ending
            || udp_state == udp_states.udp_client_game_ending
            || udp_state == udp_states.udp_host_game_post
            || udp_state == udp_states.udp_client_game_post){
                show_debug_message("input chat");
                input_state = input_states.input_typing_chat;
            }
        break;
        
        case inputs.input_set_max_clients:
            show_debug_message("input set max clients");
            if(udp_state == udp_states.udp_host_lobby){
                input_state = input_states.input_host_set_max_clients;
            }
        break;
        
        case inputs.input_kick_client:
            show_debug_message("input kick client");
            if(udp_state == udp_states.udp_host_lobby){
                input_state = input_states.input_host_kick_client;
            }
        break;
        
        case inputs.input_create_session:
            show_debug_message("input create session");
            udp_host_attempt_session_create();
        break;
        
        case inputs.input_join_session:
            show_debug_message("input join session");
            if(rendevouz_state == rdvz_states.rdvz_idle){
                input_state = input_states.input_client_set_host;
            }
        break;
        
        case inputs.input_toggle_stress_test:
            show_debug_message("input toggle stress test");
            debug_stress_test_toggle();
        break;
        
        case inputs.input_set_rdvz_tcp_port:
            if(rendevouz_state == rdvz_states.rdvz_none
            && udp_state == udp_states.udp_none){
                show_debug_message("input set tcp port");
                input_state = input_states.input_set_rdvz_tcp_port;
            }
        break;
        
        case inputs.input_set_rdvz_udp_port:
            if(rendeouvz_state == rdvz_states.rdvz_none
            && udp_state == udp_states.udp_none){
                show_debug_message("input set udp port");
                input_state = input_states.input_set_rdvz_udp_port;
            }
        break;
        
        case inputs.input_set_username:
            if(rendevouz_state == rdvz_states.rdvz_none
            && udp_state == udp_states.udp_none){
                show_debug_message("input set username");
                input_state = input_states.input_set_username;
            }
        break;
        
        case inputs.input_ready:
            show_debug_message("input ready");
            if(udp_state == udp_states.udp_client_lobby)
                udp_client_set_ready();
        break;
        
        case inputs.input_start_game:
            if(udp_state == udp_states.udp_host_lobby)
                udp_host_begin_game_init();
        break;
        
        case inputs.input_end_game:
            if(udp_state == udp_states.udp_host_game)
                udp_host_game_end();
        break;
        
        case inputs.input_lobby_return:
            if(udp_state == udp_states.udp_host_game_post)
                udp_host_lobby_return();
        break;
     
        case inputs.input_force_takeover:
            if(udp_is_client())
                udp_client_become_host();
        break;
           
    }
    
    keyboard_string = "";
    exit;
}

    // -- // execute a command requiring string input // -- //
    
    
if(_input == inputs.input_execute){

    var _input_string = keyboard_string;
    keyboard_string = "";

    switch(input_state){
    
        case input_states.input_none:
            // Do Nothing
        break;
        
        case input_states.input_set_username:
            set_network_username(_input_string);
        break;
    
        case input_states.input_set_rdvz_ip:
            rdvz_set_ip(_input_string);
        break;
        
        case input_states.input_set_rdvz_tcp_port:
            rdvz_set_tcp_port(_input_string);
        break;
        
        case input_states.input_set_rdvz_udp_port:
            rdvz_set_udp_port(_input_string);
        break;
        
        case input_states.input_client_set_host:
            _input_string = real( string_digits(_input_string));
            udp_client_join_session(_input_string);
        break;
        
        case input_states.input_host_set_max_clients:
            _input_string = real( string_digits(_input_string) );
            udp_host_set_max_clients(_input_string);
        break;
        
        case input_states.input_host_kick_client:
            _input_string = real( string_digits(_input_string) );
            udp_host_disconnect_client(_input_string);
        break;
        
        case input_states.input_typing_chat:
            show_debug_message("keyboard execute chat");
            if(udp_state == udp_states.udp_host_lobby
            || udp_state == udp_states.udp_host_game_init
            || udp_state == udp_states.udp_host_game
            || udp_state == udp_states.udp_host_game_ending
            || udp_state == udp_states.udp_host_game_post)
                udp_host_send_chat(_input_string);
            if(udp_state == udp_states.udp_client_lobby
            || udp_state == udp_states.udp_client_game_init
            || udp_state == udp_states.udp_client_game
            || udp_state == udp_states.udp_client_game_ending
            || udp_state == udp_states.udp_client_game_post)
                udp_client_send_chat(_input_string);
        break;
        
        
    }
    
    input_state = input_states.input_none;
    exit;

}
