// Atributos de movimentação
move_spd = 4;
dash_spd = 12;

// Controle do Dash
is_dashing = false;
dash_time = 0;
dash_time_max = 8;
dash_cooldown = 0;
dash_cooldown_max = 25;

// Orientação
move_dir = 270;

// Item segurado
held_item = noone;

estado = scr_player_step;

// Carga do Arremesso
throw_charge = 0;
throw_charge_max = 30;   // Tempo em frames para carga máxima (~0.5s a 60 FPS)
throw_dist_min = 80;     // Distância mínima (toque rápido)
throw_dist_max = 280;    // Distância máxima (carga completa)