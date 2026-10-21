/// Menu-only data. Gameplay and networking keep their existing contracts.
function frontend_init() {
    display_set_gui_size(1280, 720);
    if (!variable_global_exists("frontend_mode")) global.frontend_mode = "solo";
    if (!variable_global_exists("game_mode")) global.game_mode = "solo";
    if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
    if (!variable_global_exists("frontend_level")) global.frontend_level = 0;
    if (!variable_global_exists("frontend_network_entry")) global.frontend_network_entry = false;
    if (!variable_global_exists("frontend_reduced_motion")) global.frontend_reduced_motion = false;
    frontend_keybindings_init();
    // Presentation state only. The gameplay result system will populate this later.
    if (!variable_global_exists("frontend_level_completed")) global.frontend_level_completed = array_create(5, false);
    save_slots_init();
    ink = make_color_rgb(36, 41, 40);
    muted = make_color_rgb(110, 118, 114);
    paper = c_white;
    teal = make_color_rgb(18, 113, 105);
    mint = make_color_rgb(182, 220, 178);
    gold = make_color_rgb(242, 183, 78);
    coral = make_color_rgb(212, 106, 85);
    font_small = fnt_ui_small;
    font_body = fnt_ui_body;
    font_title = fnt_ui_title;
    scientists = [
        {name: "Ju", role: "ENGENHARIA AMBIENTAL", color: teal,
         bio: "Ju transforma resíduos em novas possibilidades. Ela pesquisa soluções para cuidar da água e ajuda a cidade a proteger seus rios e praias."},
        {name: "Lê", role: "ROBÓTICA", color: coral,
         bio: "Lê cria robôs para dar uma mão à equipe. Com criatividade e ciência, transforma peças recuperadas em invenções que ajudam a limpar a cidade."},
        {name: "Manu", role: "BIOLOGIA MARINHA", color: make_color_rgb(68, 125, 168),
         bio: "Manu estuda a vida no mar e os efeitos do lixo no litoral. Ela compartilha descobertas para que mais pessoas cuidem da nossa biodiversidade."},
        {name: "Maria", role: "CIÊNCIA DA COMPUTAÇÃO", color: make_color_rgb(129, 102, 161),
         bio: "Maria programa soluções para desafios da cidade. Ela conecta as ideias da equipe e desenvolve a inteligência das novas robôs de reciclagem."}
    ];
    levels = [
        {name: "Primeiros passos", place: "Porto Novo", tag: "01 / TUTORIAL", difficulty: "Tranquila", goal: "Faça a triagem e atenda os primeiros pedidos.", targets: [3, 5, 7], scene: 0},
        {name: "Ideias em construção", place: "Indaiá", tag: "02 / TRATAMENTO", difficulty: "Leve", goal: "Organize limpeza, biodigestão e desmontagem.", targets: [4, 6, 8], scene: 1},
        {name: "De mão em mão", place: "Centro", tag: "03 / COOPERAÇÃO", difficulty: "Moderada", goal: "Passe materiais entre as bancadas dos dois lados.", targets: [5, 7, 9], scene: 2},
        {name: "Mutirão no bairro", place: "Martim de Sá", tag: "04 / ORGANIZAÇÃO", difficulty: "Desafiadora", goal: "Coordene as máquinas e evite desperdícios.", targets: [6, 8, 10], scene: 3},
        {name: "Uma nova maré", place: "Massaguaçu", tag: "05 / GRANDE DESAFIO", difficulty: "Intensa", goal: "Domine o processamento e controle os incidentes.", targets: [7, 9, 12], scene: 4}
    ];
    level_nodes = [{x: 200, y: 400}, {x: 385, y: 265}, {x: 640, y: 194}, {x: 897, y: 250}, {x: 1100, y: 150}];
    screen = "main";
    if (room == rm_game_mode) screen = "mode";
    if (room == rm_save_select) screen = "saves";
    if (room == rm_character_select) screen = "characters";
    if (room == rm_level_select) screen = "levels";
    if (room == rm_options) screen = "options";
    focus = 0;
    selected_level = global.frontend_level;
    pointer_x = device_mouse_x_to_gui(0);
    pointer_y = device_mouse_y_to_gui(0);
    elapsed = 0;
    notice = "";
    notice_timer = 0;
    pending_reset = -1;
    if (!variable_global_exists("frontend_rebinding")) global.frontend_rebinding = "";
    buttons = [];
    if (screen == "characters") frontend_character_init();
    frontend_build_buttons();
    if (screen == "levels") focus = selected_level;
}

function frontend_keybinding_names() {
    return ["p1_up", "p1_down", "p1_left", "p1_right", "p1_interact", "p1_action", "p1_dash",
        "p2_up", "p2_down", "p2_left", "p2_right", "p2_interact", "p2_action", "p2_dash", "pause"];
}

function frontend_keybindings_defaults() {
    return {
        p1_up: ord("W"), p1_down: ord("S"), p1_left: ord("A"), p1_right: ord("D"),
        p1_interact: vk_lshift, p1_action: vk_lcontrol, p1_dash: vk_lalt,
        p2_up: vk_up, p2_down: vk_down, p2_left: vk_left, p2_right: vk_right,
        p2_interact: vk_rshift, p2_action: vk_rcontrol, p2_dash: vk_ralt,
        pause: vk_escape
    };
}

function frontend_keybindings_init() {
    if (variable_global_exists("frontend_keybindings_ready") && global.frontend_keybindings_ready) return;
    global.frontend_keybindings = frontend_keybindings_defaults();
    if (file_exists("controls.ini")) {
        ini_open("controls.ini");
        var names = frontend_keybinding_names();
        for (var i = 0; i < array_length(names); i++) {
            var name = names[i];
            var default_key = variable_struct_get(global.frontend_keybindings, name);
            variable_struct_set(global.frontend_keybindings, name, ini_read_real("keys", name, default_key));
        }
        ini_close();
    }
    global.frontend_keybindings_ready = true;
}

function frontend_keybinding(_name) {
    frontend_keybindings_init();
    return variable_struct_get(global.frontend_keybindings, _name);
}

function frontend_keybinding_save() {
    ini_open("controls.ini");
    var names = frontend_keybinding_names();
    for (var i = 0; i < array_length(names); i++) {
        var name = names[i];
        ini_write_real("keys", name, variable_struct_get(global.frontend_keybindings, name));
    }
    ini_close();
}

function frontend_keybinding_set(_name, _key) {
    var names = frontend_keybinding_names();
    for (var i = 0; i < array_length(names); i++) {
        var other_name = names[i];
        if (other_name != _name && variable_struct_get(global.frontend_keybindings, other_name) == _key) return false;
    }
    variable_struct_set(global.frontend_keybindings, _name, _key);
    frontend_keybinding_save();
    return true;
}

function frontend_key_name(_key) {
    switch (_key) {
        case vk_up: return "Seta cima";
        case vk_down: return "Seta baixo";
        case vk_left: return "Seta esquerda";
        case vk_right: return "Seta direita";
        case vk_lshift: return "Shift esquerdo";
        case vk_rshift: return "Shift direito";
        case vk_lcontrol: return "Ctrl esquerdo";
        case vk_rcontrol: return "Ctrl direito";
        case vk_lalt: return "Alt esquerdo";
        case vk_ralt: return "Alt Gr";
        case vk_space: return "Espaço";
        case vk_tab: return "Tab";
        case vk_enter: return "Enter";
        case vk_escape: return "Esc";
        case vk_backspace: return "Backspace";
    }
    if (_key >= 112 && _key <= 123) return "F" + string(_key - 111);
    if (_key >= 32 && _key <= 126) return string_upper(chr(_key));
    return "Tecla " + string(_key);
}

function frontend_button(_x, _y, _w, _h, _label, _action, _value = 0) {
    array_push(buttons, {x: _x, y: _y, w: _w, h: _h, label: _label, action: _action, value: _value});
}

function frontend_build_buttons() {
    buttons = [];
    switch (screen) {
        case "main":
            frontend_button(460, 246, 360, 64, "Jogar", "play");
            frontend_button(460, 334, 360, 64, "Opções", "options");
            frontend_button(460, 422, 360, 64, "Sair", "quit");
            break;
        case "mode":
            var labels = ["Solo", "Co-op Local", "Co-op Rede"];
            for (var i = 0; i < 3; i++) frontend_button(460, 246 + i * 88, 360, 64, labels[i], "mode", i);
            frontend_button(540, 572, 200, 48, "Voltar", "back");
            break;
        case "saves":
            save_slots_buttons();
            break;
        case "characters":
            frontend_character_build_buttons();
            break;
        case "levels":
            for (var i = 0; i < 5; i++) frontend_button(level_nodes[i].x - 34, level_nodes[i].y - 34, 68, 68, string(i + 1), "level", i);
            frontend_button(64, 624, 184, 48, "Voltar", "back");
            frontend_button(1032, 624, 184, 48, "Jogar", "start");
            break;
        case "options":
            frontend_button(420, 246, 440, 64, global.frontend_reduced_motion ? "Animações: não" : "Animações: sim", "motion");
            frontend_button(420, 334, 440, 64, "Configurar teclas", "controls");
            frontend_button(540, 572, 200, 48, "Voltar", "back");
            break;
        case "controls":
            var commands = ["up", "down", "left", "right", "interact", "action", "dash"];
            var labels = ["Mover para cima", "Mover para baixo", "Mover para esquerda", "Mover para direita",
                "Pegar / colocar", "Cortar / arremessar", "Dash"];
            for (var i = 0; i < array_length(commands); i++) {
                var p1_name = "p1_" + commands[i];
                var p2_name = "p2_" + commands[i];
                var p1_label = global.frontend_rebinding == p1_name ? "Pressione uma tecla..." : labels[i] + " — " + frontend_key_name(frontend_keybinding(p1_name));
                var p2_label = global.frontend_rebinding == p2_name ? "Pressione uma tecla..." : labels[i] + " — " + frontend_key_name(frontend_keybinding(p2_name));
                frontend_button(56, 166 + i * 48, 560, 42, p1_label, "bind_key", p1_name);
                frontend_button(664, 166 + i * 48, 560, 42, p2_label, "bind_key", p2_name);
            }
            frontend_button(430, 526, 420, 38, "Pausar — " + frontend_key_name(frontend_keybinding("pause")), "bind_key", "pause");
            frontend_button(430, 572, 420, 38, "Restaurar teclas padrão", "reset_keys");
            frontend_button(540, 620, 200, 38, "Voltar", "back");
            break;
    }
}

function frontend_mode_name() {
    switch (global.frontend_mode) {
        case "coop_local": return "Co-op Local";
        case "coop_online": return "Co-op Rede";
        default: return "Solo";
    }
}
