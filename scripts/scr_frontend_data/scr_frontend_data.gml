/// Menu-only data. Gameplay and networking keep their existing contracts.
function frontend_init() {
    display_set_gui_size(1280, 720);
    if (!variable_global_exists("frontend_mode")) global.frontend_mode = "solo";
    if (!variable_global_exists("game_mode")) global.game_mode = "solo";
    if (!variable_global_exists("frontend_characters")) global.frontend_characters = [0, 1];
    if (!variable_global_exists("frontend_level")) global.frontend_level = -1;
    if (!variable_global_exists("frontend_network_entry")) global.frontend_network_entry = false;
    if (!variable_global_exists("frontend_reduced_motion")) global.frontend_reduced_motion = false;
    frontend_double_tap_dash_init();
    frontend_keybindings_init();
    frontend_accessibility_init();
    frontend_audio_init();
    settings_in_pause = false;
    audio_drag_channel = "";
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
        {name: "Juliana Gregio", role: "EDUCAÇÃO E TECNOLOGIA", color: teal,
         bio: "Professora do IFSP Caraguatatuba e coordenadora de ADS. Une educação e tecnologia, incentiva projetos e aproxima estudantes dos desafios reais da sociedade."},
        {name: "Leticia Pacheco", role: "DESENHISTA MESTRE", color: coral,
         bio: "Leticia é uma desenhista mestre. Faz desenhos como ninguém, que se tornam tatuagens incríveis. Na equipe de Coleta Maluca, ela é a nossa Lê!"},
        {name: "Manuela Otavio", role: "DESENVOLVIMENTO FULLSTACK", color: make_color_rgb(68, 125, 168),
         bio: "Desenvolvedora fullstack e bicampeã do Hackathon do IFSP Caraguatatuba. Técnica em Informática para Internet e estudante de ADS, transforma desafios em soluções com criatividade e trabalho em equipe."},
        {name: "Maria Klara", role: "CIENTISTA · LABTECH", color: make_color_rgb(129, 102, 161),
         bio: "Cientista de Portugal e dona do Labtech. Em Coleta Maluca, Maria Klara faz parte do nosso time de cientistas, criando diversas coisas em impressão 3D!"}
    ];
    levels = [
        {name: "Primeiro mutirão", place: "Porto Novo", tag: "01 / RECICLAGEM", difficulty: "Leve", goal: "Separe recicláveis, lave plástico e trate orgânicos.", targets: [3, 5, 7], scene: 0},
        {name: "Ideias em construção", place: "Indaiá", tag: "02 / TRATAMENTO", difficulty: "Leve", goal: "Organize limpeza, biodigestão e desmontagem.", targets: [4, 6, 8], scene: 1},
        {name: "De mão em mão", place: "Centro", tag: "03 / COOPERAÇÃO", difficulty: "Moderada", goal: "Passe materiais entre as bancadas dos dois lados.", targets: [5, 7, 9], scene: 2},
        {name: "Mutirão no bairro", place: "Martim de Sá", tag: "04 / ORGANIZAÇÃO", difficulty: "Desafiadora", goal: "Coordene as máquinas e evite desperdícios.", targets: [6, 8, 10], scene: 3},
        {name: "Uma nova maré", place: "Massaguaçu", tag: "05 / GRANDE DESAFIO", difficulty: "Intensa", goal: "Domine o processamento e controle os incidentes.", targets: [7, 9, 12], scene: 4}
    ];
    level_nodes = [{x: 200, y: 400}, {x: 385, y: 265}, {x: 640, y: 194}, {x: 897, y: 250}, {x: 1100, y: 150}];
    tutorial_node = {x: 88, y: 520};
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
    pending_new_slot = -1;
    if (!variable_global_exists("frontend_rebinding")) global.frontend_rebinding = "";
    buttons = [];
    if (screen == "characters") frontend_character_init();
    frontend_build_buttons();
    if (screen == "levels") focus = selected_level + 1;
}

function frontend_accessibility_init() {
    if (variable_global_exists("frontend_accessibility_ready") && global.frontend_accessibility_ready) return;
    global.frontend_colorblind = false;
    if (file_exists("controls.ini")) {
        ini_open("controls.ini");
        global.frontend_colorblind = ini_read_real("accessibility", "colorblind", 0) != 0;
        ini_close();
    }
    global.frontend_accessibility_ready = true;
}

function frontend_accessibility_save() {
    ini_open("controls.ini");
    ini_write_real("accessibility", "colorblind", global.frontend_colorblind ? 1 : 0);
    ini_close();
}

function frontend_keybinding_names() {
    return ["p1_up", "p1_down", "p1_left", "p1_right", "p1_interact", "p1_action", "p1_dash",
        "p2_up", "p2_down", "p2_left", "p2_right", "p2_interact", "p2_action", "p2_dash", "pause"];
}

function frontend_audio_init() {
    if (variable_global_exists("frontend_audio_ready") && global.frontend_audio_ready) return;
    if (!variable_global_exists("frontend_audio_effects")) {
        global.frontend_audio_effects = [
            {sound: snd_dialogue_blip, gain: audio_sound_get_gain(snd_dialogue_blip)},
            {sound: snd_delivery_success, gain: audio_sound_get_gain(snd_delivery_success)}
        ];
    }
    global.frontend_audio = {master: 1, music: 1, effects: 1};
    if (file_exists("audio.ini")) {
        ini_open("audio.ini");
        var channels = ["master", "music", "effects"];
        for (var i = 0; i < array_length(channels); i++) {
            var channel = channels[i];
            variable_struct_set(global.frontend_audio, channel, clamp(ini_read_real("volume", channel, 1), 0, 1));
        }
        ini_close();
    }
    global.frontend_audio_ready = true;
    frontend_audio_apply();
}

function frontend_audio_apply() {
    audio_master_gain(global.frontend_audio.master);
    for (var i = 0; i < array_length(global.frontend_audio_effects); i++) {
        var effect = global.frontend_audio_effects[i];
        audio_sound_gain(effect.sound, effect.gain * global.frontend_audio.effects, 0);
    }
    // Apply a music change immediately, including while the game is paused.
    with (obj_session_ui) {
        for (var i = 0; i < array_length(music_voices); i++) {
            var entry = music_voices[i];
            audio_sound_gain(entry.handle, entry.gain * global.frontend_audio.music, 0);
        }
    }
}

function frontend_audio_set(_channel, _value, _save = true) {
    variable_struct_set(global.frontend_audio, _channel, round(clamp(_value, 0, 1) * 100) / 100);
    frontend_audio_apply();
    if (_save) frontend_audio_save();
}

function frontend_audio_save() {
    ini_open("audio.ini");
    var channels = ["master", "music", "effects"];
    for (var i = 0; i < array_length(channels); i++) {
        ini_write_real("volume", channels[i], variable_struct_get(global.frontend_audio, channels[i]));
    }
    ini_close();
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

function frontend_double_tap_dash_init() {
    if (variable_global_exists("frontend_double_tap_dash_ready") && global.frontend_double_tap_dash_ready) return;
    global.frontend_double_tap_dash = true;
    if (file_exists("controls.ini")) {
        ini_open("controls.ini");
        global.frontend_double_tap_dash = ini_read_real("gameplay", "double_tap_dash", 1) != 0;
        ini_close();
    }
    global.frontend_double_tap_dash_ready = true;
}

function frontend_double_tap_dash_save() {
    ini_open("controls.ini");
    ini_write_real("gameplay", "double_tap_dash", global.frontend_double_tap_dash ? 1 : 0);
    ini_close();
}

function frontend_online_selection_start(_is_host) {
    global.frontend_network_difficulty = "easy";
    var characters = global.frontend_characters;
    var p1 = clamp(characters[0], 0, 3);
    var p2 = clamp(characters[1], 0, 3);
    if (p1 == p2) p2 = (p1 + 1) mod 4;
    global.online_selection = {
        p1_choice: p1, p1_ready: false, p1_back: false,
        p2_choice: p2, p2_ready: false, p2_back: false, p2_active: false,
        screen: "characters", level: -1, seed: _is_host ? irandom(2000000000) : 0
    };
    global.online_connected = false;
    global.online_connection_lost = false;
    global.online_input = [array_create(7,false),array_create(7,false),array_create(7,false)];
    global.client_socket = noone;
}

function frontend_online_send_p2_selection() {
    if (global.is_host || !global.online_connected || !variable_global_exists("client_socket")
        || global.client_socket == noone || global.client_socket < 0) return;
    var packet = buffer_create(16, buffer_fixed, 1);
    buffer_write(packet, buffer_u8, 10);
    buffer_write(packet, buffer_u8, global.online_selection.p2_choice);
    buffer_write(packet, buffer_bool, global.online_selection.p2_ready);
    buffer_write(packet, buffer_bool, global.online_selection.p2_back);
    network_send_packet(global.client_socket, packet, buffer_tell(packet));
    buffer_delete(packet);
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
        case vk_numpad0: return "Num 0";
        case vk_numpad1: return "Num 1";
        case vk_numpad2: return "Num 2";
        case vk_numpad3: return "Num 3";
        case vk_numpad4: return "Num 4";
        case vk_numpad5: return "Num 5";
        case vk_numpad6: return "Num 6";
        case vk_numpad7: return "Num 7";
        case vk_numpad8: return "Num 8";
        case vk_numpad9: return "Num 9";
    }
    if (_key >= 112 && _key <= 123) return "F" + string(_key - 111);
    if (_key >= 32 && _key <= 126) return string_upper(chr(_key));
    return "Tecla " + string(_key);
}

function frontend_key_short_name(_key) {
    switch (_key) {
        case vk_up: return "Cima";
        case vk_down: return "Baixo";
        case vk_left: return "Esq.";
        case vk_right: return "Dir.";
        case vk_lshift: return "L-Shift";
        case vk_rshift: return "R-Shift";
        case vk_lcontrol: return "L-Ctrl";
        case vk_rcontrol: return "R-Ctrl";
        case vk_lalt: return "L-Alt";
        case vk_ralt: return "Alt Gr";
        case vk_space: return "Espaço";
        case vk_tab: return "Tab";
        case vk_enter: return "Enter";
        case vk_escape: return "Esc";
        case vk_backspace: return "Backspace";
        case vk_numpad0: return "Num0";
        case vk_numpad1: return "Num1";
        case vk_numpad2: return "Num2";
        case vk_numpad3: return "Num3";
        case vk_numpad4: return "Num4";
        case vk_numpad5: return "Num5";
        case vk_numpad6: return "Num6";
        case vk_numpad7: return "Num7";
        case vk_numpad8: return "Num8";
        case vk_numpad9: return "Num9";
    }
    if (_key >= 112 && _key <= 123) return "F" + string(_key - 111);
    if (_key >= 32 && _key <= 126) return string_upper(chr(_key));
    return frontend_key_name(_key);
}

function frontend_player_movement_hint(_player_id) {
    var prefix = _player_id == 2 ? "p2_" : "p1_";
    return "Mover cima/baixo/esq./dir.: " +
        frontend_key_short_name(frontend_keybinding(prefix + "up")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "down")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "left")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "right"));
}

function frontend_player_controls_hint(_player_id) {
    var prefix = _player_id == 2 ? "p2_" : "p1_";
    var player_label = "J" + string(_player_id);
    var movement = frontend_key_short_name(frontend_keybinding(prefix + "up")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "down")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "left")) + "/" +
        frontend_key_short_name(frontend_keybinding(prefix + "right"));
    return player_label + " mover (cima/baixo/esq./dir.) " + movement +
        " | pegar " + frontend_key_short_name(frontend_keybinding(prefix + "interact")) +
        " | arremesso " + frontend_key_short_name(frontend_keybinding(prefix + "action")) +
        " | dash " + frontend_key_short_name(frontend_keybinding(prefix + "dash"));
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
            for (var i = 0; i < 3; i++) frontend_button(184 + i * 312, 238, 288, 288, labels[i], "mode", i);
            frontend_button(520, 630, 240, 48, "Voltar", "back");
            break;
        case "saves":
            save_slots_buttons();
            break;
        case "difficulty":
            if (pending_new_slot < 0) { screen = "saves"; save_slots_buttons(); break; }
            var ids = ["easy", "medium", "hard"];
            for (var i = 0; i < 3; i++) frontend_button(172+i*320, 230, 296, 310, save_difficulty_name(ids[i]), "choose_difficulty", ids[i]);
            frontend_button(530, 632, 220, 48, "Voltar", "back");
            break;
        case "characters":
            frontend_character_build_buttons();
            break;
        case "levels":
            frontend_button(tutorial_node.x - 34, tutorial_node.y - 34, 68, 68, "T", "level", -1);
            for (var i = 0; i < 5; i++) frontend_button(level_nodes[i].x - 34, level_nodes[i].y - 34, 68, 68, string(i + 1), "level", i);
            frontend_button(64, 624, 184, 48, "Voltar", "back");
            frontend_button(1032, 624, 184, 48, "Jogar", "start");
            break;
        case "options":
            var channels = ["master", "music", "effects"];
            for (var i = 0; i < 3; i++) {
                var by = 206 + i * 88;
                frontend_button(416, by, 44, 40, "-", "volume_down", channels[i]);
                frontend_button(476, by, 328, 40, "", "volume", channels[i]);
                frontend_button(820, by, 44, 40, "+", "volume_up", channels[i]);
            }
            frontend_button(420, 466, 440, 40, global.frontend_reduced_motion ? "Animações: não" : "Animações: sim", "motion");
            frontend_button(420, 514, 440, 40, "Daltonismo: " + (global.frontend_colorblind ? "sim" : "não"), "colorblind");
            frontend_button(420, 562, 440, 40, "Configurar teclas", "controls");
            frontend_button(540, 652, 200, 36, "Voltar", "back");
            break;
        case "controls":
            var commands = ["up", "down", "left", "right", "interact", "action", "dash"];
            var labels = ["Mover para cima", "Mover para baixo", "Mover para esquerda", "Mover para direita",
                "Pegar / colocar / trabalhar", "Arremessar", "Dash (atalho)"];
            for (var i = 0; i < array_length(commands); i++) {
                var p1_name = "p1_" + commands[i];
                var p2_name = "p2_" + commands[i];
                var p1_label = global.frontend_rebinding == p1_name ? "Pressione uma tecla..." : labels[i] + " — " + frontend_key_name(frontend_keybinding(p1_name));
                var p2_label = global.frontend_rebinding == p2_name ? "Pressione uma tecla..." : labels[i] + " — " + frontend_key_name(frontend_keybinding(p2_name));
                frontend_button(56, 166 + i * 48, 560, 42, p1_label, "bind_key", p1_name);
                frontend_button(664, 166 + i * 48, 560, 42, p2_label, "bind_key", p2_name);
            }
            frontend_button(430, 502, 420, 34, "Pausar — " + frontend_key_name(frontend_keybinding("pause")), "bind_key", "pause");
            frontend_button(430, 540, 420, 34, global.frontend_double_tap_dash ? "Dash por clique duplo: sim" : "Dash por clique duplo: não", "double_tap_dash");
            frontend_button(430, 580, 420, 34, "Restaurar teclas padrão", "reset_keys");
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
