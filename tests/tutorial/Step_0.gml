ticks++;
if (!variable_global_exists("probe_released")) { global.keys_released=[];global.probe_released=function(_key){return array_contains(global.keys_released,_key);}; }
if (ticks < 7) exit;
function check(_ok, _label) {
    show_debug_message((_ok ? "PASS: " : "FAIL: ") + _label);
    if (!_ok) global.probe_failed = true;
}
function approach(_player, _station) {
    if (!instance_exists(_station)) return false;
    for (var dx=-160; dx<=160; dx+=8) for (var dy=-160; dy<=160; dy+=8) {
        var px=_station.x+dx, py=_station.y+dy;
        if (recycling_position_clear(px,py)) {
            _player.x=px; _player.y=py;
            if (recycling_nearest_station(_player)==_station) return true;
        }
    }
    return false;
}
function guided_tick(_dt=0) { with (obj_recycling_level) recycling_level_tick(_dt); }
function interact_at(_player, _station) {
    guided_tick();
    check(approach(_player,_station), "guided station accessible");
    recycling_interact(_player);
    guided_tick();
}
if (stage==0 || stage==5) {
    var ui=instance_find(obj_frontend,0);
    check(room==rm_character_select, "character selection opened");
    with (ui) {
        check(character_player_count==(other.stage==0?1:2), "correct character card count");
        frontend_character_flip(0);
        check(character_slots[0].back, "biography can still be read");
        frontend_character_toggle_ready(0);
        if (other.stage==5) {
            check(!character_starting && character_slots[0].ready, "co-op waits for both selections");
            frontend_character_toggle_ready(1);
        }
        check(character_starting, "selection team ready");
    }
    stage++; ticks=0; exit;
}
if (stage==1 || stage==3 || stage==6) {
    check(room==rm_level_select && !instance_exists(obj_recycling_level), "characters and results open map instead of entering a phase");
    var ui=instance_find(obj_frontend,0);
    with (ui) {
        check(array_length(buttons)==8 && buttons[0].value==-1, "map has tutorial plus five campaign stops");
        check(frontend_level_is_available(-1) && frontend_level_is_available(0), "tutorial replay and first phase available independently");
        if (other.stage==3) {
            check(global.frontend_tutorial_completed && !global.frontend_level_completed[0], "tutorial completion does not complete first campaign phase");
            check(!frontend_level_is_available(1), "tutorial does not unlock second campaign phase");
            screen_save(working_directory+"tutorial-map.png");
        }
        frontend_activate({action:"level",value:other.stage==3?0:-1});
        frontend_activate({action:"start"});
    }
    stage++; ticks=0; exit;
}
var level=instance_find(obj_recycling_level,0), player=instance_find(obj_recycling_player,0);
if (stage==2) {
    check(room==rm_tutorial && level.level_index==-1 && level.processing_enabled, "separate tutorial uses shared mixed processing mechanics");
    check(array_length(level.bins)==4 && instance_exists(obj_sorting_table), "tutorial contains editor-placed bins and treatment machines");
    var before=level.time_remaining;
    guided_tick(10000);
    check(level.time_remaining==before && level.tutorial_stage==0 && array_length(level.dispenser.queue)==0, "guided lesson waits for action without timer or automatic spawn");
    check(!obj_washer.visible && !instance_exists(obj_hydraulic_press), "advanced machines introduced later and press removed");
    check(!level.tutorial_dash_done && tutorial_guidance().action=="dash", "tutorial begins with a practical dash lesson");
    with(player){x=640;y=480;recycling_player_movement(1/60,1,0,false);}
    guided_tick();
    check(!level.tutorial_dash_done && array_length(level.dispenser.queue)==0, "walking alone does not finish dash lesson");
    global.keys_held=[frontend_keybinding("p1_right")];global.keys_pressed=[frontend_keybinding("p1_dash")];
    with(player)recycling_player_step();global.keys_held=[];global.keys_pressed=[];
    check(level.tutorial_dash_done, "configured dash key finishes practical dash lesson");
    check(approach(player,level.dispenser), "first movement target accessible");
    guided_tick();
    check(level.dispenser.queue[0]=="sorted_paper", "first lesson supplies identifiable paper");
    global.keys_pressed=[frontend_keybinding("p1_interact")];
    with (player) recycling_player_step();
    global.keys_pressed=[]; guided_tick();
    check(player.carried_item.process_state=="sorted_paper", "configured pickup button takes the displayed item");
    check(obj_bin_paper.visible && !obj_washer.visible, "first delivery reveals only relevant bin");
    stage=21; ticks=0; exit;
}
if (stage==21) {
    screen_save(working_directory+"tutorial-step.png");
    // Complete all four legacy bin/bag paths through the real interaction handlers.
    for (var lesson=0; lesson<4; lesson++) {
        if (!instance_exists(player.carried_item)) interact_at(player,level.dispenser);
        check(player.carried_item.process_state==level.tutorial_lessons[lesson].source, "source preview and carried material match");
        var bin=tutorial_station("bin",lesson);
        if (lesson==1) {
            approach(player,tutorial_station("bin",0)); recycling_interact(player);
            check(instance_exists(player.carried_item) && level.delivered_total==1, "wrong bin preserves material and lesson");
        }
        interact_at(player,bin);
        check(bin.load==1 && level.delivered_total==lesson, "bin fills without prematurely awarding a delivery");
        interact_at(player,bin);
        check(player.carried_item.process_state==level.tutorial_lessons[lesson].result && player.carried_item.amount==1 && bin.load==0, "empty hands collect matching filled bag");
        interact_at(player,level.truck);
        if (lesson==0) {
            check(level.tutorial_lesson==0 && level.tutorial_dispatch_phase=="send", "first delivery waits for manual truck dispatch");
            check(tutorial_guidance().target==level.truck && tutorial_guidance().verb=="despachar o caminhão", "tutorial points to truck with contextual dispatch action");
            check(!instance_exists(player.carried_item) && level.truck.load==1, "truck is loaded and player has empty hands for dispatch");
            guided_tick(10);
            check(level.tutorial_lesson==0 && level.truck.trip_remaining==0, "waiting alone cannot skip manual dispatch");
            interact_at(player,level.truck);
            check(level.truck.trip_remaining>0 && level.tutorial_dispatch_phase=="return", "empty-hand interaction actually dispatches truck");
            check(tutorial_guidance().action=="wait", "tutorial explains waiting for truck return");
            guided_tick(level.truck.return_duration+0.01);
            check(level.tutorial_dispatch_done && level.truck.load==0 && level.truck.trip_remaining==0, "truck returns before next material is supplied");
        }
        check(level.delivered_total==lesson+1 && level.tutorial_lesson==lesson+1, "bag counts delivery and unlocks next lesson");
    }
    // The same intake now feeds raw sacks into each of the new treatment paths.
    for (var lesson=4; lesson<7; lesson++) {
        interact_at(player,level.dispenser);
        check(player.carried_item.process_state=="raw_waste", "same intake introduces mixed waste after separation");
        interact_at(player,tutorial_station("sorting"));
        var sorting=tutorial_station("sorting");
        check(tutorial_guidance().action=="interact", "manual work has contextual hold-action hint");
        global.keys_held=[frontend_keybinding("p1_interact")];
        with (player) recycling_player_step();
        global.keys_held=[];
        check(sorting.process_progress>0, "configured held action works during guided tutorial");
        guided_tick(); processing_player_action(player,true,false,2.01); guided_tick();
        check(sorting.process_status=="ready", "manual triage completes progressively");
        interact_at(player,sorting);
        var result=player.carried_item.process_state;
        check(result==level.tutorial_lessons[lesson].sorted, "guided triage introduces chosen treatment material");
        var machine_kind = "dismantler";
        if (lesson == 4) machine_kind = "washer";
        if (lesson == 5) machine_kind = "biodigester";
        var machine = tutorial_station(machine_kind);
        interact_at(player,machine);
        if (lesson==6) { guided_tick(); processing_player_action(player,true,false,2.51); }
        else {
            var process_seconds = (lesson == 4) ? 3.01 : 4.01;
            guided_tick(process_seconds);
        }
        guided_tick();
        check(machine.process_status=="ready", "treatment uses real duration or held work");
        interact_at(player,machine);
        check(!instance_exists(obj_hydraulic_press), "processed materials need no press");
        if (lesson==6) {
            check(player.carried_item.process_state=="metal_plate", "dismantling recovers robot components");
            guided_tick();
            check(tutorial_guidance().target==tutorial_station("bench"), "guided assembly points to scientific bench");
            interact_at(player,tutorial_station("bench"));
            guided_tick(3.01);
            check(level.robot_total==1 && !instance_exists(player.carried_item), "tutorial robot leaves automatically");
            check(is_undefined(tutorial_station("bench").buffer), "automatic departure frees tutorial bench");
            check(level.delivered_total==lesson+1, "automatic robot departure completes lesson");
            continue;
        }
        check(player.carried_item.process_state==level.tutorial_lessons[lesson].result, "processed output matches lesson goal");
        interact_at(player,level.truck);
        check(level.delivered_total==lesson+1, "processed item fulfills shared truck delivery");
    }
    check(level.phase_state=="playing" && level.tutorial_fire_phase=="warning", "tutorial waits for practical firefighting after seven deliveries");
    var fire_counter=level.tutorial_fire_counter;
    check(processing_warning_remaining(fire_counter.stored_item,false)==2,"guided electronic displays warning before fire");
    check(string_pos(string(level.fire_failure_time)+"s",tutorial_guidance().text)>0 && string_pos("fase acaba",tutorial_guidance().text)>0,"tutorial explains fire deadline and defeat before ignition");
    guided_tick(1);
    check(!fire_counter.stored_item.burning,"warning gives time before ignition");
    guided_tick(1.01);
    var rack=tutorial_station("extinguisher_rack");
    check(fire_counter.stored_item.burning && rack.visible && rack.tutorial_unlocked,"guided fire reveals real extinguisher");
    interact_at(player,rack);
    check(player.carried_item.process_state=="extinguisher","player collects extinguisher in tutorial");
    check(approach(player,fire_counter),"tutorial fire is reachable");
    guided_tick();processing_player_action(player,true,false,level.extinguish_duration/2);
    check(fire_counter.stored_item.burning && fire_counter.stored_item.fire_progress>0,"holding action progressively extinguishes tutorial fire");
    guided_tick();processing_player_action(player,true,false,level.extinguish_duration/2+0.01);guided_tick();
    check(!fire_counter.stored_item.burning && level.tutorial_fire_phase=="return" && level.phase_state=="playing","tutorial requires extinguishing then returning tool");
    interact_at(player,rack);
    check(level.phase_state=="won" && global.frontend_tutorial_completed && !global.frontend_level_completed[0], "tutorial saves separate completion after practical firefighting without changing campaign indices");
    stage=22; ticks=0; exit;
}
if (stage==22) {
    screen_save(working_directory+"tutorial-complete.png");
    stage=3; ticks=0; room_goto(rm_level_select); exit;
}
if (stage==4) {
    check(room==rm_level_01 && !instance_exists(obj_tutorial) && level.level_index==0, "phase one restored as independent normal timed campaign phase");
    check(level.processing_enabled && level.minimum_goal==3 && array_length(level.bins)==4, "first phase has all four recyclable bins");
    check(instance_exists(obj_sorting_table) && instance_exists(obj_washer) && instance_exists(obj_biodigester) && !instance_exists(obj_dismantling_bench) && !instance_exists(obj_hydraulic_press) && !instance_exists(obj_extinguisher_rack) && !instance_exists(obj_common_trash), "first phase adds triage, washing and organics while leaving electronics for phase two");
    check(instance_number(obj_counter)>0, "first phase retains editor-placed support counters for handoffs");
    check(!variable_instance_exists(level,"active_orders"), "campaign has no active order system");
    for(var i=0;i<array_length(level.stations);i++) {
        var station=level.stations[i];
        check(station.station_kind=="dispatch" || (station.station_width==64 && station.station_height==64), "workstation has square collision footprint");
    }
    screen_save(working_directory+"mixed-first-level.png");
    var before=level.time_remaining; with(level)recycling_level_tick(1);
    check(level.time_remaining<before, "normal phase retains timer pressure");
    var bin=tutorial_station("bin",0);
    approach(player,bin);
    repeat(3) { processing_give_payload(player,processing_payload_new("sorted_paper")); recycling_interact(player); }
    processing_give_payload(player,processing_payload_new("sorted_paper")); recycling_interact(player);
    check(bin.load==3 && instance_exists(player.carried_item), "campaign bin capacity rejects overflow without item loss");
    recycling_consume_item(player); recycling_interact(player);
    check(player.carried_item.amount==3, "campaign bag preserves all three waste units");
    var counter=instance_find(obj_counter,0); processing_handoff(player,counter); processing_handoff(player,counter);
    check(player.carried_item.amount==3, "counter handoff preserves bag quantity");
    level.truck.capacity=3; level.truck.load=0;
    approach(player,level.truck); recycling_interact(player);
    check(level.delivered_total==1 && level.truck.trip_remaining>0 && !instance_exists(player.carried_item), "bag shares truck capacity and counts one unrestricted delivery");
    var source=level.dispenser; source.spawn_bag=[]; var seen=[]; repeat(14)array_push(seen,processing_next_source(source));
    check(array_contains(seen,"sorted_paper") && array_contains(seen,"sorted_plastic") && array_contains(seen,"sorted_glass") && array_contains(seen,"sorted_metal") && array_contains(seen,"raw_waste"), "first phase source never spawns materials without matching equipment");
    check(array_length(level.sorting_pool)==2 && !array_contains(level.sorting_pool,"electronic"), "first phase triage yields only washable plastic or organics");
    source.queue=["sorted_plastic","sorted_paper","sorted_plastic"]; approach(player,source); recycling_interact(player);
    check(player.carried_item.process_state=="sorted_plastic" && source.queue[0]=="sorted_paper" && source.queue[1]=="sorted_plastic", "FIFO pickup preserves displayed queue order");
    // The fixture rewrites save filenames to absolute paths inside its TEMP package.
    var filename=save_slot_filename(2);
    check(string_pos("probe_tutorial_progress_",filename)>0, "test saves isolated from real progress");
    if(file_exists(filename))file_delete(filename);
    ini_open(filename); ini_write_real("save","version",1); ini_write_real("save","level",0); ini_write_real("completed","0",1); ini_write_real("stars","0",2); ini_close();
    check(save_slot_load(2) && global.frontend_level_completed[0] && global.frontend_level_stars[0]==2 && !global.frontend_tutorial_completed, "old save migrates without shifting or clearing campaign progress");
    global.frontend_tutorial_completed=true; save_slot_write(); global.frontend_tutorial_completed=false;
    check(save_slot_load(2) && global.frontend_tutorial_completed && global.frontend_level_stars[0]==2, "tutorial completion persists alongside existing stars");
    global.frontend_save_slot=-1; global.frontend_level=-1; global.frontend_mode="coop_local"; global.game_mode="coop_local";
    stage=5; ticks=0; room_goto(rm_character_select); exit;
}
if (stage==7) {
    check(room==rm_tutorial && instance_number(obj_recycling_player)==2, "co-op map selection creates both tutorial players");
    var partner=instance_find(obj_recycling_player,1);
    with(partner){x=640;y=480;recycling_player_movement(1/60,0,1,true);}
    check(level.tutorial_dash_done,"second player can complete shared dash lesson");
    partner.x=384; partner.y=192;
    approach(player,level.dispenser); guided_tick(); recycling_interact(player); guided_tick();
    check(recycling_position_clear(partner.x,partner.y), "revealed furniture cannot trap the other player");
    approach(partner,level.dispenser); recycling_interact(partner);
    check(instance_exists(player.carried_item) && !instance_exists(partner.carried_item) && array_length(level.dispenser.queue)==0, "shared tutorial intake cannot duplicate current lesson item");
    player.x=400; player.y=600; var item=player.carried_item; processing_drop(player,item);
    partner.x=item.x; partner.y=item.y;
    global.keys_pressed=[frontend_keybinding("p2_interact")]; with(partner)recycling_player_step(); global.keys_pressed=[];
    check(partner.carried_item==item, "partner can recover dropped lesson item using own binding");
    interact_at(partner,tutorial_station("bin",0)); interact_at(player,tutorial_station("bin",0)); interact_at(player,level.truck);
    check(level.delivered_total==1 && level.tutorial_dispatch_phase=="send", "both players can share sorting and delivery steps");
    interact_at(partner,level.truck);
    guided_tick(level.truck.return_duration+0.01);
    check(level.tutorial_lesson==1 && level.tutorial_dispatch_done, "partner can dispatch shared tutorial truck");
    show_debug_message(global.probe_failed?"TUTORIAL_PROBE_FAILED":"TUTORIAL_PROBE_PASSED"); game_end();
}
