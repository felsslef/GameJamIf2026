/// Assembly logic; benches and delivery stations are placed in the room editor.
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

function construction_interact(_player, _station_override = noone) {
    var station = instance_exists(_station_override) ? _station_override : recycling_nearest_station(_player);
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
    draw_sprite_ext(recycling_part_sprite(_type), 0, _x, _y, _scale, _scale, 0, c_white, draw_get_alpha());
}

function construction_draw_robot(_x, _y) {
    draw_sprite(object_get_sprite(obj_robot), 0, _x, _y);
}
