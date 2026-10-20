if (!variable_global_exists("game_mode")) global.game_mode = "solo";
if (!variable_global_exists("is_host")) global.is_host = true;
if (!variable_global_exists("target_ip")) global.target_ip = "127.0.0.1";

switch (global.game_mode) {
    case "solo":
        if (coopPlayer == 1) {
            var p1 = instance_create_layer(x, y, "Instances", obj_player);
            p1.playerid = 1;
            p1.is_local = true;
        }
        break;
        
    case "coop_local":
        if (coopPlayer == 1) {
            var p1 = instance_create_layer(x, y, "Instances", obj_player);
            p1.playerid = 1;
            p1.is_local = true;
        } else if (coopPlayer == 2) {
            var p2 = instance_create_layer(x, y, "Instances", obj_player);
            p2.playerid = 2;
            p2.is_local = true;
        }
        break;
        
    case "coop_online":
        if (global.is_host) {
            // Host controla o Player 1
            if (coopPlayer == 1) {
                var p1 = instance_create_layer(x, y, "Instances", obj_player);
                p1.playerid = 1;
                p1.is_local = true;
                
                global.server = network_create_server(network_socket_tcp, 6510, 2);
                global.client_socket = noone;
            } else if (coopPlayer == 2) {
                var p2 = instance_create_layer(x, y, "Instances", obj_player);
                p2.playerid = 2;
                p2.is_local = false; // Remoto no Host
            }
        } else {
            // Client controla o Player 2
            if (coopPlayer == 1) {
                var p1 = instance_create_layer(x, y, "Instances", obj_player);
                p1.playerid = 1;
                p1.is_local = false; // Remoto no Client
            } else if (coopPlayer == 2) {
                var p2 = instance_create_layer(x, y, "Instances", obj_player);
                p2.playerid = 2;
                p2.is_local = true;
                
                global.client_socket = network_create_socket(network_socket_tcp);
                network_connect(global.client_socket, global.target_ip, 6510);
            }
        }
        
        // Garante a criação do gerenciador de rede
        if (!instance_exists(obj_network)) {
            instance_create_layer(0, 0, "Instances", obj_network);
        }
        break;
}