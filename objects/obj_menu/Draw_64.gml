var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var start_x = display_get_gui_width() / 2;
var start_y = display_get_gui_height() / 2 - 60;
var line_height = 40;

draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Lista de opções ativa
var current_options = (menu_state == "main") ? options_main : options_online;

for (var i = 0; i < array_length(current_options); i++) {
    var item_y = start_y + (i * line_height);
    var btn_w = 200;
    var btn_h = 30;
    
    var is_hover = point_in_rectangle(mx, my, start_x - btn_w / 2, item_y - btn_h / 2, start_x + btn_w / 2, item_y + btn_h / 2);
    
    if (is_hover) {
        draw_set_color(c_yellow);
        
        if (mouse_check_button_pressed(mb_left)) {
            if (menu_state == "main") {
                // Menu Principal
                switch (i) {
                    case 0: // Solo
                        global.game_mode = "solo";
                        room_goto_next();
                        break;
                    case 1: // Coop Local
                        global.game_mode = "coop_local";
                        room_goto_next();
                        break;
                    case 2: // Entra no submódulo Online
                        menu_state = "online";
                        break;
                    case 3: // Sair
                        game_end();
                        break;
                }
            } else {
                // Submenu Online
                switch (i) {
                    case 0: // Criar Sala (Host = Player 1)
                        global.game_mode = "coop_online";
                        global.is_host = true;
                        room_goto_next();
                        break;
                    case 1: // Entrar em Sala (Client = Player 2)
                        var ip_input = get_string("Digite o IP do Host:", "127.0.0.1");
                        if (ip_input != "") {
                            global.target_ip = ip_input;
                            global.game_mode = "coop_online";
                            global.is_host = false;
                            room_goto_next();
                        }
                        break;
                    case 2: // Voltar
                        menu_state = "main";
                        break;
                }
            }
        }
    } else {
        draw_set_color(c_white);
    }
    
    draw_text(start_x, item_y, current_options[i]);
}