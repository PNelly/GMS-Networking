/// @description  udp_get_keep_alive_time

// gives a randomized interval for keep alive timers to avoid
// several being triggered simultaneously

return ( irandom_range( floor(udp_keep_alive_interval) , ceil(udp_keep_alive_interval) *2 ));
