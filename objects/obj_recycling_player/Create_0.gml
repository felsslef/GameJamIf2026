event_inherited();
estado = recycling_player_step;
move_spd = 6;
dash_spd = 18;
carried_item = noone;
character_index = 0;
ink = make_color_rgb(36, 41, 40);
scientists = [{color: make_color_rgb(18, 113, 105)}, {color: make_color_rgb(212, 106, 85)},
    {color: make_color_rgb(68, 125, 168)}, {color: make_color_rgb(129, 102, 161)}];

image_speed = 0;
if (!variable_global_exists("game_mode")) global.game_mode = "solo";
if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
if (playerid == 2 && global.game_mode != "coop_local") { instance_destroy(); exit; }
character_index = global.frontend_characters[clamp(playerid - 1, 0, 1)];
sprite_index = recycling_scientist_sprite(character_index);
