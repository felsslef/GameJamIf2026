/// Optional lesson room. Uses the same bins, payloads, machines and dispatch as the campaign.
function tutorial_setup() {
    tutorial_stage = 0;
    tutorial_dash_done = false;
    tutorial_lesson = 0;
    tutorial_dispatch_phase = "none";
    tutorial_dispatch_done = false;
    tutorial_fire_phase = "none";
    tutorial_fire_counter = noone;
    tutorial_lessons = [
        {source: "sorted_paper", sorted: "", result: "bag_paper"},
        {source: "sorted_plastic", sorted: "", result: "bag_plastic"},
        {source: "sorted_glass", sorted: "", result: "bag_glass"},
        {source: "sorted_metal", sorted: "", result: "bag_metal"},
        {source: "raw_waste", sorted: "dirty_plastic", result: "clean_plastic"},
        {source: "raw_waste", sorted: "organic", result: "fertilizer"},
        {source: "raw_waste", sorted: "electronic", result: "robot"}
    ];
    feedback_timer = 0;
    minimum_goal = array_length(tutorial_lessons);
    star_goals = [minimum_goal, minimum_goal, minimum_goal];
    for (var i = 0; i < array_length(stations); i++) {
        var station = stations[i];
        station.tutorial_unlocked = station.station_kind == "intake" || station.station_kind == "handoff";
        station.visible = station.tutorial_unlocked;
        station.queue = [];
    }
    for (var i = 0; i < array_length(bins); i++) bins[i].capacity = 1;
    truck.capacity = 8;
    truck.return_duration = 3;
}

function tutorial_station(_kind, _type = -1) {
    var level = obj_recycling_level;
    for (var i = 0; i < array_length(level.stations); i++) {
        var station = level.stations[i];
        if (station.station_kind == _kind && (_type == -1 || station.trash_type == _type)) return station;
    }
    return noone;
}

function tutorial_supply() {
    var lesson = tutorial_lessons[tutorial_lesson];
    dispenser.queue = [lesson.source];
    if (lesson.sorted != "") material_bag = [lesson.sorted];
}

function tutorial_tick(_dt) {
    feedback_timer = max(0, feedback_timer - _dt);
    // Guided processing disables spawning and decay; active fires keep their deadline.
    processing_tick(_dt, true);
    if (phase_state != "playing") return;
    if (!tutorial_dash_done) return;
    if (tutorial_fire_phase != "none") {
        tutorial_fire_tick(_dt);
        tutorial_reveal_target(tutorial_guidance().target);
        return;
    }
    if (tutorial_stage == 0) {
        var reached = false;
        var source = dispenser;
        with (obj_recycling_player) if (recycling_station_distance(x, y, source) < 64) reached = true;
        if (reached) { tutorial_stage = 1; tutorial_supply(); }
    }
    if (delivered_total > tutorial_lesson) {
        // Loading and sending are separate actions. The first bag teaches both.
        if (tutorial_lesson == 0 && !tutorial_dispatch_done) {
            if (truck.trip_remaining > 0) tutorial_dispatch_phase = "return";
            else if (tutorial_dispatch_phase == "return") {
                tutorial_dispatch_done = true;
                tutorial_dispatch_phase = "none";
            } else tutorial_dispatch_phase = "send";
            if (!tutorial_dispatch_done) {
                tutorial_reveal_target(truck);
                return;
            }
        }
        tutorial_lesson++;
        if (tutorial_lesson >= array_length(tutorial_lessons)) {
            tutorial_fire_begin();
            return;
        }
        tutorial_supply();
    }
    var guide = tutorial_guidance();
    tutorial_reveal_target(guide.target);
}

function tutorial_reveal_target(_target) {
    if (instance_exists(_target) && variable_instance_exists(_target, "station_kind") && !_target.tutorial_unlocked) {
        _target.tutorial_unlocked = true;
        _target.visible = true;
        var revealed_station = _target;
        with (obj_recycling_player) {
            if (recycling_station_distance(x, y, revealed_station) < 15) {
                var origin_x = x, origin_y = y, moved = false;
                for (var radius = 16; radius <= 256 && !moved; radius += 16) {
                    for (var angle = 0; angle < 360 && !moved; angle += 45) {
                        var safe_x = origin_x + lengthdir_x(radius, angle);
                        var safe_y = origin_y + lengthdir_y(radius, angle);
                        if (recycling_position_clear(safe_x, safe_y)) { x = safe_x; y = safe_y; moved = true; }
                    }
                }
            }
        }
    }
}

function tutorial_guidance() {
    var level = obj_recycling_level;
    if (!level.tutorial_dash_done) return {target:noone, text:"Experimente um dash para se deslocar mais rápido.", action:"dash", verb:"dar um dash"};
    if (level.tutorial_fire_phase != "none") return tutorial_fire_guidance();
    if (!level.tutorial_dispatch_done && level.delivered_total > 0) {
        if (level.truck.trip_remaining > 0) return {target:level.truck, text:"Carga enviada! Aguarde o caminhão voltar.", action:"wait", verb:"O caminhão volta sozinho e libera espaço para novas entregas."};
        return {target:level.truck, text:"Com as mãos vazias, interaja com o caminhão para despachar a carga.", action:"interact", verb:"despachar o caminhão"};
    }
    if (level.tutorial_stage == 0) return {target: level.dispenser, text: "Dash aprendido! Agora vá até a caçamba.", action: "move", verb: "andar"};
    var item = noone;
    with (obj_process_item) if (is_held || item == noone) item = id;
    if (item != noone && !item.is_held) {
        return {target: item, text: "Recolha o material do chão.", action: "interact", verb: "pegar"};
    }
    if (item != noone) {
        var state = item.process_state;
        var kind = "", text = "", type = -1;
        switch (state) {
            case "sorted_paper": type = 0; break;
            case "sorted_plastic": type = 1; break;
            case "sorted_glass": type = 2; break;
            case "sorted_metal": type = 3; break;
            case "raw_waste": kind = "sorting"; text = "Leve o saco misturado à mesa de triagem."; break;
            case "dirty_plastic": kind = "washer"; text = "Coloque o plástico sujo na lavadora."; break;
            case "organic": kind = "biodigester"; text = "Coloque o orgânico no biodigestor."; break;
            case "electronic": kind = "dismantler"; text = "Leve o eletrônico à bancada de desmontagem."; break;
            case "metal_plate": kind = "bench"; text = "Leve os componentes à bancada científica para montar o robô."; break;
            default: kind = "dispatch"; text = "Entregue o material pronto ao caminhão."; break;
        }
        if (type >= 0) {
            var colors = ["azul", "vermelha", "verde", "amarela"];
            kind = "bin"; text = recycling_trash_name(type) + " na lixeira " + colors[type] + ".";
            if (global.frontend_colorblind) text = "Leve " + string_lower(recycling_trash_name(type)) + " à lixeira " + ["PAP","PLA","VID","MET"][type] + ", com o mesmo símbolo.";
        }
        var target = tutorial_station(kind, type);
        if (kind == "dispatch" && target.trip_remaining > 0) return {target: target, text: "Aguarde o caminhão voltar.", action: "wait", verb: ""};
        return {target: target, text: text, action: "interact", verb: "colocar"};
    }
    for (var i = 0; i < array_length(level.stations); i++) {
        var station = level.stations[i];
        if (station.station_kind == "bin" && station.load > 0) return {target: station, text: "A lixeira encheu. Retire o saco.", action: "interact", verb: "pegar o saco"};
        if (station.station_kind == "handoff" && !is_undefined(station.stored_item)) return {target: station, text: "Pegue o material que ficou na bancada.", action: "interact", verb: "pegar"};
        if (is_undefined(station.buffer)) continue;
        if (station.process_status == "ready") return {target: station, text: "Pronto! Retire o material.", action: "interact", verb: "pegar"};
        if (station.process_status == "processing") return {target: station, text: "Aguarde: " + string(ceil(station.process_remaining)) + "s.", action: "wait", verb: ""};
        return {target: station, text: station.station_kind == "sorting" ? "Mantenha o botão de pegar pressionado para separar." : "Mantenha o botão de pegar pressionado para desmontar.", action: "interact", verb: "segurar para trabalhar"};
    }
    var state = level.tutorial_lessons[min(level.tutorial_lesson, 6)].source;
    return {target: level.dispenser, text: state == "raw_waste" ? "Agora pegue um saco de lixo misturado." : "Pegue o material da caçamba.", action: "interact", verb: "pegar"};
}

function tutorial_controls_hint(_action, _verb) {
    if (_action == "dash") {
        var keys = "J1: " + frontend_key_short_name(frontend_keybinding("p1_dash"));
        if (global.game_mode == "coop_local") keys += " | J2: " + frontend_key_short_name(frontend_keybinding("p2_dash"));
        return (global.frontend_double_tap_dash ? "Toque duas vezes na mesma direção ou use " : "Segure uma direção e use ") + keys + " para dar um dash";
    }
    if (_action == "observe") return "A exclamação avisa que o material precisa de atenção.";
    if (_action == "wait") return _verb != "" ? _verb : "A máquina trabalha sozinha.";
    if (_action == "move") {
        var movement = frontend_player_movement_hint(1);
        if (global.game_mode == "coop_local") movement += " | " + frontend_player_movement_hint(2);
        return movement;
    }
    var hint = "J1: " + frontend_key_name(frontend_keybinding("p1_" + _action));
    if (global.game_mode == "coop_local") hint += " | J2: " + frontend_key_name(frontend_keybinding("p2_" + _action));
    return hint + " para " + _verb;
}

function tutorial_draw() {
    var level = obj_recycling_level;
    if (level.phase_state != "playing") return;
    var guide = tutorial_guidance();
    var dark = make_color_rgb(35, 57, 64);
    frontend_panel(128, 100, 1024, 42, make_color_rgb(255, 252, 235), dark);
    frontend_text(640, 109, guide.text, fnt_ui_body, dark, fa_center);
    if (instance_exists(guide.target)) {
        var offset = variable_instance_exists(guide.target, "station_kind") ? 84 : 50;
        draw_sprite_ext(spr_ui_arrow, 0, guide.target.x, guide.target.y - offset + sin(current_time / 220) * 4, 1.3, 1.3, 270, make_color_rgb(18, 113, 105), 1);
    }
    frontend_panel(120, 668, 1040, 36, make_color_rgb(255, 252, 235), dark);
    frontend_text(640, 675, tutorial_controls_hint(guide.action, guide.verb), fnt_ui_small, dark, fa_center);

    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_font(-1);
}

function tutorial_draw_hud() {
    var dark = make_color_rgb(35, 57, 64);
    frontend_panel(32, 20, 1216, 70, make_color_rgb(255, 252, 235), dark);
    var step = tutorial_dash_done ? tutorial_lesson + 2 + (tutorial_lesson > 0 || tutorial_dispatch_phase != "none" ? 1 : 0) : 1;
    frontend_text(56, 38, "Tutorial: " + string(min(step, 10)) + " / 10", fnt_ui_body, dark);
    var lesson_result = tutorial_fire_phase != "none" ? "extinguisher" : tutorial_lessons[min(tutorial_lesson, 6)].result;
    var dispatching = tutorial_dispatch_phase != "none";
    var badge = !tutorial_dash_done ? recycling_scientist_sprite(global.frontend_characters[0])
        : (dispatching ? spr_truck : object_get_sprite(processing_material_object(lesson_result)));
    var badge_scale = 42 / max(sprite_get_width(badge), sprite_get_height(badge));
    draw_sprite_ext(badge, 0, 870, 54, badge_scale, badge_scale, 0, c_white, 1);
    frontend_text(1220, 38, !tutorial_dash_done ? "Aprender o dash" : (dispatching ? "Despachar o caminhão" : processing_material_name(lesson_result)), fnt_ui_small, dark, fa_right);
    processing_draw_fire_alert();
    if (phase_state != "playing") {
        recycling_draw_result();
    }
    draw_set_alpha(1); draw_set_color(c_white); draw_set_halign(fa_left); draw_set_font(-1);
}

/// A single supervised fire teaches the real extinguisher without enabling random hazards.
function tutorial_fire_begin() {
    tutorial_fire_phase = "warning";
    tutorial_fire_counter = tutorial_station("handoff");
    tutorial_fire_counter.stored_item = processing_payload_new("electronic");
    tutorial_fire_counter.stored_item.exposure_age = electronic_overheat_time - 2;
    dispenser.queue = [];
}

function tutorial_fire_tick(_dt) {
    var payload = tutorial_fire_counter.stored_item;
    if (tutorial_fire_phase == "warning") {
        payload.exposure_age += _dt;
        if (payload.exposure_age >= electronic_overheat_time) {
            processing_ignite_payload(payload);
            tutorial_fire_phase = "extinguish";
        }
    } else if (tutorial_fire_phase == "extinguish" && !payload.burning) tutorial_fire_phase = "return";
    if (tutorial_fire_phase == "return" && !tutorial_station("extinguisher_rack").tool_loaned) {
        recycling_finish(true, "Você aprendeu a reciclar, despachar o caminhão e controlar incêndios!");
    }
}

function tutorial_fire_guidance() {
    var level = obj_recycling_level;
    var rack = tutorial_station("extinguisher_rack");
    if (level.tutorial_fire_phase == "warning") return {target:level.tutorial_fire_counter,text:"Eletrônico superaquecendo! Se pegar fogo, apague em " + string(level.fire_failure_time) + "s ou a fase acaba.",action:"observe",verb:""};
    if (level.tutorial_fire_phase == "return") return {target:rack,text:"Fogo apagado! Devolva o extintor ao suporte.",action:"interact",verb:"devolver"};
    var tool_held = false;
    with (obj_recycling_player) if (instance_exists(carried_item) && carried_item.process_state == "extinguisher") tool_held = true;
    if (tool_held) return {target:level.tutorial_fire_counter,text:"Aproxime-se do fogo e segure o botão de pegar para apagar.",action:"interact",verb:"segurar para apagar"};
    return {target:rack,text:"Pegou fogo! Busque o extintor no suporte.",action:"interact",verb:"pegar o extintor"};
}
