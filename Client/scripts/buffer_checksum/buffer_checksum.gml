/// @description  buffer_checksum(offset,buffer,length)

// read over the given buffer and sum all the bytes between
// offset position and the end

var _offset = argument0;
var _buffer = argument1;
var _size	= argument2;

var _sum		= 0;
var _start_pos	= buffer_tell(_buffer);

// check empty buffer

if(_size == 0 || buffer_get_size(_buffer) == 0)
	return 0;

buffer_seek(_buffer,buffer_seek_start,_offset);

// check offset carried outside buffer length

if(buffer_tell(_buffer) >= _size
|| buffer_tell(_buffer) >= buffer_get_size(_buffer)){
	
	buffer_seek(_buffer,buffer_seek_start,_start_pos);
	return 0;
}

// calculate checksum

while(buffer_tell(_buffer) < _size)
    _sum += buffer_read(_buffer,buffer_u8);

// leave buffer as found

buffer_seek(_buffer,buffer_seek_start,_start_pos);

return _sum;
