/// Shared fullscreen shortcut and gameplay menu. Existing gameplay/network events stay intact.
function online_game() {
    return variable_global_exists("game_mode") && global.game_mode=="coop_online";
}

function online_key(_key,_kind) {
    if(online_game() && global.is_host && variable_instance_exists(id,"playerid") && playerid==2) {
        if(!variable_global_exists("online_input"))return false;
        var actions=["up","down","left","right","interact","action","dash"];
        for(var i=0;i<7;i++)if(frontend_keybinding("p2_"+actions[i])==_key) {
            var result=global.online_input[_kind][i];
            if(_kind>0)global.online_input[_kind][i]=false;
            return result;
        }
        return false;
    }
    if(_kind==1)return keyboard_check_pressed(_key);
    if(_kind==2)return keyboard_check_released(_key);
    return keyboard_check(_key);
}
function online_key_held(_key){return online_key(_key,0);}
function online_key_pressed(_key){return online_key(_key,1);}
function online_key_released(_key){return online_key(_key,2);}

function online_fields(_source,_names) {
    var result={};var names=string_split(_names,",");
    for(var i=0;i<array_length(names);i++)if(variable_instance_exists(_source,names[i])) {
        var value=variable_instance_get(_source,names[i]);
        if(!is_undefined(value))variable_struct_set(result,names[i],value);
    }
    return result;
}
function online_apply(_target,_data) {
    var names=variable_struct_get_names(_data);
    for(var i=0;i<array_length(names);i++)variable_instance_set(_target,names[i],variable_struct_get(_data,names[i]));
}
function online_station_index(_station) {
    if(!instance_exists(_station))return -1;
    var list=obj_recycling_level.stations;
    for(var i=0;i<array_length(list);i++)if(list[i]==_station)return i;
    return -1;
}
function online_payload(_data) {
    if(is_undefined(_data))return undefined;
    var result=processing_payload_new(_data.process_state,_data.amount);
    result.exposure_age=_data.exposure_age;result.burning=_data.burning;
    result.fire_progress=_data.fire_progress;
    return result;
}
function online_snapshot() {
    var level=obj_recycling_level;
    var state=online_fields(level,"phase_state,start_countdown,time_remaining,star_goals,minimum_goal,result_reason,result_stars,result_is_timeout,recycled_total,sorted_total,robot_total,delivered_total,points_total,overflow_elapsed,processing_frame,robot_departures,story_mode,story_age,story_line,story_lines,story_text,story_visible,tutorial_stage,tutorial_lesson,tutorial_fire_phase");
    state.result_age=current_time-level.result_started;
    state.level=level.level_index;state.stations=[];state.players=[];state.items=[];state.puddles=[];
    state.tutorial_counter=variable_instance_exists(level,"tutorial_fire_counter")?online_station_index(level.tutorial_fire_counter):-1;
    for(var i=0;i<array_length(level.stations);i++) {
        var station=level.stations[i];
        var data=online_fields(station,"load,queue,spawn_timer,overflow_elapsed,trip_remaining,process_status,process_progress,process_remaining,process_duration,tool_loaned,visible,tutorial_unlocked");
        var payload=station.station_kind=="handoff"?station.stored_item:station.buffer;
        data.payload=online_payload(payload);
        array_push(state.stations,data);
    }
    with(obj_recycling_player) {
        var data=online_fields(id,"x,y,move_dir,is_dashing,stun_remaining,image_index,image_xscale,throw_charge");
        data.playerid=playerid;array_push(state.players,data);
    }
    with(obj_process_item) {
        var data=online_fields(id,"x,y,process_state,item_kind,trash_type,amount,is_held,is_thrown,move_dir,throw_dir,throw_spd,throw_peak_spd,floor_age,exposure_age,burning,fire_progress,spray_active");
        data.object=object_get_name(object_index);
        data.owner=instance_exists(holder)?holder.playerid:0;
        data.rack=online_station_index(tool_owner);
        array_push(state.items,data);
    }
    with(obj_leachate)array_push(state.puddles,{x:x,y:y});
    state.completed=global.frontend_level_completed;state.stars=global.frontend_level_stars;
    return state;
}
function online_sync(_state) {
    if(!instance_exists(obj_recycling_level) || obj_recycling_level.level_index!=_state.level)return;
    var level=obj_recycling_level;
    // Only named gameplay fields can be copied; transport metadata never becomes instance state.
    var fields=string_split("phase_state,start_countdown,time_remaining,star_goals,minimum_goal,result_reason,result_stars,result_is_timeout,recycled_total,sorted_total,robot_total,delivered_total,points_total,overflow_elapsed,processing_frame,robot_departures,story_mode,story_age,story_line,story_lines,story_text,story_visible,tutorial_stage,tutorial_lesson,tutorial_fire_phase",",");
    for(var i=0;i<array_length(fields);i++)if(variable_struct_exists(_state,fields[i]))variable_instance_set(level,fields[i],variable_struct_get(_state,fields[i]));
    level.result_started=current_time-_state.result_age;
    if(array_length(_state.stations)!=array_length(level.stations))return;
    for(var i=0;i<array_length(_state.stations);i++) {
        var station=level.stations[i];var data=_state.stations[i];
        var payload=variable_struct_exists(data,"payload")?online_payload(data.payload):undefined;
        variable_struct_remove(data,"payload");online_apply(station,data);
        if(station.station_kind=="handoff")station.stored_item=payload;else station.buffer=payload;
    }
    if(_state.tutorial_counter>=0)level.tutorial_fire_counter=level.stations[_state.tutorial_counter];
    for(var i=0;i<array_length(_state.players);i++) {
        var data=_state.players[i];
        with(obj_recycling_player)if(playerid==data.playerid){online_apply(id,data);depth=-y;carried_item=noone;}
    }
    // Reuse replicas to preserve trails and avoid destroying/recreating every network frame.
    var replicas=[];with(obj_process_item)array_push(replicas,id);
    for(var i=0;i<array_length(_state.items);i++) {
        var data=_state.items[i];var object=asset_get_index(data.object);
        if(object<0 || !object_is_ancestor(object,obj_process_item))continue;
        var item=i<array_length(replicas)?replicas[i]:noone;
        if(instance_exists(item) && item.object_index!=object){instance_destroy(item);item=noone;}
        if(!instance_exists(item))item=instance_create_layer(data.x,data.y,"Items",object);
        var owner=data.owner,rack=data.rack;
        variable_struct_remove(data,"object");variable_struct_remove(data,"owner");variable_struct_remove(data,"rack");
        online_apply(item,data);item.depth=-item.y-2;
        item.holder=noone;item.tool_owner=rack>=0?level.stations[rack]:noone;
        with(obj_recycling_player)if(playerid==owner){item.holder=id;carried_item=item;}
    }
    for(var i=array_length(_state.items);i<array_length(replicas);i++)instance_destroy(replicas[i]);
    with(obj_leachate)instance_destroy();
    for(var i=0;i<array_length(_state.puddles);i++)instance_create_layer(_state.puddles[i].x,_state.puddles[i].y,"Items",obj_leachate);
    global.frontend_level_completed=_state.completed;global.frontend_level_stars=_state.stars;
}
function online_send(_message,_data) {
    if(!global.online_connected || global.client_socket==noone)return;
    var packet=buffer_create(4096,buffer_grow,1);
    buffer_write(packet,buffer_u8,_message);buffer_write(packet,buffer_string,json_stringify(_data));
    network_send_packet(global.client_socket,packet,buffer_tell(packet));buffer_delete(packet);
}
function online_receive(_message,_buffer) {
    try {
        var data=json_parse(buffer_read(_buffer,buffer_string));
        if(_message==20 && global.is_host && is_array(data) && array_length(data)==3) {
            if(!variable_global_exists("online_input"))global.online_input=[array_create(7,false),array_create(7,false),array_create(7,false)];
            for(var k=0;k<3;k++)for(var i=0;i<7;i++)global.online_input[k][i]=k==0?data[k][i]:(global.online_input[k][i] || data[k][i]);
            global.online_input_time=current_time;
        } else if(_message==21 && !global.is_host)online_sync(data);
    } catch(error){show_debug_message("Online packet rejected: "+string(error));}
}
function online_game_update() {
    if(!global.online_connected)return;
    if(global.is_host) {
        if(variable_global_exists("online_input_time") && current_time-global.online_input_time>500)global.online_input=[array_create(7,false),array_create(7,false),array_create(7,false)];
        if(!variable_instance_exists(id,"snapshot_time"))snapshot_time=0;
        if(current_time>=snapshot_time){snapshot_time=current_time+50;online_send(21,online_snapshot());}
    } else {
        var actions=["up","down","left","right","interact","action","dash"];
        var input=[[],[],[]];
        for(var i=0;i<7;i++) {
            var key=frontend_keybinding("p1_"+actions[i]);
            var blocked=instance_exists(obj_session_ui) && obj_session_ui.pause_open;
            array_push(input[0],!blocked && keyboard_check(key));array_push(input[1],!blocked && keyboard_check_pressed(key));array_push(input[2],!blocked && keyboard_check_released(key));
        }
        online_send(20,input);
    }
}

function session_music_update() {
    var playing = session_ui_is_gameplay();
    var dialogue = story_active();
    if (instance_exists(obj_recycling_level) && obj_recycling_level.phase_state != "playing") playing = false;
    var desired = playing ? mus_recycling_rush : mus_coleta_theme;
    if (desired != music_track) {
        music_track = desired;
        var exists=false;
        for(var i=0;i<array_length(music_voices);i++) if(music_voices[i].track==desired) exists=true;
        if(!exists) {
            var voice = audio_play_sound(desired, 0, true);
            audio_sound_gain(voice,0,0);
            array_push(music_voices,{handle:voice,track:desired,gain:0});
        }
    }
    var target_gain = pause_open ? 0.16 : (dialogue ? 0.2 : 0.5);
    var dt = min(0.1,max(0,delta_time/1000000));
    for(var i=array_length(music_voices)-1;i>=0;i--) {
        var entry=music_voices[i];
        var target=entry.track==desired?target_gain:0;
        entry.gain=lerp(entry.gain,target,1-exp(-dt*5));
        audio_sound_gain(entry.handle,entry.gain,0);
        if(target==0 && entry.gain<0.002) {
            audio_stop_sound(entry.handle);
            array_delete(music_voices,i,1);
        }
    }
}

function session_music_stop() {
    for(var i=0;i<array_length(music_voices);i++) audio_stop_sound(music_voices[i].handle);
    music_voices=[];
}

function session_ui_transition_active() {
    if (!variable_global_exists("ui_fade_phase")) return false;
    return global.ui_fade_phase != "idle";
}

function session_ui_change_room(_target) {
    if (session_ui_transition_active()) return;
    if (!instance_exists(obj_session_ui) || global.frontend_reduced_motion) {
        if (_target == room) room_restart(); else room_goto(_target);
        return;
    }
    global.ui_fade_room = _target;
    global.ui_fade_screen = "";
    global.ui_fade_phase = "out";
    global.ui_fade_progress = 0;
}

function session_ui_change_screen(_screen) {
    if (session_ui_transition_active()) return;
    if (global.frontend_reduced_motion) {
        with(obj_frontend) { screen = _screen; focus = 0; frontend_build_buttons(); }
        return;
    }
    global.ui_fade_room = room;
    global.ui_fade_screen = _screen;
    global.ui_fade_phase = "out";
    global.ui_fade_progress = 0;
}

function session_ui_draw_transition() {
    if (!session_ui_transition_active()) return;
    var t = clamp(global.ui_fade_progress,0,1);
    var eased = t*t*t*(t*(t*6-15)+10);
    var w = display_get_gui_width(), h = display_get_gui_height();
    var cover_x = global.ui_fade_phase == "out" ? -w-96+(w+96)*eased : (w+96)*eased;
    draw_set_alpha(1);
    // A coastal wipe travels in one direction across both screens.
    frontend_rect(cover_x,0,w+96,h,make_color_rgb(38,126,120));
    var edge = global.ui_fade_phase == "out" ? cover_x+w+96 : cover_x;
    var stripe_direction = global.ui_fade_phase == "out" ? -1 : 1;
    frontend_rect(edge+stripe_direction*40,0,16,h,make_color_rgb(164,215,191));
    frontend_rect(edge+stripe_direction*18,0,8,h,make_color_rgb(248,235,195));
    draw_set_alpha(1);draw_set_color(c_white);
    global.ui_fade_progress += min(0.05,max(0,delta_time/1000000))/0.36;
    if (t < 1) return;
    if (global.ui_fade_phase == "out") {
        global.ui_fade_phase = "in";global.ui_fade_progress = 0;
        if (global.ui_fade_screen != "") {
            with(obj_frontend) { screen = global.ui_fade_screen; focus = 0; frontend_build_buttons(); }
        } else if (global.ui_fade_room == room) room_restart();
        else room_goto(global.ui_fade_room);
    } else global.ui_fade_phase = "idle";
}

function session_ui_is_gameplay() {
    return room != rm_main_menu && room != rm_game_mode
        && room != rm_character_select && room != rm_level_select
        && room != rm_options && room != rm_menu && room != rm_save_select;
}

function session_ui_toggle_fullscreen() {
    window_set_fullscreen(!window_get_fullscreen());
}

function session_ui_no_input() {
    // Keep local ownership and networking active while the LAN menu is open.
}

function session_ui_open_menu() {
    if (pause_open || !session_ui_is_gameplay()) return;
    pause_open = true;
    pause_focus = 0;
    frozen_offline = !variable_global_exists("game_mode") || global.game_mode != "coop_online";
    if (frozen_offline) {
        if (surface_exists(application_surface)) {
            pause_snapshot = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
            if (surface_exists(pause_snapshot)) surface_copy(pause_snapshot, 0, 0, application_surface);
        }
        instance_deactivate_all(true);
    } else {
        blocked_players = [];
        with (obj_player) {
            if (is_local && playerid==(global.is_host?1:2)) {
                array_push(other.blocked_players, {player: id, behavior: estado});
                estado = session_ui_no_input;
            }
        }
    }
}

function session_ui_close_menu() {
    if (!pause_open) return;
    if (frozen_offline) {
        instance_activate_all();
    } else {
        for (var i = 0; i < array_length(blocked_players); i++) {
            var entry = blocked_players[i];
            if (instance_exists(entry.player)) entry.player.estado = entry.behavior;
        }
    }
    blocked_players = [];
    if (surface_exists(pause_snapshot)) surface_free(pause_snapshot);
    pause_snapshot = -1;
    pause_open = false;
    frozen_offline = false;
}

function session_ui_return_to_title() {
    session_ui_close_menu();
    // Leaving a LAN session closes its existing handles; no packet/protocol changes.
    if (variable_global_exists("game_mode") && global.game_mode == "coop_online") {
        if (variable_global_exists("client_socket")) {
            if (global.client_socket >= 0) network_destroy(global.client_socket);
            global.client_socket = noone;
        }
        if (variable_global_exists("server")) {
            if (global.server >= 0) network_destroy(global.server);
            global.server = noone;
        }
    }
    global.game_mode = "solo";
    global.frontend_network_entry = false;
    room_goto(rm_main_menu);
}

function session_ui_update() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    if (keyboard_check_pressed(vk_f11)) {
        session_ui_toggle_fullscreen();
        return;
    }
    if (session_ui_transition_active()) return;
    if (!session_ui_is_gameplay()) return;
    // The finished round owns its result-screen input; F11 above remains available.
    if (instance_exists(obj_recycling_level) && obj_recycling_level.phase_state != "playing") return;
    if (keyboard_check_pressed(frontend_keybinding("pause"))) {
        if (pause_open) session_ui_close_menu();
        else session_ui_open_menu();
        return;
    }
    if (!pause_open) return;

    var panel_x = (gui_w - 360) / 2;
    var panel_y = (gui_h - 280) / 2;
    var moved = abs(mx - pause_pointer_x) + abs(my - pause_pointer_y) > 1;
    pause_pointer_x = mx;
    pause_pointer_y = my;
    var hovered = -1;
    for (var i = 0; i < 2; i++) {
        var by = panel_y + 100 + i * 76;
        if (point_in_rectangle(mx, my, panel_x + 32, by, panel_x + 328, by + 52)) hovered = i;
    }
    if (moved && hovered >= 0) pause_focus = hovered;
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)
        || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("S"))
        || keyboard_check_pressed(vk_tab)) pause_focus = 1 - pause_focus;
    var activate = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
    if (mouse_check_button_pressed(mb_left) && hovered >= 0) {
        pause_focus = hovered;
        activate = true;
    }
    if (activate) {
        if (pause_focus == 0) session_ui_close_menu();
        else session_ui_return_to_title();
    }
}

function session_ui_draw() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var color_ink = make_color_rgb(36, 41, 40);
    var color_focus = make_color_rgb(234, 240, 236);
    if(online_game() && variable_global_exists("online_connected") && !global.online_connected && instance_exists(obj_recycling_level)) {
        frontend_panel(300,108,680,60,make_color_rgb(248,240,213),color_ink);
        frontend_text(640,120,"Conexão interrompida. Esc para abrir o menu.",fnt_ui_body,color_ink,fa_center);
    }
    draw_set_alpha(1);
    if (pause_open) {
        if (frozen_offline) {
            if (surface_exists(pause_snapshot)) {
                draw_set_color(c_white);
                draw_surface_stretched(pause_snapshot, 0, 0, gui_w, gui_h);
            } else frontend_rect(0, 0, gui_w, gui_h, c_white);
        }
        draw_set_alpha(0.45);
        frontend_rect(0, 0, gui_w, gui_h, c_black);
        draw_set_alpha(1);
        var panel_x = (gui_w - 360) / 2;
        var panel_y = (gui_h - 280) / 2;
        frontend_panel(panel_x, panel_y, 360, 280, c_white, color_ink);
        frontend_text(gui_w / 2, panel_y + 32, frozen_offline ? "Pausado" : "Menu", fnt_ui_body, color_ink, fa_center);
        var labels = ["Continuar", "Tela inicial"];
        for (var i = 0; i < 2; i++) {
            var by = panel_y + 100 + i * 76;
            frontend_panel(panel_x + 32, by, 296, 52, pause_focus == i ? color_focus : c_white, color_ink);
            frontend_text(gui_w / 2, by + 12, labels[i], fnt_ui_body, color_ink, fa_center);
        }
    }
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
