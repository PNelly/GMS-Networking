/// @description  state_independent_updates()

// actions that need treatment each frame regardless of what's going on

// clock for lower resolution timing
milliseconds_elapsed = current_time -milliseconds_reference;
milliseconds_u32 = milliseconds_elapsed mod unsigned_32_max;


// clock for wiping the buffer clean so it doesn't get bloated
buffer_refresh_timer--;
if(buffer_refresh_timer < 0){
    buffer_refresh_timer = buffer_refresh_interval;
    if(buffer_exists(message_buffer)){
        buffer_delete(message_buffer);
        message_buffer = buffer_create(message_buffer_size,buffer_grow,1);
    }
}

// system messages
system_message_manage();
