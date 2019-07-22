/// @description  debug_stress_test_behaviors

// make randomized choices based on current state

if(debug_stress_test){

    var _take_action = false;

    debug_stress_test_timer--;
    if(debug_stress_test_timer < 0){
        _take_action = true;
        debug_stress_test_timer = irandom_range(debug_stress_test_interval_min,debug_stress_test_interval_max);
        if(udp_state == udp_states.udp_host_lobby)
            debug_stress_test_timer = debug_stress_test_interval_max;
    }
    
    if(_take_action){

        switch(rendevouz_state){
        
            
        
            case rdvz_states.rdvz_idle:
                // need keyboard string to join a udp session
                var _host = rdvz_client_list[| irandom_range(0, ds_list_size(rdvz_client_list)) ];
                keyboard_string = string(_host);
                debug_stress_test_choice();
            break;
            
            case rdvz_states.rdvz_host_pinging_udp:
                debug_stress_test_choice();
            break;
            
            case rdvz_states.rdvz_join_pinging_udp:
                debug_stress_test_choice();
            break;
            
            case rdvz_states.rdvz_join_awaiting_hole_punch:
                debug_stress_test_choice();
            break;
            
            case rdvz_states.rdvz_join_hole_punching:
                debug_stress_test_choice();
            break;
            
            case rdvz_states.rdvz_host:
                debug_stress_test_choice();
            break;
            
            default:
            break;
        
        }
        
        switch(udp_state){
        
            case udp_states.udp_none:
            break;
            
            case udp_states.udp_client_lobby:
                debug_stress_test_choice();
            break;
            
            case udp_states.udp_host_lobby:
                debug_stress_test_choice();
            break;
            
            default:
            break;
        
        }
    
    }
}
