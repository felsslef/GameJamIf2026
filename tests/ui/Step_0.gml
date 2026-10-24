ticks++;
if (ticks < 12) exit;
function check(_ok, _label) {
    show_debug_message((_ok ? "PASS: " : "FAIL: ") + _label);
    if (!_ok) global.probe_failed = true;
}
function pause_key(_key) {
    global.keys_pressed = [_key];
    with (obj_session_ui) session_ui_update();
    global.keys_pressed = [];
}
function mouse_at(_x, _y, _pressed, _held) {
    global.probe_mouse_x = _x;
    global.probe_mouse_y = _y;
    global.probe_mouse_pressed = _pressed;
    global.probe_mouse_down = _held;
}
if (stage == 0) {
    with (obj_frontend) {
        check(scientists[2].name == "Manuela Otavio" && scientists[3].name == "Maria Klara", "correct scientist names");
        check(string_pos("Maria Clara", scientists[3].bio) == 0, "biography uses Maria Klara");
        check(character_player_count == 1 && buttons[4].action == "character_ready", "solo has explicit confirm action");
        frontend_character_cycle(0, 1);
        frontend_character_cycle(0, 1);
    }
    stage = 1; ticks = 0; exit;
}
if (stage == 1) {
    screen_save(working_directory + "selection-solo.png");
    with (obj_frontend) frontend_character_toggle_ready(0);
    stage = 2; ticks = 0; exit;
}
if (stage == 2) {
    check(room == rm_level_select && global.frontend_characters[0] == 2, "solo confirmation opens map with chosen scientist");
    global.frontend_mode = "coop_local";
    room_goto(rm_character_select);
    stage = 3; ticks = 0; exit;
}
if (stage == 3) {
    with (obj_frontend) {
        check(character_player_count == 2 && array_length(buttons) == 9, "co-op has independent card actions");
        character_slots[0].choice = 2;
        character_slots[1].choice = 3;
        frontend_character_toggle_ready(0);
        check(character_slots[0].ready && !character_starting, "co-op waits for partner");
        frontend_character_flip(0);
        check(character_slots[0].back, "ready character can read biography");
    }
    stage = 4; ticks = 0; exit;
}
if (stage == 4) {
    screen_save(working_directory + "selection-coop-ready.png");
    with (obj_frontend) {
        frontend_character_toggle_ready(0);
        character_slots[1].choice = 2;
        frontend_character_toggle_ready(0);
        frontend_character_toggle_ready(1);
        check(!character_slots[1].ready && !character_starting, "duplicate character confirmation stays blocked");
        frontend_character_cycle(1, 1);
        frontend_character_toggle_ready(1);
    }
    stage = 5; ticks = 0; exit;
}
if (stage == 5) {
    check(room == rm_level_select && global.frontend_characters[1] == 3, "co-op commits both characters and opens map");
    room_goto(rm_options);
    stage = 6; ticks = 0; exit;
}
if (stage == 6) {
    with (obj_frontend) {
        check(array_length(buttons) == 13, "settings expose volume sliders and accessibility options");
        frontend_audio_set("master", 0.75);
        frontend_audio_set("music", 0.4);
        frontend_audio_set("effects", 0.25);
        global.frontend_audio_ready = false;
        frontend_audio_init();
        check(global.frontend_audio.master == 0.75 && global.frontend_audio.music == 0.4 && global.frontend_audio.effects == 0.25, "all three volumes reload from saved preferences");
        check(abs(audio_get_master_gain(0) - 0.75) < 0.001, "master gain applied to audio engine");
        check(abs(audio_sound_get_gain(snd_delivery_success) - 0.15) < 0.001, "effects volume preserves the original sound mix");
        with (obj_session_ui) {
            check(array_length(music_voices) > 0, "music has an active voice");
            frontend_audio_set("music", 0);
            for (var i = 0; i < array_length(music_voices); i++) {
                check(audio_sound_get_gain(music_voices[i].handle) == 0, "music slider mutes existing voices immediately");
            }
            frontend_audio_set("music", 0.4);
        }
        focus = 4;
        global.keys_pressed = [vk_right]; frontend_update(); global.keys_pressed = [];
        check(global.frontend_audio.music == 0.45, "keyboard adjusts focused volume slider");
        mouse_at(640, 402, true, true); frontend_update();
        check(global.frontend_audio.effects == 0.5, "click sets volume slider position");
        mouse_at(804, 402, false, true); frontend_update();
        check(global.frontend_audio.effects == 1, "drag reaches maximum volume");
        mouse_at(476, 402, false, true); frontend_update();
        check(global.frontend_audio.effects == 0, "drag reaches mute");
        mouse_at(640, 402, false, true); frontend_update();
        mouse_at(-100, -100, false, false); frontend_update();
    }
    stage = 7; ticks = 0; exit;
}
if (stage == 7) {
    screen_save(working_directory + "audio-settings.png");
    global.game_mode = "solo";
    global.frontend_mode = "solo";
    room_goto(rm_level_01);
    stage = 8; ticks = 0; exit;
}
if (stage == 8) {
    with (obj_recycling_level) {
        time_remaining = 15; check(!recycling_time_is_urgent(), "no flash at fifteen seconds");
        time_remaining = 10.01; check(!recycling_time_is_urgent(), "no flash above ten seconds");
        time_remaining = 10; check(recycling_time_is_urgent(), "warning starts at ten seconds");
        time_remaining = 5; check(recycling_time_is_urgent(), "warning continues through final five seconds");
        phase_state = "won"; check(!recycling_time_is_urgent(), "finished round has no urgency flash");
        phase_state = "playing"; time_remaining = 60;
    }
    frozen_level = instance_find(obj_recycling_level, 0);
    frozen_time = frozen_level.time_remaining;
    pause_key(vk_escape);
    instance_activate_object(id);
    with (obj_session_ui) check(pause_open && frozen_offline, "pause freezes offline gameplay");
    stage = 9; ticks = 0; exit;
}
if (stage == 9) {
    screen_save(working_directory + "pause-settings-button.png");
    check(frozen_level.time_remaining == frozen_time, "timer remains frozen while paused");
    pause_key(vk_down); pause_key(vk_enter);
    with (obj_session_ui) {
        check(pause_settings && screen == "options", "pause button opens settings in same room");
        frontend_activate({action: "volume_down", value: "music"});
        check(global.frontend_audio.music == 0.4, "pause settings adjust volume");
        frontend_activate({action: "controls"});
        check(screen == "controls" && pause_open, "pause settings include key configuration");
        frontend_activate({action: "bind_key", value: "p1_interact"});
    }
    pause_key(vk_escape);
    with (obj_session_ui) check(screen == "controls" && global.frontend_rebinding == "", "escape cancels rebinding without leaving controls");
    pause_key(vk_escape);
    with (obj_session_ui) check(screen == "options" && pause_open, "escape returns to pause settings");
    stage = 10; ticks = 0; exit;
}
if (stage == 10) {
    screen_save(working_directory + "paused-audio-settings.png");
    check(room == rm_level_01 && frozen_level.time_remaining == frozen_time, "settings preserve current phase and timer");
    pause_key(vk_escape);
    with (obj_session_ui) check(pause_open && !pause_settings, "escape returns to pause menu");
    pause_key(vk_escape);
    with (obj_session_ui) check(!pause_open, "second escape resumes gameplay");
    check(instance_exists(frozen_level), "gameplay instances reactivate");
    if (file_exists(working_directory + "probe_audio.ini")) file_delete(working_directory + "probe_audio.ini");
    show_debug_message(global.probe_failed ? "UI_PROBE_FAILED" : "UI_PROBE_PASSED");
    game_end();
}
