function scr_player_get_inputs() {
    if (playerid == 1) {
        // Controles P1
        return {
            up:             keyboard_check(ord("W")),
            down:           keyboard_check(ord("S")),
            left:           keyboard_check(ord("A")),
            right:          keyboard_check(ord("D")),
            pick:           keyboard_check_pressed(vk_lshift),
            action_hold:    keyboard_check(vk_lcontrol),
            action_release: keyboard_check_released(vk_lcontrol),
            dash:           keyboard_check_pressed(vk_lalt)
        };
    } else {
        // Controles P2
        return {
            up:             keyboard_check(vk_up),
            down:           keyboard_check(vk_down),
            left:           keyboard_check(vk_left),
            right:          keyboard_check(vk_right),
            pick:           keyboard_check_pressed(vk_rshift),
            action_hold:    keyboard_check(vk_rcontrol),
            action_release: keyboard_check_released(vk_rcontrol),
            dash:           keyboard_check_pressed(vk_ralt)
        };
    }
}

function scr_player_step() {
    var in = scr_player_get_inputs();

    // Movimentação e Dash
    if (dash_cooldown > 0) dash_cooldown--;

    if (!is_dashing) {
        var input_x = in.right - in.left;
        var input_y = in.down - in.up;

        if (input_x != 0 || input_y != 0) {
            move_dir = point_direction(0, 0, input_x, input_y);

            var vx = lengthdir_x(move_spd, move_dir);
            var vy = lengthdir_y(move_spd, move_dir);

            move_and_collide(vx, vy, obj_wall);

            if (in.dash && dash_cooldown <= 0) {
                is_dashing = true;
                dash_time = dash_time_max;
                dash_cooldown = dash_cooldown_max;
            }
        }
    } else {
        var dash_vx = lengthdir_x(dash_spd, move_dir);
        var dash_vy = lengthdir_y(dash_spd, move_dir);

        move_and_collide(dash_vx, dash_vy, obj_wall);

        dash_time--;
        if (dash_time <= 0) is_dashing = false;
    }

    // Posição do item segurado nas mãos
    if (held_item != noone && instance_exists(held_item)) {
        var offset_dist = 14;
        
        held_item.x = x + lengthdir_x(offset_dist, move_dir);
        held_item.y = y + lengthdir_y(offset_dist, move_dir) - 6;

        // Ajuste de profundidade (atrás do player se olhar para cima)
        if (move_dir >= 45 && move_dir <= 135) {
            held_item.depth = depth + 1;
        } else {
            held_item.depth = depth - 1;
        }
    }

    // Pegar ou soltar item
    if (in.pick) {
        if (held_item == noone) {
            var check_x = x + lengthdir_x(20, move_dir);
            var check_y = y + lengthdir_y(20, move_dir);
            
            var item_found = instance_position(check_x, check_y, obj_item_main);

            if (item_found == noone) {
                item_found = instance_nearest(x, y, obj_item_main);
                if (item_found != noone && distance_to_object(item_found) > 24) {
                    item_found = noone;
                }
            }

            if (item_found != noone && !item_found.is_held && !item_found.is_thrown) {
                held_item = item_found;
                held_item.is_held = true;
                held_item.holder = id;
            }
        } 
        else {
            held_item.is_held = false;
            held_item.holder = noone;
            held_item.x = x + lengthdir_x(16, move_dir);
            held_item.y = y + lengthdir_y(16, move_dir);
            held_item = noone;
            throw_charge = 0;
        }
    }

    // Carga e arremesso do item
    if (held_item != noone) {
        if (in.action_hold) {
            throw_charge = min(throw_charge + 1, throw_charge_max);
        }

        if (in.action_release) {
            var charge_ratio = throw_charge / throw_charge_max;
            
            // Define a velocidade inicial baseada no tempo de carga
            var initial_spd = lerp(6, 15, charge_ratio);

            held_item.is_held = false;
            held_item.holder = noone;
            held_item.is_thrown = true;
            held_item.throw_dir = move_dir;
            held_item.throw_spd = initial_spd;

            held_item = noone;
            throw_charge = 0;
        }
    } else {
        throw_charge = 0;
    }
}