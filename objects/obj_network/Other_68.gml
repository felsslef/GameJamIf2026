var type = async_load[? "type"];

switch (type) {
    case network_type_connect:
        if (global.is_host) {
            global.client_socket = async_load[? "socket"];
            connected = true;
        }
        break;

    case network_type_disconnect:
        if (global.is_host) {
            global.client_socket = noone;
            connected = false;
        }
        break;

    case network_type_data:
        var buffer = async_load[? "buffer"];
        buffer_seek(buffer, buffer_seek_start, 0);
        var msg_id = buffer_read(buffer, buffer_u8);

        // Recebe dados do jogador remoto
        if (msg_id == 1) {
            var r_id   = buffer_read(buffer, buffer_u8);
            var r_x    = buffer_read(buffer, buffer_f32);
            var r_y    = buffer_read(buffer, buffer_f32);
            var r_dir  = buffer_read(buffer, buffer_f32);
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
        
        // Recebe dados dos itens
        else if (msg_id == 2) {
            var r_item_id = buffer_read(buffer, buffer_f32);
            var r_x       = buffer_read(buffer, buffer_f32);
            var r_y       = buffer_read(buffer, buffer_f32);
            var r_held    = buffer_read(buffer, buffer_bool);
            var r_holder  = buffer_read(buffer, buffer_u8);
            var r_thrown  = buffer_read(buffer, buffer_bool);

            with (obj_item_main) {
                if (item_id == r_item_id) {
                    // Atualiza apenas se não for o jogador local que está segurando
                    if (!is_held || (instance_exists(holder) && !holder.is_local)) {
                        x = r_x;
                        y = r_y;
                        is_held = r_held;
                        is_thrown = r_thrown;

                        if (r_held && r_holder != 0) {
                            with (obj_player) {
                                if (playerid == r_holder) other.holder = id;
                            }
                        } else {
                            holder = noone;
                        }
                    }
                }
            }
        }
        break;
}