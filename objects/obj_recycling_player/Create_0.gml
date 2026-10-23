event_inherited();
estado = recycling_player_step;
move_spd = 6;
dash_spd = 18;
carried_item = noone;
throw_charge = 0;
throw_charge_max = 30;
character_index = 0;
ink = make_color_rgb(36, 41, 40);
scientists = [{color: make_color_rgb(18, 113, 105)}, {color: make_color_rgb(212, 106, 85)},
    {color: make_color_rgb(68, 125, 168)}, {color: make_color_rgb(129, 102, 161)}];

image_speed = 0;
image_xscale = 1;
image_yscale = 1;
if (!variable_global_exists("game_mode")) global.game_mode = "solo";
if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
if (playerid == 2 && global.game_mode != "coop_local" && global.game_mode != "coop_online") { instance_destroy(); exit; }
is_local = global.game_mode != "coop_online" || (global.is_host ? playerid == 1 : playerid == 2);
if (global.game_mode == "coop_online") is_local = global.is_host;
character_index = global.frontend_characters[clamp(playerid - 1, 0, 1)];
sprite_index = recycling_scientist_sprite(character_index);

stun_remaining = 0;
slip_contact = noone;
dash_trail_x = [];
dash_trail_y = [];
dash_trail_age = [];
dash_trail_strength = [];
last_tap_direction = -1;
last_tap_elapsed = 1;
double_tap_window = 0.25;
