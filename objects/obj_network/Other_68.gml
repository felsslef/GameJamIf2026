var type = async_load[? "type"];

switch (type) {
    case network_type_connect:
        if (global.is_host) {
            global.client_socket = async_load[? "socket"];
        }
        break;

    case network_type_disconnect:
        if (global.is_host) {
            global.client_socket = noone;
        }
        break;

    case network_type_data:
        var buffer = async_load[? "buffer"];
        buffer_seek(buffer, buffer_seek_start, 0);
        var msg_id = buffer_read(buffer, buffer_u8);

        if (msg_id == 1) { // Dados de Posição de Jogador
            var r_id = buffer_read(buffer, buffer_u8);
            var r_x = buffer_read(buffer, buffer_f32);
            var r_y = buffer_read(buffer, buffer_f32);
            var r_dir = buffer_read(buffer, buffer_f32);
            var r_dash = buffer_read(buffer, buffer_bool);

            with (obj_player) {
                if (!is_local && playerid == r_id) {
                    x = r_x;
                    y = r_y;
                    move_dir = r_dir;
                    is_dashing = r_dash;
                }
            }
        }
        break;
}