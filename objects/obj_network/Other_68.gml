var type = async_load[? "type"];

switch (type) {
    case network_type_connect:
        if (global.is_host) {
            global.client_socket = async_load[? "socket"];
            connected = true;
            global.online_connected = true;
            global.online_selection.p2_active = true;
        } else {
            global.client_socket = async_load[? "socket"];
            connected = true;
            global.online_connected = true;
        }
        break;

    case network_type_disconnect:
        if (global.is_host) {
            global.client_socket = noone;
            connected = false;
            global.online_connected = false;
            global.online_selection.p2_active = false;
            global.online_selection.p2_ready = false;
            global.online_input = [array_create(7,false),array_create(7,false),array_create(7,false)];
        } else {
            connected = false;
            global.online_connected = false;
            global.online_connection_lost = true;
        }
        break;

    case network_type_data:
        var buffer = async_load[? "buffer"];
        buffer_seek(buffer, buffer_seek_start, 0);
        var msg_id = buffer_read(buffer, buffer_u8);

        if (msg_id == 20 || msg_id == 21) { online_receive(msg_id,buffer); break; }
        // Recebe dados do jogador remoto
        if (msg_id == 10 && global.is_host && global.online_selection.p2_active) {
            var choice = buffer_read(buffer, buffer_u8);
            var ready = buffer_read(buffer, buffer_bool);
            var back = buffer_read(buffer, buffer_bool);
            if (choice >= 0 && choice < 4 && choice != global.online_selection.p1_choice) {
                global.online_selection.p2_choice = choice;
                global.online_selection.p2_ready = ready;
                global.online_selection.p2_back = back;
                if (ready && global.online_selection.p1_ready && global.online_selection.p2_active) {
                    with (obj_frontend) frontend_character_continue();
                }
            }
        }
        else if (msg_id == 11 && !global.is_host) {
            // A synchronous TCP connect does not emit a client connect event.
            // The host's first selection packet acknowledges the accepted session.
            connected = true;
            global.online_connected = true;
            global.online_connection_lost = false;
            global.online_selection.p1_choice = buffer_read(buffer, buffer_u8);
            global.online_selection.p1_ready = buffer_read(buffer, buffer_bool);
            global.online_selection.p1_back = buffer_read(buffer, buffer_bool);
            global.online_selection.p2_choice = buffer_read(buffer, buffer_u8);
            global.online_selection.p2_ready = buffer_read(buffer, buffer_bool);
            global.online_selection.p2_back = buffer_read(buffer, buffer_bool);
            global.online_selection.p2_active = buffer_read(buffer, buffer_bool);
            var remote_screen = buffer_read(buffer, buffer_u8);
            global.online_selection.level = buffer_read(buffer, buffer_s8);
            global.online_selection.seed = buffer_read(buffer, buffer_u32);
            global.frontend_characters[0] = global.online_selection.p1_choice;
            global.frontend_characters[1] = global.online_selection.p2_choice;
            global.frontend_level = global.online_selection.level;
            global.online_selection.screen = remote_screen == 0 ? "characters" : (remote_screen == 1 ? "levels" : "game");
        }
        else if (msg_id == 1) {
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
