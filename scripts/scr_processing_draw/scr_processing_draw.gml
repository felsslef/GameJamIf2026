function processing_draw_payload(_payload, _x, _y, _scale = 1) {
    var asset = object_get_sprite(processing_material_object(_payload.process_state));
    draw_sprite_ext(asset,0,_x,_y,_scale,_scale,0,c_white,1);
    if (_payload.burning) draw_sprite(spr_fire,0,_x,_y-14);
}

function processing_draw_item() {
    recycling_draw_item_visual(id);
    var level = instance_exists(obj_recycling_level) ? instance_find(obj_recycling_level,0) : noone;
    if (burning) {
        draw_sprite(spr_fire,0,x,y-14);
        if (level != noone && fire_progress > 0) recycling_draw_bar(x-22,y-45,44,fire_progress/level.extinguish_duration,make_color_rgb(100,180,210));
    } else if (!is_held && level != noone) {
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
        case "press": return "Prensa";
        case "dispatch": return "Expedição";
        case "trash": return "Lixo comum";
        case "extinguisher_rack": return "Extintor";
    }
    return "Bancada";
}

function processing_draw_station() {
    var dark = make_color_rgb(35,57,64);
    if (station_kind == "dispatch" && station_height > 88) draw_sprite_stretched(spr_counter,0,x-station_width/2,y-station_height/2,station_width,station_height);
    if (station_kind == "dispatch" && trip_remaining > 0) draw_set_alpha(0.3);
    draw_self();draw_set_alpha(1);
    if (station_kind == "handoff") {
        if (!is_undefined(stored_item)) processing_draw_payload(stored_item,x,y-3);
        return;
    }
    var label = processing_station_name(station_kind);
    var level = obj_recycling_level;
    if (station_kind == "intake") {
        var count = array_length(queue);
        for (var i = 0; i < count; i++) draw_sprite_ext(object_get_sprite(obj_material_raw_waste),0,x-63+(i mod 4)*42,y+13+floor(i/4)*28,0.5,0.5,0,c_white,1);
        frontend_text(x,y-30,string(count)+" / "+string(capacity),fnt_ui_small,dark,fa_center);
        recycling_draw_bar(x-80,y+56,160,count/capacity,make_color_rgb(70,150,130));
        if (count >= capacity) label = "CHEIA! "+string(max(0,ceil(level.overflow_limit-overflow_elapsed)))+"s";
        frontend_text(x,y-84,label,fnt_ui_body,dark,fa_center);
    } else if (station_kind == "dispatch") {
        frontend_text(x,y-76,label,fnt_ui_body,dark,fa_center);
        frontend_text(x,y-15,trip_remaining>0?"Voltando: "+string(ceil(trip_remaining))+"s":string(load)+"/"+string(capacity),fnt_ui_small,trip_remaining>0?dark:c_white,fa_center);
    } else {
        if (!is_undefined(buffer)) {
            processing_draw_payload(buffer,x,y-10);
            if (buffer.burning) {
                label += ": FOGO!";
                recycling_draw_bar(x-50,y+31,100,buffer.fire_progress/level.extinguish_duration,make_color_rgb(92,169,204));
            } else if (process_status == "processing" || process_status == "loaded") {
                recycling_draw_bar(x-50,y+31,100,process_duration>0?process_progress/process_duration:0,make_color_rgb(68,158,120));
                if (station_kind == "press" && process_status == "loaded") label += ": acione";
            } else if (process_status == "ready") label += ": pronto";
        } else if (station_kind == "extinguisher_rack" && !tool_loaned) {
            draw_sprite(object_get_sprite(obj_material_extinguisher),0,x,y-6);
        }
        frontend_text(x,y+52,label,fnt_ui_small,dark,fa_center);
    }
    draw_set_font(-1);draw_set_color(c_white);draw_set_halign(fa_left);
}

function processing_draw_hud() {
    var dark = make_color_rgb(35,57,64);
    frontend_panel(32,20,1216,70,make_color_rgb(255,252,235),dark);
    frontend_text(56,29,"Pedidos: "+string(delivered_total)+" / "+string(minimum_goal),fnt_ui_body,dark);
    frontend_text(56,59,"Pontos: "+string(points_total),fnt_ui_small,dark);
    var seconds_left=ceil(time_remaining);
    var clock=string(floor(seconds_left/60))+":"+(seconds_left mod 60<10?"0":"")+string(seconds_left mod 60);
    frontend_text(640,30,clock,fnt_ui_title,time_remaining<=20?make_color_rgb(177,51,47):dark,fa_center);
    var names=["Porto Novo","Indaiá","Centro","Martim de Sá","Massaguaçu"];
    frontend_text(1220,32,names[level_index],fnt_ui_body,dark,fa_right);
    frontend_text(1220,62,frontend_key_name(frontend_keybinding("pause"))+": pausa | F11: tela cheia",fnt_ui_small,dark,fa_right);
    for(var i=0;i<array_length(active_orders);i++) {
        var ox=32+i*410;
        frontend_panel(ox,98,396,46,make_color_rgb(255,252,235),dark);
        draw_sprite(object_get_sprite(processing_material_object(active_orders[i])),0,ox+24,121);
        frontend_text(ox+48,110,processing_material_name(active_orders[i]),fnt_ui_small,dark);
    }
    if(feedback_timer>0 && phase_state=="playing") {
        frontend_panel(160,652,960,30,make_color_rgb(255,252,235),dark);
        frontend_text(640,656,feedback,fnt_ui_small,dark,fa_center);
    }
    frontend_text(40,694,global.game_mode=="coop_local"?"J1: WASD | Shift: pegar/colocar | Ctrl: cortar/arremessar | Alt: dash   J2: Setas | Shift dir. | Ctrl dir. | Alt Gr: dash":"WASD: mover | Shift: pegar/colocar | Ctrl: cortar/arremessar | Alt: dash",fnt_ui_small,c_white);
    with(obj_recycling_player) if(stun_remaining>0) frontend_text(x,y-86,"Atordoada "+string(ceil(stun_remaining))+"s",fnt_ui_small,make_color_rgb(177,51,47),fa_center);
    if(phase_state!="playing") {
        draw_set_alpha(0.55);frontend_rect(0,0,1280,720,c_black);draw_set_alpha(1);
        frontend_panel(320,184,640,370,make_color_rgb(255,252,235),dark);
        frontend_text(640,217,phase_state=="won"?"Fase concluída!":"Fim da rodada",fnt_ui_title,dark,fa_center);
        frontend_text(640,296,result_reason,fnt_ui_small,dark,fa_center);
        frontend_text(640,335,"Pedidos: "+string(delivered_total)+" / "+string(minimum_goal)+"   Pontos: "+string(points_total),fnt_ui_body,dark,fa_center);
        for(var i=0;i<3;i++)recycling_draw_star(584+i*56,410,i<result_stars?make_color_rgb(233,178,55):make_color_rgb(186,190,177));
        frontend_panel(400,470,220,52,c_white,dark);frontend_panel(660,470,220,52,c_white,dark);
        frontend_text(510,482,"Tentar de novo",fnt_ui_body,dark,fa_center);frontend_text(770,482,"Mapa",fnt_ui_body,dark,fa_center);
    }
    draw_set_alpha(1);draw_set_font(-1);draw_set_color(c_white);draw_set_halign(fa_left);draw_set_valign(fa_top);
}
