/// First playable level. Offline gameplay is isolated from the existing LAN prototype.
function recycling_level_init() {
    display_set_gui_size(1280, 720);
    if (!variable_global_exists("recycling_rng_ready")) { randomize(); global.recycling_rng_ready = true; }
    if (!variable_global_exists("game_mode")) global.game_mode = "solo";
    if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
    if (!variable_global_exists("frontend_level_completed")) global.frontend_level_completed = array_create(5, false);
    var level_rooms = [rm_level_01, rm_level_02, rm_level_03, rm_level_04, rm_level_05];
    level_index = 0;
    for (var room_index = 0; room_index < 5; room_index++) if (room == level_rooms[room_index]) level_index = room_index;
    has_construction = level_index == 1 || level_index >= 3;
    global.frontend_level = level_index;
    phase_state = "playing";
    result_reason = "";
    level_duration = 120;
    time_remaining = level_duration;
    minimum_goal = 12;
    star_goals = [12, 21, 30];
    result_stars = 0;
    recycled_total = 0;
    sorted_total = 0;
    spawn_interval = 4;
    spawn_timer = spawn_interval;
    spawn_bag = [];
    overflow_limit = 12;
    overflow_elapsed = 0;
    feedback = "Separe os resíduos e envie a carga do caminhão.";
    feedback_timer = 6;
    stations = [];
    bins = [];
    dispenser = recycling_create_station("dispenser", 640, 320, 160, 100);
    dispenser.capacity = 8;
    dispenser.queue = [];
    var positions = [{x: 280, y: 240}, {x: 1000, y: 240}, {x: 280, y: 450}, {x: 1000, y: 450}];
    for (var i = 0; i < 4; i++) {
        var bin = recycling_create_station("bin", positions[i].x, positions[i].y, 112, 88);
        bin.trash_type = i;
        bin.capacity = 3;
        array_push(bins, bin);
    }
    truck = recycling_create_station("truck", 640, 592, 192, 88);
    truck.capacity = 12;
    truck.return_duration = 8;
    var player_count = global.game_mode == "coop_local" ? 2 : 1;
    for (var i = 0; i < player_count; i++) {
        var player = instance_create_layer((530 + i * 220) * room_width / 1280, 430 * room_height / 720, "Instances", obj_recycling_player);
        player.playerid = i + 1;
        player.character_index = global.frontend_characters[i];
    }
    if (has_construction) construction_level_init();
    repeat (4) array_push(dispenser.queue, recycling_next_entry());
    if (level_index == 2) split_level_init();
    workshop_layout_init();
    // Draw the floor above the room's default background (depth 100), below stations.
    depth = 50;
}

function recycling_create_station(_kind, _x, _y, _w, _h) {
    var station = instance_create_layer(_x * room_width / 1280, _y * room_height / 720, "Instances", obj_recycling_station);
    station.station_kind = _kind;
    station.station_width = _w;
    station.station_height = _h;
    array_push(stations, station);
    return station;
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
    result_reason = _reason;
    result_stars = 0;
    if (_won) {
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
    time_remaining = max(0, time_remaining - _dt);
    feedback_timer = max(0, feedback_timer - _dt);
    if (has_construction) construction_tick(_dt);
    truck.trip_remaining = max(0, truck.trip_remaining - _dt);
    if (level_index == 2) { split_level_tick(_dt); return; }
    spawn_timer -= _dt;
    while (spawn_timer <= 0 && array_length(dispenser.queue) < dispenser.capacity) {
        array_push(dispenser.queue, recycling_next_entry());
        spawn_timer += spawn_interval;
    }
    if (array_length(dispenser.queue) >= dispenser.capacity) {
        spawn_timer = max(0, spawn_timer);
        overflow_elapsed += _dt;
    } else overflow_elapsed = 0;
    if (overflow_elapsed >= overflow_limit) {
        recycling_finish(false, "O dispenser ficou cheio por muito tempo.");
    } else if (time_remaining <= 0) {
        var goal_met = recycled_total >= minimum_goal && (!has_construction || robot_total >= robot_minimum);
        recycling_finish(goal_met,
            goal_met ? "Mutirão concluído!" : (has_construction ? "Faltou reciclar ou entregar robôs." : "A meta de reciclagem não foi atingida."));
    }
}

function recycling_level_update() {
    if (phase_state == "playing") {
        recycling_level_tick(max(0, delta_time / 1000000));
        return;
    }
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    if (keyboard_check_pressed(ord("R")) || (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(mx, my, 400, 470, 620, 522))) room_restart();
    else if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)
        || (mouse_check_button_pressed(mb_left) && point_in_rectangle(mx, my, 660, 470, 880, 522))) {
        room_goto(rm_level_select);
    }
}

function recycling_station_distance(_px, _py, _station) {
    var nearest_x = clamp(_px, _station.x - _station.station_width / 2, _station.x + _station.station_width / 2);
    var nearest_y = clamp(_py, _station.y - _station.station_height / 2, _station.y + _station.station_height / 2);
    return point_distance(_px, _py, nearest_x, nearest_y);
}

function recycling_nearest_station(_player) {
    var found = noone;
    var nearest_distance = 58;
    var level = obj_recycling_level;
    for (var i = 0; i < array_length(level.stations); i++) {
        var station = level.stations[i];
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
        if (recycling_station_distance(_px, _py, level.stations[i]) < 15) return false;
    }
    return true;
}

function recycling_give_item(_player, _kind, _type, _amount) {
    var item = instance_create_layer(_player.x, _player.y, "Instances", obj_recycling_item);
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

function recycling_interact(_player) {
    var level = obj_recycling_level;
    if (level.phase_state != "playing") return;
    var station = recycling_nearest_station(_player);
    if (!instance_exists(_player.carried_item)) _player.carried_item = noone;
    var item = _player.carried_item;
    if (station != noone && station.station_kind == "handoff") { split_level_handoff(_player, station); return; }
    if (station != noone && (station.station_kind == "bench" || station.station_kind == "storage")) {
        construction_interact(_player); return;
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
        if (!is_held && item_distance < nearest_distance) {
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
    if (!instance_exists(obj_recycling_level) || obj_recycling_level.phase_state != "playing") return;
    var use_arrows = global.game_mode == "coop_local" && playerid == 2;
    var move_x = use_arrows ? keyboard_check(vk_right) - keyboard_check(vk_left) : keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var move_y = use_arrows ? keyboard_check(vk_down) - keyboard_check(vk_up) : keyboard_check(ord("S")) - keyboard_check(ord("W"));
    var tapped_direction = -1;
    if (keyboard_check_pressed(use_arrows ? vk_right : ord("D"))) tapped_direction = 0;
    if (keyboard_check_pressed(use_arrows ? vk_up : ord("W"))) tapped_direction = 1;
    if (keyboard_check_pressed(use_arrows ? vk_left : ord("A"))) tapped_direction = 2;
    if (keyboard_check_pressed(use_arrows ? vk_down : ord("S"))) tapped_direction = 3;
    recycling_player_movement(min(0.05, delta_time / 1000000), move_x, move_y, tapped_direction);
    depth = -y;
    var command = use_arrows
        ? keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_rshift)
        : keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_lshift);
    if (command) recycling_interact(id);
}

function recycling_dispenser_take(_station) {
    var taken_type = _station.queue[0];
    var remaining = [];
    for (var queue_index = 1; queue_index < array_length(_station.queue); queue_index++) array_push(remaining, _station.queue[queue_index]);
    _station.queue = remaining;
    obj_recycling_level.overflow_elapsed = 0;
    if (obj_recycling_level.level_index == 2) _station.overflow_elapsed = 0;
    return taken_type;
}

// A shuffled bag keeps the order unpredictable without starving a robot recipe.
function recycling_next_entry() {
    if (array_length(spawn_bag) == 0) {
        var entry_count = has_construction ? 8 : 4;
        for (var entry_index = 0; entry_index < entry_count; entry_index++) array_push(spawn_bag, entry_index);
        for (var shuffle_index = entry_count - 1; shuffle_index > 0; shuffle_index--) {
            var swap_index = irandom(shuffle_index);
            var swap_value = spawn_bag[shuffle_index];
            spawn_bag[shuffle_index] = spawn_bag[swap_index];
            spawn_bag[swap_index] = swap_value;
        }
    }
    return array_pop(spawn_bag);
}

// Reuse the inherited dash speed, duration and cooldown (60 Hz frame units).
function recycling_player_movement(_dt, _move_x, _move_y, _tapped_direction) {
    tap_remaining = max(0, tap_remaining - _dt);
    dash_cooldown = max(0, dash_cooldown - _dt * 60);
    if (_tapped_direction >= 0) {
        if (_tapped_direction == last_tap_direction && tap_remaining > 0
            && !is_dashing && dash_cooldown <= 0) {
            is_dashing = true;
            dash_time = dash_time_max;
            dash_cooldown = dash_cooldown_max;
            move_dir = _tapped_direction * 90;
            last_tap_direction = -1;
            tap_remaining = 0;
        } else {
            last_tap_direction = _tapped_direction;
            tap_remaining = double_tap_window;
        }
    }
    if (!is_dashing && (_move_x != 0 || _move_y != 0)) {
        move_dir = point_direction(0, 0, _move_x, _move_y);
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
        }
    }
    if (is_dashing) {
        dash_time = max(0, dash_time - _dt * 60);
        if (dash_time <= 0) is_dashing = false;
    }
}
