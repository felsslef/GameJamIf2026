function processing_draw_payload(_payload, _x, _y, _scale = 1) {
    var asset = object_get_sprite(processing_material_object(_payload.process_state));
    var payload_scale = 52 * _scale / max(sprite_get_width(asset),sprite_get_height(asset));
    draw_sprite_ext(asset,0,_x,_y,payload_scale,payload_scale,0,c_white,1);
    if (_payload.burning) draw_sprite(spr_fire,0,_x,_y-14);
    recycling_draw_material_marker(recycling_material_type(_payload.process_state),_x,_y-28*_scale,0.7);
}

function processing_warning_remaining(_payload, _on_floor) {
    if (_payload.burning) return -1;
    var level = obj_recycling_level;
    if (_payload.process_state == "electronic") return level.electronic_overheat_time - _payload.exposure_age;
    if (_on_floor && _payload.process_state == "organic") return level.organic_decay_time - _payload.floor_age;
    return -1;
}

function processing_draw_warning(_payload, _x, _y, _on_floor) {
    var remaining = processing_warning_remaining(_payload, _on_floor);
    if (remaining <= 0 || remaining > 2) return;
    var camera = view_camera[0];
    var reduced = variable_global_exists("frontend_reduced_motion") && global.frontend_reduced_motion;
    var bob = reduced ? 0 : sin(current_time / 140) * 4;
    var px = (_x - camera_get_view_x(camera)) * 1280 / camera_get_view_width(camera);
    var py = (_y - camera_get_view_y(camera)) * 720 / camera_get_view_height(camera);
    draw_sprite(spr_ui_warning, 0, round(px), round(_on_floor ? py-54+bob : max(108,py-94+bob)));
}

function processing_draw_warnings() {
    if (!processing_enabled || phase_state != "playing") return;
    with (obj_process_item) if (!is_held) processing_draw_warning(id, x, y, true);
    for (var i=0;i<array_length(stations);i++) {
        var station = stations[i];
        var payload = station.station_kind == "handoff" ? station.stored_item : station.buffer;
        if (station.visible && !is_undefined(payload)) processing_draw_warning(payload,station.x,station.y,false);
    }
}

function processing_draw_item() {
    recycling_draw_item_visual(id);
    recycling_draw_material_marker(recycling_material_type(process_state),x,y-30,0.7);
    if (process_state == "extinguisher" && is_held && variable_instance_exists(id,"spray_active") && spray_active && instance_exists(holder)) {
        // A short animated plume follows the player's facing direction while a fire is being treated.
        var spray_dir = holder.move_dir;
        var flicker = current_time / 55;
        draw_set_alpha(0.78);
        for (var i = 0; i < 6; i++) {
            var progress = (i + 1) / 6;
            var drift = sin(flicker + i * 1.7) * (3 + progress * 5);
            var spray_x = x + lengthdir_x(9 + progress * 38, spray_dir) + lengthdir_x(drift, spray_dir + 90);
            var spray_y = y + lengthdir_y(9 + progress * 38, spray_dir) + lengthdir_y(drift, spray_dir + 90);
            var radius = 2 + (i mod 3);
            draw_set_color(i mod 2 == 0 ? make_color_rgb(210, 246, 255) : make_color_rgb(140, 218, 239));
            draw_circle(spray_x, spray_y, radius, false);
        }
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
    var level = instance_exists(obj_recycling_level) ? instance_find(obj_recycling_level,0) : noone;
    if (burning) {
        draw_sprite(spr_fire,0,x,y-14);
        if (level != noone && fire_progress > 0) recycling_draw_bar(x-22,y-45,44,fire_progress/level.extinguish_duration,make_color_rgb(100,180,210));
    } else if (!is_held && level != noone && !instance_exists(obj_tutorial)) {
        if (process_state == "organic") recycling_draw_bar(x-18,y-28,36,1-floor_age/level.organic_decay_time,make_color_rgb(124,158,65));
        if (process_state == "electronic") recycling_draw_bar(x-18,y-28,36,1-exposure_age/level.electronic_overheat_time,make_color_rgb(209,112,59));
    }
    draw_set_color(c_white);
}

function processing_station_name(_kind) {
    switch (_kind) {
        case "intake": return "Caçamba";
        case "sorting": return "Triagem";
        case "washer": return "Lavadora";
        case "biodigester": return "Biodigestor";
        case "dismantler": return "Desmontagem";
        case "bench": return "Bancada científica";
        case "dispatch": return "Expedição";
        case "trash": return "Lixo comum";
        case "extinguisher_rack": return "Extintor";
    }
    return "Bancada";
}

function processing_station_near(_station, _range = 58) {
    var nearby = false;
    with (obj_recycling_player) if (recycling_nearest_station(id) == _station && recycling_station_distance(x,y,_station) <= _range) nearby = true;
    return nearby;
}

function processing_draw_text_over_player(_x, _y, _text, _font, _color, _align = fa_center) {
    // Keep the original label style; only its draw order changes when a character overlaps it.
    frontend_text(_x, _y, _text, _font, _color, _align);
}

function processing_draw_station_text_over_player(_player) {
    if (!instance_exists(_player) || !instance_exists(obj_recycling_level)) return;
    var level = obj_recycling_level;
    var processing = level.processing_enabled;
    var dark = make_color_rgb(35, 57, 64);
    for (var station_index = 0; station_index < array_length(level.stations); station_index++) {
        var station = level.stations[station_index];
        if (!instance_exists(station) || abs(_player.x - station.x) > 95 || abs(_player.y - station.y) > 90) continue;
        if (!processing) {
            if (station.station_kind == "bin" && abs(_player.y - (station.y + 56)) < 24) {
                var bin_full = station.load >= station.capacity;
                var bin_label = recycling_trash_name(station.trash_type) + " " + string(station.load) + "/" + string(station.capacity) + (bin_full ? " CHEIA" : "");
                processing_draw_text_over_player(station.x, station.y + 56, bin_label, fnt_ui_small, dark);
            } else if (station.station_kind == "dispenser" && array_length(station.queue) >= station.capacity
                && abs(_player.y - (station.y + 72)) < 24) {
                processing_draw_text_over_player(station.x, station.y + 72, "CHEIO! " + string(max(0, ceil(level.overflow_limit - station.overflow_elapsed))) + "s", fnt_ui_small, make_color_rgb(177, 51, 47));
            } else if (station.station_kind == "bench" && abs(_player.y - (station.y + 43)) < 24) {
                var bench_status = station.module_ready ? "Retire o robô" : (station.build_remaining > 0 ? "Montando: " + string(ceil(station.build_remaining)) + "s" : "C + B + M + A");
                processing_draw_text_over_player(station.x, station.y + 43, bench_status, fnt_ui_small, dark);
            }
            continue;
        }
        var nearby = recycling_station_distance(_player.x, _player.y, station) <= 58;
        if (station.station_kind == "intake") {
            continue;
        } else if (station.station_kind == "bin") {
            if (abs(_player.y - (station.y + 38)) < 24) {
                if (nearby) processing_draw_text_over_player(station.x, station.y + 38, string(station.load) + "/" + string(station.capacity), fnt_ui_small, dark);
                else if (station.load >= station.capacity) processing_draw_text_over_player(station.x, station.y + 38, "Cheia", fnt_ui_small, dark);
            }
        } else if (station.station_kind == "dispatch") {
            if ((nearby || station.trip_remaining > 0) && abs(_player.y - (station.y + 40)) < 24) {
                var truck_status = station.trip_remaining > 0 ? "Voltando: " + string(ceil(station.trip_remaining)) + "s" : "Caminhão " + string(station.load) + "/" + string(station.capacity);
                processing_draw_text_over_player(station.x, station.y + 40, truck_status, fnt_ui_small, dark);
            }
        }
    }
    draw_set_color(c_white);
    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function processing_draw_station() {
    var dark = make_color_rgb(35, 57, 64);
    var nearby = processing_station_near(id);
    var level = obj_recycling_level;
    if (station_kind == "dispatch") recycling_draw_truck();
    else if (station_kind == "extinguisher_rack") draw_sprite(sprite_index, tool_loaned ? 1 : 0, x, y);
    else draw_self();
    if (station_kind == "bin") recycling_draw_material_marker(trash_type,x,y-48,1);
    draw_set_alpha(1);
    if (station_kind == "handoff") {
        if (!is_undefined(stored_item)) processing_draw_payload(stored_item, x, y - 3, 0.75);

        return;
    }
    var label = processing_station_name(station_kind);
    if (station_kind == "bin") {

        if (nearby) frontend_text(x, y + 38, string(load) + "/" + string(capacity), fnt_ui_small, dark, fa_center);
        else if (load >= capacity) frontend_text(x, y + 38, "Cheia", fnt_ui_small, dark, fa_center);
    } else if (station_kind == "intake") {
        nearby = processing_station_near(id,28);
        var count = array_length(queue);
        if (count > 0) {
            var asset = object_get_sprite(processing_material_object(queue[0]));
            var scale = 40 / max(sprite_get_width(asset), sprite_get_height(asset));
            draw_sprite_ext(asset, 0, x, y + 4, scale, scale, 0, c_white, 1);
        }
    } else if (station_kind == "dispatch") {
        if (nearby || trip_remaining > 0) frontend_text(x, y + 40, trip_remaining > 0 ? "Voltando: " + string(ceil(trip_remaining)) + "s" : "Caminhão " + string(load) + "/" + string(capacity), fnt_ui_small, dark, fa_center);
    } else {
        if (!is_undefined(buffer)) {
            processing_draw_payload(buffer, x, y - 3, 0.75);

        }
        if (station_kind == "extinguisher_rack" && tool_loaned) label += ": em uso";

    }
    draw_set_alpha(1); draw_set_font(-1); draw_set_color(c_white); draw_set_halign(fa_left);
}

function processing_draw_fire_alert() {
    if (phase_state != "playing" || fire_count <= 0) return;
    var urgent = fire_remaining <= 5;
    var accent = urgent ? make_color_rgb(174, 52, 43) : make_color_rgb(153, 91, 30);
    var by = instance_exists(obj_tutorial) ? 150 : 104;
    frontend_panel(232, by, 816, 68, make_color_rgb(255, 241, 211), accent);
    draw_sprite_ext(spr_fire, 0, 266, by + 34, 0.75, 0.75, 0, c_white, 1);
    frontend_text(640, by + 8, "INCÊNDIO ATIVO · " + string(ceil(fire_remaining)) + "s PARA EVITAR A DERROTA", fnt_ui_body, accent, fa_center);
    frontend_text(640, by + 39, "Pegue o extintor e segure o botão de pegar perto do fogo.", fnt_ui_small, accent, fa_center);
}

function processing_draw_hud() {
    var reduced = variable_global_exists("frontend_reduced_motion") && global.frontend_reduced_motion;
    var urgency = recycling_time_is_urgent();
    var pulse = urgency ? recycling_urgency_pulse(time_remaining) : 0;
    if (pulse > 0 && !reduced) {
        draw_set_alpha(pulse * 0.12);
        frontend_rect(0,0,1280,720,make_color_rgb(230,61,52));
        draw_set_alpha(1);
    }
    var dark = make_color_rgb(35,57,64);
    frontend_panel(32,20,1216,70,make_color_rgb(255,252,235),dark);
    frontend_text(56,29,"Entregas: "+string(delivered_total)+" / "+string(processing_delivery_goal()),fnt_ui_body,dark);
    frontend_text(56,59,"Pontos: "+string(points_total)+" / "+string(minimum_goal*100)+" · "+save_difficulty_name(difficulty),fnt_ui_small,dark);
    var seconds_left=ceil(time_remaining);
    var clock=string(floor(seconds_left/60))+":"+(seconds_left mod 60<10?"0":"")+string(seconds_left mod 60);
    var clock_scale = reduced ? 1 : 1 + pulse * 0.13;
    var clock_matrix = matrix_get(matrix_world);
    matrix_set(matrix_world,matrix_build(640,30,0,0,0,0,clock_scale,clock_scale,1));
    frontend_text(0,0,clock,fnt_ui_title,time_remaining<=20?make_color_rgb(177,51,47):dark,fa_center);
    matrix_set(matrix_world,clock_matrix);
    var names=["Porto Novo","Indaiá","Centro","Martim de Sá","Massaguaçu"];
    frontend_text(1220,32,names[level_index],fnt_ui_body,dark,fa_right);
    for (var goal_index=0;goal_index<3;goal_index++) {
        var reached=delivered_total>=star_goals[goal_index];
        draw_sprite_ext(spr_ui_star,0,980+goal_index*80,70,0.45,0.45,0,reached?make_color_rgb(233,178,55):make_color_rgb(166,178,171),1);
        frontend_text(994+goal_index*80,59,string(min(delivered_total,star_goals[goal_index]))+"/"+string(star_goals[goal_index]),fnt_ui_small,dark);
    }

    with(obj_recycling_player) if(stun_remaining>0) frontend_text(x,y-86,"Atordoada "+string(ceil(stun_remaining))+"s",fnt_ui_small,make_color_rgb(177,51,47),fa_center);
    processing_draw_fire_alert();
    if(phase_state!="playing") recycling_draw_result();
    draw_set_alpha(1);draw_set_font(-1);draw_set_color(c_white);draw_set_halign(fa_left);draw_set_valign(fa_top);
}

/// Shared result card for campaign, tutorial and failures; button hitboxes stay fixed.
function recycling_draw_result() {
    var won = phase_state == "won";
    var training = level_index == -1;
    var reduced = global.frontend_reduced_motion;
    var age = max(0, (current_time - result_started) / 1000);
    var cream = make_color_rgb(255, 250, 229);
    var ink = make_color_rgb(35, 57, 64);
    var teal = make_color_rgb(18, 113, 105);
    var gold = make_color_rgb(239, 179, 65);
    var accent = won ? teal : make_color_rgb(172, 68, 50);
    if (result_is_timeout && age < 1.25) {
        draw_set_alpha(0.55); frontend_rect(0,0,1280,720,c_black); draw_set_alpha(1);
        var pop = reduced ? 1 : ui_pop_scale(min(1,age/0.45));
        draw_sprite_ext(spr_ui_timeout,0,640,300,pop*2,pop*2,0,c_white,1);
        frontend_text(640,420,"Tempo esgotado!",fnt_ui_title,cream,fa_center);
        return;
    }
    var elapsed = max(0, age - (result_is_timeout ? 1.25 : 0));
    var entry = reduced ? 1 : clamp(elapsed / 0.4, 0, 1);
    draw_set_alpha(0.65 * entry); frontend_rect(0,0,1280,720,ink); draw_set_alpha(1);
    var previous_matrix = matrix_get(matrix_world);
    matrix_set(matrix_world,matrix_build(0,(1-entry)*(1-entry)*64,0,0,0,0,1,1,1));
    frontend_panel(168,110,944,520,cream,accent);
    frontend_panel(184,126,912,42,accent,accent);
    var places = ["Porto Novo", "Indaiá", "Centro", "Martim de Sá", "Massaguaçu"];
    var label = training ? "ACADEMIA DA RECICLAGEM" : "FASE " + string(level_index + 1) + " · " + string_upper(places[level_index]);
    if (!training) label += " · " + string_upper(save_difficulty_name(difficulty));
    frontend_text(640,135,label,fnt_ui_small,cream,fa_center);
    frontend_text(640,184,won ? (training ? "Tutorial concluído!" : "Fase concluída!") : "Vamos tentar de novo?",fnt_ui_title,accent,fa_center);
    draw_set_font(fnt_ui_small); draw_set_halign(fa_center); draw_set_color(ink);
    draw_text_ext(640,246,result_reason,22,800);
    for (var i = 0; i < 3; i++) {
        var sx = 512 + i * 128;
        var earned = i < result_stars;
        var star_pop = reduced ? 1 : ui_pop_scale(clamp((elapsed-0.15-i*0.13)/0.35,0,1));
        draw_set_color(earned ? make_color_rgb(250,229,174) : make_color_rgb(228,229,212));
        draw_circle(sx,326,44,false);
        draw_sprite_ext(spr_ui_star,0,sx,326,star_pop*2.2,star_pop*2.2,0,earned?gold:make_color_rgb(166,176,163),1);
        var captions = ["Separar", "Despachar", "Apagar fogo"];
        frontend_text(sx,378,training ? captions[i] : string(star_goals[i])+" entregas",fnt_ui_small,earned?teal:ink,fa_center);
    }
    var values = [string(processing_enabled ? delivered_total : recycled_total), string(robot_total), string(processing_enabled ? points_total : recycled_total*100)];
    var captions = ["ENTREGAS", "ROBÔS NA CIDADE", "PONTOS"];
    for (var i = 0; i < 3; i++) {
        var sx = 320 + i * 220;
        frontend_panel(sx,408,200,48,make_color_rgb(232,240,219),make_color_rgb(184,207,174));
        frontend_text(sx+100,410,captions[i],fnt_ui_small,teal,fa_center);
        frontend_text(sx+100,430,values[i],fnt_ui_body,ink,fa_center);
    }
    // Confetti stays in the margins so the result and the controls remain readable.
    if (won && !reduced && elapsed < 3) {
        for (var i = 0; i < 20; i++) {
            var cx = i mod 2 == 0 ? 208+(i*17 mod 82) : 988+(i*19 mod 82);
            var cy = 186 + ((i*41+elapsed*58) mod 270);
            draw_set_alpha(max(0,1-elapsed/3));
            frontend_rect(cx,cy,5,10,i mod 3 == 0 ? gold : (i mod 3 == 1 ? teal : make_color_rgb(221,128,95)));
        }
        draw_set_alpha(1);
    }
    recycling_draw_result_buttons();
    var next = recycling_result_has_next();
    var footer = won ? (next ? (training ? "Treino completo! Comece sua jornada em Porto Novo." : "Próxima fase liberada. A cidade conta com você!") : "Parabéns! Você cuidou de todos os bairros.") : "Reorganize o trabalho e cuide dos incidentes para continuar.";
    frontend_text(640,550,footer,fnt_ui_small,accent,fa_center);
    frontend_text(640,588,online_game() && !global.is_host ? "Aguardando a anfitriã escolher..."
        : (next ? "Enter: próxima fase   |   R: repetir   |   Esc: mapa" : "Enter / Esc: mapa   |   R: tentar de novo"),fnt_ui_small,ink,fa_center);
    matrix_set(matrix_world,previous_matrix);
    draw_set_alpha(1); draw_set_color(c_white); draw_set_font(-1); draw_set_halign(fa_left);
}

function processing_delivery_goal() {
    return star_goals[array_length(star_goals)-1];
}

/// Draw GUI keeps work, ready-state and bin-fill indicators above world actors.
function processing_draw_station_overlays() {
    if (!processing_enabled || phase_state != "playing") return;
    var camera=view_camera[0];
    var dark=make_color_rgb(35,57,64);
    for(var i=0;i<array_length(stations);i++) {
        var station=stations[i];
        if(!instance_exists(station) || !station.visible) continue;
        var payload=station.station_kind=="handoff"?station.stored_item:station.buffer;
        var ratio=-1;
        var color=make_color_rgb(68,158,120);
        if(station.station_kind=="bin" && station.load>0) {
            ratio=station.load/station.capacity;
            color=recycling_trash_color(station.trash_type);
        } else if(!is_undefined(payload)) {
            if(payload.burning) {
                if(payload.fire_progress>0) { ratio=payload.fire_progress/extinguish_duration;color=make_color_rgb(92,169,204); }
            } else if(station.station_kind!="handoff") {
                if(station.process_status=="ready") ratio=1;
                else if(station.process_status=="processing" || station.process_status=="loaded") ratio=station.process_duration>0?station.process_progress/station.process_duration:0;
            }
        }
        if(ratio<0) continue;
        var px=(station.x-camera_get_view_x(camera))*1280/camera_get_view_width(camera);
        var marker_offset = station.station_kind=="bin" && global.frontend_colorblind ? 100 : 68;
        var py=max(100,(station.y-camera_get_view_y(camera))*720/camera_get_view_height(camera)-marker_offset);
        frontend_panel(px-42,py,84,28,make_color_rgb(255,252,235),dark);
        if(!is_undefined(payload)) {
            var asset=object_get_sprite(processing_material_object(payload.process_state));
            var scale=20/max(sprite_get_width(asset),sprite_get_height(asset));
            draw_sprite_ext(asset,0,px-27,py+14,scale,scale,0,c_white,1);
        } else draw_sprite_ext(station.sprite_index,0,px-27,py+14,0.28,0.28,0,c_white,1);
        recycling_draw_bar(px-12,py+9,46,ratio,color);
    }
}

function ui_pop_scale(_t) {
    var v = clamp(_t,0,1)-1;
    return max(0,1+2.70158*v*v*v+1.70158*v*v);
}

function processing_earned_stars() {
    var earned=0;
    for(var i=0;i<3;i++)if(delivered_total>=star_goals[i])earned++;
    return earned;
}

function processing_draw_robot_departures() {
    if (!processing_enabled) return;
    var reduced=variable_global_exists("frontend_reduced_motion") && global.frontend_reduced_motion;
    for(var i=0;i<array_length(robot_departures);i++) {
        var robot=robot_departures[i];
        var t=clamp(robot.age/0.9,0,1);
        var eased=t*t*(3-2*t);
        draw_sprite_ext(spr_robot,0,robot.x+(reduced?0:72*eased),robot.y-(reduced?0:48*eased),1.3,1.3,0,c_white,1-eased);
    }
}
