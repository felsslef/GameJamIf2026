ticks++;
if (ticks < 12) exit;
function check(_ok,_label) {
    show_debug_message((_ok?"PASS: ":"FAIL: ")+_label);
    if (!_ok) global.probe_failed = true;
}
function simulate(_dt) { with (obj_recycling_level) processing_tick(_dt,true); }
function prepare_incident_round() {
    with (obj_recycling_level) {
        story_mode = "none";
        start_countdown = 0;
        time_remaining = 90;
        overflow_limit = 10000;
        phase_state = "playing";
        for (var i=0;i<array_length(dispensers);i++) { dispensers[i].queue=[]; dispensers[i].spawn_timer=10000; }
    }
}
var level = instance_find(obj_recycling_level,0);
if (stage==0) {
    prepare_incident_round();
    check(level.fire_failure_time==20,"default fire defeat deadline is twenty seconds");
    var station = instance_find(obj_dismantling_bench,0);
    station.buffer=processing_payload_new("electronic");
    processing_ignite_payload(station.buffer);
    station.process_status="burning";
    fire_station=station;
    simulate(14.99);
    check(level.phase_state=="playing" && level.fire_count==1 && level.fire_remaining>5,"fire warns before critical final seconds");
    simulate(0.02);
    check(level.phase_state=="playing" && level.fire_remaining<5,"critical warning starts before defeat");
    stage=1;ticks=0;exit;
}
if (stage==1) {
    screen_save(working_directory+"fire-countdown.png");
    // The oldest unresolved fire determines the remaining time.
    var player=instance_find(obj_recycling_player,0);
    var younger=processing_give_payload(player,processing_payload_new("electronic"));
    younger.is_held=false;younger.holder=noone;player.carried_item=noone;
    younger.x=400;younger.y=400;
    processing_ignite_payload(younger);
    fire_station.buffer.burning_age=18;
    younger.burning_age=3;
    simulate(0);
    check(level.fire_count==2 && level.fire_remaining==2,"multiple fires use the oldest deadline");
    player.x=fire_station.x;player.y=fire_station.y+50;
    var tool=processing_payload_new("extinguisher");
    processing_give_payload(player,tool);
    level.processing_frame++;
    processing_extinguish(player,level.extinguish_duration+0.01);
    check(!fire_station.buffer.burning && fire_station.buffer.burning_age==0,"extinguishing clears that fire deadline");
    simulate(0);
    check(level.fire_count==1 && level.fire_remaining==17,"putting out oldest fire preserves younger fire age");
    younger.burning=false;
    simulate(0);
    check(level.fire_count==0 && level.fire_remaining==-1,"last extinguished fire removes warning");
    instance_destroy(younger);
    recycling_consume_item(player);
    // Network replicas retain the timer both on stations and on loose materials.
    processing_ignite_payload(fire_station.buffer);
    fire_station.buffer.burning_age=7;
    younger=processing_give_payload(player,processing_payload_new("electronic"));
    younger.is_held=false;younger.holder=noone;player.carried_item=noone;
    processing_ignite_payload(younger);younger.burning_age=4;
    simulate(0);
    var snapshot=json_parse(json_stringify(online_snapshot()));
    fire_station.buffer.burning_age=0;
    online_sync(snapshot);
    check(fire_station.buffer.burning_age==7 && level.fire_remaining==13,"network snapshots retain fire deadline and warning");
    var loose_age=-1;with(obj_process_item)if(burning)loose_age=burning_age;
    check(loose_age==4,"network snapshots retain loose fire age");
    with(obj_process_item)if(burning)instance_destroy();
    // Pause uses real deactivation: neither fire nor round time may advance.
    with(obj_session_ui)session_ui_open_menu();
    instance_activate_object(id);
    frozen_level=level;
    frozen_age=fire_station.buffer.burning_age;
    stage=2;ticks=0;exit;
}
if (stage==2) {
    check(fire_station.buffer.burning_age==frozen_age,"pause stops fire deadline");
    with(obj_session_ui)session_ui_close_menu();
    level=frozen_level;
    fire_station.buffer.burning_age=19.99;
    simulate(0);
    check(level.phase_state=="playing","fire does not lose before twenty seconds");
    level.delivered_total=level.star_goals[2];level.recycled_total=level.delivered_total;
    level.time_remaining=0;
    simulate(0.02);
    check(level.phase_state=="lost" && !level.result_is_timeout,"persistent fire defeats even a completed delivery goal");
    check(!global.frontend_level_completed[1] && string_pos("incêndio",level.result_reason)>0,"fire defeat explains cause and does not save completion");
    stage=3;ticks=0;exit;
}
if (stage==3) {
    screen_save(working_directory+"fire-defeat.png");
    prepare_incident_round();fire_station.buffer=undefined;fire_station.process_status="empty";
    // A new ignition counts only time since ignition, excluding warm-up.
    var player=instance_find(obj_recycling_player,0);
    var item=processing_give_payload(player,processing_payload_new("electronic"));
    item.is_held=false;item.holder=noone;player.carried_item=noone;
    item.exposure_age=level.electronic_overheat_time-0.5;
    with(level)processing_tick(1);
    check(item.burning && abs(item.burning_age-0.5)<0.001,"floor fire starts its deadline after overheating");
    instance_destroy(item);
    fire_station.buffer=processing_payload_new("electronic");
    fire_station.buffer.exposure_age=level.electronic_overheat_time-0.5;
    fire_station.work_frame=-100;
    with(level)processing_tick(1);
    check(fire_station.buffer.burning && abs(fire_station.buffer.burning_age-0.5)<0.001,"station fire starts its deadline after overheating");
    fire_station.buffer=undefined;fire_station.process_status="empty";
    with(level){delivered_total=star_goals[2];recycled_total=delivered_total;robot_total=2;points_total=delivered_total*100;recycling_finish(true,"Mutirão concluído! Obrigada por cuidar da cidade.");result_started=current_time-2000;}
    stage=4;ticks=0;exit;
}
if (stage==4) {
    with(level)check(result_stars==3 && recycling_result_has_next(),"three-star victory retains campaign progression");
    screen_save(working_directory+"phase-complete.png");
    global.frontend_reduced_motion=false;level.result_started=current_time;
    stage=41;ticks=0;exit;
}
if (stage==41) {
    screen_save(working_directory+"phase-complete-animated.png");
    global.frontend_reduced_motion=true;
    level.result_stars=1;level.delivered_total=level.minimum_goal;level.recycled_total=level.delivered_total;
    stage=5;ticks=0;exit;
}
if (stage==5) {
    screen_save(working_directory+"phase-complete-one-star.png");
    global.keys_pressed=[vk_enter];with(level)recycling_level_update();global.keys_pressed=[];
    stage=6;ticks=0;exit;
}
if (stage==6) {
    check(room==rm_level_03,"result Enter still advances to next phase");
    room_goto(rm_tutorial);stage=7;ticks=0;exit;
}
if (stage==7) {
    prepare_incident_round();
    with(level){tutorial_dash_done=true;tutorial_stage=1;delivered_total=1;truck.load=1;tutorial_tick(0);}
    stage=71;ticks=0;exit;
}
if (stage==71) {
    screen_save(working_directory+"tutorial-dispatch.png");
    var player=instance_find(obj_recycling_player,0);
    player.x=level.truck.x-92;player.y=level.truck.y;
    processing_interact(player,level.truck);
    with(level)tutorial_tick(0);
    stage=72;ticks=0;exit;
}
if (stage==72) {
    screen_save(working_directory+"tutorial-truck-return.png");
    with(level){tutorial_dispatch_done=true;tutorial_lesson=7;delivered_total=7;tutorial_fire_begin();tutorial_tick(2.01);tutorial_tick(0);}
    check(level.tutorial_fire_phase=="extinguish" && level.fire_count==1,"tutorial fire uses real persistent-fire warning");
    stage=8;ticks=0;exit;
}
if (stage==8) {
    screen_save(working_directory+"tutorial-fire-warning.png");
    with(level){tutorial_fire_counter.stored_item.burning_age=19.99;tutorial_tick(0.02);}
    check(level.phase_state=="lost" && !global.frontend_tutorial_completed,"ignored tutorial fire loses without granting completion");
    stage=9;ticks=0;exit;
}
if (stage==9) {
    screen_save(working_directory+"tutorial-fire-defeat.png");
    show_debug_message(global.probe_failed?"INCIDENTS_PROBE_FAILED":"INCIDENTS_PROBE_PASSED");
    game_end();
}
