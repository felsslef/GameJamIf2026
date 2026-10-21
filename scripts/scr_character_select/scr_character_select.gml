/// Independent UI slots. LAN remains a local selection and does not change network packets.
function frontend_character_init() {
    character_player_count = global.frontend_mode == "coop_local" ? 2 : 1;
    character_slots = [];
    for (var i = 0; i < character_player_count; i++) {
        var choice = clamp(global.frontend_characters[i], 0, array_length(scientists) - 1);
        if (i == 1 && choice == character_slots[0].choice) choice = (choice + 1) mod array_length(scientists);
        array_push(character_slots, {choice: choice, ready: false, back: false, flip_timer: 0});
    }
}

function frontend_character_card(_player) {
    return {x: character_player_count == 1 ? 500 : 262 + _player * 476, y: 150, w: 280, h: 350};
}

function frontend_character_build_buttons() {
    frontend_button(32, 24, 48, 40, "", "back");
    for (var i = 0; i < character_player_count; i++) {
        var card = frontend_character_card(i);
        frontend_button(card.x - 72, card.y + 150, 48, 48, "", "character_previous", i);
        frontend_button(card.x + card.w + 24, card.y + 150, 48, 48, "", "character_next", i);
        frontend_button(card.x, card.y, card.w, card.h, "", "character_flip", i);
        frontend_button(card.x + 40, 516, 200, 40, "", "character_ready", i);
    }
    frontend_button(530, 628, 220, 46, "Continuar", "character_continue");
}

function frontend_character_is_claimed(_player, _choice) {
    for (var i = 0; i < character_player_count; i++) {
        if (i != _player && character_slots[i].ready && character_slots[i].choice == _choice) return true;
    }
    return false;
}

function frontend_character_cycle(_player, _direction) {
    var slot = character_slots[_player];
    if (slot.ready) return;
    var count = array_length(scientists);
    var choice = slot.choice;
    repeat (count) {
        choice = (choice + _direction + count) mod count;
        if (!frontend_character_is_claimed(_player, choice)) break;
    }
    slot.choice = choice;
    slot.back = false;
    slot.flip_timer = 0;
}

function frontend_character_flip(_player) {
    var slot = character_slots[_player];
    if (slot.flip_timer > 0) return;
    slot.back = !slot.back;
    slot.flip_timer = global.frontend_reduced_motion ? 0 : 0.2;
}

function frontend_character_toggle_ready(_player) {
    var slot = character_slots[_player];
    if (slot.ready) {
        slot.ready = false;
        return;
    }
    if (frontend_character_is_claimed(_player, slot.choice)) {
        notice = "Personagem já escolhida.";
        notice_timer = 2;
        return;
    }
    slot.ready = true;
}

function frontend_character_all_ready() {
    for (var i = 0; i < character_player_count; i++) {
        if (!character_slots[i].ready) return false;
    }
    return true;
}

function frontend_character_continue() {
    if (!frontend_character_all_ready()) return;
    for (var i = 0; i < character_player_count; i++) global.frontend_characters[i] = character_slots[i].choice;
    room_goto(rm_level_select);
}

function frontend_character_update(_dt) {
    if (keyboard_check_pressed(vk_escape)) {
        frontend_back();
        return;
    }
    // Both input sets are read every frame; neither player waits for the other.
    for (var i = 0; i < character_player_count; i++) {
        character_slots[i].flip_timer = max(0, character_slots[i].flip_timer - _dt);
        var use_arrows = i == 1;
        var solo = character_player_count == 1;
        var previous = use_arrows ? keyboard_check_pressed(vk_left) : keyboard_check_pressed(ord("A"));
        var next = use_arrows ? keyboard_check_pressed(vk_right) : keyboard_check_pressed(ord("D"));
        var flip = use_arrows
            ? (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down))
            : (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("S")));
        var confirm = keyboard_check_pressed(use_arrows ? vk_enter : ord("E"));
        if (solo) {
            previous = previous || keyboard_check_pressed(vk_left);
            next = next || keyboard_check_pressed(vk_right);
            flip = flip || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down);
            confirm = confirm || keyboard_check_pressed(vk_enter);
        }
        var choice_step = next - previous;
        if (choice_step != 0) frontend_character_cycle(i, choice_step);
        if (flip) frontend_character_flip(i);
        if (confirm) frontend_character_toggle_ready(i);
    }
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    focus = -1;
    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        if (point_in_rectangle(mx, my, b.x, b.y, b.x + b.w, b.y + b.h)) focus = i;
    }
    if (mouse_check_button_pressed(mb_left) && focus >= 0) {
        frontend_activate(buttons[focus]);
        return;
    }
    if (keyboard_check_pressed(vk_space)) frontend_character_continue();
}

function frontend_character_arrow(_x, _y, _direction, _color) {
    draw_sprite_ext(spr_ui_arrow, 0, _x, _y, _direction, 1, 0, _color, draw_get_alpha());
}

function frontend_draw_character_select() {
    draw_set_alpha(1);
    frontend_rect(0, 0, 1280, 720, paper);
    frontend_text(640, 38, "Cientistas", font_body, ink, fa_center);
    var back_button = buttons[0];
    frontend_panel(back_button.x, back_button.y, back_button.w, back_button.h,
        focus == 0 ? make_color_rgb(234, 240, 236) : paper, ink);
    frontend_character_arrow(56, 44, -1, ink);

    for (var i = 0; i < character_player_count; i++) {
        var card = frontend_character_card(i);
        var slot = character_slots[i];
        var scientist = scientists[slot.choice];
        var center_x = card.x + card.w / 2;
        var accent = i == 0 ? teal : make_color_rgb(75, 108, 168);
        if (character_player_count == 2) frontend_text(center_x, 112, "Jogadora " + string(i + 1), font_small, accent, fa_center);
        var width_scale = slot.flip_timer > 0 ? max(0.02, abs(slot.flip_timer / 0.1 - 1)) : 1;
        var show_back = slot.flip_timer > 0.1 ? !slot.back : slot.back;
        var card_width = card.w * width_scale;
        frontend_panel(center_x - card_width / 2, card.y, card_width, card.h,
            slot.ready ? make_color_rgb(239, 246, 239) : paper, slot.ready ? accent : muted);
        if (width_scale > 0.9) {
            if (show_back) {
                frontend_text(center_x, card.y + 28, scientist.name, font_body, accent, fa_center);
                draw_set_font(font_small);
                draw_set_halign(fa_left);
                draw_set_color(ink);
                draw_text_ext(card.x + 24, card.y + 86, scientist.bio, 26, card.w - 48);
            } else {
                frontend_rect(card.x + 16, card.y + 20, card.w - 32, 252, make_color_rgb(235, 239, 235));
                frontend_scientist(card.x + 28, card.y + 32, 7, slot.choice);
                frontend_text(center_x, card.y + 304, scientist.role, font_small, muted, fa_center);
            }
        }
        var first_button = 1 + i * 4;
        for (var arrow = 0; arrow < 2; arrow++) {
            var b = buttons[first_button + arrow];
            var color_arrow = slot.ready ? make_color_rgb(188, 195, 190) : accent;
            if (focus == first_button + arrow && !slot.ready) frontend_rect(b.x, b.y, b.w, b.h, make_color_rgb(239, 244, 240));
            frontend_character_arrow(b.x + b.w / 2, b.y + b.h / 2, arrow == 0 ? -1 : 1, color_arrow);
        }
        var status_button = buttons[first_button + 3];
        if (slot.ready || focus == first_button + 3) {
            frontend_panel(status_button.x, status_button.y, status_button.w, status_button.h,
                slot.ready ? make_color_rgb(234, 240, 236) : paper, accent);
        }
        frontend_text(center_x, 522, slot.ready ? "Pronto" : scientist.name, font_body, slot.ready ? accent : ink, fa_center);
        if (character_player_count == 1) {
            frontend_text(center_x, 568, "A/D ou setas: escolher | W/S ou cima/baixo: virar", font_small, muted, fa_center);
            frontend_text(center_x, 594, "E ou Enter: confirmar / desfazer", font_small, muted, fa_center);
        } else if (i == 0) {
            frontend_text(center_x, 568, "A/D: escolher | W/S: virar", font_small, muted, fa_center);
            frontend_text(center_x, 594, "E: confirmar / desfazer", font_small, muted, fa_center);
        } else {
            frontend_text(center_x, 568, "Esquerda/direita: escolher", font_small, muted, fa_center);
            frontend_text(center_x, 594, "Cima/baixo: virar | Enter: confirmar", font_small, muted, fa_center);
        }
    }
    var all_ready = frontend_character_all_ready();
    var continue_index = array_length(buttons) - 1;
    if (all_ready) {
        frontend_panel(530, 628, 220, 46, focus == continue_index ? make_color_rgb(234, 240, 236) : paper, teal);
        frontend_text(640, 638, "Continuar", font_body, ink, fa_center);
        frontend_text(640, 688, "Espaço para continuar", font_small, muted, fa_center);
    } else frontend_text(640, 650, "Escolhendo personagem", font_small, muted, fa_center);
    if (notice_timer > 0) frontend_text(640, 76, notice, font_small, coral, fa_center);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
