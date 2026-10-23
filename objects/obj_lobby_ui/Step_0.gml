if (!global.frontend_reduced_motion) elapsed += min(delta_time / 1000000, 0.05);
if (keyboard_check_pressed(vk_escape)) {
    with (obj_menu) {
        if (udp_listener != noone) {
            network_destroy(udp_listener);
            udp_listener = noone;
        }
    }
    global.frontend_mode = "coop_online";
    room_goto(rm_game_mode);
    exit;
}
// The original Voltar action closes the listener before returning to main.
if (instance_exists(obj_menu) && obj_menu.menu_state == "main") room_goto(rm_game_mode);
