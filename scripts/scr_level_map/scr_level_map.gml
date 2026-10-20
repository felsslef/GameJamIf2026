/// Visual campaign state only; victory detection and persistence are intentionally out of scope.
function frontend_level_is_available(_level) {
    if (_level < 0 || _level >= array_length(global.frontend_level_completed)) return false;
    if (variable_global_exists("frontend_test_unlock") && global.frontend_test_unlock) return true;
    for (var i = 0; i < _level; i++) {
        if (!global.frontend_level_completed[i]) return false;
    }
    return true;
}

function level_map_round_panel(_x, _y, _w, _h, _fill, _outline) {
    draw_set_color(_outline);
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 14, 14, false);
    draw_set_color(_fill);
    draw_roundrect_ext(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, 11, 11, false);
}

function level_map_route(_from, _to, _completed) {
    var cx = (_from.x + _to.x) / 2;
    var cy = (_from.y + _to.y) / 2 - 32;
    var steps = max(12, ceil(point_distance(_from.x, _from.y, _to.x, _to.y) / 7));
    var previous_x = _from.x;
    var previous_y = _from.y;
    for (var i = 1; i <= steps; i++) {
        var t = i / steps;
        var px = sqr(1 - t) * _from.x + 2 * (1 - t) * t * cx + sqr(t) * _to.x;
        var py = sqr(1 - t) * _from.y + 2 * (1 - t) * t * cy + sqr(t) * _to.y;
        if (_completed) {
            draw_line_width_color(previous_x, previous_y, px, py, 12, c_white, c_white);
            draw_line_width_color(previous_x, previous_y, px, py, 6, teal, teal);
        } else if (i mod 3 == 0) {
            draw_set_color(c_white);
            draw_circle(px, py, 6, false);
            draw_set_color(make_color_rgb(110, 128, 103));
            draw_circle(px, py, 3, false);
        }
        previous_x = px;
        previous_y = py;
    }
}

function level_map_lock(_x, _y, _color) {
    draw_set_color(_color);
    draw_roundrect_ext(_x - 10, _y - 17, _x + 10, _y + 6, 9, 9, false);
    draw_set_color(make_color_rgb(222, 232, 215));
    draw_roundrect_ext(_x - 6, _y - 13, _x + 6, _y + 4, 6, 6, false);
    draw_set_color(_color);
    draw_roundrect_ext(_x - 15, _y - 3, _x + 15, _y + 17, 4, 4, false);
    draw_set_color(c_white);
    draw_circle(_x, _y + 5, 2, false);
    draw_rectangle(_x - 1, _y + 5, _x + 1, _y + 11, false);
}

function frontend_draw_level_map() {
    draw_set_alpha(1);
    draw_set_color(c_white);
    var previous_filter = gpu_get_texfilter();
    gpu_set_texfilter(true);
    draw_sprite_stretched(spr_caragua_map, 0, 0, 0, 1280, 720);
    gpu_set_texfilter(previous_filter);
    var outline = make_color_rgb(44, 76, 63);
    level_map_round_panel(512, 24, 256, 60, make_color_rgb(255, 251, 232), outline);
    frontend_text(640, 40, "Caraguatatuba", font_body, outline, fa_center);

    for (var i = 0; i < 4; i++) level_map_route(level_nodes[i], level_nodes[i + 1], global.frontend_level_completed[i]);
    for (var i = 0; i < 5; i++) {
        var node = level_nodes[i];
        var available = frontend_level_is_available(i);
        var completed = available && global.frontend_level_completed[i];
        var selected = selected_level == i;
        var fill = completed ? teal : (available ? gold : make_color_rgb(222, 232, 215));
        draw_set_alpha(0.24);
        draw_set_color(outline);
        draw_circle(node.x + 3, node.y + 6, 36, false);
        draw_set_alpha(1);
        if (selected) {
            draw_set_color(c_white);
            draw_circle(node.x, node.y, 43, false);
        }
        draw_set_color(outline);
        draw_circle(node.x, node.y, 35, false);
        draw_set_color(fill);
        draw_circle(node.x, node.y, 31, false);
        if (available) {
            frontend_text(node.x, node.y - 14, string(i + 1), font_body, completed ? c_white : outline, fa_center);
            if (completed) {
                draw_set_color(outline);
                draw_circle(node.x + 26, node.y + 23, 12, false);
                draw_set_color(c_white);
                draw_line_width(node.x + 20, node.y + 23, node.x + 24, node.y + 27, 3);
                draw_line_width(node.x + 24, node.y + 27, node.x + 32, node.y + 18, 3);
            }
        } else {
            level_map_lock(node.x, node.y, make_color_rgb(104, 123, 102));
            draw_set_color(outline);
            draw_circle(node.x - 28, node.y - 24, 12, false);
            frontend_text(node.x - 28, node.y - 35, string(i + 1), font_small, c_white, fa_center);
        }
        var label_width = max(100, string_length(levels[i].place) * 10 + 28);
        level_map_round_panel(node.x - label_width / 2, node.y + 46, label_width, 32,
            make_color_rgb(255, 251, 232), outline);
        frontend_text(node.x, node.y + 51, levels[i].place, font_small, outline, fa_center);
    }

    level_map_round_panel(32, 608, 1216, 80, make_color_rgb(255, 251, 232), outline);
    frontend_text(640, 620, "Fase " + string(selected_level + 1) + " - " + levels[selected_level].place, font_body, outline, fa_center);
    var available = frontend_level_is_available(selected_level);
    var status = global.frontend_level_completed[selected_level] ? "Concluída" : (available ? "Disponível" : "Conclua a fase anterior");
    frontend_text(640, 652, status, font_small, outline, fa_center);
    for (var i = 5; i < 7; i++) {
        var b = buttons[i];
        var enabled = b.action != "start" || available;
        var active = focus == i && enabled;
        level_map_round_panel(b.x, b.y, b.w, b.h,
            active ? gold : (enabled ? c_white : make_color_rgb(222, 232, 215)), outline);
        frontend_text(b.x + b.w / 2, b.y + 10, enabled ? b.label : "Bloqueada", font_body,
            enabled ? outline : make_color_rgb(104, 123, 102), fa_center);
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
