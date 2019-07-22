/// @description  hole_punch_fail_client_reset()

// hole punch failure of some kind compels client 
// to revert to rdvz idle state

rendevouz_state = rdvz_states.rdvz_idle;
udp_client_reset();
