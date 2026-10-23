/// Campaign dialogue and sprite-based finale. All state belongs to the level controller.
function story_active() {
    return instance_exists(obj_recycling_level) && variable_instance_exists(obj_recycling_level,"story_mode") && obj_recycling_level.story_mode != "none";
}

function story_init() {
    story_blip = -1;
    story_mode = "none";
    story_age = 0;
    story_line = 0;
    story_lines = [];
    if (level_index == 0) story_begin("intro");
    if (level_index == 1) story_begin("robots");
}

function story_begin(_chapter) {
    story_mode = _chapter;
    story_age = 0;
    story_line = 0;
    switch (_chapter) {
        case "intro": story_lines = [
            ["Ju", "Depois da temporada, olhem a nossa cidade! Os monstros... quer dizer, os humanos... deixaram lixo por toda parte!"],
            ["Lê", "Esses resíduos estão machucando a natureza. Precisamos cuidar de Caraguá!"],
            ["Manu", "Vamos separar os materiais e dar um destino certo a cada um."],
            ["Maria", "E usar a nossa ciência para construir robôs que ajudem na limpeza. Vamos juntas!"]]; break;
        case "robots": story_lines = [
            ["Manu", "Recuperamos componentes eletrônicos! Já sei como transformar essas peças em ajuda."],
            ["Maria", "Nossa bancada científica está pronta. Com os componentes recuperados, podemos montar robôs!"],
            ["Ju", "Eles vão automatizar o trabalho repetitivo. Assim conseguimos cuidar de mais lugares."],
            ["Lê", "Quatro cientistas, muitas ideias e uma cidade para transformar. Ciência também é trabalho em equipe!"]]; break;
        case "ending": story_lines = [
            ["Ju", "Ufa! Deu muito trabalho, mas conseguimos!"],
            ["Maria", "Cada material separado e cada peça recuperada fizeram a diferença."],
            ["Lê", "Nossa inteligência e nossas invenções viraram uma equipe de robôs!"],
            ["Manu", "Agora eles ajudam a manter a praia limpa. Deu tudo certo, meninas!"]]; break;
    }
    story_prepare_text();
}

function story_advance() {
    story_stop_blip();
    story_age = 0;
    if (story_mode == "beach") {
        story_mode = "none";
        result_started = current_time;
        result_is_timeout = false;
        return;
    }
    story_line++;
    if (story_line >= array_length(story_lines)) {
        if (story_mode == "ending") story_mode = "beach";
        else story_mode = "none";
    }
    if (story_mode != "none" && story_mode != "beach") story_prepare_text();
}

function story_stop_blip() {
    if (variable_instance_exists(id,"story_blip") && story_blip != -1) audio_stop_sound(story_blip);
    story_blip = -1;
}

function story_prepare_text() {
    story_stop_blip();
    // Wrap the complete sentence first, keeping words stationary as letters appear.
    var previous_font=draw_get_font();
    draw_set_font(fnt_ui_body);
    var words=string_split(story_lines[story_line][1]," ");
    var row="";
    story_text="";
    for(var i=0;i<array_length(words);i++) {
        var candidate=row==""?words[i]:row+" "+words[i];
        if(row!="" && string_width(candidate)>864) {
            story_text+=row+"\n";
            row=words[i];
        } else row=candidate;
    }
    story_text+=row;
    draw_set_font(previous_font);
    story_visible=global.frontend_reduced_motion?string_length(story_text):0;
    story_type_accumulator=0;
    story_type_wait=0;
    story_blip_wait=0;
}

function story_type_tick(_dt) {
    if (story_mode=="beach" || story_mode=="none") return;
    var length=string_length(story_text);
    if(global.frontend_reduced_motion) { story_visible=length;return; }
    story_blip_wait=max(0,story_blip_wait-_dt);
    story_type_wait=max(0,story_type_wait-_dt);
    if(story_type_wait>0 || story_visible>=length) return;
    story_type_accumulator+=_dt*42;
    var audible=false;
    while(story_type_accumulator>=1 && story_visible<length) {
        story_type_accumulator--;
        story_visible++;
        var letter=string_char_at(story_text,story_visible);
        if(letter!=" " && letter!="\n" && string_pos(letter,",.!?;:")==0) audible=true;
        if(string_pos(letter,",.!?;:")>0) {
            story_type_wait=(letter=="," || letter==";" || letter==":")?0.08:0.16;
            story_type_accumulator=0;
            break;
        }
    }
    if(audible && story_blip_wait<=0) {
        story_stop_blip();
        story_blip=audio_play_sound(snd_dialogue_blip,1,false);
        audio_sound_pitch(story_blip,0.95+(story_line mod 4)*0.06);
        story_blip_wait=0.065;
    }
}

function story_continue() {
    if(story_mode!="beach" && story_visible<string_length(story_text)) {
        story_visible=string_length(story_text);
        story_stop_blip();
    } else story_advance();
}

function story_update(_dt) {
    if (!story_active()) return false;
    story_age += min(0.1,_dt);
    story_type_tick(min(0.1,max(0,_dt)));
    var clicked = mouse_check_button_pressed(mb_left) && point_in_rectangle(device_mouse_x_to_gui(0),device_mouse_y_to_gui(0),960,620,1200,676);
    var advance = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || clicked;
    if (story_age > 0.25 && advance && (story_mode != "beach" || story_age >= 10)) story_continue();
    return true;
}

function story_draw() {
    if (!story_active()) return;
    var level = obj_recycling_level;
    var dark = make_color_rgb(35,57,64);
    if (level.story_mode == "beach") {
        draw_sprite_stretched(spr_story_beach,0,0,0,1280,720);
        var age = level.story_age;
        var reduced = global.frontend_reduced_motion;
        for (var i=0;i<4;i++) {
            var start = i*1.8;
            var progress = clamp((age-start)/2.5,0,1);
            var target_x = 260+i*240;
            var target_y = 380+(i mod 2)*100;
            if (progress<0.8) {
                var waste = object_get_sprite(processing_material_object(i mod 2 == 0 ? "sorted_plastic" : "sorted_paper"));
                draw_sprite_ext(waste,0,target_x,target_y,1.5,1.5,0,c_white,1);
            }
            var travel = progress<0.8 ? progress/0.8 : 1+(progress-0.8)*2;
            var robot_x = reduced ? target_x : lerp(target_x-180,target_x,travel);
            var robot_y = target_y+(reduced?0:sin(age*10+i)*2);
            draw_sprite_ext(spr_robot,0,robot_x,robot_y,2,2,0,c_white,1);
        }
        frontend_panel(300,36,680,74,make_color_rgb(255,252,235),dark);
        frontend_text(640,60,age<9 ? "A ciência cuida de Caraguá!" : "Juntas, fizemos a diferença!",fnt_ui_body,dark,fa_center);
        if(age>=10) {
            frontend_stone_button(960,620,240,56,true);
            frontend_text(1080,633,"Continuar",fnt_ui_body,dark,fa_center);
        }
    } else {
        draw_set_alpha(0.35);frontend_rect(0,0,1280,720,c_black);draw_set_alpha(1);
        frontend_panel(64,438,1152,252,make_color_rgb(255,252,235),dark);
        var line = level.story_lines[level.story_line];
        var names = ["Ju","Lê","Manu","Maria"];
        var index = 0;
        for(var i=0;i<4;i++)if(names[i]==line[0])index=i;
        frontend_panel(92,478,136,136,make_color_rgb(239,233,214),dark);
        var portraits=[spr_portrait_ju,spr_portrait_le,spr_portrait_manu,spr_portrait_maria];
        draw_sprite_ext(portraits[index],0,160,546,2,2,0,c_white,1);
        frontend_text(268,460,line[0],fnt_dialogue_name,dark);
        draw_set_font(fnt_ui_body);draw_set_color(dark);draw_set_halign(fa_left);draw_set_valign(fa_top);
        draw_text_ext(264,548,string_copy(level.story_text,1,level.story_visible),30,864);
        frontend_stone_button(960,620,240,56,true);
        frontend_text(1080,633,level.story_visible<string_length(level.story_text)?"Mostrar tudo":"Continuar",fnt_ui_body,dark,fa_center);
    }
    draw_set_alpha(1);draw_set_color(c_white);draw_set_halign(fa_left);draw_set_valign(fa_top);
}

function frontend_stone_button(_x,_y,_w,_h,_active) {
    var pressed = _active && mouse_check_button(mb_left) && point_in_rectangle(device_mouse_x_to_gui(0),device_mouse_y_to_gui(0),_x,_y,_x+_w,_y+_h);
    draw_sprite_stretched_ext(spr_ui_stone_button,0,_x,_y+(pressed?3:0),_w,_h,_active?c_white:make_color_rgb(220,220,220),draw_get_alpha());
}

function processing_draw_intake_popups() {
    if (!processing_enabled || phase_state != "playing") return;
    var camera = view_camera[0];
    for(var i=0;i<array_length(stations);i++) {
        var station = stations[i];
        if (!instance_exists(station) || station.station_kind != "intake") continue;
        if (variable_instance_exists(station,"tutorial_unlocked") && !station.tutorial_unlocked) continue;
        if (!processing_station_near(station,28)) continue;
        var px = clamp((station.x-camera_get_view_x(camera))*1280/camera_get_view_width(camera),100,1180);
        var py = max(102,(station.y-camera_get_view_y(camera))*720/camera_get_view_height(camera)-100);
        var count = array_length(station.queue);
        var full = count >= station.capacity;
        var ink = full?make_color_rgb(177,51,47):make_color_rgb(38,117,104);
        frontend_panel(px-96,py,192,64,make_color_rgb(255,252,235),ink);
        frontend_text(px,py+6,"Caçamba "+string(count)+"/"+string(station.capacity),fnt_ui_small,ink,fa_center);
        frontend_text(px,py+32,full?"Cheia!":"Há espaço",fnt_ui_body,ink,fa_center);
    }
}
