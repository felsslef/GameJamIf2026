/// Offline levels use editor-placed room instances and stay isolated from the LAN prototype.
function recycling_level_init() {
    display_set_gui_size(1280, 720);
    if (!layer_exists("Items")) layer_create(-1, "Items");
    if (!variable_global_exists("recycling_rng_ready")) { randomize(); global.recycling_rng_ready = true; }
    if (!variable_global_exists("game_mode")) global.game_mode = "solo";
    if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
    if (!variable_global_exists("frontend_level_completed")) global.frontend_level_completed = array_create(5, false);
    var level_rooms = [rm_level_01, rm_level_02, rm_level_03, rm_level_04, rm_level_05];
    level_index = room == rm_tutorial ? -1 : 0;
    for (var room_index = 0; room_index < 5; room_index++) if (room == level_rooms[room_index]) level_index = room_index;
    global.frontend_level = level_index;
    phase_state = "playing";
    start_countdown = 3.65;
    result_reason = "";
    time_remaining = level_duration;
    star_goals = [minimum_goal, star_goal_two, star_goal_three];
    robot_star_goals = [robot_minimum, robot_star_two, robot_star_three];
    result_stars = 0;
    result_started = current_time;
    result_is_timeout = false;
    camera_base_x = camera_get_view_x(view_camera[0]);
    camera_base_y = camera_get_view_y(view_camera[0]);
    recycled_total = 0;
    sorted_total = 0;
    robot_total = 0;
    overflow_elapsed = 0;
    feedback = "Separe os resíduos e envie a carga do caminhão.";
    feedback_timer = 6;
    // The room editor owns the instances, positions and appearance.
    workshop_layout_init();
    has_construction = instance_exists(obj_science_bench);
    if (processing_enabled) processing_level_init();
    else for (var i = 0; i < array_length(dispensers); i++) {
        var source = dispensers[i];
        repeat (min(4, source.capacity)) array_push(source.queue, recycling_next_entry(source));
    }
    if (room == rm_tutorial && instance_exists(obj_tutorial)) tutorial_setup();
    // Artwork is the editable background layer; this controller only draws the HUD.
    depth = 50;
}


function recycling_feedback(_message) {
    with (obj_recycling_level) {
        feedback = _message;
        feedback_timer = 2.5;
    }
}

function recycling_finish(_won, _reason) {
    if (phase_state != "playing") return;
    phase_state = _won ? "won" : "lost";
    result_started = current_time;
    result_is_timeout = !instance_exists(obj_tutorial) && time_remaining <= 0;
    camera_set_view_pos(view_camera[0], camera_base_x, camera_base_y);
    result_reason = _reason;
    result_stars = 0;
    if (_won) {
        if (level_index == -1) {
            result_stars = 3;
            save_slots_init();
            global.frontend_tutorial_completed = true;
            save_slot_write();
            return;
        }
        for (var i = 0; i < 3; i++) {
            if (recycled_total >= star_goals[i] && (!has_construction || robot_total >= robot_star_goals[i])) result_stars++;
        }
        global.frontend_level_completed[level_index] = true;
        save_slots_init();
        global.frontend_level_stars[level_index] = max(global.frontend_level_stars[level_index], result_stars);
        save_slot_write();
    }
}

function recycling_level_tick(_dt) {
    if (phase_state != "playing") return;
    if (start_countdown > 0) return;
    if (instance_exists(obj_tutorial)) { tutorial_tick(_dt); return; }
    time_remaining = max(0, time_remaining - _dt);
    feedback_timer = max(0, feedback_timer - _dt);
    if (processing_enabled) { processing_tick(_dt); return; }
    if (has_construction) construction_tick(_dt);
    truck.trip_remaining = max(0, truck.trip_remaining - _dt);
    overflow_elapsed = 0;
    for (var i = 0; i < array_length(dispensers); i++) {
        var source = dispensers[i];
        source.spawn_timer -= _dt;
        while (source.spawn_timer <= 0 && array_length(source.queue) < source.capacity) {
            array_push(source.queue, recycling_next_entry(source));
            source.spawn_timer += source.spawn_interval;
        }
        if (array_length(source.queue) >= source.capacity) {
            source.spawn_timer = max(0, source.spawn_timer);
            source.overflow_elapsed += _dt;
        } else source.overflow_elapsed = 0;
        overflow_elapsed = max(overflow_elapsed, source.overflow_elapsed);
    }
    if (overflow_elapsed >= overflow_limit) {
        recycling_finish(false, "O dispenser ficou cheio por muito tempo.");
    } else if (time_remaining <= 0) {
        var goal_met = recycled_total >= minimum_goal && (!has_construction || robot_total >= robot_minimum);
        recycling_finish(goal_met,
            goal_met ? "Mutirão concluído!" : (has_construction ? "Faltou reciclar ou entregar robôs." : "A meta de reciclagem não foi atingida."));
    }
}

function recycling_level_update() {
    if (session_ui_transition_active()) return;
    if (processing_enabled) {
        for (var departure_index=array_length(robot_departures)-1;departure_index>=0;departure_index--) {
            robot_departures[departure_index].age += min(0.05,max(0,delta_time/1000000));
            if (robot_departures[departure_index].age>=0.9) array_delete(robot_departures,departure_index,1);
        }
    }
    if (phase_state == "playing" && recycling_start_tick(max(0,delta_time/1000000))) return;
    var reduced = variable_global_exists("frontend_reduced_motion") && global.frontend_reduced_motion;
    var urgent = phase_state == "playing" && !instance_exists(obj_tutorial) && time_remaining <= 15;
    var beat = 1 - frac(max(0, time_remaining));
    var shake = urgent && !reduced && beat < 0.16 ? (time_remaining <= 5 ? 3 : 1.5) : 0;
    camera_set_view_pos(view_camera[0], camera_base_x + sin(current_time * 0.09) * shake, camera_base_y + cos(current_time * 0.11) * shake);
    if (phase_state == "playing") {
        recycling_level_tick(max(0, delta_time / 1000000));
        return;
    }
    if (current_time - result_started < (result_is_timeout ? 1250 : 0) + (reduced ? 0 : 400)) return;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var next_available = recycling_result_has_next();
    var clicked = mouse_check_button_pressed(mb_left);
    var retry_x = next_available ? 320 : 400;
    var map_x = next_available ? 540 : 660;
    var button_width = next_available ? 200 : 220;
    if (next_available && (keyboard_check_pressed(vk_enter) || (clicked && point_in_rectangle(mx,my,760,470,960,522)))) {
        var levels = [rm_level_01,rm_level_02,rm_level_03,rm_level_04,rm_level_05];
        global.frontend_level = level_index + 1;
        session_ui_change_room(levels[global.frontend_level]);
    } else if (keyboard_check_pressed(ord("R")) || (clicked && point_in_rectangle(mx,my,retry_x,470,retry_x+button_width,522))) session_ui_change_room(room);
    else if (keyboard_check_pressed(vk_escape) || (!next_available && keyboard_check_pressed(vk_enter))
        || (clicked && point_in_rectangle(mx,my,map_x,470,map_x+button_width,522))) session_ui_change_room(rm_level_select);
}

function recycling_result_has_next() {
    return phase_state == "won" && level_index >= -1 && level_index < 4;
}

function recycling_draw_result_buttons() {
    var next_available = recycling_result_has_next();
    var labels = next_available ? ["Repetir", "Mapa", "Próxima fase"] : ["Tentar de novo", "Mapa"];
    var width = next_available ? 200 : 220;
    var start_x = next_available ? 320 : 400;
    var dark = make_color_rgb(35,57,64);
    for (var i=0;i<array_length(labels);i++) {
        var bx = start_x+i*(width+20);
        var hover = point_in_rectangle(device_mouse_x_to_gui(0),device_mouse_y_to_gui(0),bx,470,bx+width,522);
        frontend_panel(bx,470,width,52,hover?make_color_rgb(226,238,222):c_white,dark);
        frontend_text(bx+width/2,482,labels[i],fnt_ui_body,dark,fa_center);
    }
}

function recycling_station_distance(_px, _py, _station) {
    var nearest_x = clamp(_px, _station.x - _station.station_width * abs(_station.image_xscale) / 2, _station.x + _station.station_width * abs(_station.image_xscale) / 2);
    var nearest_y = clamp(_py, _station.y - _station.station_height * abs(_station.image_yscale) / 2, _station.y + _station.station_height * abs(_station.image_yscale) / 2);
    return point_distance(_px, _py, nearest_x, nearest_y);
}

function recycling_nearest_station(_player) {
    var found = noone;
    var nearest_distance = 58;
    var level = obj_recycling_level;
    for (var i = 0; i < array_length(level.stations); i++) {
        var station = level.stations[i];
        if (variable_instance_exists(station, "tutorial_unlocked") && !station.tutorial_unlocked) continue;
        if (station.station_kind == "divider") continue;
        var station_distance = recycling_station_distance(_player.x, _player.y, station);
        if (station_distance < nearest_distance) {
            nearest_distance = station_distance;
            found = station;
        }
    }
    return found;
}

function recycling_position_clear(_px, _py) {
    if (_px < 64 * room_width / 1280 || _px > room_width - 64 * room_width / 1280
        || _py < 154 * room_height / 720 || _py > room_height - 56 * room_height / 720) return false;
    var level = obj_recycling_level;
    for (var i = 0; i < array_length(level.stations); i++) {
        if (variable_instance_exists(level.stations[i], "tutorial_unlocked") && !level.stations[i].tutorial_unlocked) continue;
        if (recycling_station_distance(_px, _py, level.stations[i]) < 15) return false;
    }
    return true;
}

function recycling_give_item(_player, _kind, _type, _amount) {
    var item_object = recycling_item_object(_kind, _type);
    var item = instance_create_layer(_player.x, _player.y, "Items", item_object);
    item.item_kind = _kind;
    item.trash_type = _type;
    item.amount = _amount;
    item.is_held = true;
    item.holder = _player;
    _player.carried_item = item;
    return item;
}

function recycling_consume_item(_player) {
    if (instance_exists(_player.carried_item)) instance_destroy(_player.carried_item);
    _player.carried_item = noone;
}

function recycling_thrown_item_can_interact(_item, _station) {
    var level = obj_recycling_level;
    if (level.processing_enabled) {
        if (!variable_instance_exists(_item, "process_state")) {
            return false;
        }
        var state = _item.process_state;
        switch (_station.station_kind) {
            case "bin":
                var types = ["sorted_paper", "sorted_plastic", "sorted_glass", "sorted_metal"];
                return state == types[_station.trash_type] && _station.load < _station.capacity;
            case "handoff": return is_undefined(_station.stored_item);
            case "dispatch": return processing_is_final(state) && _station.trip_remaining <= 0;
            case "trash": return false;
            case "extinguisher_rack": return state == "extinguisher";
            case "intake": return state == "raw_waste" && array_length(_station.queue) < _station.capacity;
            default:
                return is_undefined(_station.buffer)
                    && processing_station_accepts(_station.station_kind, state);
        }
    }

    switch (_station.station_kind) {
        case "handoff": return is_undefined(_station.stored_item);
        case "bin":
            return _item.item_kind == "waste" && _item.trash_type == _station.trash_type
                && _station.load < _station.capacity;
        case "truck":
            return _item.item_kind == "bag" && _station.trip_remaining <= 0
                && _station.load + _item.amount <= _station.capacity;
        case "bench":
            return _item.item_kind == "part" && !_station.module_ready && _station.build_remaining <= 0
                && !_station.parts[_item.trash_type];
        case "storage": return _item.item_kind == "robot";
        case "dispenser":
            return (_item.item_kind == "waste" || _item.item_kind == "part")
                && array_length(_station.queue) < _station.capacity;
    }
    return false;
}

function recycling_thrown_item_interact(_item, _station) {
    var thrower = _item.thrower;
    if (!instance_exists(thrower)) {
        _item.is_held = false;
        _item.holder = noone;
        _item.is_thrown = false;
        _item.throw_spd = 0;
        _item.x = _station.x;
        _item.y = _station.y;
        return;
    }

    thrower.carried_item = _item;
    _item.is_held = true;
    _item.holder = thrower;
    if (obj_recycling_level.processing_enabled) processing_interact(thrower, _station);
    else recycling_interact(thrower, _station);

    // If the station rejects the item, leave it placed on that station.
    if (instance_exists(_item) && thrower.carried_item == _item) {
        thrower.carried_item = noone;
        _item.is_held = false;
        _item.holder = noone;
        _item.is_thrown = false;
        _item.throw_spd = 0;
        _item.x = _station.x;
        _item.y = _station.y;
    }
}

function recycling_interact(_player, _station_override = noone) {
    var level = obj_recycling_level;
    if (level.phase_state != "playing") return;
    if (level.processing_enabled) { processing_interact(_player, _station_override); return; }
    var station = instance_exists(_station_override) ? _station_override : recycling_nearest_station(_player);
    if (!instance_exists(_player.carried_item)) _player.carried_item = noone;
    var item = _player.carried_item;
    if (station != noone && station.station_kind == "handoff") { split_level_handoff(_player, station); return; }
    if (station != noone && (station.station_kind == "bench" || station.station_kind == "storage")) {
        construction_interact(_player, station); return;
    }
    if (item != noone) {
        if (station != noone) {
            if (station.station_kind == "bin") {
                if (item.item_kind != "waste") recycling_feedback("Leve o saco ao caminhão.");
                else if (item.trash_type != station.trash_type) recycling_feedback("Esse resíduo pertence a outra lixeira.");
                else if (station.load >= station.capacity) recycling_feedback("Lixeira cheia! Pegue o saco com as mãos vazias.");
                else {
                    station.load++;
                    level.sorted_total++;
                    recycling_consume_item(_player);
                    recycling_feedback(station.load >= station.capacity ? "Lixeira cheia: leve o saco ao caminhão." : "Resíduo separado!");
                }
            } else if (station.station_kind == "truck") {
                if (station.trip_remaining > 0) recycling_feedback("O caminhão ainda está voltando.");
                else if (item.item_kind != "bag") recycling_feedback("Separe o resíduo na lixeira primeiro.");
                else if (station.load + item.amount > station.capacity) recycling_feedback("Caminhão sem espaço. Envie a carga com as mãos vazias.");
                else {
                    station.load += item.amount;
                    recycling_consume_item(_player);
                    recycling_feedback("Carga recebida. Com as mãos vazias, envie o caminhão.");
                }
            } else {
                if ((item.item_kind == "waste" || item.item_kind == "part") && array_length(station.queue) < station.capacity) {
                    array_push(station.queue, item.trash_type + (item.item_kind == "part" ? 4 : 0));
                    recycling_consume_item(_player);
                } else recycling_feedback("Não há espaço no dispenser.");
            }
        } else {
            var drop_x = _player.x + lengthdir_x(38, _player.move_dir);
            var drop_y = _player.y + lengthdir_y(38, _player.move_dir);
            if (!recycling_position_clear(drop_x, drop_y)) {
                drop_x = _player.x;
                drop_y = _player.y;
            }
            item.is_held = false;
            item.holder = noone;
            item.x = drop_x;
            item.y = drop_y;
            _player.carried_item = noone;
        }
        return;
    }
    var loose_item = noone;
    var nearest_distance = 42;
    with (obj_recycling_item) {
        var item_distance = point_distance(x, y, _player.x, _player.y);
        if (!is_held && !is_thrown && item_distance < nearest_distance) {
            nearest_distance = item_distance;
            loose_item = id;
        }
    }
    if (loose_item != noone) {
        loose_item.is_held = true;
        loose_item.holder = _player;
        _player.carried_item = loose_item;
    } else if (station != noone) {
        if (station.station_kind == "dispenser") {
            if (array_length(station.queue) > 0) {
                var taken_type = recycling_dispenser_take(station);
                level.overflow_elapsed = 0;
                recycling_give_item(_player, taken_type >= 4 ? "part" : "waste", taken_type mod 4, 1);
            } else recycling_feedback("O próximo resíduo está chegando.");
        } else if (station.station_kind == "bin") {
            if (station.load > 0) {
                recycling_give_item(_player, "bag", station.trash_type, station.load);
                station.load = 0;
                recycling_feedback("Leve o saco ao caminhão.");
            } else recycling_feedback("Lixeira vazia.");
        } else if (station.trip_remaining > 0) recycling_feedback("O caminhão ainda está voltando.");
        else if (station.load > 0) {
            level.recycled_total += station.load;
            station.load = 0;
            station.trip_remaining = station.return_duration;
            recycling_feedback("Carga enviada para reciclagem!");
        } else recycling_feedback("Coloque os sacos no caminhão.");
    }
}

function recycling_player_step() {
    if (session_ui_transition_active()) return;
    if (instance_exists(obj_recycling_level) && obj_recycling_level.start_countdown > 0) return;
    if (!instance_exists(obj_recycling_level) || obj_recycling_level.phase_state != "playing") return;
    if (obj_recycling_level.processing_enabled && stun_remaining > 0) { is_dashing = false; return; }
    var use_arrows = global.game_mode == "coop_local" && playerid == 2;
    var prefix = use_arrows ? "p2_" : "p1_";
    var move_x = keyboard_check(frontend_keybinding(prefix + "right")) - keyboard_check(frontend_keybinding(prefix + "left"));
    var move_y = keyboard_check(frontend_keybinding(prefix + "down")) - keyboard_check(frontend_keybinding(prefix + "up"));
    var dt = max(0, delta_time / 1000000);
    var directions = ["up", "down", "left", "right"];
    var tapped_direction = -1;
    for (var direction_index = 0; direction_index < 4; direction_index++) {
        if (keyboard_check_pressed(frontend_keybinding(prefix + directions[direction_index]))) tapped_direction = direction_index;
    }
    var dash_direction = recycling_player_dash_input(dt, tapped_direction);
    var dash_pressed = dash_direction >= 0 || keyboard_check_pressed(frontend_keybinding(prefix + "dash"));
    if (dash_direction >= 0) {
        var angles = [90, 270, 180, 0];
        move_x = lengthdir_x(1, angles[dash_direction]);
        move_y = lengthdir_y(1, angles[dash_direction]);
    }
    recycling_player_movement(min(0.05, dt), move_x, move_y, dash_pressed);
    depth = -y;
    var interact = keyboard_check_pressed(frontend_keybinding(prefix + "interact"));
    var interact_held = keyboard_check(frontend_keybinding(prefix + "interact"));
    var action_key = frontend_keybinding(prefix + "action");
    var action_held = keyboard_check(action_key);
    var action_released = keyboard_check_released(action_key);
    // Tap to pick up/place, or keep the same button held to work or extinguish.
    if (obj_recycling_level.processing_enabled) processing_player_action(id, interact_held, interact, dt);
    else if (interact) recycling_interact(id);

    if (instance_exists(obj_tutorial) && instance_exists(carried_item)) { throw_charge = 0; return; }
    if (instance_exists(carried_item) && obj_recycling_level.processing_enabled
        && variable_instance_exists(carried_item, "process_state") && carried_item.process_state == "extinguisher") {
        throw_charge = 0;
    } else if (instance_exists(carried_item)) {
        if (action_held) throw_charge = min(throw_charge + dt * 60, throw_charge_max);
        if (action_released) {
            var ratio = throw_charge / throw_charge_max;
            carried_item.is_held = false;
            carried_item.holder = noone;
            carried_item.is_thrown = true;
            carried_item.throw_dir = move_dir;
            carried_item.throw_spd = 0;
            carried_item.throw_peak_spd = lerp(420, 760, ratio);
            carried_item.throw_age = 0;
            carried_item.thrower = id;
            carried_item.x = x + lengthdir_x(22, move_dir);
            carried_item.y = y + lengthdir_y(22, move_dir) - 8;
            carried_item = noone;
            throw_charge = 0;
        }
    } else {
        throw_charge = 0;
    }
}

// Track each player's taps independently, using their configured movement keys.
function recycling_player_dash_input(_dt, _direction) {
    last_tap_elapsed += _dt;
    if (_direction < 0) return -1;
    var repeated = _direction == last_tap_direction && last_tap_elapsed <= double_tap_window;
    last_tap_direction = repeated ? -1 : _direction;
    last_tap_elapsed = 0;
    return repeated ? _direction : -1;
}

function recycling_dispenser_take(_station) {
    var taken_type = _station.queue[0];
    var remaining = [];
    for (var queue_index = 1; queue_index < array_length(_station.queue); queue_index++) array_push(remaining, _station.queue[queue_index]);
    _station.queue = remaining;
    obj_recycling_level.overflow_elapsed = 0;
    _station.overflow_elapsed = 0;
    return taken_type;
}

// A shuffled bag keeps the order unpredictable without starving a robot recipe.
function recycling_next_entry(_source = noone) {
    if (_source == noone) _source = dispenser;
    if (array_length(_source.spawn_bag) == 0) {
        var entry_count = has_construction ? 8 : 4;
        for (var entry_index = 0; entry_index < entry_count; entry_index++) array_push(_source.spawn_bag, entry_index);
        for (var shuffle_index = entry_count - 1; shuffle_index > 0; shuffle_index--) {
            var swap_index = irandom(shuffle_index);
            var swap_value = _source.spawn_bag[shuffle_index];
            _source.spawn_bag[shuffle_index] = _source.spawn_bag[swap_index];
            _source.spawn_bag[swap_index] = swap_value;
        }
    }
    return array_pop(_source.spawn_bag);
}

// Reuse the inherited dash speed, duration and cooldown (60 Hz frame units).
function recycling_player_movement(_dt, _move_x, _move_y, _dash_pressed) {
    dash_cooldown = max(0, dash_cooldown - _dt * 60);
    // Fade old afterimages and capture the player's position while dashing.
    for (var trail_index = array_length(dash_trail_age) - 1; trail_index >= 0; trail_index--) {
        dash_trail_age[trail_index] += _dt;
        if (dash_trail_age[trail_index] >= 0.18) {
            array_delete(dash_trail_x, trail_index, 1);
            array_delete(dash_trail_y, trail_index, 1);
            array_delete(dash_trail_age, trail_index, 1);
            array_delete(dash_trail_strength, trail_index, 1);
        }
    }
    if (!is_dashing && (_move_x != 0 || _move_y != 0)) {
        move_dir = point_direction(0, 0, _move_x, _move_y);
    }
    if (_dash_pressed && !is_dashing && dash_cooldown <= 0) {
        is_dashing = true;
        dash_time = dash_time_max;
        dash_cooldown = dash_cooldown_max;
    }
    if (character_index >= 0 && character_index <= 2) {
        var sprite_side = [spr_juLado, spr_leleLado, spr_manuLado][character_index];
        var sprite_back = [spr_juCostas, spr_leleCostas, spr_manuCostas][character_index];
        var sprite_front = [spr_juFrente, spr_leleFrente, spr_manuFrente][character_index];
        var animation_x = is_dashing ? lengthdir_x(1, move_dir) : _move_x;
        var animation_y = is_dashing ? lengthdir_y(1, move_dir) : _move_y;
        if (animation_x != 0 || animation_y != 0) {
            if (abs(animation_x) > abs(animation_y)) {
                sprite_index = sprite_side;
                image_xscale = animation_x < 0 ? -1 : 1;
            } else if (animation_y < 0) {
                sprite_index = sprite_back;
                image_xscale = 1;
            } else {
                sprite_index = sprite_front;
                image_xscale = 1;
            }
            image_speed = 0.2;
        } else {
            image_speed = 0;
            image_index = 0;
        }
    }
    if (is_dashing) {
        array_push(dash_trail_x, x);
        array_push(dash_trail_y, y);
        array_push(dash_trail_age, 0);
        array_push(dash_trail_strength, clamp(dash_time / max(1, dash_time_max), 0, 1));
        while (array_length(dash_trail_x) > 6) {
            array_delete(dash_trail_x, 0, 1);
            array_delete(dash_trail_y, 0, 1);
            array_delete(dash_trail_age, 0, 1);
            array_delete(dash_trail_strength, 0, 1);
        }
    }
    var moving = is_dashing || _move_x != 0 || _move_y != 0;
    if (moving) {
        var frame_time = is_dashing ? min(_dt * 60, dash_time) : _dt * 60;
        var travel = (is_dashing ? dash_spd : move_spd) * frame_time;
        // Short collision steps prevent fast movement from crossing a station.
        var segments = max(1, ceil(travel / 4));
        var step_x = lengthdir_x(travel / segments, move_dir);
        var step_y = lengthdir_y(travel / segments, move_dir);
        repeat (segments) {
            if (recycling_position_clear(x + step_x, y)) x += step_x;
            if (recycling_position_clear(x, y + step_y)) y += step_y;
            if (obj_recycling_level.processing_enabled && processing_check_puddle(id)) break;
        }
    }
    if (is_dashing) {
        dash_time = max(0, dash_time - _dt * 60);
        if (dash_time <= 0) is_dashing = false;
    }
}
