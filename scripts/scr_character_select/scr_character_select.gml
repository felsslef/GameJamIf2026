/// Independent UI slots. LAN remains a local selection and does not change network packets.
function frontend_character_init() {
    character_player_count = (global.frontend_mode == "coop_local" || global.frontend_mode == "coop_online") ? 2 : 1;
    character_slots = [];
    character_starting = false;
    for (var i = 0; i < character_player_count; i++) {
        var choice = clamp(global.frontend_characters[i], 0, array_length(scientists) - 1);
        if (i == 1 && choice == character_slots[0].choice) choice = (choice + 1) mod array_length(scientists);
        var is_online_remote = global.frontend_mode == "coop_online" && i == (global.is_host ? 1 : 0);
        array_push(character_slots, {choice: choice, ready: false, back: false, flip_timer: 0, active: !is_online_remote});
    }
    if (global.frontend_mode == "coop_online" && variable_global_exists("online_selection")) {
        var state = global.online_selection;
        character_slots[0].choice = state.p1_choice;
        character_slots[0].ready = state.p1_ready;
        character_slots[0].back = state.p1_back;
        character_slots[0].active = global.is_host || state.p2_active;
        character_slots[1].choice = state.p2_choice;
        character_slots[1].ready = state.p2_ready;
        character_slots[1].back = state.p2_back;
        character_slots[1].active = !global.is_host || state.p2_active;
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
        frontend_button(card.x - 12, 546, card.w + 24, 48, "", "character_ready", i);
    }

}

function frontend_character_is_claimed(_player, _choice) {
    if (global.frontend_mode == "coop_online") {
        var other_choice = _player == 0 ? global.online_selection.p2_choice : global.online_selection.p1_choice;
        return other_choice == _choice;
    }
    for (var i = 0; i < character_player_count; i++) {
        if (i != _player && character_slots[i].ready && character_slots[i].choice == _choice) return true;
    }
    return false;
}

function frontend_character_cycle(_player, _direction) {
    var slot = character_slots[_player];
    if (slot.ready || !slot.active) return;
    if (global.frontend_mode == "coop_online" && ((_player == 0) != global.is_host)) return;
    var count = array_length(scientists);
    var choice = slot.choice;
    repeat (count) {
        choice = (choice + _direction + count) mod count;
        if (!frontend_character_is_claimed(_player, choice)) break;
    }
    slot.choice = choice;
    slot.back = false;
    slot.flip_timer = 0;
    if (global.frontend_mode == "coop_online") {
        if (_player == 0) global.online_selection.p1_choice = slot.choice;
        else global.online_selection.p2_choice = slot.choice;
        frontend_online_send_p2_selection();
    }
}

function frontend_character_flip(_player) {
    var slot = character_slots[_player];
    if (!slot.active || (global.frontend_mode == "coop_online" && ((_player == 0) != global.is_host))) return;
    if (slot.flip_timer > 0) return;
    slot.back = !slot.back;
    slot.flip_timer = global.frontend_reduced_motion ? 0 : 0.2;
    if (global.frontend_mode == "coop_online") {
        if (_player == 0) global.online_selection.p1_back = slot.back;
        else global.online_selection.p2_back = slot.back;
        frontend_online_send_p2_selection();
    }
}

function frontend_character_toggle_ready(_player) {
    var slot = character_slots[_player];
    if (!slot.active || (global.frontend_mode == "coop_online" && ((_player == 0) != global.is_host))) return;
    if (slot.ready) {
        slot.ready = false;
        if (global.frontend_mode == "coop_online") {
            if (_player == 0) global.online_selection.p1_ready = false;
            else global.online_selection.p2_ready = false;
            frontend_online_send_p2_selection();
        }
        return;
    }
    if (frontend_character_is_claimed(_player, slot.choice)) {
        notice = "Personagem já escolhida.";
        notice_timer = 2;
        return;
    }
    slot.ready = true;
    if (global.frontend_mode == "coop_online") {
        if (_player == 0) global.online_selection.p1_ready = slot.ready;
        else global.online_selection.p2_ready = slot.ready;
        frontend_online_send_p2_selection();
        if (global.is_host && frontend_character_all_ready()) frontend_character_continue();
        return;
    }
    if (frontend_character_all_ready()) frontend_character_continue();
}

function frontend_character_all_ready() {
    if (global.frontend_mode == "coop_online") return global.online_selection.p2_active && global.online_selection.p1_ready && global.online_selection.p2_ready;
    for (var i = 0; i < character_player_count; i++) {
        if (!character_slots[i].ready) return false;
    }
    return true;
}

function frontend_character_continue() {
    if (global.frontend_mode == "coop_online" && !global.is_host) return;
    if (character_starting || !frontend_character_all_ready()) return;
    character_starting = true;
    if (global.frontend_mode == "coop_online") {
        global.frontend_characters[0] = global.online_selection.p1_choice;
        global.frontend_characters[1] = global.online_selection.p2_choice;
        global.online_selection.screen = "levels";
        global.online_selection.level = global.frontend_level;
    } else {
        for (var i = 0; i < character_player_count; i++) global.frontend_characters[i] = character_slots[i].choice;
    }
    session_ui_change_room(rm_level_select);
}

function frontend_character_update(_dt) {
    if (global.frontend_mode == "coop_online") {
        character_slots[0].choice = global.online_selection.p1_choice;
        character_slots[0].ready = global.online_selection.p1_ready;
        character_slots[0].back = global.online_selection.p1_back;
        character_slots[0].active = global.is_host || global.online_selection.p2_active;
        character_slots[1].choice = global.online_selection.p2_choice;
        character_slots[1].ready = global.online_selection.p2_ready;
        character_slots[1].back = global.online_selection.p2_back;
        character_slots[1].active = !global.is_host || global.online_selection.p2_active;
        var local_slot = global.is_host ? 0 : 1;
        var slot = character_slots[local_slot];
        slot.flip_timer = max(0, slot.flip_timer - _dt);
        if (keyboard_check_pressed(vk_escape)) { with(obj_session_ui) session_ui_return_to_title(); return; }
        var prefix = "p1_";
        var choice_step = keyboard_check_pressed(frontend_keybinding(prefix + "right")) - keyboard_check_pressed(frontend_keybinding(prefix + "left"));
        if (choice_step != 0) frontend_character_cycle(local_slot, choice_step);
        if (keyboard_check_pressed(frontend_keybinding(prefix + "up")) || keyboard_check_pressed(frontend_keybinding(prefix + "down"))) frontend_character_flip(local_slot);
        if (keyboard_check_pressed(frontend_keybinding("p1_interact")) || keyboard_check_pressed(vk_enter)) frontend_character_toggle_ready(local_slot);
        var mx = device_mouse_x_to_gui(0), my = device_mouse_y_to_gui(0);
        focus = -1;
        for (var b = 0; b < array_length(buttons); b++) if (point_in_rectangle(mx, my, buttons[b].x, buttons[b].y, buttons[b].x + buttons[b].w, buttons[b].y + buttons[b].h)) focus = b;
        if (mouse_check_button_pressed(mb_left) && focus >= 0) frontend_activate(buttons[focus]);
        return;
    }
    if (keyboard_check_pressed(vk_escape)) {
        frontend_back();
        return;
    }
    // Both input sets are read every frame; neither player waits for the other.
    for (var i = 0; i < character_player_count; i++) {
        character_slots[i].flip_timer = max(0, character_slots[i].flip_timer - _dt);
        var use_arrows = i == 1;
        var key_prefix = use_arrows ? "p2_" : "p1_";
        var previous = keyboard_check_pressed(frontend_keybinding(key_prefix + "left"));
        var next = keyboard_check_pressed(frontend_keybinding(key_prefix + "right"));
        var flip = keyboard_check_pressed(frontend_keybinding(key_prefix + "up"))
            || keyboard_check_pressed(frontend_keybinding(key_prefix + "down"));
        var confirm = keyboard_check_pressed(use_arrows ? vk_enter : ord("E"));
        if (character_player_count == 1) confirm = confirm || keyboard_check_pressed(vk_enter);
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

}

function frontend_character_arrow(_x, _y, _direction, _color) {
    draw_sprite_ext(spr_ui_arrow, 0, _x, _y, _direction, 1, 0, _color, draw_get_alpha());
}

function frontend_character_confirm_hint(_player) {
    if (global.frontend_mode == "coop_online") return frontend_key_short_name(frontend_keybinding("p1_interact")) + " / Enter";
    return _player == 1 ? "Enter" : (character_player_count == 1 ? "E / Enter" : "E");
}

function frontend_draw_character_select() {
    draw_set_alpha(1);
    draw_sprite(spr_character_background, 0, 0, 0);
    frontend_panel(400, 20, 480, 54, make_color_rgb(245, 240, 216), ink);
    frontend_text(640, 32, "Escolha sua cientista", font_body, ink, fa_center);
    frontend_panel(264, 82, 752, 30, make_color_rgb(245, 240, 216), teal);
    frontend_text(640, 87, "1. Use as setas para escolher    2. Confirme para abrir o mapa", font_small, ink, fa_center);
    // Quiet surfaces keep names and bindings readable over the illustrated floor.
    frontend_panel(character_player_count == 1 ? 400 : 160, 536,
        character_player_count == 1 ? 480 : 960, 124, make_color_rgb(232, 241, 224), teal);
    frontend_panel(280, 674, 720, 32, make_color_rgb(245, 240, 216), teal);
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
        var local_card = global.frontend_mode != "coop_online" || ((i == 0) == global.is_host);
        if (!slot.active) {
            frontend_panel(card.x, card.y, card.w, card.h, make_color_rgb(229, 232, 230), muted);
            frontend_text(center_x, card.y + 125, "Aguardando outro", font_body, muted, fa_center);
            frontend_text(center_x, card.y + 160, "jogador entrar na sala", font_small, muted, fa_center);
            continue;
        }
        if (character_player_count == 2) {
            frontend_panel(center_x - 112, 116, 224, 28, make_color_rgb(245, 240, 216), accent);
            frontend_text(center_x, 120, "Jogadora " + string(i + 1) + (local_card ? "" : " · remota"), font_small, accent, fa_center);
        }
        var width_scale = slot.flip_timer > 0 ? max(0.02, abs(slot.flip_timer / 0.1 - 1)) : 1;
        var show_back = slot.flip_timer > 0.1 ? !slot.back : slot.back;
        var card_width = card.w * width_scale;
        frontend_panel(center_x - card_width / 2, card.y, card_width, card.h,
            slot.ready ? make_color_rgb(218, 239, 211) : make_color_rgb(248, 240, 213), slot.ready ? accent : muted);
        if (width_scale > 0.9) {
            frontend_text(center_x, card.y + 14, scientist.name, font_body, accent, fa_center);
            if (show_back) {
                draw_set_font(font_small);
                draw_set_halign(fa_left);
                draw_set_color(ink);
                draw_text_ext(card.x + 20, card.y + 58, scientist.bio, 22, card.w - 40);
            } else {
                frontend_rect(card.x + 16, card.y + 52, card.w - 32, 206, make_color_rgb(194, 218, 195));
                frontend_scientist(card.x + 44, card.y + 52, 6, slot.choice);
                draw_set_font(font_small);
                draw_set_halign(fa_center);
                draw_set_color(muted);
                draw_text_ext(center_x, card.y + 266, scientist.role, 20, card.w - 28);
            }
            // This strip is inside the existing clickable card, so it also flips the card.
            if (local_card) {
                var hovering = point_in_rectangle(device_mouse_x_to_gui(0),device_mouse_y_to_gui(0),card.x,card.y,card.x+card.w,card.y+card.h);
                frontend_panel(card.x+12,card.y+312,card.w-24,30,
                    hovering || focus==3+i*4 ? make_color_rgb(193,221,182) : make_color_rgb(224,235,211),accent);
                draw_sprite_ext(spr_ui_arrow,0,card.x+28,card.y+327,0.35,0.35,180,accent,1);
                frontend_text(center_x+6,card.y+317,show_back?"Ver personagem":"Ver história",font_small,accent,fa_center);
            }
        }
        var first_button = 1 + i * 4;
        for (var arrow = 0; arrow < 2; arrow++) {
            var b = buttons[first_button + arrow];
            var color_arrow = slot.ready || !local_card ? make_color_rgb(188, 195, 190) : accent;
            frontend_panel(b.x, b.y, b.w, b.h,
                focus == first_button + arrow && !slot.ready ? make_color_rgb(219, 236, 210) : make_color_rgb(245, 240, 216), color_arrow);
            frontend_character_arrow(b.x + b.w / 2, b.y + b.h / 2, arrow == 0 ? -1 : 1, color_arrow);
        }
        for (var dot = 0; dot < array_length(scientists); dot++) {
            draw_set_color(dot == slot.choice ? accent : make_color_rgb(238, 234, 213));
            draw_circle(center_x - 36 + dot * 24, 518, dot == slot.choice ? 6 : 4, false);
        }
        var status_button = buttons[first_button + 3];
        frontend_panel(status_button.x, status_button.y, status_button.w, status_button.h,
            slot.ready ? make_color_rgb(193, 221, 182) : (focus == first_button + 3 ? mint : paper), accent);
        frontend_text(center_x, status_button.y + 10,
            !local_card ? (slot.ready ? "Pronta!" : "Aguardando escolha") : (slot.ready ? "Pronta! Desfazer" : "Confirmar personagem"),
            font_body, accent, fa_center);
        var key_prefix = global.frontend_mode == "coop_online" || i == 0 ? "p1_" : "p2_";
        var key_left = frontend_key_short_name(frontend_keybinding(key_prefix + "left"));
        var key_right = frontend_key_short_name(frontend_keybinding(key_prefix + "right"));
        var key_up = frontend_key_short_name(frontend_keybinding(key_prefix + "up"));
        var key_down = frontend_key_short_name(frontend_keybinding(key_prefix + "down"));
        if (!local_card) {
            frontend_text(center_x, 606, "Controlada no outro computador", font_small, muted, fa_center);
        } else {
            frontend_text(center_x, 604, key_left + "/" + key_right + ": escolher | " + key_up + "/" + key_down + ": história", font_small, muted, fa_center);
            frontend_text(center_x, 632, frontend_character_confirm_hint(i) + ": " + (slot.ready ? "desfazer" : "confirmar"), font_small, accent, fa_center);
        }
    }
    var waiting = false;
    for (var i = 0; i < character_player_count; i++) if (character_slots[i].ready) waiting = true;
    frontend_text(640, 680, character_player_count == 2
        ? (waiting ? "Aguardando a outra jogadora confirmar para abrir o mapa" : "Cada jogadora escolhe uma cientista diferente e confirma")
        : "Confirme sua personagem para escolher uma fase no mapa", font_small, muted, fa_center);
    if (notice_timer > 0) {
        frontend_panel(320, 82, 640, 30, paper, coral);
        frontend_text(640, 87, notice, font_small, coral, fa_center);
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
