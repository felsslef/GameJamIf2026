/// Shared fullscreen shortcut and gameplay menu. Existing gameplay/network events stay intact.
function session_ui_transition_active() {
    if (!variable_global_exists("ui_fade_phase")) return false;
    return global.ui_fade_phase != "idle";
}

function session_ui_change_room(_target) {
    if (session_ui_transition_active()) return;
    if (!instance_exists(obj_session_ui) || global.frontend_reduced_motion) {
        if (_target == room) room_restart(); else room_goto(_target);
        return;
    }
    global.ui_fade_room = _target;
    global.ui_fade_screen = "";
    global.ui_fade_phase = "out";
    global.ui_fade_progress = 0;
}

function session_ui_change_screen(_screen) {
    if (session_ui_transition_active()) return;
    if (global.frontend_reduced_motion) {
        with(obj_frontend) { screen = _screen; focus = 0; frontend_build_buttons(); }
        return;
    }
    global.ui_fade_room = room;
    global.ui_fade_screen = _screen;
    global.ui_fade_phase = "out";
    global.ui_fade_progress = 0;
}

function session_ui_draw_transition() {
    if (!session_ui_transition_active()) return;
    var t = clamp(global.ui_fade_progress,0,1);
    var eased = t*t*t*(t*(t*6-15)+10);
    var w = display_get_gui_width(), h = display_get_gui_height();
    var cover_x = global.ui_fade_phase == "out" ? -w-96+(w+96)*eased : (w+96)*eased;
    draw_set_alpha(1);
    // A coastal wipe travels in one direction across both screens.
    frontend_rect(cover_x,0,w+96,h,make_color_rgb(38,126,120));
    var edge = global.ui_fade_phase == "out" ? cover_x+w+96 : cover_x;
    var stripe_direction = global.ui_fade_phase == "out" ? -1 : 1;
    frontend_rect(edge+stripe_direction*40,0,16,h,make_color_rgb(164,215,191));
    frontend_rect(edge+stripe_direction*18,0,8,h,make_color_rgb(248,235,195));
    draw_set_alpha(1);draw_set_color(c_white);
    global.ui_fade_progress += min(0.05,max(0,delta_time/1000000))/0.36;
    if (t < 1) return;
    if (global.ui_fade_phase == "out") {
        global.ui_fade_phase = "in";global.ui_fade_progress = 0;
        if (global.ui_fade_screen != "") {
            with(obj_frontend) { screen = global.ui_fade_screen; focus = 0; frontend_build_buttons(); }
        } else if (global.ui_fade_room == room) room_restart();
        else room_goto(global.ui_fade_room);
    } else global.ui_fade_phase = "idle";
}

function session_ui_is_gameplay() {
    return room != rm_main_menu && room != rm_game_mode
        && room != rm_character_select && room != rm_level_select
        && room != rm_options && room != rm_menu && room != rm_save_select;
}

function session_ui_toggle_fullscreen() {
    window_set_fullscreen(!window_get_fullscreen());
}

function session_ui_no_input() {
    // Keep local ownership and networking active while the LAN menu is open.
}

function session_ui_open_menu() {
    if (pause_open || !session_ui_is_gameplay()) return;
    pause_open = true;
    pause_focus = 0;
    frozen_offline = !variable_global_exists("game_mode") || global.game_mode != "coop_online";
    if (frozen_offline) {
        if (surface_exists(application_surface)) {
            pause_snapshot = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
            if (surface_exists(pause_snapshot)) surface_copy(pause_snapshot, 0, 0, application_surface);
        }
        instance_deactivate_all(true);
    } else {
        blocked_players = [];
        with (obj_player) {
            if (is_local) {
                array_push(other.blocked_players, {player: id, behavior: estado});
                estado = session_ui_no_input;
            }
        }
    }
}

function session_ui_close_menu() {
    if (!pause_open) return;
    if (frozen_offline) {
        instance_activate_all();
    } else {
        for (var i = 0; i < array_length(blocked_players); i++) {
            var entry = blocked_players[i];
            if (instance_exists(entry.player)) entry.player.estado = entry.behavior;
        }
    }
    blocked_players = [];
    if (surface_exists(pause_snapshot)) surface_free(pause_snapshot);
    pause_snapshot = -1;
    pause_open = false;
    frozen_offline = false;
}

function session_ui_return_to_title() {
    session_ui_close_menu();
    // Leaving a LAN session closes its existing handles; no packet/protocol changes.
    if (variable_global_exists("game_mode") && global.game_mode == "coop_online") {
        if (variable_global_exists("client_socket")) {
            if (global.client_socket >= 0) network_destroy(global.client_socket);
            global.client_socket = noone;
        }
        if (variable_global_exists("server")) {
            if (global.server >= 0) network_destroy(global.server);
            global.server = noone;
        }
    }
    global.game_mode = "solo";
    global.frontend_network_entry = false;
    room_goto(rm_main_menu);
}

function session_ui_update() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    if (keyboard_check_pressed(vk_f11)) {
        session_ui_toggle_fullscreen();
        return;
    }
    if (session_ui_transition_active()) return;
    if (!session_ui_is_gameplay()) return;
    // The finished round owns its result-screen input; F11 above remains available.
    if (instance_exists(obj_recycling_level) && obj_recycling_level.phase_state != "playing") return;
    if (keyboard_check_pressed(frontend_keybinding("pause"))) {
        if (pause_open) session_ui_close_menu();
        else session_ui_open_menu();
        return;
    }
    if (!pause_open) return;

    var panel_x = (gui_w - 360) / 2;
    var panel_y = (gui_h - 280) / 2;
    var moved = abs(mx - pause_pointer_x) + abs(my - pause_pointer_y) > 1;
    pause_pointer_x = mx;
    pause_pointer_y = my;
    var hovered = -1;
    for (var i = 0; i < 2; i++) {
        var by = panel_y + 100 + i * 76;
        if (point_in_rectangle(mx, my, panel_x + 32, by, panel_x + 328, by + 52)) hovered = i;
    }
    if (moved && hovered >= 0) pause_focus = hovered;
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)
        || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("S"))
        || keyboard_check_pressed(vk_tab)) pause_focus = 1 - pause_focus;
    var activate = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
    if (mouse_check_button_pressed(mb_left) && hovered >= 0) {
        pause_focus = hovered;
        activate = true;
    }
    if (activate) {
        if (pause_focus == 0) session_ui_close_menu();
        else session_ui_return_to_title();
    }
}

function session_ui_draw() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var color_ink = make_color_rgb(36, 41, 40);
    var color_focus = make_color_rgb(234, 240, 236);
    draw_set_alpha(1);
    if (pause_open) {
        if (frozen_offline) {
            if (surface_exists(pause_snapshot)) {
                draw_set_color(c_white);
                draw_surface_stretched(pause_snapshot, 0, 0, gui_w, gui_h);
            } else frontend_rect(0, 0, gui_w, gui_h, c_white);
        }
        draw_set_alpha(0.45);
        frontend_rect(0, 0, gui_w, gui_h, c_black);
        draw_set_alpha(1);
        var panel_x = (gui_w - 360) / 2;
        var panel_y = (gui_h - 280) / 2;
        frontend_panel(panel_x, panel_y, 360, 280, c_white, color_ink);
        frontend_text(gui_w / 2, panel_y + 32, frozen_offline ? "Pausado" : "Menu", fnt_ui_body, color_ink, fa_center);
        var labels = ["Continuar", "Tela inicial"];
        for (var i = 0; i < 2; i++) {
            var by = panel_y + 100 + i * 76;
            frontend_panel(panel_x + 32, by, 296, 52, pause_focus == i ? color_focus : c_white, color_ink);
            frontend_text(gui_w / 2, by + 12, labels[i], fnt_ui_body, color_ink, fa_center);
        }
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
