/// @description  udp_client_manage_migrate_verify()

// *if* this client is *not* the current backup host, manage sending
// of notice packets to the backup host that this client has lost
// connection with host

if(!udp_is_client()) exit;

if(udp_client_is_next_host()) exit;

var _send_notice = false;

if(migrate_verify_timer >= 0){
    --migrate_verify_timer;
    if(migrate_verify_timer == 0){
        _send_notice = true;
        migrate_verify_timer = migrate_verify_interval;
    }
}

if(!_send_notice) exit;

var _backup_host = udp_client_get_next_host();

if(!ds_map_exists(udp_client_maps,_backup_host)) exit;

show_debug_message("Client sending notice to backup host: "+string(_backup_host));

var _map = udp_client_maps[? _backup_host];

var _backup_host_ip     = _map[? "ip"];
var _backup_host_port   = _map[? "host_port"];

buffer_seek(message_buffer,buffer_seek_start,udp_header_size);
buffer_write(message_buffer,buffer_s32,udp_id);

udp_client_write_header(
    message_buffer,
    udp_msg.udp_migrate_lost_host,
    false,
	0, 1, 1,
	buffer_tell(message_buffer)
);

udp_send_packet(
    udp_client_socket,
    _backup_host_ip,
    _backup_host_port,
    message_buffer
);
