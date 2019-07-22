/// @description  udp_host_generate_session_id()

// create a randomized unique identifier to reduce
// confusion between multiple sessions on the same
// local network

return( 
        sha1_string_utf8(
             string(udp_public_ip)
            +string(udp_public_host_port)
            +string(udp_public_client_port)
            +string(current_time)
        )
    );
