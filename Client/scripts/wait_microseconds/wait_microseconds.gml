/// @description wait_microseconds(amount)

var _amount		= argument0;
var _base_time	= get_timer();

while(true){

	if(get_timer() -_base_time >= _amount)
		break;
}