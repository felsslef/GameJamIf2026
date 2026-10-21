function recycling_trash_color(_type) {
    var colors = [make_color_rgb(62, 125, 193), make_color_rgb(206, 79, 73),
        make_color_rgb(50, 144, 98), make_color_rgb(230, 181, 52)];
    return colors[_type];
}

function recycling_trash_name(_type) {
    var names = ["Papel", "Plástico", "Vidro", "Metal"];
    return names[_type];
}

function recycling_draw_waste(_x, _y, _type, _scale = 1) {
    draw_sprite_ext(recycling_waste_sprite(_type), 0, _x, _y, _scale, _scale, 0, c_white, draw_get_alpha());
}

function recycling_draw_item(_x, _y, _kind, _type, _amount) {
    var asset = recycling_waste_sprite(_type);
    if (_kind == "bag") asset = recycling_bag_sprite(_type);
    if (_kind == "part") asset = recycling_part_sprite(_type);
    if (_kind == "robot") asset = object_get_sprite(obj_robot);
    draw_sprite(asset, 0, _x, _y);
    if (_kind == "bag") frontend_text(_x, _y - 12, string(_amount), fnt_ui_small, c_white, fa_center);
}

function recycling_draw_bar(_x, _y, _w, _ratio, _color) {
    frontend_rect(_x, _y, _w, 10, make_color_rgb(37, 59, 65));
    frontend_rect(_x + 2, _y + 2, (_w - 4) * clamp(_ratio, 0, 1), 6, _color);
}

function recycling_draw_station() {
    if (instance_exists(obj_recycling_level) && obj_recycling_level.processing_enabled) { processing_draw_station(); return; }
    var dark = make_color_rgb(35, 57, 64);
    if (station_kind == "truck" && station_height > 88) {
        draw_sprite_stretched(spr_counter, 0, x - station_width / 2, y - station_height / 2, station_width, station_height);
    }
    var returning = station_kind == "truck" && trip_remaining > 0;
    if (returning) draw_set_alpha(0.3);
    draw_self();
    draw_set_alpha(1);
    switch (station_kind) {
        case "handoff":
            if (!is_undefined(stored_item)) recycling_draw_item(x, y - 3, stored_item.kind, stored_item.trash_type, stored_item.amount);
            break;
        case "bin":
            var full = load >= capacity;
            recycling_draw_bar(x - 43, y + 40, 86, load / capacity, full ? make_color_rgb(209,73,65) : recycling_trash_color(trash_type));
            frontend_text(x, y + 56, recycling_trash_name(trash_type) + " " + string(load) + "/" + string(capacity) + (full ? " CHEIA" : ""), fnt_ui_small, dark, fa_center);
            break;
        case "dispenser":
            var queued = array_length(queue);
            frontend_text(x, y - 88, "Dispenser", fnt_ui_body, dark, fa_center);
            frontend_text(x, y - 30, string(queued) + " / " + string(capacity), fnt_ui_small, dark, fa_center);
            for (var i = 0; i < queued; i++) {
                var icon_x = x - 63 + (i mod 4) * 42;
                var icon_y = y + 13 + floor(i / 4) * 28;
                var entry_sprite = queue[i] >= 4 ? recycling_part_sprite(queue[i] mod 4) : recycling_waste_sprite(queue[i]);
                draw_sprite_ext(entry_sprite, 0, icon_x, icon_y, 0.65, 0.65, 0, c_white, 1);
                if (i == 0) { draw_set_color(c_white); draw_rectangle(icon_x - 15, icon_y - 16, icon_x + 15, icon_y + 16, true); }
            }
            recycling_draw_bar(x - 80, y + 56, 160, queued / capacity, make_color_rgb(75,159,133));
            if (queued >= capacity) frontend_text(x, y + 72, "CHEIO! " + string(max(0,ceil(obj_recycling_level.overflow_limit - overflow_elapsed))) + "s", fnt_ui_small, make_color_rgb(177,51,47), fa_center);
            break;
        case "truck":
            frontend_text(x, y - 77, "Caminhão", fnt_ui_body, dark, fa_center);
            frontend_text(x, y - 15, returning ? "Voltando: " + string(ceil(trip_remaining)) + "s" : string(load) + "/" + string(capacity), fnt_ui_small, returning ? dark : c_white, fa_center);
            break;
        case "bench":
            if (module_ready) construction_draw_robot(x, y - 5);
            else for (var i = 0; i < 4; i++) if (parts[i]) construction_draw_part(x - 57 + i * 38, y - 5, i, 0.7);
            frontend_text(x, y - 82, "Bancada", fnt_ui_body, dark, fa_center);
            frontend_text(x, y + 43, module_ready ? "Retire o robô" : (build_remaining > 0 ? "Montando: " + string(ceil(build_remaining)) + "s" : "C + B + M + A"), fnt_ui_small, dark, fa_center);
            break;
        case "storage":
            frontend_text(x, y - 82, "Entrega", fnt_ui_body, dark, fa_center);
            frontend_text(x, y - 12, string(obj_recycling_level.robot_total) + " robôs", fnt_ui_body, dark, fa_center);
            break;
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}

function recycling_draw_star(_x, _y, _color) {
    draw_sprite_ext(spr_ui_star, 0, _x, _y, 1, 1, 0, _color, draw_get_alpha());
}

function recycling_draw_hud() {
    if (processing_enabled) { processing_draw_hud(); return; }
    var dark = make_color_rgb(35, 57, 64);
    frontend_panel(32, 20, 1216, 70, make_color_rgb(255, 252, 235), dark);
    frontend_text(56, 31, "Reciclados: " + string(recycled_total) + " / " + string(minimum_goal), fnt_ui_body,
        recycled_total >= minimum_goal ? make_color_rgb(32, 128, 87) : dark);
    frontend_text(56, 61, has_construction ? "Robôs: " + string(robot_total) + " / " + string(robot_minimum) : "Separe > leve os sacos > envie o caminhão", fnt_ui_small, dark);
    var seconds_left = ceil(time_remaining);
    var clock = string(floor(seconds_left / 60)) + ":" + string_format(seconds_left mod 60, 2, 0);
    if (seconds_left mod 60 < 10) clock = string(floor(seconds_left / 60)) + ":0" + string(seconds_left mod 60);
    frontend_text(640, 30, clock, fnt_ui_title, time_remaining <= 20 ? make_color_rgb(177, 51, 47) : dark, fa_center);
    var place_names = ["Porto Novo", "Indaiá", "Centro", "Martim de Sá", "Massaguaçu"];
    frontend_text(1220, 32, place_names[level_index], fnt_ui_body, dark, fa_right);
    frontend_text(1220, 62, "Esc: pausa | F11: tela cheia", fnt_ui_small, dark, fa_right);
    frontend_text(48, 694, global.game_mode == "coop_local" ? "J1: WASD | G: dash | H: ação   J2: Setas | Num 2: dash | Num 3: ação" : "WASD: mover   G: dash   H: pegar / colocar", fnt_ui_small, c_white);
    if (feedback_timer > 0 && phase_state == "playing") {
        var message_width = min(1120, string_length(feedback) * 10 + 32);
        frontend_panel(640 - message_width / 2, 99, message_width, 32, make_color_rgb(255, 252, 235), dark);
        frontend_text(640, 104, feedback, fnt_ui_small, dark, fa_center);
    }
    if (phase_state != "playing") {
        draw_set_alpha(0.55);
        frontend_rect(0, 0, 1280, 720, c_black);
        draw_set_alpha(1);
        frontend_panel(320, 184, 640, 370, make_color_rgb(255, 252, 235), dark);
        frontend_text(640, 217, phase_state == "won" ? "Fase concluída!" : "Fim da rodada", fnt_ui_title, dark, fa_center);
        frontend_text(640, 296, result_reason, fnt_ui_small, dark, fa_center);
        frontend_text(640, 335, "Reciclados: " + string(recycled_total) + " / " + string(minimum_goal), fnt_ui_body, dark, fa_center);
        if (has_construction) frontend_text(640, 370, "Robôs: " + string(robot_total) + " / " + string(robot_minimum), fnt_ui_small, dark, fa_center);
        for (var i = 0; i < 3; i++) recycling_draw_star(584 + i * 56, 410,
            i < result_stars ? make_color_rgb(233, 178, 55) : make_color_rgb(186, 190, 177));
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        frontend_panel(400, 470, 220, 52, point_in_rectangle(mx, my, 400, 470, 620, 522) ? make_color_rgb(226, 238, 222) : c_white, dark);
        frontend_panel(660, 470, 220, 52, point_in_rectangle(mx, my, 660, 470, 880, 522) ? make_color_rgb(226, 238, 222) : c_white, dark);
        frontend_text(510, 482, "Tentar de novo", fnt_ui_body, dark, fa_center);
        frontend_text(770, 482, "Mapa", fnt_ui_body, dark, fa_center);
    }
    draw_set_alpha(1);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
