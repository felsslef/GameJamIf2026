pause_open = false;
pause_snapshot = -1;
pause_focus = 0;
pause_pointer_x = device_mouse_x_to_gui(0);
pause_pointer_y = device_mouse_y_to_gui(0);
frozen_offline = false;
blocked_players = [];
is_primary = instance_number(obj_session_ui) == 1;
if (!is_primary) {
    instance_destroy();
    exit;
}
// Keep the overlay above the room while staying inside the 2D depth range.
depth = -10000;
music_track = -1;
music_voices = [];
