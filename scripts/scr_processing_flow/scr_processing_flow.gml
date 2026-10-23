/// Complete processing loop. English state names are persisted only inside the current round.
function processing_level_init() {
    has_construction = false;
    processing_frame = 0;
    points_total = 0;
    delivered_total = 0;
    robot_departures = [];
    material_bag = [];
    processing_build_recipe_pools();
    for (var i = 0; i < array_length(dispensers); i++) {
        var source = dispensers[i];
        source.queue = [];
        repeat (min(2, source.capacity)) array_push(source.queue, processing_next_source(source));
    }
    feedback = "Entregue sacos separados e materiais tratados antes do tempo acabar.";
    feedback_timer = 6;
}

function processing_material_object(_state) {
    switch (_state) {
        case "sorted_paper": return obj_material_sorted_paper;
        case "sorted_plastic": return obj_material_sorted_plastic;
        case "sorted_glass": return obj_material_sorted_glass;
        case "sorted_metal": return obj_material_sorted_metal;
        case "bag_paper": return obj_material_bag_paper;
        case "bag_plastic": return obj_material_bag_plastic;
        case "bag_glass": return obj_material_bag_glass;
        case "bag_metal": return obj_material_bag_metal;
        case "raw_waste": return obj_material_raw_waste;
        case "dirty_plastic": return obj_material_dirty_plastic;
        case "organic": return obj_material_organic;
        case "electronic": return obj_material_electronic;
        case "clean_plastic": return obj_material_clean_plastic;
        case "fertilizer": return obj_material_fertilizer;
        case "metal_plate": return obj_material_metal_plate;
        case "robot": return obj_material_robot;
        case "plastic_bale": return obj_material_plastic_bale;
        case "metal_bale": return obj_material_metal_bale;
        case "burned_electronic": return obj_material_burned_electronic;
        case "extinguisher": return obj_material_extinguisher;
    }
    return obj_material_raw_waste;
}

function processing_material_name(_state) {
    switch (_state) {
        case "sorted_paper": return "Papel";
        case "sorted_plastic": return "Plástico reciclável";
        case "sorted_glass": return "Vidro";
        case "sorted_metal": return "Metal reciclável";
        case "bag_paper": return "Saco de papel";
        case "bag_plastic": return "Saco de plástico";
        case "bag_glass": return "Saco de vidro";
        case "bag_metal": return "Saco de metal";
        case "raw_waste": return "Lixo bruto";
        case "dirty_plastic": return "Plástico sujo";
        case "organic": return "Orgânico";
        case "electronic": return "Eletrônico";
        case "clean_plastic": return "Plástico limpo";
        case "fertilizer": return "Biogás / adubo";
        case "metal_plate": return "Componentes recuperados";
        case "robot": return "Robô de limpeza";
        case "plastic_bale": return "Fardo de plástico";
        case "metal_bale": return "Fardo de metal";
        case "burned_electronic": return "Eletrônico queimado";
        case "extinguisher": return "Extintor";
    }
    return "Material";
}

function processing_payload_new(_state, _amount = 1) {
    return {process_state: _state, amount: _amount, exposure_age: 0, burning: false,
        fire_progress: 0, fire_work_frame: -1, tool_owner: noone, spray_active: false};
}

function processing_payload_from_item(_item) {
    return {process_state: _item.process_state, amount: _item.amount, exposure_age: _item.exposure_age,
        burning: _item.burning, fire_progress: _item.fire_progress,
        fire_work_frame: -1, tool_owner: _item.tool_owner};
}

function processing_give_payload(_player, _payload) {
    var item = instance_create_layer(_player.x, _player.y, "Items", processing_material_object(_payload.process_state));
    item.process_state = _payload.process_state;
    item.amount = _payload.amount;
    item.exposure_age = _payload.exposure_age;
    item.burning = _payload.burning;
    item.fire_progress = _payload.fire_progress;
    item.tool_owner = _payload.tool_owner;
    item.spray_active = false;
    item.is_held = true;
    item.holder = _player;
    _player.carried_item = item;
    return item;
}

function processing_is_final(_state) {
    return string_pos("bag_", _state) == 1 || _state == "clean_plastic" || _state == "fertilizer";
}

// Derive materials from the editable room; only spawn routes with available equipment.
function processing_build_recipe_pools() {
    source_pool = [];
    sorting_pool = [];
    var types = ["paper", "plastic", "glass", "metal"];
    for (var i = 0; i < array_length(bins); i++) {
        var type = types[bins[i].trash_type];
        array_push(source_pool, "sorted_" + type);
    }
    if (instance_exists(obj_sorting_table)) {
        if (instance_exists(obj_washer)) array_push(sorting_pool, "dirty_plastic");
        if (instance_exists(obj_biodigester)) array_push(sorting_pool, "organic");
        if (instance_exists(obj_dismantling_bench)) array_push(sorting_pool, "electronic");
        repeat (array_length(sorting_pool)) array_push(source_pool, "raw_waste");
    }
}

function processing_next_source(_station) {
    if (array_length(_station.spawn_bag) == 0) {
        _station.spawn_bag = array_create(array_length(obj_recycling_level.source_pool));
        array_copy(_station.spawn_bag, 0, obj_recycling_level.source_pool, 0, array_length(obj_recycling_level.source_pool));
        for (var i = array_length(_station.spawn_bag) - 1; i > 0; i--) {
            var j = irandom(i), swap = _station.spawn_bag[i];
            _station.spawn_bag[i] = _station.spawn_bag[j]; _station.spawn_bag[j] = swap;
        }
    }
    return array_pop(_station.spawn_bag);
}

function processing_bin_interact(_player, _station) {
    var types = ["paper", "plastic", "glass", "metal"];
    var expected = "sorted_" + types[_station.trash_type];
    if (instance_exists(_player.carried_item)) {
        if (_player.carried_item.process_state != expected) recycling_feedback("Esta lixeira recebe " + string_lower(recycling_trash_name(_station.trash_type)) + " já separado.");
        else if (_station.load >= _station.capacity) recycling_feedback("Lixeira cheia. Retire o saco com as mãos vazias.");
        else {
            _station.load++; obj_recycling_level.sorted_total++;
            recycling_consume_item(_player);
            recycling_feedback(_station.load >= _station.capacity ? "Lixeira cheia. Retire o saco para o caminhão." : "Material separado!");
        }
    } else if (_station.load > 0) {
        processing_give_payload(_player, processing_payload_new("bag_" + types[_station.trash_type], _station.load));
        _station.load = 0;
    }
}

function processing_station_accepts(_kind, _state) {
    switch (_kind) {
        case "sorting": return _state == "raw_waste";
        case "washer": return _state == "dirty_plastic";
        case "biodigester": return _state == "organic";
        case "dismantler": return _state == "electronic" || _state == "burned_electronic";
        case "bench": return _state == "metal_plate";
    }
    return false;
}

function processing_random_material() {
    var level = obj_recycling_level;
    if (array_length(level.material_bag) == 0) {
        level.material_bag = array_create(array_length(level.sorting_pool));
        array_copy(level.material_bag, 0, level.sorting_pool, 0, array_length(level.sorting_pool));
        for (var i = array_length(level.material_bag) - 1; i > 0; i--) {
            var swap_index = irandom(i);
            var temp = level.material_bag[i];
            level.material_bag[i] = level.material_bag[swap_index];
            level.material_bag[swap_index] = temp;
        }
    }
    return array_pop(level.material_bag);
}

function processing_station_finish(_station) {
    var result = "";
    switch (_station.station_kind) {
        case "sorting": result = processing_random_material(); break;
        case "washer": result = "clean_plastic"; break;
        case "biodigester": result = "fertilizer"; break;
        case "dismantler": result = "metal_plate"; break;
        case "bench":
            var level = obj_recycling_level;
            level.robot_total++;
            level.delivered_total++;
            level.recycled_total = level.delivered_total;
            level.points_total += 100;
            array_push(level.robot_departures,{x:_station.x,y:_station.y,age:0});
            _station.buffer = undefined;
            _station.process_status = "empty";
            _station.process_progress = 0;
            _station.process_remaining = 0;
            audio_play_sound(snd_delivery_success,1,false);
            recycling_feedback("Robô pronto! A caminho da cidade.");
            return;
    }
    _station.buffer = processing_payload_new(result);
    _station.process_status = "ready";
    _station.process_progress = _station.process_duration;
    _station.process_remaining = 0;
}

function processing_store(_player, _station) {
    if (!is_undefined(_station.buffer)) { recycling_feedback("Equipamento ocupado. Retire o material pronto."); return false; }
    var item = _player.carried_item;
    if (item.burning) { recycling_feedback("Apague o fogo antes de recuperar o material."); return false; }
    if (!processing_station_accepts(_station.station_kind, item.process_state)) {
        recycling_feedback("Este material precisa de outro equipamento."); return false;
    }
    _station.buffer = processing_payload_from_item(item);
    _station.process_progress = 0;
    _station.process_remaining = _station.process_duration;
    _station.process_status = "loaded";
    if (_station.station_kind == "washer" || _station.station_kind == "biodigester" || _station.station_kind == "bench") _station.process_status = "processing";
    recycling_consume_item(_player);
    return true;
}

function processing_drop(_player, _item) {
    var drop_x = _player.x + lengthdir_x(38, _player.move_dir);
    var drop_y = _player.y + lengthdir_y(38, _player.move_dir);
    if (!recycling_position_clear(drop_x, drop_y)) { drop_x = _player.x; drop_y = _player.y; }
    _item.is_held = false;
    _item.holder = noone;
    _item.x = drop_x;
    _item.y = drop_y;
    _item.floor_age = 0;
    _item.exposure_age = 0;
    _player.carried_item = noone;
}

function processing_dispatch(_player, _station) {
    var level = obj_recycling_level;
    var item = _player.carried_item;
    if (_station.trip_remaining > 0) { recycling_feedback("O caminhão ainda está voltando."); return; }
    if (!processing_is_final(item.process_state)) { recycling_feedback("Entregue sacos separados ou materiais tratados."); return; }
    var load_units = string_pos("bag_", item.process_state) == 1 ? item.amount : 1;
    if (_station.load + load_units > _station.capacity) { recycling_feedback("Caminhão cheio. Envie a carga com as mãos vazias."); return; }
    level.points_total += 100;
    level.delivered_total++;
    if (item.process_state == "robot") level.robot_total++;
    level.recycled_total = level.delivered_total;
    _station.load += load_units;
    audio_play_sound(snd_delivery_success, 1, false);
    recycling_feedback("Material entregue! " + string(level.delivered_total) + " / " + string(level.minimum_goal));
    if (_station.load >= _station.capacity) { _station.load = 0; _station.trip_remaining = _station.return_duration; }
    recycling_consume_item(_player);
}

function processing_handoff(_player, _station) {
    if (instance_exists(obj_tutorial) && obj_recycling_level.tutorial_fire_phase != "none"
        && _station == obj_recycling_level.tutorial_fire_counter) return;
    if (instance_exists(_player.carried_item)) {
        if (!is_undefined(_station.stored_item)) { recycling_feedback("Bloco ocupado."); return; }
        _station.stored_item = processing_payload_from_item(_player.carried_item);
        recycling_consume_item(_player);
    } else if (!is_undefined(_station.stored_item)) {
        if (_station.stored_item.burning) { recycling_feedback("Apague o fogo com o extintor primeiro."); return; }
        var payload = _station.stored_item;
        _station.stored_item = undefined;
        payload.exposure_age = 0;
        processing_give_payload(_player, payload);
    }
}

function processing_interact(_player, _station_override = noone) {
    var station = instance_exists(_station_override) ? _station_override : recycling_nearest_station(_player);
    if (station != noone && variable_instance_exists(station, "tutorial_unlocked") && !station.tutorial_unlocked) return;
    var item = _player.carried_item;
    if (!instance_exists(item)) { item = noone; _player.carried_item = noone; }
    if (item != noone) {
        if (station == noone) { processing_drop(_player, item); return; }
        if (!variable_instance_exists(item, "process_state")) {
            recycling_feedback("Este material deve ser reaproveitado.");
            return;
        }
        switch (station.station_kind) {
            case "bin": processing_bin_interact(_player, station); break;
            case "handoff": processing_handoff(_player, station); break;
            case "dispatch": processing_dispatch(_player, station); break;
            case "trash":
                recycling_feedback("Nenhum material vai para o lixo comum. Reaproveite-o.");
                break;
            case "extinguisher_rack":
                if (item.process_state != "extinguisher") { recycling_feedback("Este suporte recebe o extintor."); break; }
                if (instance_exists(item.tool_owner)) item.tool_owner.tool_loaned = false;
                recycling_consume_item(_player);
                break;
            case "intake":
                if (item.process_state == "raw_waste" && array_length(station.queue) < station.capacity) {
                    array_push(station.queue, "raw_waste"); recycling_consume_item(_player);
                } else recycling_feedback("Leve o material à estação correta.");
                break;
            default: processing_store(_player, station); break;
        }
        return;
    }
    // Loose items are claimed immediately to keep simultaneous pickup atomic.
    var loose = noone;
    var closest = 42;
    with (obj_process_item) {
        var item_distance = point_distance(x,y,_player.x,_player.y);
        if (!is_held && !is_thrown && !burning && item_distance < closest) { loose = id; closest = item_distance; }
    }
    if (loose != noone) {
        loose.is_held = true; loose.holder = _player; loose.floor_age = 0; loose.exposure_age = 0;
        _player.carried_item = loose; return;
    }
    if (station == noone) return;
    switch (station.station_kind) {
        case "intake":
            if (array_length(station.queue) == 0) {
                if (instance_exists(obj_tutorial)) return;
                array_push(station.queue,processing_next_source(station));
                recycling_feedback("Alavanca acionada. Pegue o saco.");
            } else { var state = recycling_dispenser_take(station); processing_give_payload(_player, processing_payload_new(state)); }
            break;
        case "bin": processing_bin_interact(_player, station); break;
        case "handoff": processing_handoff(_player, station); break;
        case "extinguisher_rack":
            if (station.tool_loaned) recycling_feedback("O extintor já está em uso.");
            else {
                station.tool_loaned = true;
                var payload = processing_payload_new("extinguisher"); payload.tool_owner = station;
                processing_give_payload(_player, payload);
            }
            break;
        case "dispatch":
            if (station.trip_remaining <= 0 && station.load > 0) { station.load = 0; station.trip_remaining = station.return_duration; recycling_feedback("Caminhão enviado."); }
            break;
        default:
            if (is_undefined(station.buffer)) return;
            if (station.buffer.burning) { recycling_feedback("Apague o fogo primeiro."); return; }
            if (station.process_status == "ready") {
                var payload = station.buffer; station.buffer = undefined;
                station.process_status = "empty"; station.process_progress = 0;
                payload.exposure_age = 0; processing_give_payload(_player,payload);
            }
            break;
    }
}

function processing_manual_work(_player, _station, _dt) {
    var level = obj_recycling_level;
    if (instance_exists(_player.carried_item) || is_undefined(_station.buffer)) return;
    if (_station.process_status != "loaded" || _station.buffer.burning) return;
    if (_station.station_kind != "sorting" && _station.station_kind != "dismantler") return;
    if (_station.work_frame == level.processing_frame) return;
    _station.work_frame = level.processing_frame;
    _station.buffer.exposure_age = 0;
    _station.process_progress = min(_station.process_duration, _station.process_progress + _dt);
    if (_station.process_progress >= _station.process_duration) processing_station_finish(_station);
}

function processing_fire_data(_target) {
    if (variable_instance_exists(_target,"process_state")) return _target;
    if (_target.station_kind == "handoff") return _target.stored_item;
    return _target.buffer;
}

function processing_extinguish(_player, _dt) {
    if (!instance_exists(_player.carried_item)) return false;
    if (!variable_instance_exists(_player.carried_item,"process_state") || _player.carried_item.process_state != "extinguisher") return false;
    _player.carried_item.spray_active = false;
    var level = obj_recycling_level;
    var target = noone;
    var closest = 90;
    with (obj_process_item) {
        var fire_distance = point_distance(x,y,_player.x,_player.y);
        if (burning && !is_held && fire_distance < closest) { closest = fire_distance; target = id; }
    }
    for (var i = 0; i < array_length(level.stations); i++) {
        var station = level.stations[i];
        var payload = station.station_kind == "handoff" ? station.stored_item : station.buffer;
        if (!is_undefined(payload) && payload.burning) {
            var fire_distance = recycling_station_distance(_player.x,_player.y,station);
            if (fire_distance < min(58,closest)) { closest = fire_distance; target = station; }
        }
    }
    if (target == noone) return false;
    _player.carried_item.spray_active = true;
    var fire_data = processing_fire_data(target);
    if (fire_data.fire_work_frame == level.processing_frame) return true;
    fire_data.fire_work_frame = level.processing_frame;
    fire_data.fire_progress += _dt;
    if (fire_data.fire_progress >= level.extinguish_duration) {
        fire_data.burning = false;
        if (!variable_instance_exists(target,"process_state") && target.station_kind != "handoff") target.process_status = "ready";
        recycling_feedback("Fogo apagado. Recupere o eletrônico na desmontagem.");
    }
    return true;
}

function processing_player_action(_player, _held, _pressed, _dt) {
    // Firefighting takes precedence over placing the tool on the floor or counter.
    if (_held && processing_extinguish(_player, _dt)) return;
    if (_pressed) processing_interact(_player);
    if (!_held) return;
    if (instance_exists(_player.carried_item)) {
        var item = _player.carried_item;
        if (variable_instance_exists(item,"process_state") && item.process_state == "extinguisher") processing_extinguish(_player,_dt);
    } else {
        var station = recycling_nearest_station(_player);
        if (station != noone) processing_manual_work(_player,station,_dt);
    }
}

function processing_ignite_payload(_payload) {
    _payload.process_state = "burned_electronic";
    _payload.burning = true;
    _payload.fire_progress = 0;
    _payload.fire_work_frame = -1;
}

function processing_tick(_dt, _guided = false) {
    var level = id;
    processing_frame++;
    truck.trip_remaining = max(0, truck.trip_remaining - _dt);
    overflow_elapsed = 0;
    for (var i = 0; i < array_length(stations); i++) {
        var station = stations[i];
        if (!_guided && station.station_kind == "intake") {
            station.spawn_timer -= _dt;
            while (station.spawn_timer <= 0 && array_length(station.queue) < station.capacity) {
                array_push(station.queue,processing_next_source(station)); station.spawn_timer += max(0.1,station.spawn_interval);
            }
            if (array_length(station.queue) >= station.capacity) { station.spawn_timer = max(0,station.spawn_timer); station.overflow_elapsed += _dt; }
            else station.overflow_elapsed = 0;
            overflow_elapsed = max(overflow_elapsed,station.overflow_elapsed);
        }
        if (station.process_status == "processing") {
            station.process_remaining = max(0,station.process_remaining-_dt);
            station.process_progress = station.process_duration-station.process_remaining;
            if (station.process_remaining <= 0) processing_station_finish(station);
        }
        var payload = station.station_kind == "handoff" ? station.stored_item : station.buffer;
        if (!_guided && !is_undefined(payload) && payload.process_state == "electronic") {
            if (station.work_frame >= processing_frame-1 && station.station_kind == "dismantler") payload.exposure_age = 0;
            else payload.exposure_age += _dt;
            if (payload.exposure_age >= electronic_overheat_time) {
                processing_ignite_payload(payload);
                if (station.station_kind != "handoff") { station.process_status = "burning"; station.process_progress = 0; }
            }
        }
    }
    with (obj_process_item) {
        if (is_held) { floor_age = 0; exposure_age = 0; }
        else if (!_guided) {
            if (process_state == "organic") {
                floor_age += _dt;
                if (floor_age >= level.organic_decay_time) {
                    var puddle = instance_create_layer(x,y,"Items",obj_leachate);puddle.depth = -y+10;
                    instance_destroy();
                }
            } else if (process_state == "electronic") {
                exposure_age += _dt;
                if (exposure_age >= level.electronic_overheat_time) {
                    processing_ignite_payload(id);
                    sprite_index = object_get_sprite(obj_material_burned_electronic);
                }
            }
        }
    }
    with (obj_recycling_player) {
        stun_remaining = max(0,stun_remaining-_dt);
        processing_check_puddle(id);
    }
    if (!_guided && overflow_elapsed >= overflow_limit) recycling_finish(false,"A caçamba ficou cheia por muito tempo.");
    else if (!_guided && time_remaining <= 0) recycling_finish(delivered_total>=minimum_goal,
        delivered_total>=minimum_goal ? "Mutirão concluído!" : "A meta de entregas não foi atingida.");
}

// Called for each short movement step so a dash cannot skip over a puddle.
function processing_check_puddle(_player) {
    var contact = noone;
    with (obj_leachate) if (point_distance(x,y,_player.x,_player.y)<26) contact=id;
    var entered = contact != noone && contact != _player.slip_contact;
    if (entered) {
        _player.stun_remaining = obj_recycling_level.slip_stun_duration;
        _player.is_dashing = false;
    }
    _player.slip_contact = contact;
    return entered;
}
