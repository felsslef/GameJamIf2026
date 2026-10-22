/// Sprite-based presentation helpers; text and interface state remain dynamic.
function frontend_rect(_x, _y, _w, _h, _color) {
    draw_sprite_stretched_ext(spr_ui_fill, 0, _x, _y, _w, _h, _color, draw_get_alpha());
}

function frontend_text(_x, _y, _text, _font, _color, _align = fa_left) {
    draw_set_font(_font);
    draw_set_color(_color);
    draw_set_halign(_align);
    draw_set_valign(fa_top);
    draw_text(_x, _y, _text);
}

function frontend_panel(_x, _y, _w, _h, _fill, _border) {
    draw_set_color(make_color_rgb(25, 45, 51));
    var panel_alpha = draw_get_alpha();
    draw_set_alpha(panel_alpha * 0.18);
    draw_roundrect_ext(_x, _y + 5, _x + _w, _y + _h + 5, 12, 12, false);
    draw_set_alpha(panel_alpha);
    draw_set_color(_border);
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 12, 12, false);
    draw_set_color(_fill);
    draw_roundrect_ext(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, 10, 10, false);
    draw_set_color(c_white);
}

function frontend_scientist(_x, _y, _scale, _index) {
    draw_sprite_ext(recycling_scientist_sprite(_index), 0, _x + 16 * _scale, _y + 30 * _scale,
        _scale / 2, _scale / 2, 0, c_white, draw_get_alpha());
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
        case "controls": title = "Configuração de teclas"; break;
    }
    frontend_text(640, 92, title, font_title, ink, fa_center);

    if (screen == "controls") {
        frontend_text(336, 132, "Jogador 1", font_body, teal, fa_center);
        frontend_text(944, 132, "Jogador 2", font_body, teal, fa_center);
        frontend_text(640, 504, "Clique em um comando para trocar a tecla. Esc cancela a captura.", font_small, muted, fa_center);
    }

    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        if (b.action != "character" && b.action != "level") frontend_draw_button(b, i);
    }
    if (screen == "controls" && notice_timer > 0) frontend_text(640, 666, notice, font_small, ink, fa_center);
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
