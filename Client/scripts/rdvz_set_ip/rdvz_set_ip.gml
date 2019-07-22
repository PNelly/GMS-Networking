/// @description  rdvz_set_ip(ip_string)

// set meetup server ip address to user input string

var _ip = string(argument0);

rendevouz_ip = _ip;
system_message_set("meetup server ip set to: "+_ip);
