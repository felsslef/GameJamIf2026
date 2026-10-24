function frontend_back() {
    if (online_game() && (screen=="characters" || (!global.is_host && screen=="levels"))) {
        with(obj_session_ui)session_ui_return_to_title();
        return;
    }
    switch (screen) {
        case "main": break;
        case "mode": session_ui_change_room(rm_main_menu); break;
        case "options":
            frontend_audio_save();
            audio_drag_channel = "";
            if (settings_in_pause) pause_settings = false;
            else session_ui_change_room(rm_main_menu);
            break;
        case "controls":
            global.frontend_rebinding = "";
            if (settings_in_pause) screen = "options";
            else session_ui_change_screen("options");
            focus = 0;
            frontend_build_buttons();
            break;
        case "saves": session_ui_change_room(rm_game_mode); break;
        case "difficulty":
            pending_new_slot = -1;
            session_ui_change_screen("saves");
            break;
        case "characters": session_ui_change_room(rm_save_select); break;
        case "levels":
            global.frontend_level = selected_level;
            session_ui_change_room(rm_character_select);
            break;
    }
}

function frontend_activate(_button) {
    switch (_button.action) {
        case "play": session_ui_change_room(rm_game_mode); break;
        case "options": session_ui_change_room(rm_options); break;
        case "controls":
            if (settings_in_pause) screen = "controls";
            else session_ui_change_screen("controls");
            global.frontend_rebinding = "";
            focus = 0;
            frontend_build_buttons();
            break;
        case "bind_key":
            global.frontend_rebinding = _button.value;
            notice = "Pressione a nova tecla. Esc cancela.";
            notice_timer = 3;
            frontend_build_buttons();
            break;
        case "reset_keys":
            global.frontend_keybindings = frontend_keybindings_defaults();
            global.frontend_rebinding = "";
            frontend_keybinding_save();
            notice = "Teclas padrão restauradas.";
            notice_timer = 3;
            frontend_build_buttons();
            break;
        case "quit": game_end(); break;
        case "back": frontend_back(); break;
        case "mode":
            var modes = ["solo", "coop_local", "coop_online"];
            global.frontend_mode = modes[_button.value];
            if (global.frontend_mode == "coop_online") {
                global.frontend_network_entry = true;
                global.game_mode = "coop_online";
                session_ui_change_room(rm_menu);
            } else session_ui_change_room(rm_save_select);
            break;
        case "save_load":
            if (!save_slot_exists(_button.value)) frontend_begin_save_creation(_button.value);
            else if (save_slot_load(_button.value)) session_ui_change_room(rm_character_select);
            else { notice = "Falha ao abrir o save."; notice_timer = 3; }
            break;
        case "save_new":
            if (save_slot_exists(_button.value) && pending_reset != _button.value) {
                pending_reset = _button.value;
                notice = "Apagar progresso? Clique em Confirmar.";
                notice_timer = 5;
                frontend_build_buttons();
            } else if (save_slot_exists(_button.value)) {
                var deleted = save_slot_delete(_button.value);
                pending_reset = -1;
                notice = deleted ? "Save excluído." : "Falha ao excluir o save.";
                notice_timer = 3;
                frontend_build_buttons();
                focus = clamp(focus, 0, array_length(buttons)-1);
            } else {
                frontend_begin_save_creation(_button.value);
            }
            break;
        case "choose_difficulty":
            if (screen != "difficulty" || pending_new_slot < 0) break;
            if (save_slot_new(pending_new_slot, _button.value)) {
                pending_new_slot = -1;
                session_ui_change_room(rm_character_select);
            } else { notice = "Não foi possível criar o save."; notice_timer = 3; }
            break;
        case "save_write":
            notice = save_slot_write() ? "Progresso salvo." : "Escolha um slot primeiro.";
            notice_timer = 3;
            frontend_build_buttons();
            break;
        case "character_previous": frontend_character_cycle(_button.value, -1); break;
        case "character_next": frontend_character_cycle(_button.value, 1); break;
        case "character_flip": frontend_character_flip(_button.value); break;
        case "character_ready": frontend_character_toggle_ready(_button.value); break;
        case "character_continue": frontend_character_continue(); break;
        case "level":
            if (global.frontend_mode == "coop_online" && !global.is_host) break;
            selected_level = _button.value;
            global.frontend_level = selected_level;
            if (global.frontend_mode == "coop_online" && global.is_host && variable_global_exists("online_selection")) global.online_selection.level = selected_level;
            break;
        case "start":
            if (global.frontend_mode == "coop_online" && !global.is_host) break;
            if (!frontend_level_is_available(selected_level)) {
                notice = "Conclua a fase anterior.";
                notice_timer = 2;
                break;
            }
            global.frontend_level = selected_level;
            if (global.frontend_mode == "coop_online") {
                global.game_mode = "coop_online";
                global.online_selection.screen = "game";
                global.online_selection.level = selected_level;
                global.online_selection.p1_choice = global.frontend_characters[0];
                global.online_selection.p2_choice = global.frontend_characters[1];
                var online_rooms = [rm_level_01, rm_level_02, rm_level_03, rm_level_04, rm_level_05];
                session_ui_change_room(selected_level == -1 ? rm_tutorial : online_rooms[selected_level]);
            } else {
                global.game_mode = global.frontend_mode;
                var offline_rooms = [rm_level_01, rm_level_02, rm_level_03, rm_level_04, rm_level_05];
                session_ui_change_room(selected_level == -1 ? rm_tutorial : offline_rooms[selected_level]);
            }
            break;
        case "motion":
            global.frontend_reduced_motion = !global.frontend_reduced_motion;
            frontend_build_buttons();
            break;
        case "colorblind":
            global.frontend_colorblind = !global.frontend_colorblind;
            frontend_accessibility_save();
            frontend_build_buttons();
            break;
        case "volume":
        case "volume_up":
        case "volume_down":
            frontend_audio_set(_button.value, variable_struct_get(global.frontend_audio, _button.value)
                + (_button.action == "volume_down" ? -0.05 : 0.05));
            break;
        case "double_tap_dash":
            global.frontend_double_tap_dash = !global.frontend_double_tap_dash;
            frontend_double_tap_dash_save();
            frontend_build_buttons();
            break;
    }
}

function frontend_controls_move_focus(_dx, _dy) {
    if (_dx == 0 && _dy == 0) return;
    var current = buttons[focus];
    var current_x = current.x + current.w * 0.5;
    var current_y = current.y + current.h * 0.5;
    var best = -1;
    var best_score = 1000000000;
    for (var i = 0; i < array_length(buttons); i++) {
        if (i == focus) continue;
        var candidate = buttons[i];
        var dx = candidate.x + candidate.w * 0.5 - current_x;
        var dy = candidate.y + candidate.h * 0.5 - current_y;
        var forward = _dx != 0 ? dx * _dx : dy * _dy;
        if (forward <= 0) continue;
        var sideways = _dx != 0 ? abs(dy) : abs(dx);
        var candidate_score = forward + sideways * 2;
        if (candidate_score < best_score) {
            best_score = candidate_score;
            best = i;
        }
    }
    if (best >= 0) focus = best;
}

function frontend_update() {
    if (session_ui_transition_active()) return;
    var dt = min(delta_time / 1000000, 0.05);
    if (!global.frontend_reduced_motion) elapsed += dt;
    notice_timer = max(0, notice_timer - dt);
    if (screen == "controls" && global.frontend_rebinding != "") {
        if (keyboard_check_pressed(vk_escape)) {
            global.frontend_rebinding = "";
            frontend_build_buttons();
            return;
        }
        for (var key_code = 8; key_code < 256; key_code++) {
            if (keyboard_check_pressed(key_code)) {
                if (frontend_keybinding_set(global.frontend_rebinding, key_code)) {
                    global.frontend_rebinding = "";
                    notice = "Tecla configurada: " + frontend_key_name(key_code);
                    notice_timer = 2;
                } else {
                    notice = "Essa tecla já está atribuída a outro comando.";
                    notice_timer = 2;
                }
                frontend_build_buttons();
                return;
            }
        }
        return;
    }
    if (screen == "levels" && keyboard_check_pressed(ord("Q"))) {
        global.frontend_test_unlock = true;
    }
    if (screen == "characters") {
        frontend_character_update(dt);
        return;
    }
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var mouse_moved = abs(mx - pointer_x) + abs(my - pointer_y) > 1;
    pointer_x = mx;
    pointer_y = my;
    if (screen == "options" && audio_drag_channel != "") {
        if (mouse_check_button(mb_left)) {
            frontend_audio_set(audio_drag_channel, (mx - 488) / 304, false);
        } else {
            frontend_audio_save();
            audio_drag_channel = "";
        }
        return;
    }
    var hovered = -1;
    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        if (b.action == "level") {
            if (point_in_circle(mx, my, b.x + b.w / 2, b.y + b.h / 2, b.w / 2)) hovered = i;
        } else if (point_in_rectangle(mx, my, b.x, b.y, b.x + b.w, b.y + b.h)) hovered = i;
    }
    if (mouse_moved && hovered >= 0) focus = hovered;
    if (screen == "controls" || screen == "options") {
        var nav_x = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))
            - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")));
        var nav_y = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")))
            - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")));
        if (nav_x != 0 && buttons[focus].action == "volume") {
            var channel = buttons[focus].value;
            frontend_audio_set(channel, variable_struct_get(global.frontend_audio, channel) + nav_x * 0.05);
        } else if (nav_x != 0) frontend_controls_move_focus(nav_x, 0);
        else if (nav_y != 0) frontend_controls_move_focus(0, nav_y);
        if (keyboard_check_pressed(vk_tab)) focus = (focus + 1) mod array_length(buttons);
    } else {
        var previous = keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"));
        var next = keyboard_check_pressed(vk_down) || keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_tab);
        if (previous) focus = (focus + array_length(buttons) - 1) mod array_length(buttons);
        if (next) focus = (focus + 1) mod array_length(buttons);
    }
    if (screen == "levels" && global.frontend_mode == "coop_online" && !global.is_host) {
        selected_level = global.frontend_level;
        focus = clamp(selected_level + 1, 0, 5);
    } else if (screen == "levels" && buttons[focus].action == "level") {
        selected_level = buttons[focus].value;
        if (global.frontend_mode == "coop_online" && global.is_host) global.online_selection.level = selected_level;
    }
    if (keyboard_check_pressed(vk_escape)) {
        if (screen == "saves" && pending_reset >= 0) { pending_reset = -1; frontend_build_buttons(); return; }
        frontend_back(); return;
    }
    if (mouse_check_button_pressed(mb_left) && hovered >= 0) {
        focus = hovered;
        if (buttons[hovered].action == "volume") {
            audio_drag_channel = buttons[hovered].value;
            frontend_audio_set(audio_drag_channel, (mx - buttons[hovered].x - 12) / (buttons[hovered].w - 24), false);
            return;
        }
        frontend_activate(buttons[hovered]);
        return;
    }
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) frontend_activate(buttons[focus]);
}
