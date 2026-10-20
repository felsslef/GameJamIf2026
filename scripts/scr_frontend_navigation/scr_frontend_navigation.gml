function frontend_back() {
    switch (screen) {
        case "main": break;
        case "mode": room_goto(rm_main_menu); break;
        case "options": room_goto(rm_main_menu); break;
        case "saves": room_goto(rm_game_mode); break;
        case "characters": room_goto(rm_save_select); break;
        case "levels":
            global.frontend_level = selected_level;
            room_goto(rm_character_select);
            break;
    }
}

function frontend_activate(_button) {
    switch (_button.action) {
        case "play": room_goto(rm_game_mode); break;
        case "options": room_goto(rm_options); break;
        case "quit": game_end(); break;
        case "back": frontend_back(); break;
        case "mode":
            var modes = ["solo", "coop_local", "coop_online"];
            global.frontend_mode = modes[_button.value];
            room_goto(rm_save_select);
            break;
        case "save_load":
            if (save_slot_load(_button.value)) room_goto(rm_character_select);
            else { notice = "Falha ao abrir o save."; notice_timer = 3; }
            break;
        case "save_new":
            if (save_slot_exists(_button.value) && pending_reset != _button.value) {
                pending_reset = _button.value;
                notice = "Apagar progresso? Clique em Confirmar.";
                notice_timer = 5;
                frontend_build_buttons();
            } else {
                if (save_slot_new(_button.value)) room_goto(rm_character_select);
                else { notice = "Falha ao salvar."; notice_timer = 3; }
            }
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
            selected_level = _button.value;
            global.frontend_level = selected_level;
            break;
        case "start":
            if (!frontend_level_is_available(selected_level)) {
                notice = "Conclua a fase anterior.";
                notice_timer = 2;
                break;
            }
            global.frontend_level = selected_level;
            // The first offline stop has its own playable level. LAN keeps its original prototype.
            if (global.frontend_mode == "coop_online") {
                global.frontend_network_entry = true;
                global.game_mode = "solo";
                // The legacy room stays directly before rm_teste in RoomOrderNodes.
                // Its original room_goto_next() and network events remain untouched.
                room_goto(rm_menu);
            } else {
                global.game_mode = global.frontend_mode;
                var offline_rooms = [rm_level_01, rm_level_02, rm_level_03, rm_level_04, rm_level_05];
                room_goto(offline_rooms[selected_level]);
            }
            break;
        case "motion":
            global.frontend_reduced_motion = !global.frontend_reduced_motion;
            frontend_build_buttons();
            break;
    }
}

function frontend_update() {
    var dt = min(delta_time / 1000000, 0.05);
    if (!global.frontend_reduced_motion) elapsed += dt;
    notice_timer = max(0, notice_timer - dt);
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
    var hovered = -1;
    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        if (b.action == "level") {
            if (point_in_circle(mx, my, b.x + b.w / 2, b.y + b.h / 2, b.w / 2)) hovered = i;
        } else if (point_in_rectangle(mx, my, b.x, b.y, b.x + b.w, b.y + b.h)) hovered = i;
    }
    if (mouse_moved && hovered >= 0) focus = hovered;
    var previous = keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"));
    var next = keyboard_check_pressed(vk_down) || keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_tab);
    if (previous) focus = (focus + array_length(buttons) - 1) mod array_length(buttons);
    if (next) focus = (focus + 1) mod array_length(buttons);
    if (screen == "levels" && focus < 5) selected_level = focus;
    if (keyboard_check_pressed(vk_escape)) {
        if (screen == "saves" && pending_reset >= 0) { pending_reset = -1; frontend_build_buttons(); return; }
        frontend_back(); return;
    }
    if (mouse_check_button_pressed(mb_left) && hovered >= 0) {
        focus = hovered;
        frontend_activate(buttons[hovered]);
        return;
    }
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) frontend_activate(buttons[focus]);
}
