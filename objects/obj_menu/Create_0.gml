options_main = ["Solo", "Coop Local", "Coop Online", "Sair"];
menu_state = "main"; // "main" ou "lobby_online"

if (!variable_global_exists("game_mode")) global.game_mode = "solo";
if (!variable_global_exists("is_host")) global.is_host = true;
if (!variable_global_exists("target_ip")) global.target_ip = "127.0.0.1";
if (!variable_global_exists("room_name")) global.room_name = "Mutirão de Caraguá";
lobby_error="";

// Lista de salas encontradas na rede local
rooms_list = array_create(0);
udp_listener = noone;
