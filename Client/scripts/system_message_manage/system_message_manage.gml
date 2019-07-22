/// @description  system_message_manage()

// decrement system message timer and reset message to blank when it bottoms out

if(system_message_timer >= 0)
    system_message_timer--;
    
if(system_message_timer < 0)
    system_message = "";
