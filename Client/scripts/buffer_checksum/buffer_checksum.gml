/// @description  buffer_checksum(offset,buffer)

// read over the given buffer and sum all the bytes between
// offset position and the end

var _offset = argument0;
var _buffer = argument1;

var _sum = 0;
var _size = buffer_get_size(_buffer);
var _idx;
var _start_pos = buffer_tell(_buffer);

buffer_seek(_buffer,buffer_seek_start,_offset);

while(buffer_tell(_buffer) < _size){
    _sum += buffer_read(_buffer,buffer_u8);
}

// leave the buffer like we found it
buffer_seek(_buffer,buffer_seek_start,_start_pos);

return _sum;
