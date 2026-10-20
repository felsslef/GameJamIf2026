options_main = ["Solo", "Coop Local", "Coop Online", "Sair"];
options_online = ["Criar Sala (Host)", "Entrar em Sala", "Voltar"];

menu_state = "main"; // Estados: "main" ou "online"

if (!variable_global_exists("game_mode")) {
    global.game_mode = "solo";
}
if (!variable_global_exists("is_host")) {
    global.is_host = true;
}
if (!variable_global_exists("target_ip")) {
    global.target_ip = "127.0.0.1";
}