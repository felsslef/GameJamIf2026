// Se não houver jogadores na sala, cancela
if (!instance_exists(obj_player)) exit;

// 1. Encontrar as coordenadas extremas de todos os jogadores
var min_x = room_width;
var max_x = 0;
var min_y = room_height;
var max_y = 0;

with (obj_player) {
    min_x = min(min_x, x);
    max_x = max(max_x, x);
    min_y = min(min_y, y);
    max_y = max(max_y, y);
}

// 2. Calcular o ponto central e a área necessária
var center_x = (min_x + max_x) / 2;
var center_y = (min_y + max_y) / 2;

var padding = 128; // Margem extra para os jogadores não ficarem colados na borda da tela
var req_w = (max_x - min_x) + padding * 2;
var req_h = (max_y - min_y) + padding * 2;

// Manter a proporção 16:9
var aspect_ratio = 16 / 9;
if (req_w / req_h < aspect_ratio) {
    req_w = req_h * aspect_ratio;
} else {
    req_h = req_w / aspect_ratio;
}

// Limites de Zoom (Min = zoom máximo / Max = visão total da sala)
var min_w = 640;  // Resolução mínima da visão
var max_w = 1920; // Resolução máxima da visão

var target_w = clamp(req_w, min_w, max_w);
var target_h = target_w / aspect_ratio;

// 3. Suavização (lerp) para movimento e zoom fluidos
var cam = view_camera[0];
var current_w = camera_get_view_width(cam);
var current_h = camera_get_view_height(cam);

var new_w = lerp(current_w, target_w, 0.08);
var new_h = lerp(current_h, target_h, 0.08);

// Posição com base no centro calculado
var target_x = center_x - (new_w / 2);
var target_y = center_y - (new_h / 2);

// Travar a câmera dentro dos limites do Room
target_x = clamp(target_x, 0, room_width - new_w);
target_y = clamp(target_y, 0, room_height - new_h);

var current_x = camera_get_view_x(cam);
var current_y = camera_get_view_y(cam);

var new_x = lerp(current_x, target_x, 0.08);
var new_y = lerp(current_y, target_y, 0.08);

// Aplicar alterações na View
camera_set_view_size(cam, new_w, new_h);
camera_set_view_pos(cam, new_x, new_y);