/// @description  stepwise_behaviors()

// clock for wiping the buffer clean so it doesn't get bloated
buffer_refresh_timer--;
if(buffer_refresh_timer < 0){
    buffer_refresh_timer = buffer_refresh_interval;
    if(buffer_exists(message_buffer)){
        buffer_delete(message_buffer);
        message_buffer = buffer_create(message_buffer_size,buffer_grow,1);
    }
}

// idle timers
rdvz_manage_idle();
