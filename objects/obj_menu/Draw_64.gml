var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var start_x = display_get_gui_width() / 2;
var start_y = display_get_gui_height() / 2 - 80;
var line_height = 40;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// MENU PRINCIPAL
if (menu_state == "main") {
    for (var i = 0; i < array_length(options_main); i++) {
        var item_y = start_y + (i * line_height);
        var is_hover = point_in_rectangle(mx, my, start_x - 100, item_y - 15, start_x + 100, item_y + 15);
        
        draw_set_color(is_hover ? c_yellow : c_white);
        draw_text(start_x, item_y, options_main[i]);
        
        if (is_hover && mouse_check_button_pressed(mb_left)) {
            switch (i) {
                case 0: global.game_mode = "solo"; room_goto_next(); break;
                case 1: global.game_mode = "coop_local"; room_goto_next(); break;
                case 2: 
                    menu_state = "lobby_online";
                    if (udp_listener == noone) {
                        udp_listener = network_create_socket_ext(network_socket_udp, 6511);
                    }
                    break;
                case 3: game_end(); break;
            }
        }
    }
} 
// LOBBY ONLINE
else if (menu_state == "lobby_online") {
    draw_set_color(c_white);
    draw_text(start_x, start_y - 40, "--- LOBBY ONLINE ---");

    // Botão Criar Sala
    var create_y = start_y;
    var hover_create = point_in_rectangle(mx, my, start_x - 100, create_y - 15, start_x + 100, create_y + 15);
    draw_set_color(hover_create ? c_lime : c_white);
    draw_text(start_x, create_y, "[ + Criar Nova Sala ]");

    if (hover_create && mouse_check_button_pressed(mb_left)) {
        var input_name = get_string("Nome da sua sala:", "Sala do Gari");
        if (input_name != "") {
            global.room_name = input_name;
            global.game_mode = "coop_online";
            global.is_host = true;
            frontend_online_selection_start(true);
            if (udp_listener != noone) network_destroy(udp_listener);
            global.server = network_create_server(network_socket_tcp, 6510, 1);
            if (global.server >= 0) session_ui_change_room(rm_character_select);
        }
    }

    // Lista de Salas Disponíveis
    draw_set_color(c_white);
    draw_text(start_x, start_y + 40, "Salas Encontradas:");

    for (var i = array_length(rooms_list) - 1; i >= 0; i--) {
        rooms_list[i].timer--;
        if (rooms_list[i].timer <= 0) {
            array_delete(rooms_list, i, 1);
            continue;
        }

        var room_item = rooms_list[i];
        var item_y = start_y + 80 + (i * 35);
        var hover_room = point_in_rectangle(mx, my, start_x - 120, item_y - 12, start_x + 120, item_y + 12);

        draw_set_color(hover_room ? c_yellow : c_aqua);
        draw_text(start_x, item_y, room_item.name + " (" + room_item.ip + ")");

        if (hover_room && mouse_check_button_pressed(mb_left)) {
            global.target_ip = room_item.ip;
            global.game_mode = "coop_online";
            global.is_host = false;
            frontend_online_selection_start(false);
            if (udp_listener != noone) network_destroy(udp_listener);
            global.client_socket = network_create_socket(network_socket_tcp);
            network_connect(global.client_socket, global.target_ip, 6510);
            session_ui_change_room(rm_character_select);
        }
    }

    // Botão Voltar
    var back_y = display_get_gui_height() - 50;
    var hover_back = point_in_rectangle(mx, my, start_x - 60, back_y - 15, start_x + 60, back_y + 15);
    draw_set_color(hover_back ? c_red : c_white);
    draw_text(start_x, back_y, "Voltar");

    if (hover_back && mouse_check_button_pressed(mb_left)) {
        if (udp_listener != noone) {
            network_destroy(udp_listener);
            udp_listener = noone;
        }
        menu_state = "main";
    }
}
