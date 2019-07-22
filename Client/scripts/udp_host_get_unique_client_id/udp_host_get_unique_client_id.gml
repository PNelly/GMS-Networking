/// @description  udp_host_get_unique_client_id

// compute unique id to use for next joining client
// increment while next id to be issued already exists in
// client data structures or coincides with this host's id

while(ds_map_exists(udp_client_maps, udp_next_client_id) 
      || (udp_next_client_id == udp_id)){

    ++udp_next_client_id;
    if(udp_next_client_id > signed_32_max)
        udp_next_client_id = 1;
}

return (udp_next_client_id);
