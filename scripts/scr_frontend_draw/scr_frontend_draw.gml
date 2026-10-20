/// Primitive placeholders on a 32px grid; replace these helpers with sprites later.
function frontend_rect(_x, _y, _w, _h, _color) {
    draw_set_color(_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
}

function frontend_text(_x, _y, _text, _font, _color, _align = fa_left) {
    draw_set_font(_font);
    draw_set_color(_color);
    draw_set_halign(_align);
    draw_set_valign(fa_top);
    draw_text(_x, _y, _text);
}

function frontend_panel(_x, _y, _w, _h, _fill, _border) {
    frontend_rect(_x, _y, _w, _h, _border);
    frontend_rect(_x + 2, _y + 2, _w - 4, _h - 4, _fill);
}

function frontend_pixel(_x, _y, _scale, _px, _py, _w, _h, _color) {
    frontend_rect(_x + _px * _scale, _y + _py * _scale, _w * _scale - 1, _h * _scale - 1, _color);
}

function frontend_scientist(_x, _y, _scale, _index) {
    var c = scientists[_index].color;
    var skin = [make_color_rgb(193, 130, 91), make_color_rgb(239, 185, 142), make_color_rgb(137, 85, 65), make_color_rgb(216, 161, 119)];
    var hair = [ink, make_color_rgb(105, 63, 43), make_color_rgb(62, 42, 43), make_color_rgb(72, 48, 34)];
    frontend_pixel(_x, _y, _scale, 8, 30, 18, 2, make_color_rgb(150, 177, 158));
    frontend_pixel(_x, _y, _scale, 10, 3, 13, 14, hair[_index]);
    if (_index == 0 || _index == 2) frontend_pixel(_x, _y, _scale, 23, 7, 4, 7, hair[_index]);
    frontend_pixel(_x, _y, _scale, 12, 7, 10, 9, skin[_index]);
    frontend_pixel(_x, _y, _scale, 12, 5, 10, 4, hair[_index]);
    if (_index == 1) frontend_pixel(_x, _y, _scale, 10, 1, 7, 5, hair[_index]);
    frontend_pixel(_x, _y, _scale, 14, 11, 2, 2, ink);
    frontend_pixel(_x, _y, _scale, 19, 11, 2, 2, ink);
    if (_index == 3) {
        frontend_pixel(_x, _y, _scale, 12, 10, 5, 1, c);
        frontend_pixel(_x, _y, _scale, 18, 10, 5, 1, c);
    }
    frontend_pixel(_x, _y, _scale, 10, 17, 14, 10, c_white);
    frontend_pixel(_x, _y, _scale, 15, 17, 4, 10, c);
    frontend_pixel(_x, _y, _scale, 7, 18, 3, 8, c_white);
    frontend_pixel(_x, _y, _scale, 24, 18, 3, 8, c_white);
    frontend_pixel(_x, _y, _scale, 11, 27, 5, 4, ink);
    frontend_pixel(_x, _y, _scale, 19, 27, 5, 4, ink);
    frontend_pixel(_x, _y, _scale, 21, 20, 2, 2, c);
}

function frontend_draw_button(_b, _index) {
    var active = focus == _index;
    frontend_panel(_b.x, _b.y, _b.w, _b.h,
        active ? make_color_rgb(234, 240, 236) : paper, active ? teal : ink);
    frontend_text(_b.x + _b.w / 2, _b.y + (_b.h - 27) / 2,
        _b.label, font_body, ink, fa_center);
}

function frontend_draw() {
    draw_set_alpha(1);
    if (screen == "levels") {
        frontend_draw_level_map();
        return;
    }
    if (screen == "characters") {
        frontend_draw_character_select();
        return;
    }
    frontend_rect(0, 0, 1280, 720, paper);
    var title = "Maré da Ciência";
    switch (screen) {
        case "mode": title = "Modo de jogo"; break;
        case "saves": title = "Escolha seu save"; break;
        case "characters": title = "Cientistas"; break;
        case "levels": title = "Fases"; break;
        case "options": title = "Opções"; break;
    }
    frontend_text(640, 92, title, font_title, ink, fa_center);

    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        if (b.action != "character" && b.action != "level") frontend_draw_button(b, i);
    }
    if (screen == "saves" && notice_timer > 0) frontend_text(640, 520, notice, font_small, ink, fa_center);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

function frontend_draw_lobby() {
    // The original Draw event still handles clicks and discovery. Match its hitboxes.
    frontend_rect(0, 0, 1280, 720, paper);
    frontend_text(640, 92, "Co-op Rede", font_title, ink, fa_center);
    if (!instance_exists(obj_menu)) return;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var hover_create = point_in_rectangle(mx, my, 540, 265, 740, 295);
    frontend_panel(540, 265, 200, 30, hover_create ? mint : paper, ink);
    frontend_text(640, 266, "Criar sala", font_body, ink, fa_center);
    var found_rooms = obj_menu.rooms_list;
    if (array_length(found_rooms) == 0) frontend_text(640, 350, "Nenhuma sala", font_small, muted, fa_center);
    for (var i = 0; i < array_length(found_rooms); i++) {
        var item_y = 360 + i * 35;
        var active = point_in_rectangle(mx, my, 520, item_y - 12, 760, item_y + 12);
        frontend_panel(520, item_y - 12, 240, 24, active ? mint : paper, active ? teal : muted);
        frontend_text(640, item_y - 11, string_copy(found_rooms[i].name, 1, 22), font_small, ink, fa_center);
    }
    var hover_back = point_in_rectangle(mx, my, 580, 655, 700, 685);
    frontend_panel(580, 655, 120, 30, hover_back ? mint : paper, ink);
    frontend_text(640, 656, "Voltar", font_body, ink, fa_center);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
