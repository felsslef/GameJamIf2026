function processing_draw_payload(_payload, _x, _y, _scale = 1) {
    var asset = object_get_sprite(processing_material_object(_payload.process_state));
    var payload_scale = 52 * _scale / max(sprite_get_width(asset),sprite_get_height(asset));
    draw_sprite_ext(asset,0,_x,_y,payload_scale,payload_scale,0,c_white,1);
    if (_payload.burning) draw_sprite(spr_fire,0,_x,_y-14);
}

function processing_draw_item() {
    recycling_draw_item_visual(id);
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
            nearby = recycling_station_distance(_player.x, _player.y, station) <= 28;
            if (!nearby) continue;
            var count = array_length(station.queue);
            var full = count >= station.capacity;
            var accent = full ? make_color_rgb(185, 52, 46) : make_color_rgb(38, 117, 104);
            var status = "Próximo: " + string(max(0, ceil(station.spawn_timer))) + "s";
            if (instance_exists(obj_tutorial)) status = count > 0 ? "Retire o item" : "Aguarde a etapa";
            if (full) status = "Cheia! " + string(max(0, ceil(level.overflow_limit - station.overflow_elapsed))) + "s";
            if (abs(_player.y - (station.y + 41)) < 24) processing_draw_text_over_player(station.x, station.y + 41, "Caçamba " + string(count) + "/" + string(station.capacity), fnt_ui_small, dark);
            if (abs(_player.y - (station.y + 63)) < 24) processing_draw_text_over_player(station.x, station.y + 63, status, fnt_ui_small, accent);
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
        } else if (nearby && abs(_player.y - (station.y + 38)) < 24) {
            var label = processing_station_name(station.station_kind);
            if (!is_undefined(station.buffer)) {
                if (station.buffer.burning) label += ": fogo!";
                else if (station.process_status == "ready") label += ": pronto";
            }
            if (station.station_kind == "extinguisher_rack" && station.tool_loaned) label += ": em uso";
            processing_draw_text_over_player(station.x, station.y + 38, label, fnt_ui_small, dark);
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
    draw_set_alpha(1);
    if (station_kind == "handoff") {
        if (!is_undefined(stored_item)) processing_draw_payload(stored_item, x, y - 3, 0.75);
        return;
    }
    var label = processing_station_name(station_kind);
    if (station_kind == "bin") {
        if (load > 0) recycling_draw_bar(x - 24, y + 24, 48, load / capacity, recycling_trash_color(trash_type));
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
        if (nearby) {
            var shown = min(3, count);
            if (shown > 0) {
                frontend_panel(x - 66, y - 82, 132, 44, make_color_rgb(255,252,235), dark);
                for (var i = 0; i < shown; i++) {
                    var asset = object_get_sprite(processing_material_object(queue[i]));
                    var scale = 36 / max(sprite_get_width(asset), sprite_get_height(asset));
                    draw_sprite_ext(asset, 0, x - 44 + i * 44, y - 60, scale, scale, 0, c_white, 1);
                }
            }
        }
        if (nearby) {
        var full = count >= capacity;
        var accent = full ? make_color_rgb(185,52,46) : make_color_rgb(38,117,104);
        frontend_panel(x-74,y+38,148,48,full?make_color_rgb(255,225,212):make_color_rgb(255,252,235),accent);
        frontend_text(x,y+41,"Caçamba " + string(count) + "/" + string(capacity),fnt_ui_small,dark,fa_center);
        var status = "Próximo: " + string(max(0,ceil(spawn_timer))) + "s";
        if (instance_exists(obj_tutorial)) status = count > 0 ? "Retire o item" : "Aguarde a etapa";
        if (full) status = "Cheia! " + string(max(0,ceil(level.overflow_limit-overflow_elapsed))) + "s";
        frontend_text(x,y+63,status,fnt_ui_small,accent,fa_center);
        recycling_draw_bar(x-32,y+25,64,full?1:1-clamp(spawn_timer/max(0.1,spawn_interval),0,1),accent);
        }
    } else if (station_kind == "dispatch") {
        if (nearby || trip_remaining > 0) frontend_text(x, y + 40, trip_remaining > 0 ? "Voltando: " + string(ceil(trip_remaining)) + "s" : "Caminhão " + string(load) + "/" + string(capacity), fnt_ui_small, dark, fa_center);
    } else {
        if (!is_undefined(buffer)) {
            processing_draw_payload(buffer, x, y - 3, 0.75);
            if (buffer.burning) {
                label += ": fogo!";
                if (buffer.fire_progress > 0) recycling_draw_bar(x - 24, y + 24, 48, buffer.fire_progress / level.extinguish_duration, make_color_rgb(92,169,204));
            } else if (process_status == "processing" || process_status == "loaded") {
                recycling_draw_bar(x - 24, y + 24, 48, process_duration > 0 ? process_progress / process_duration : 0, make_color_rgb(68,158,120));
            } else if (process_status == "ready") label += ": pronto";
        }
        if (station_kind == "extinguisher_rack" && tool_loaned) label += ": em uso";
        if (nearby) frontend_text(x, y + 38, label, fnt_ui_small, dark, fa_center);
    }
    draw_set_alpha(1); draw_set_font(-1); draw_set_color(c_white); draw_set_halign(fa_left);
}

function processing_draw_hud() {
    var reduced = variable_global_exists("frontend_reduced_motion") && global.frontend_reduced_motion;
    var urgency = phase_state == "playing" && time_remaining <= 15;
    var pulse = urgency ? max(0, 1 - (1 - frac(time_remaining)) / 0.24) : 0;
    if (pulse > 0 && !reduced) {
        draw_set_alpha(pulse * 0.12);
        frontend_rect(0,0,1280,720,make_color_rgb(230,61,52));
        draw_set_alpha(1);
    }
    var dark = make_color_rgb(35,57,64);
    frontend_panel(32,20,1216,70,make_color_rgb(255,252,235),dark);
    frontend_text(56,29,"Entregas: "+string(delivered_total)+" / "+string(minimum_goal),fnt_ui_body,dark);
    frontend_text(56,59,"Estrelas: "+string(processing_earned_stars())+" / 3",fnt_ui_small,dark);
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
    if(feedback_timer>0 && phase_state=="playing") {
        frontend_panel(160,612,960,30,make_color_rgb(255,252,235),dark);
        frontend_text(640,616,feedback,fnt_ui_small,dark,fa_center);
    }
    with(obj_recycling_player) if(stun_remaining>0) frontend_text(x,y-86,"Atordoada "+string(ceil(stun_remaining))+"s",fnt_ui_small,make_color_rgb(177,51,47),fa_center);
    if(phase_state!="playing") {
        var result_age = max(0,(current_time-result_started)/1000);
        if (result_is_timeout && result_age < 1.25) {
            draw_set_alpha(0.5 * min(1,result_age/0.15));frontend_rect(0,0,1280,720,c_black);draw_set_alpha(1);
            var pop = reduced ? 1 : ui_pop_scale(min(1,result_age/0.45));
            draw_sprite_ext(spr_ui_timeout,0,640,300,pop*2,pop*2,0,c_white,1);
            frontend_text(640,420,"Tempo esgotado!",fnt_ui_title,make_color_rgb(255,252,235),fa_center);
            return;
        }
        var entry = reduced ? 1 : clamp((result_age-(result_is_timeout?1.25:0))/0.4,0,1);
        var result_matrix = matrix_get(matrix_world);
        draw_set_alpha(0.55*entry);frontend_rect(0,0,1280,720,c_black);draw_set_alpha(1);
        matrix_set(matrix_world,matrix_build(0,(1-entry)*(1-entry)*80,0,0,0,0,1,1,1));
        frontend_panel(240,150,800,440,make_color_rgb(255,252,235),dark);
        frontend_text(640,217,phase_state=="won"?"Fase concluída!":"Fim da rodada",fnt_ui_title,dark,fa_center);
        frontend_text(640,296,result_reason,fnt_ui_small,dark,fa_center);
        frontend_text(640,335,"Entregas: "+string(delivered_total)+" / "+string(minimum_goal),fnt_ui_body,dark,fa_center);
        for(var i=0;i<3;i++) {
            var star_scale = reduced ? 1 : ui_pop_scale(clamp((result_age-(result_is_timeout?1.25:0)-0.2-i*0.12)/0.35,0,1));
            draw_sprite_ext(spr_ui_star,0,584+i*56,410,star_scale,star_scale,0,i<result_stars?make_color_rgb(233,178,55):make_color_rgb(186,190,177),1);
        }
        recycling_draw_result_buttons();
        matrix_set(matrix_world,result_matrix);
    }
    draw_set_alpha(1);draw_set_font(-1);draw_set_color(c_white);draw_set_halign(fa_left);draw_set_valign(fa_top);
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
