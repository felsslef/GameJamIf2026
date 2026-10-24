ticks++;if(ticks<12)exit;
function check(_ok,_label){show_debug_message((_ok?"PASS: ":"FAIL: ")+_label);if(!_ok)global.probe_failed=true;}
function pause_key(_key){global.keys_pressed=[_key];with(obj_session_ui)session_ui_update();global.keys_pressed=[];}
var level=instance_find(obj_recycling_level,0);
if(stage==0){
    check(!save_slot_load(0) && !save_slot_exists(0),"loading empty slot cannot create a save without difficulty selection");
    with(obj_frontend)frontend_activate({action:"save_load",value:1});
    with(obj_frontend)check(screen=="difficulty" && pending_new_slot==1,"empty save opens difficulty selection");
    check(!save_slot_exists(1),"opening difficulty screen has not created a save");
    stage=1;ticks=0;exit;
}
if(stage==1){
    screen_save(working_directory+"difficulty-selection.png");
    with(obj_frontend){frontend_back();check(screen=="saves" && pending_new_slot==-1,"back cancels save creation");}
    check(!save_slot_exists(1),"cancel leaves slot empty");
    with(obj_frontend){frontend_activate({action:"save_new",value:1});frontend_activate({action:"choose_difficulty",value:"medium"});}
    stage=2;ticks=0;exit;
}
if(stage==2){
    check(room==rm_character_select && global.frontend_save_slot==1,"choosing difficulty creates save and opens characters");
    check(save_slot_difficulty(1)=="medium" && global.frontend_difficulty=="medium","medium is persisted in its slot");
    check(!save_slot_new(1,"hard"),"new-save API cannot overwrite existing difficulty");
    global.frontend_difficulty="hard";
    check(save_slot_write() && save_slot_difficulty(1)=="medium" && global.frontend_difficulty=="medium","autosave preserves immutable slot difficulty");
    check(save_slot_new(0,"easy") && save_slot_new(2,"hard"),"different slots can use easy and hard");
    global.frontend_difficulty="easy";
    check(save_slot_load(2) && global.frontend_difficulty=="hard","loading restores hard difficulty");
    room_goto(rm_save_select);stage=3;ticks=0;exit;
}
if(stage==3){
    screen_save(working_directory+"save-difficulties.png");
    with(obj_frontend)frontend_activate({action:"save_load",value:1});
    stage=4;ticks=0;exit;
}
if(stage==4){
    check(room==rm_character_select && global.frontend_difficulty=="medium","continue skips difficulty screen and restores medium");
    room_goto(rm_options);stage=5;ticks=0;exit;
}
if(stage==5){
    with(obj_frontend){
        frontend_activate({action:"colorblind"});
        check(global.frontend_colorblind,"accessibility option enables colorblind markers");
        global.frontend_colorblind=false;global.frontend_accessibility_ready=false;frontend_accessibility_init();
        check(global.frontend_colorblind,"colorblind preference reloads from disk");
    }
    check(save_slot_difficulty(1)=="medium","accessibility settings do not change save difficulty");
    stage=6;ticks=0;exit;
}
if(stage==6){
    screen_save(working_directory+"colorblind-settings.png");
    room_goto(rm_level_01);stage=7;ticks=0;exit;
}
if(stage==7){
    check(level.difficulty=="medium" && level.minimum_goal==5 && level.star_goals[1]==8 && level.star_goals[2]==11,"medium increases all first-phase targets by fifty percent with rounding");
    check(level.fire_failure_time==20 && level.time_remaining>100,"difficulty preserves time and fire rules");
    for(var type=0;type<4;type++){
        check(recycling_material_type("sorted_"+["paper","plastic","glass","metal"][type])==type,"material marker identifies sorted material "+string(type));
        check(recycling_material_type("bag_"+["paper","plastic","glass","metal"][type])==type,"bag marker matches corresponding bin "+string(type));
    }
    check(recycling_material_type("organic")==-1,"other materials do not receive wrong recycling markers");
    with(obj_recycling_level){for(var i=0;i<array_length(dispensers);i++)dispensers[i].spawn_timer=10000;}
    stage=8;ticks=0;exit;
}
if(stage==8){
    screen_save(working_directory+"colorblind-gameplay.png");
    with(level){delivered_total=4;recycled_total=4;time_remaining=0;processing_tick(0);}
    check(level.phase_state=="lost","old easy target cannot win a medium save");
    with(level){phase_state="playing";delivered_total=5;recycled_total=5;processing_tick(0);}
    check(level.phase_state=="won" && level.result_stars==1 && save_slot_difficulty(1)=="medium","medium target wins and saves progress at same difficulty");
    check(save_slot_load(1) && global.frontend_level_completed[0],"medium completion survives reload");
    room_goto(rm_level_01);stage=9;ticks=0;exit;
}
if(stage==9){
    check(level.minimum_goal==5 && level.star_goals[2]==11,"replaying does not multiply difficulty targets twice");
    // The paused settings use the same persisted preference without touching the save.
    with(obj_session_ui)session_ui_open_menu();instance_activate_object(id);
    pause_key(vk_down);pause_key(vk_enter);
    with(obj_session_ui){check(pause_settings,"pause opens settings");frontend_activate({action:"colorblind"});}
    check(!global.frontend_colorblind && save_slot_difficulty(1)=="medium","colorblind toggle applies during pause and preserves difficulty");
    with(obj_session_ui){frontend_back();session_ui_close_menu();}
    check(save_slot_load(0),"easy save opens independently");
    room_goto(rm_level_01);stage=10;ticks=0;exit;
}
if(stage==10){
    check(level.minimum_goal==3 && level.star_goals[1]==5 && level.star_goals[2]==7,"easy retains original first-phase targets");
    check(save_slot_load(2),"hard save opens independently");
    room_goto(rm_level_01);stage=11;ticks=0;exit;
}
if(stage==11){
    check(level.minimum_goal==6 && level.star_goals[1]==10 && level.star_goals[2]==14,"hard doubles first-phase targets");
    var snapshot=json_parse(json_stringify(online_snapshot()));
    level.difficulty="easy";level.minimum_goal=3;online_sync(snapshot);
    check(level.difficulty=="hard" && level.minimum_goal==6,"network snapshot preserves host difficulty and goals");
    // Old saves have no difficulty key and must migrate to easy without losing progress.
    save_slot_delete(0);
    ini_open(save_slot_filename(0));ini_write_real("save","version",2);ini_write_real("completed","0",1);ini_write_real("stars","0",2);ini_close();
    check(save_slot_load(0) && global.frontend_difficulty=="easy" && global.frontend_level_completed[0] && global.frontend_level_stars[0]==2,"old save migrates to easy and retains stars");
    check(save_slot_write() && save_slot_difficulty(0)=="easy","migrated save writes a stable difficulty");
    global.frontend_save_slot=-1;global.frontend_difficulty="hard";
    room_goto(rm_tutorial);stage=12;ticks=0;exit;
}
if(stage==12){
    check(level.minimum_goal==7 && level.star_goals[2]==7,"tutorial targets stay unchanged on hard");
    check(!level.tutorial_dash_done && tutorial_guidance().action=="dash","tutorial gates progress on actual dash");
    check(frontend_keybinding_set("p1_dash",ord("F")),"dash key can be remapped");
    global.frontend_double_tap_dash=false;
    check(string_pos("F",tutorial_controls_hint("dash",""))>0 && string_pos("duas vezes",tutorial_controls_hint("dash",""))==0,"dash instructions respect remapping and disabled double tap");
    stage=13;ticks=0;exit;
}
if(stage==13){
    screen_save(working_directory+"tutorial-dash.png");
    var player=instance_find(obj_recycling_player,0);
    player.x=640;player.y=480;
    global.keys_held=[frontend_keybinding("p1_right")];global.keys_pressed=[];
    with(player)recycling_player_step();with(level)tutorial_tick(0);
    check(!level.tutorial_dash_done && array_length(level.dispenser.queue)==0,"walking cannot bypass dash lesson");
    global.keys_pressed=[ord("F")];with(player)recycling_player_step();
    global.keys_held=[];global.keys_pressed=[];
    check(level.tutorial_dash_done,"remapped dash performs real movement and completes lesson");
    level.tutorial_dash_done=false;
    player.is_dashing=false;player.dash_cooldown=0;player.last_tap_direction=-1;player.last_tap_elapsed=1;
    global.frontend_double_tap_dash=true;
    global.keys_held=[frontend_keybinding("p1_right")];global.keys_pressed=[frontend_keybinding("p1_right")];
    with(player)recycling_player_step();
    global.keys_held=[];global.keys_pressed=[];with(player)recycling_player_step();
    check(!level.tutorial_dash_done,"single direction tap does not finish dash lesson");
    global.keys_held=[frontend_keybinding("p1_right")];global.keys_pressed=[frontend_keybinding("p1_right")];
    with(player)recycling_player_step();global.keys_held=[];global.keys_pressed=[];
    check(level.tutorial_dash_done,"double direction tap also completes practical dash lesson");
    // Check every campaign phase using the room's original targets as the baseline.
    goal_room=0;goal_mode=0;
    save_slot_load(0);room_goto(rm_level_01);stage=20;ticks=0;exit;
}
if(stage==20){
    var expected=[[3,5,7],[4,6,8],[5,7,9],[6,8,10],[7,9,12]][goal_room];
    var multiplier=[1,1.5,2][goal_mode];
    for(var i=0;i<3;i++)check(level.star_goals[i]==ceil(expected[i]*multiplier),"campaign phase "+string(goal_room+1)+" target "+string(i+1)+" difficulty "+string(goal_mode));
    goal_room++;
    if(goal_room>=5){goal_room=0;goal_mode++;if(goal_mode<3)save_slot_load(goal_mode);}
    if(goal_mode>=3){
        for(var slot=0;slot<3;slot++)save_slot_delete(slot);
        if(file_exists(working_directory+"probe_controls.ini"))file_delete(working_directory+"probe_controls.ini");
        show_debug_message(global.probe_failed?"PROGRESSION_PROBE_FAILED":"PROGRESSION_PROBE_PASSED");game_end();exit;
    }
    var rooms=[rm_level_01,rm_level_02,rm_level_03,rm_level_04,rm_level_05];room_goto(rooms[goal_room]);ticks=0;exit;
}
