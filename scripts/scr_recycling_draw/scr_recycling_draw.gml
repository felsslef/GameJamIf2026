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
    var color_type = recycling_trash_color(_type);
    var dark = make_color_rgb(35, 57, 64);
    if (_type == 0) {
        frontend_rect(_x - 11 * _scale, _y - 14 * _scale, 22 * _scale, 28 * _scale, dark);
        frontend_rect(_x - 8 * _scale, _y - 11 * _scale, 16 * _scale, 22 * _scale, c_white);
        for (var i = 0; i < 3; i++) frontend_rect(_x - 5 * _scale, _y - 6 * _scale + i * 6 * _scale, 10 * _scale, 2 * _scale, color_type);
    } else if (_type == 1) {
        frontend_rect(_x - 4 * _scale, _y - 15 * _scale, 8 * _scale, 5 * _scale, dark);
        frontend_rect(_x - 6 * _scale, _y - 10 * _scale, 12 * _scale, 5 * _scale, color_type);
        frontend_rect(_x - 10 * _scale, _y - 5 * _scale, 20 * _scale, 19 * _scale, color_type);
        frontend_rect(_x - 8 * _scale, _y + 2 * _scale, 16 * _scale, 5 * _scale, c_white);
    } else if (_type == 2) {
        frontend_rect(_x - 5 * _scale, _y - 15 * _scale, 10 * _scale, 5 * _scale, dark);
        frontend_rect(_x - 4 * _scale, _y - 10 * _scale, 8 * _scale, 8 * _scale, color_type);
        frontend_rect(_x - 9 * _scale, _y - 2 * _scale, 18 * _scale, 16 * _scale, color_type);
        frontend_rect(_x - 5 * _scale, _y + 1 * _scale, 3 * _scale, 10 * _scale, c_white);
    } else {
        frontend_rect(_x - 10 * _scale, _y - 13 * _scale, 20 * _scale, 26 * _scale, dark);
        frontend_rect(_x - 8 * _scale, _y - 10 * _scale, 16 * _scale, 20 * _scale, color_type);
        frontend_rect(_x - 8 * _scale, _y - 10 * _scale, 16 * _scale, 3 * _scale, c_white);
        frontend_rect(_x - 5 * _scale, _y - 4 * _scale, 3 * _scale, 11 * _scale, c_white);
    }
}

function recycling_draw_item(_x, _y, _kind, _type, _amount) {
    if (_kind == "part") construction_draw_part(_x, _y, _type);
    else if (_kind == "robot") construction_draw_robot(_x, _y);
    else if (_kind == "bag") {
        draw_set_color(make_color_rgb(35, 57, 64));
        draw_circle(_x, _y, 17, false);
        draw_set_color(recycling_trash_color(_type));
        draw_circle(_x, _y, 14, false);
        frontend_rect(_x - 5, _y - 21, 10, 7, make_color_rgb(35, 57, 64));
        frontend_text(_x, _y - 12, string(_amount), fnt_ui_small, c_white, fa_center);
    } else recycling_draw_waste(_x, _y, _type);
    draw_set_font(-1);
    draw_set_color(c_white);
}

function recycling_draw_bar(_x, _y, _w, _ratio, _color) {
    frontend_rect(_x, _y, _w, 10, make_color_rgb(37, 59, 65));
    frontend_rect(_x + 2, _y + 2, (_w - 4) * clamp(_ratio, 0, 1), 6, _color);
}

function recycling_draw_station() {
    var dark = make_color_rgb(35, 57, 64);
    if (station_kind == "divider" || station_kind == "handoff") { split_level_draw_station(); return; }
    if (station_kind == "bench" || station_kind == "storage") { construction_draw_station(); return; }
    if (station_kind == "bin") {
        var color_bin = recycling_trash_color(trash_type);
        var full = load >= capacity;
        frontend_rect(x - 40, y - 40, 80, 72, dark);
        frontend_rect(x - 35, y - 34, 70, 62, color_bin);
        frontend_rect(x - 47, y - 49, 94, 12, dark);
        frontend_rect(x - 20, y - 56, 40, 8, dark);
        frontend_rect(x - 19, y - 29, 38, 44, make_color_rgb(250, 247, 226));
        recycling_draw_waste(x, y - 5, trash_type, 0.7);
        recycling_draw_bar(x - 43, y + 40, 86, load / capacity, full ? make_color_rgb(209, 73, 65) : color_bin);
        frontend_text(x, y + 56, recycling_trash_name(trash_type) + " " + string(load) + "/" + string(capacity) + (full ? " CHEIA" : ""), fnt_ui_small, full ? make_color_rgb(177, 51, 47) : dark, fa_center);
    } else if (station_kind == "dispenser") {
        var queued = array_length(queue);
        var full = queued >= capacity;
        frontend_rect(x - 80, y - 48, 160, 88, dark);
        frontend_rect(x - 72, y - 40, 144, 56, make_color_rgb(130, 168, 164));
        frontend_rect(x - 54, y - 30, 108, 26, make_color_rgb(225, 239, 221));
        frontend_rect(x - 68, y + 22, 136, 24, make_color_rgb(72, 99, 106));
        frontend_text(x, y - 88, "Dispenser", fnt_ui_body, dark, fa_center);
        frontend_text(x, y - 30, string(queued) + " / " + string(capacity), fnt_ui_small, dark, fa_center);
        for (var i = 0; i < queued; i++) {
            var icon_x = x - 63 + (i mod 4) * 42;
            var icon_y = y + 13 + floor(i / 4) * 28;
            if (queue[i] >= 4) construction_draw_part(icon_x, icon_y, queue[i] mod 4, 0.65);
            else recycling_draw_waste(icon_x, icon_y, queue[i], 0.65);
            if (i == 0) { draw_set_color(c_white); draw_rectangle(icon_x - 15, icon_y - 16, icon_x + 15, icon_y + 16, true); }
        }
        recycling_draw_bar(x - 80, y + 56, 160, queued / capacity, full ? make_color_rgb(209, 73, 65) : make_color_rgb(75, 159, 133));
        if (full) {
            var remaining = max(0, ceil(obj_recycling_level.overflow_limit - (obj_recycling_level.level_index == 2 ? overflow_elapsed : obj_recycling_level.overflow_elapsed)));
            frontend_text(x, y + 72, "CHEIO! " + string(remaining) + "s", fnt_ui_small, make_color_rgb(177, 51, 47), fa_center);
        }
    } else {
        if (obj_recycling_level.level_index == 2) frontend_panel(x - 96, y - 64, 192, 128, make_color_rgb(139, 159, 156), dark);
        if (trip_remaining > 0) {
            draw_set_color(make_color_rgb(117, 132, 111));
            draw_rectangle(x - 96, y - 44, x + 96, y + 44, true);
            frontend_text(x, y - 14, "Voltando: " + string(ceil(trip_remaining)) + "s", fnt_ui_small, dark, fa_center);
        } else {
            frontend_rect(x - 92, y - 42, 125, 70, dark);
            frontend_rect(x - 86, y - 36, 113, 58, make_color_rgb(59, 149, 115));
            frontend_rect(x + 33, y - 30, 57, 58, dark);
            frontend_rect(x + 39, y - 24, 45, 46, make_color_rgb(229, 187, 62));
            frontend_rect(x + 45, y - 19, 31, 18, make_color_rgb(205, 235, 237));
            frontend_rect(x - 67, y + 22, 25, 16, dark);
            frontend_rect(x + 49, y + 22, 25, 16, dark);
            frontend_text(x - 29, y - 22, string(load) + "/" + string(capacity), fnt_ui_body, c_white, fa_center);
            frontend_text(x, y - 77, "Caminhão", fnt_ui_body, dark, fa_center);
        }
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}

function recycling_draw_world() {
    var sand = make_color_rgb(233, 219, 177);
    var green = make_color_rgb(108, 157, 108);
    var scale_x = room_width / 1280;
    var scale_y = room_height / 720;
    frontend_rect(0, 0, room_width, room_height, sand);
    frontend_rect(0, 0, room_width, 126 * scale_y, green);
    frontend_rect(0, room_height - 36 * scale_y, room_width, 36 * scale_y, make_color_rgb(75, 170, 190));
    frontend_rect(0, room_height - 40 * scale_y, room_width, 6 * scale_y, make_color_rgb(250, 245, 215));
    var floor_x = 64 * scale_x;
    var floor_y = 160 * scale_y;
    var floor_w = 1152 * scale_x;
    var floor_h = 480 * scale_y;
    frontend_rect(floor_x, floor_y, floor_w, floor_h, make_color_rgb(218, 207, 166));
    for (var tile_x = floor_x; tile_x <= floor_x + floor_w; tile_x += 32) frontend_rect(tile_x, floor_y, 1, floor_h, sand);
    for (var tile_y = floor_y; tile_y <= floor_y + floor_h; tile_y += 32) frontend_rect(floor_x, tile_y, floor_w, 1, sand);
    for (var i = 0; i < 15; i++) {
        frontend_rect(20 + i * 110, 100 * scale_y, 38, 24, make_color_rgb(66, 117, 82));
        frontend_rect(28 + i * 110, 100 * scale_y - 8, 22, 14, make_color_rgb(82, 137, 87));
    }
    draw_set_color(make_color_rgb(168, 159, 119));
    draw_rectangle(48 * scale_x, 140 * scale_y, room_width - 48 * scale_x, room_height - 50 * scale_y, true);
    draw_set_color(c_white);
}

function recycling_draw_star(_x, _y, _color) {
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_x, _y, _color, 1);
    for (var i = 0; i <= 10; i++) {
        var radius = i mod 2 == 0 ? 18 : 8;
        draw_vertex_color(_x + lengthdir_x(radius, 90 + i * 36), _y + lengthdir_y(radius, 90 + i * 36), _color, 1);
    }
    draw_primitive_end();
}

function recycling_draw_hud() {
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
