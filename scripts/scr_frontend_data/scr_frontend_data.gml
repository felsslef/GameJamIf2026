/// Menu-only data. Gameplay and networking keep their existing contracts.
function frontend_init() {
    display_set_gui_size(1280, 720);
    if (!variable_global_exists("frontend_mode")) global.frontend_mode = "solo";
    if (!variable_global_exists("game_mode")) global.game_mode = "solo";
    if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
    if (!variable_global_exists("frontend_level")) global.frontend_level = 0;
    if (!variable_global_exists("frontend_network_entry")) global.frontend_network_entry = false;
    if (!variable_global_exists("frontend_reduced_motion")) global.frontend_reduced_motion = false;
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
        {name: "Primeiros passos", place: "Porto Novo", tag: "01 / TUTORIAL", difficulty: "Tranquila", goal: "Aprenda a recolher, separar e encaminhar os resíduos.", targets: [12, 21, 30], scene: 0},
        {name: "Ideias em construção", place: "Indaiá", tag: "02 / ROBÓTICA", difficulty: "Leve", goal: "Recupere peças e descubra como construir robôs ajudantes.", targets: [12, 21, 30], scene: 1},
        {name: "De mão em mão", place: "Centro", tag: "03 / COOPERAÇÃO", difficulty: "Moderada", goal: "Passe os materiais entre bancadas. No solo, uma robô ajudará na travessia.", targets: [12, 21, 30], scene: 2},
        {name: "Mutirão no bairro", place: "Martim de Sá", tag: "04 / ORGANIZAÇÃO", difficulty: "Desafiadora", goal: "Planeje o descarte e as viagens do caminhão para manter o fluxo.", targets: [16, 24, 32], scene: 3},
        {name: "Uma nova maré", place: "Massaguaçu", tag: "05 / GRANDE DESAFIO", difficulty: "Intensa", goal: "Una a equipe e suas invenções no último grande mutirão.", targets: [20, 28, 36], scene: 4}
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
    buttons = [];
    if (screen == "characters") frontend_character_init();
    frontend_build_buttons();
    if (screen == "levels") focus = selected_level;
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
            frontend_button(540, 572, 200, 48, "Voltar", "back");
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
