if (!variable_global_exists("game_mode")) global.game_mode = "solo";
if (!variable_global_exists("is_host")) global.is_host = true;
if (!variable_global_exists("target_ip")) global.target_ip = "127.0.0.1";

switch (global.game_mode) {
    case "solo":
        // Só cria o Player 1 na posição da instância marcada como coopPlayer == 1
        if (coopPlayer == 1) {
            var p1 = instance_create_layer(x, y, "Instances", obj_player);
            p1.playerid = 1;
        }
        break;
        
    case "coop_local":
        if (coopPlayer == 1) {
            var p1 = instance_create_layer(x, y, "Instances", obj_player);
            p1.playerid = 1;
        } else if (coopPlayer == 2) {
            var p2 = instance_create_layer(x, y, "Instances", obj_player);
            p2.playerid = 2;
        }
        break;
        
    case "coop_online":
        if (global.is_host) {
            // Host cria o Player 1 no Spawn 1 e abre o servidor
            if (coopPlayer == 1) {
                var p1 = instance_create_layer(x, y, "Instances", obj_player);
                p1.playerid = 1;
                
                global.server = network_create_server(network_socket_tcp, 6510, 2);
                global.client_socket = noone;
            }
        } else {
            // Client cria o Player 2 no Spawn 2 e conecta ao servidor
            if (coopPlayer == 2) {
                var p2 = instance_create_layer(x, y, "Instances", obj_player);
                p2.playerid = 2;
                
                global.client_socket = network_create_socket(network_socket_tcp);
                network_connect(global.client_socket, global.target_ip, 6510);
            }
        }
        break;
}