function save_slots_init() {
    if (!variable_global_exists("frontend_difficulty")) global.frontend_difficulty = "easy";
    if (!variable_global_exists("frontend_tutorial_completed")) global.frontend_tutorial_completed = false;
    if (!variable_global_exists("frontend_save_slot")) global.frontend_save_slot = -1;
    if (!variable_global_exists("frontend_level_stars")) global.frontend_level_stars = array_create(5, 0);
}

function save_difficulty_valid(_difficulty) {
    return _difficulty == "easy" || _difficulty == "medium" || _difficulty == "hard";
}

function save_difficulty_name(_difficulty) {
    switch (_difficulty) {
        case "medium": return "Médio";
        case "hard": return "Difícil";
        default: return "Fácil";
    }
}

function save_active_difficulty() {
    save_slots_init();
    if (online_game() && !global.is_host && variable_global_exists("frontend_network_difficulty")) return global.frontend_network_difficulty;
    return global.frontend_difficulty;
}

function save_difficulty_target(_goal, _difficulty) {
    var multiplier = _difficulty == "hard" ? 2 : (_difficulty == "medium" ? 1.5 : 1);
    return ceil(_goal * multiplier);
}

function save_slot_difficulty(_slot) {
    if (!save_slot_exists(_slot)) return "easy";
    ini_open(save_slot_filename(_slot));
    var difficulty = ini_read_string("save", "difficulty", "easy");
    ini_close();
    return save_difficulty_valid(difficulty) ? difficulty : "easy";
}

function frontend_begin_save_creation(_slot) {
    if (_slot < 0 || _slot >= 3 || save_slot_exists(_slot)) return;
    pending_new_slot = _slot;
    focus = 0;
    session_ui_change_screen("difficulty");
}

function save_slot_filename(_slot) {
    return "progress_" + string(_slot + 1) + ".ini";
}

function save_slot_exists(_slot) {
    return _slot >= 0 && _slot < 3 && file_exists(save_slot_filename(_slot));
}

function save_slot_write() {
    save_slots_init();
    var slot = global.frontend_save_slot;
    if (slot < 0 || slot >= 3) return false;
    try {
        // Existing saves own their difficulty; autosaves cannot change it.
        if (save_slot_exists(slot)) global.frontend_difficulty = save_slot_difficulty(slot);
        ini_open(save_slot_filename(slot));
        ini_write_real("save", "version", 3);
        ini_write_string("save", "difficulty", global.frontend_difficulty);
        ini_write_real("save", "tutorial_completed", global.frontend_tutorial_completed ? 1 : 0);
        for (var i = 0; i < 5; i++) {
            ini_write_real("completed", string(i), global.frontend_level_completed[i] ? 1 : 0);
            ini_write_real("stars", string(i), global.frontend_level_stars[i]);
        }
        ini_write_real("save", "level", global.frontend_level);
        ini_close();
        return true;
    } catch (error) {
        show_debug_message("Save write failed: " + string(error));
        return false;
    }
}

function save_slot_load(_slot) {
    save_slots_init();
    if (_slot < 0 || _slot >= 3) return false;
    if (!save_slot_exists(_slot)) return false;
    try {
        ini_open(save_slot_filename(_slot));
        var completed = array_create(5, false);
        var stars = array_create(5, 0);
        for (var i = 0; i < 5; i++) {
            completed[i] = ini_read_real("completed", string(i), 0) == 1;
            stars[i] = completed[i] ? clamp(floor(ini_read_real("stars", string(i), 0)), 0, 3) : 0;
        }
        var selected = clamp(floor(ini_read_real("save", "level", -1)), -1, 4);
        var tutorial_completed = ini_read_real("save", "tutorial_completed", 0) == 1;
        ini_close();
        global.frontend_save_slot = _slot;
        global.frontend_difficulty = save_slot_difficulty(_slot);
        global.frontend_level_completed = completed;
        global.frontend_level_stars = stars;
        global.frontend_tutorial_completed = tutorial_completed;
        global.frontend_level = selected;
        global.frontend_test_unlock = false;
        return true;
    } catch (error) {
        show_debug_message("Save load failed: " + string(error));
        return false;
    }
}

function save_slot_new(_slot, _difficulty) {
    if (_slot < 0 || _slot >= 3 || save_slot_exists(_slot) || !save_difficulty_valid(_difficulty)) return false;
    global.frontend_save_slot = _slot;
    global.frontend_difficulty = _difficulty;
    global.frontend_level_completed = array_create(5, false);
    global.frontend_level_stars = array_create(5, 0);
    global.frontend_level = -1;
    global.frontend_tutorial_completed = false;
    global.frontend_test_unlock = false;
    return save_slot_write();
}

function save_slot_summary(_slot) {
    if (!save_slot_exists(_slot)) return "Vazio";
    ini_open(save_slot_filename(_slot));
    var count = 0;
    var stars = 0;
    for (var i = 0; i < 5; i++) {
        if (ini_read_real("completed", string(i), 0) == 1) {
            count++;
            stars += clamp(floor(ini_read_real("stars", string(i), 0)), 0, 3);
        }
    }
    ini_close();
    return string(count) + "/5 fases | " + string(stars) + " estrelas";
}

function save_slot_delete(_slot) {
    if (_slot < 0 || _slot >= 3) return false;
    try {
        var filename = save_slot_filename(_slot);
        if (file_exists(filename)) file_delete(filename);
        if (file_exists(filename)) return false;
        // Detach the deleted slot so later autosaves cannot recreate it.
        if (global.frontend_save_slot == _slot) global.frontend_save_slot = -1;
        return true;
    } catch (error) {
        show_debug_message("Save delete failed: " + string(error));
        return false;
    }
}

function save_slots_buttons() {
    for (var i = 0; i < 3; i++) {
        var occupied = save_slot_exists(i);
        var label = occupied ? "Continuar" : "Começar";
        frontend_button(184 + i * 312, 220, 288, 272, label, "save_load", i);
        buttons[array_length(buttons)-1].occupied = occupied;
        buttons[array_length(buttons)-1].summary = save_slot_summary(i);
        buttons[array_length(buttons)-1].difficulty = save_slot_difficulty(i);
        frontend_button(208 + i * 312, 512, 240, 48,
            pending_reset == i ? "Confirmar" : (occupied ? "Excluir" : "Criar"), "save_new", i);
    }
    if (global.frontend_save_slot >= 0) frontend_button(650, 630, 280, 48, "Salvar progresso", "save_write");
    frontend_button(global.frontend_save_slot >= 0 ? 380 : 530, 630, 220, 48, "Voltar", "back");
}
