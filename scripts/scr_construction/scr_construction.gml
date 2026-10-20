function construction_level_init() {
    // Keep the four bins and the truck created by the recycling level.
    robot_total = 0;
    robot_minimum = 2;
    robot_star_goals = [2, 3, 4];
    spawn_interval = 2;
    spawn_timer = spawn_interval;
    // Waste and electronic parts share the randomized dispenser queue.
    for (var bench_index = 0; bench_index < 2; bench_index++) {
        var bench = recycling_create_station("bench", 440 + bench_index * 400, 185, 144, 80);
        bench.parts = [false, false, false, false];
        bench.build_remaining = 0;
        bench.module_ready = false;
    }
    recycling_create_station("storage", 1000, 592, 172, 88);
    if (level_index >= 3) {
        minimum_goal = level_index == 3 ? 16 : 20;
        star_goals = level_index == 3 ? [16, 24, 32] : [20, 28, 36];
        robot_minimum = level_index == 3 ? 3 : 4;
        robot_star_goals = level_index == 3 ? [3, 4, 5] : [4, 5, 6];
        spawn_interval = level_index == 3 ? 1.8 : 1.5;
        spawn_timer = spawn_interval;
        dispenser.capacity = level_index == 3 ? 7 : 6;
        overflow_limit = level_index == 3 ? 10 : 8;
        truck.capacity = level_index == 3 ? 12 : 9;
        truck.return_duration = level_index == 3 ? 10 : 12;
    }
    feedback = "Recicle e monte robôs com as peças do mesmo dispenser.";
}

function construction_tick(_dt) {
    with (obj_recycling_station) {
        if (station_kind == "bench" && build_remaining > 0) {
            build_remaining = max(0, build_remaining - _dt);
            if (build_remaining == 0) module_ready = true;
        }
    }
}

function construction_drop(_player, _item) {
    var drop_x = _player.x + lengthdir_x(38, _player.move_dir);
    var drop_y = _player.y + lengthdir_y(38, _player.move_dir);
    if (!recycling_position_clear(drop_x, drop_y)) { drop_x = _player.x; drop_y = _player.y; }
    _item.is_held = false;
    _item.holder = noone;
    _item.x = drop_x;
    _item.y = drop_y;
    _player.carried_item = noone;
}

function construction_interact(_player) {
    var station = recycling_nearest_station(_player);
    var item = _player.carried_item;
    if (!instance_exists(item)) item = noone;
    if (item != noone) {
        if (station == noone) { construction_drop(_player, item); return; }
        switch (station.station_kind) {
            case "bench":
                if (station.module_ready || station.build_remaining > 0) { recycling_feedback("Retire o robô para liberar a bancada."); return; }
                if (item.item_kind != "part") { recycling_feedback("Leve o robô à área de entrega."); return; }
                if (station.parts[item.trash_type]) { recycling_feedback("Essa peça já está na bancada."); return; }
                station.parts[item.trash_type] = true;
                recycling_consume_item(_player);
                var complete = true;
                for (var part_index = 0; part_index < 4; part_index++) if (!station.parts[part_index]) complete = false;
                if (complete) station.build_remaining = 3;
                break;
            case "storage":
                if (item.item_kind != "robot") { recycling_feedback("Monte as quatro peças na bancada primeiro."); return; }
                obj_recycling_level.robot_total++;
                recycling_consume_item(_player);
                recycling_feedback("Robô entregue!");
                break;
            case "dispenser":
                if (item.item_kind == "part" && array_length(station.queue) < station.capacity) {
                    array_push(station.queue, item.trash_type);
                    recycling_consume_item(_player);
                } else recycling_feedback("Não há espaço para este item.");
                break;
        }
        return;
    }
    if (station == noone) return;
    if (station.station_kind == "bench") {
        if (station.module_ready) {
            recycling_give_item(_player, "robot", 0, 1);
            station.module_ready = false;
            station.parts = [false, false, false, false];
        } else recycling_feedback(station.build_remaining > 0 ? "Montando..." : "Junte circuito, bateria, motor e carcaça.");
    } else recycling_feedback("Entregue os robôs montados aqui.");
}

function construction_draw_part(_x, _y, _type, _scale = 1) {
    var dark = make_color_rgb(35, 57, 64);
    var part_color = recycling_trash_color(_type);
    frontend_rect(_x - 12 * _scale, _y - 12 * _scale, 24 * _scale, 24 * _scale, dark);
    frontend_rect(_x - 9 * _scale, _y - 9 * _scale, 18 * _scale, 18 * _scale, part_color);
    frontend_text(_x, _y - 10 * _scale, ["C", "B", "M", "A"][_type], fnt_ui_small, c_white, fa_center);
}

function construction_draw_robot(_x, _y) {
    var dark = make_color_rgb(35, 57, 64);
    frontend_rect(_x - 16, _y - 25, 32, 22, dark);
    frontend_rect(_x - 12, _y - 21, 24, 14, make_color_rgb(140, 205, 195));
    frontend_rect(_x - 8, _y - 17, 4, 4, dark);
    frontend_rect(_x + 4, _y - 17, 4, 4, dark);
    frontend_rect(_x - 13, _y, 26, 22, dark);
    frontend_rect(_x - 9, _y + 4, 18, 14, make_color_rgb(230, 181, 52));
}

function construction_draw_station() {
    var dark = make_color_rgb(35, 57, 64);
    frontend_rect(x - station_width / 2, y - 45, station_width, 80, dark);
    frontend_rect(x - station_width / 2 + 5, y - 40, station_width - 10, 65, make_color_rgb(206, 225, 221));
    frontend_text(x, y - 82, station_kind == "bench" ? "Bancada" : "Entrega", fnt_ui_body, dark, fa_center);
    if (station_kind == "bench") {
        if (module_ready) construction_draw_robot(x, y - 5);
        else {
            for (var part_index = 0; part_index < 4; part_index++) {
                var part_x = x - 57 + part_index * 38;
                frontend_text(part_x, y - 15, "+", fnt_ui_small, dark, fa_center);
                if (parts[part_index]) construction_draw_part(part_x, y - 5, part_index, 0.7);
            }
        }
        frontend_text(x, y + 43, module_ready ? "Retire o robô" : (build_remaining > 0 ? "Montando: " + string(ceil(build_remaining)) + "s" : "C + B + M + A"), fnt_ui_small, dark, fa_center);
    } else frontend_text(x, y - 12, string(obj_recycling_level.robot_total) + " robôs", fnt_ui_body, dark, fa_center);
}
