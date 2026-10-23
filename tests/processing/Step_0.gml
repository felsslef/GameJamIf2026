if (!variable_global_exists("probe_released")) { global.keys_released=[];global.probe_released=function(_key){return array_contains(global.keys_released,_key);}; }
ticks++; if(ticks<7)exit;
function check(_ok,_label){show_debug_message((_ok?"PASS: ":"FAIL: ")+_label);if(!_ok)global.probe_failed=true;}
function approach(_player,_station){
 for(var dx=-144;dx<=144;dx+=12)for(var dy=-144;dy<=144;dy+=12){var px=_station.x+dx,py=_station.y+dy;
  if(recycling_position_clear(px,py)){_player.x=px;_player.y=py;if(recycling_nearest_station(_player)==_station)return true;}}
 return false;
}
function give(_player,_state){if(instance_exists(_player.carried_item))recycling_consume_item(_player);return processing_give_payload(_player,processing_payload_new(_state));}
function tick(_dt){with(obj_recycling_level)processing_tick(_dt);}
function frame(){obj_recycling_level.processing_frame++;}
var level=instance_find(obj_recycling_level,0),player=instance_find(obj_recycling_player,0),partner=instance_find(obj_recycling_player,1);
if(stage==-2){screen_save(working_directory+"start-countdown.png");check(level.time_remaining==global.countdown_time,"live countdown preserves round clock");level.start_countdown=0;stage=0;ticks=0;exit;}
if(stage==16){screen_save(working_directory+"story-intro.png");with(level){story_begin("ending");repeat(4)story_advance();}stage=17;ticks=0;exit;}
if(stage==17){screen_save(working_directory+"story-beach.png");level.story_age=11;stage=18;ticks=0;exit;}
if(stage==18){screen_save(working_directory+"story-clean-beach.png");with(level)story_advance();show_debug_message(global.probe_failed?"PROCESSING_PROBE_FAILED":"PROCESSING_PROBE_PASSED");game_end();exit;}
if(stage>=7){
 if(stage==7){with(level){phase_state="lost";time_remaining=0;result_is_timeout=true;result_started=current_time;}stage=8;ticks=0;exit;}
 if(stage==8){screen_save(working_directory+"time-up.png");level.result_started=current_time-1700;stage=9;ticks=0;exit;}
 if(stage==9){screen_save(working_directory+"animated-result.png");global.frontend_reduced_motion=true;level.result_started=current_time-1700;stage=10;ticks=0;exit;}
 if(stage==10){
  screen_save(working_directory+"reduced-motion-result.png");
  with(level){phase_state="won";check(!recycling_result_has_next(),"last phase has no next-phase action");level_index=0;result_started=current_time-2000;}
  global.frontend_reduced_motion=false;global.keys_pressed=[vk_enter];with(level)recycling_level_update();global.keys_pressed=[];
  check(global.frontend_level==1,"winning result selects next campaign phase");stage=11;ticks=-60;exit;
 }
 if(stage==11){check(room==rm_level_02&&level.level_index==1&&!session_ui_transition_active(),"next phase opens after smooth transition");level.truck.trip_remaining=level.truck.return_duration/2;stage=12;ticks=0;exit;}
 if(stage==12){screen_save(working_directory+"truck-dock.png");level.truck.trip_remaining=0.4;stage=13;ticks=0;exit;}
 if(stage==13){screen_save(working_directory+"truck-returning.png");level.truck.trip_remaining=0;level.delivered_total=level.star_goals[1];stage=14;ticks=0;exit;}
 if(stage==14){screen_save(working_directory+"star-progress.png");with(level){phase_state="won";result_is_timeout=false;result_started=current_time-2000;result_stars=2;result_reason="Meta concluída!";}stage=15;ticks=0;exit;}
 screen_save(working_directory+"large-victory-panel.png");
 with(level)story_begin("intro");stage=16;ticks=0;exit;
}
check(instance_exists(level)&&level.processing_enabled,"processing mode initialized");
for(var i=0;i<array_length(level.dispensers);i++)level.dispensers[i].spawn_timer=10000;
var sorting=instance_find(obj_sorting_table,0),washer=instance_find(obj_washer,0),bio=instance_find(obj_biodigester,0),dismantler=instance_find(obj_dismantling_bench,0),press=instance_find(obj_hydraulic_press,0),rack=instance_find(obj_extinguisher_rack,0),trash=instance_find(obj_common_trash,0);
check(instance_exists(sorting)&&instance_exists(washer)&&instance_exists(bio)&&instance_exists(dismantler)&&!instance_exists(press)&&instance_exists(rack)&&instance_exists(trash),"treatment equipment placed and no press remains");
if(stage==0){
 var hazard=processing_payload_new("electronic");
 check(processing_warning_remaining(hazard,false)>2,"fresh electronics do not show urgent warning");
 hazard.exposure_age=level.electronic_overheat_time-1.5;
 check(processing_warning_remaining(hazard,false)==1.5,"station electronics warn in final two seconds");
 hazard.burning=true;check(processing_warning_remaining(hazard,false)==-1,"fire replaces pre-ignition warning");
 hazard=processing_payload_new("organic");hazard.floor_age=level.organic_decay_time-1;
 check(processing_warning_remaining(hazard,true)==1,"floor organics warn before decay");
 check(processing_warning_remaining(hazard,false)==-1,"stored organics have no false decay warning");
 with(level){
  var original_index=level_index;
  level_index=0;story_init();
  check(story_mode=="intro"&&array_length(story_lines)==4,"phase one introduces city and scientists");
  var saved_time=time_remaining;recycling_level_tick(1);
  check(time_remaining==saved_time,"dialogue freezes round timer");
  repeat(4)story_advance();check(!story_active(),"intro returns control after last line");
  level_index=1;story_init();check(story_mode=="robots","robot introduction belongs to phase two");
  repeat(4)story_advance();
  story_begin("ending");repeat(4)story_advance();
  check(story_mode=="beach","final dialogue opens robot beach cutscene");
  story_age=11;story_advance();check(!story_active()&&!result_is_timeout,"beach returns to final result");
  level_index=original_index;story_mode="none";
 }
 if(!variable_global_exists("disposal_verified")){
  global.disposal_verified=true;var disposal_x=player.x,disposal_y=player.y;
  var material_states=["sorted_paper","sorted_plastic","sorted_glass","sorted_metal","bag_paper","bag_plastic","bag_glass","bag_metal","raw_waste","dirty_plastic","clean_plastic","organic","fertilizer","electronic","metal_plate","burned_electronic","extinguisher","robot"];
  approach(player,trash);
  for(var material_index=0;material_index<array_length(material_states);material_index++){
   var preserved=give(player,material_states[material_index]);processing_interact(player);
   check(instance_exists(preserved)&&player.carried_item==preserved,"common trash preserves "+material_states[material_index]);
   check(!recycling_thrown_item_can_interact(preserved,trash),"throwing cannot discard "+material_states[material_index]);
  }
  recycling_consume_item(player);player.x=disposal_x;player.y=disposal_y;
 }
 if(!variable_global_exists("countdown_verified")){
  global.countdown_verified=true;global.countdown_time=level.time_remaining;
  level.start_countdown=3.65;with(level)recycling_level_tick(1);
  check(level.time_remaining==global.countdown_time,"countdown freezes round time and processing");
  var countdown_x=player.x;global.keys_held=[frontend_keybinding("p1_right")];with(player)recycling_player_step();global.keys_held=[];
  check(player.x==countdown_x,"countdown blocks player movement");
  with(level){recycling_start_tick(1);check(abs(start_countdown-2.65)<0.001,"countdown advances through seconds");recycling_start_tick(2.65);check(start_countdown==0,"countdown finishes without consuming match time");start_countdown=3.65;}
  stage=-2;ticks=0;exit;
 }
 var source_station=level.dispenser;
 var previous_x=player.x,previous_y=player.y;
 player.x=source_station.x-52;player.y=source_station.y;
 check(processing_station_near(source_station,28),"intake panel visible only at close range");
 player.x=source_station.x-82;
 check(!processing_station_near(source_station,28),"intake panel hidden outside close range");
 player.x=previous_x;player.y=previous_y;
 if (!variable_global_exists("throw_verified")) {
 var old_x=player.x,old_y=player.y;
 player.x=240;player.y=400;player.move_dir=0;
 var thrown=give(player,"sorted_paper");
 var launch_key=frontend_keybinding("p1_action");
 global.keys_held=[launch_key];global.keys_pressed=[launch_key];with(player)recycling_player_step();
 check(player.throw_charge>0&&player.carried_item==thrown,"configured throw button charges held material");
 global.keys_held=[];global.keys_pressed=[];global.keys_released=[launch_key];with(player)recycling_player_step();global.keys_released=[];
 check(!instance_exists(player.carried_item)&&thrown.is_thrown&&thrown.throw_spd==0,"releasing throw button launches item using original acceleration");
 global.throw_verified=false;global.probe_thrown=thrown;global.launch_x=thrown.x;global.origin_x=old_x;global.origin_y=old_y;
 stage=-1;ticks=0;exit;
 }
 // Real configured input must trigger double taps independently for both players.
 var directions=["up","down","left","right"],angles=[90,270,180,0];
 for(var actor_index=0;actor_index<2;actor_index++)for(var direction_index=0;direction_index<4;direction_index++){
  var actor=instance_find(obj_recycling_player,actor_index);
  with(actor){is_dashing=false;dash_cooldown=0;last_tap_direction=-1;last_tap_elapsed=1;}
  var prefix=actor.playerid==2?"p2_":"p1_";
  var direction_key=frontend_keybinding(prefix+directions[direction_index]);
  global.keys_pressed=[direction_key];global.keys_held=[direction_key];with(actor)recycling_player_step();
  check(!actor.is_dashing,"first directional tap walks without dashing");
  global.keys_pressed=[];global.keys_held=[];with(actor)recycling_player_step();
  global.keys_pressed=[direction_key];global.keys_held=[direction_key];with(actor)recycling_player_step();
  check(actor.is_dashing&&abs(angle_difference(actor.move_dir,angles[direction_index]))<0.01,"second configured directional tap starts dash in intended direction");
  global.keys_pressed=[];global.keys_held=[];with(actor){is_dashing=false;last_tap_direction=-1;last_tap_elapsed=1;}
 }
 with(player){
  check(recycling_player_dash_input(0,0)==-1&&recycling_player_dash_input(0.3,0)==-1,"slow double tap does not dash");
  check(recycling_player_dash_input(0.1,1)==-1,"changing direction does not count as repeated tap");
  last_tap_direction=-1;last_tap_elapsed=1;dash_cooldown=25;is_dashing=false;
 }
 var up_key=frontend_keybinding("p1_up");global.keys_held=[up_key];global.keys_pressed=[up_key];with(player)recycling_player_step();
 global.keys_pressed=[];with(player)recycling_player_step();check(!player.is_dashing,"holding direction does not retrigger dash");
 global.keys_pressed=[up_key];with(player)recycling_player_step();check(!player.is_dashing,"double tap respects dash cooldown");
 global.keys_pressed=[];global.keys_held=[];
 check(partner.last_tap_direction==-1,"one player's tap history does not affect partner");
 var source=level.dispenser;source.queue=[];source.spawn_bag=["raw_waste"];source.spawn_timer=0;tick(0.01);check(array_length(source.queue)==1,"intake generates raw bags automatically");source.spawn_timer=10000;
 source.queue=[];source.spawn_bag=["raw_waste"];check(approach(player,source),"intake accessible");processing_interact(player);check(array_length(source.queue)==1&&!instance_exists(player.carried_item),"empty intake lever generates a bag");processing_interact(player);check(player.carried_item.process_state=="raw_waste","raw bag pickup");
 approach(player,washer);processing_interact(player);check(player.carried_item.process_state=="raw_waste"&&is_undefined(washer.buffer),"raw waste rejected by washer");
 approach(player,level.truck);processing_interact(player);check(instance_exists(player.carried_item)&&level.points_total==0,"raw waste rejected by dispatch");
 approach(player,sorting);processing_interact(player);tick(0.5);check(sorting.process_progress==0&&sorting.buffer.process_state=="raw_waste","manual sorting waits for held action");
 level.material_bag=["dirty_plastic"];frame();global.keys_held=[frontend_keybinding("p1_interact")];with(player)recycling_player_step();global.keys_held=[];check(sorting.process_progress>0,"pickup button also performs held manual work");
 var previous_progress=sorting.process_progress;frame();processing_player_action(player,true,false,0.75);check(abs(sorting.process_progress-previous_progress-0.75)<0.001,"held action advances sorting");var progress=sorting.process_progress;processing_player_action(player,false,false,1);check(sorting.process_progress==progress,"released action pauses work");
 approach(partner,sorting);processing_manual_work(partner,sorting,0.5);check(sorting.process_progress==progress,"two players cannot double work in one frame");frame();processing_manual_work(player,sorting,1.25);check(sorting.process_status=="ready"&&sorting.buffer.process_state=="dirty_plastic","sorting creates dirty plastic");
 processing_interact(player);approach(player,bio);processing_interact(player);check(instance_exists(player.carried_item)&&is_undefined(bio.buffer),"wrong material refused without consuming item");approach(player,washer);processing_interact(player);check(washer.process_status=="processing","washer starts automatically");tick(2.99);check(washer.process_status=="processing","washer not done early");tick(0.02);check(washer.buffer.process_state=="clean_plastic"&&washer.process_status=="ready","washer takes three seconds");processing_interact(player);
 approach(player,level.truck);processing_interact(player);check(level.points_total==100&&level.delivered_total==1&&!instance_exists(player.carried_item),"clean plastic delivers directly without compaction");
 give(player,"dirty_plastic");var time_before=level.time_remaining;processing_interact(player);check(level.points_total==100&&level.delivered_total==1&&level.time_remaining==time_before&&instance_exists(player.carried_item),"unfinished delivery is refused without time penalty or item loss");
 give(player,"organic");approach(player,bio);processing_interact(player);tick(3.99);check(bio.process_status=="processing","biodigester waits four seconds");tick(0.02);check(bio.buffer.process_state=="fertilizer","organic becomes fertilizer");processing_interact(player);approach(player,level.truck);processing_interact(player);check(level.delivered_total==2,"fertilizer delivered without press");
 give(player,"electronic");approach(player,dismantler);processing_interact(player);tick(1);check(dismantler.process_progress==0,"dismantling needs held action");frame();processing_manual_work(player,dismantler,2.5);check(dismantler.buffer.process_state=="metal_plate","manual dismantling recovers components");processing_interact(player);
 approach(player,level.truck);processing_interact(player);check(instance_exists(player.carried_item)&&level.delivered_total==2,"robot components cannot be delivered before assembly");
 var science=instance_find(obj_science_bench,0);check(instance_exists(science)&&approach(player,science),"scientific assembly bench is editor placed and accessible");processing_interact(player);
 check(science.process_status=="processing"&&!instance_exists(player.carried_item),"placing components starts robot assembly");
 give(partner,"metal_plate");approach(partner,science);processing_interact(partner);check(instance_exists(partner.carried_item),"occupied scientific bench preserves extra components");recycling_consume_item(partner);
 tick(2.99);check(science.process_status=="processing","robot is not built early");tick(0.02);check(is_undefined(science.buffer)&&science.process_status=="empty","robot departs immediately after three-second assembly");
 check(!instance_exists(player.carried_item)&&level.delivered_total==3&&level.points_total==300&&level.robot_total==1,"robot departure credits production automatically without truck delivery");
 check(array_length(level.robot_departures)==1,"robot has an automatic departure animation");processing_interact(player);tick(0.1);check(!instance_exists(player.carried_item)&&level.robot_total==1,"robot cannot be picked up or credited twice");
 level.material_bag=[];var seen=[];repeat(3)array_push(seen,processing_random_material());check(array_contains(seen,"dirty_plastic")&&array_contains(seen,"organic")&&array_contains(seen,"electronic"),"random sorting covers all material types");
 stage=1;ticks=0;room_restart();exit;
}
if(stage==-1){
 check(instance_exists(global.probe_thrown)&&global.probe_thrown.x>global.launch_x,"launched material actually travels across normal game frames");
 if(instance_exists(global.probe_thrown))with(global.probe_thrown)instance_destroy();
 player.x=global.origin_x;player.y=global.origin_y;global.throw_verified=true;stage=0;ticks=0;exit;
}
if(stage==1){
 player.x=350;player.y=512;player.move_dir=0;var organic=give(player,"organic");processing_drop(player,organic);var px=organic.x,py=organic.y;tick(7.99);check(instance_exists(organic)&&instance_number(obj_leachate)==0,"organic stays intact before eight seconds");tick(0.02);check(!instance_exists(organic)&&instance_number(obj_leachate)==1,"organic becomes leachate after eight seconds");
 player.x=px;player.y=py;tick(0);check(player.stun_remaining==2&&partner.stun_remaining==0,"puddle stuns only touching player for two seconds");global.keys_held=[ord("D"),ord("H")];global.keys_pressed=[ord("H")];var start_x=player.x;with(player)recycling_player_step();check(player.x==start_x&&!instance_exists(player.carried_item),"stunned player cannot move or interact");global.keys_held=[];global.keys_pressed=[];tick(2.01);check(player.stun_remaining==0,"stun expires without perpetual retrigger");
 with(player){x=px-40;y=py;slip_contact=noone;stun_remaining=0;is_dashing=true;dash_time=8;move_dir=0;recycling_player_movement(0.05,1,0,false);}check(player.stun_remaining>0&&player.x<px,"dash cannot skip across leachate");tick(2.01);
 player.x=350;player.y=480;var electronic=give(player,"electronic");processing_drop(player,electronic);tick(4.99);check(!electronic.burning,"electronic safe before five seconds");tick(0.02);check(electronic.burning&&electronic.process_state=="burned_electronic","floor electronic ignites and becomes unusable");player.x=electronic.x-25;player.y=electronic.y;processing_interact(player);check(!instance_exists(player.carried_item),"burning material cannot be picked up");
 approach(player,rack);processing_interact(player);check(player.carried_item.process_state=="extinguisher"&&rack.tool_loaned,"extinguisher pickup loans tool");approach(partner,rack);processing_interact(partner);check(!instance_exists(partner.carried_item)&&instance_number(obj_material_extinguisher)==1,"rack cannot duplicate loaned extinguisher");
 player.x=electronic.x-60;player.y=electronic.y;frame();processing_player_action(player,true,true,0.5);check(instance_exists(player.carried_item)&&electronic.burning&&electronic.fire_progress>=0.5,"pressed-and-held action uses extinguisher without dropping tool");frame();processing_extinguish(player,0.51);check(!electronic.burning&&electronic.process_state=="burned_electronic","extinguisher clears fire but does not restore material");approach(player,rack);processing_interact(player);check(!rack.tool_loaned&&!instance_exists(player.carried_item),"extinguisher returns to rack");player.x=electronic.x-25;player.y=electronic.y;processing_interact(player);check(player.carried_item.process_state=="burned_electronic","extinguished item can be collected");approach(player,trash);processing_interact(player);check(instance_exists(player.carried_item)&&instance_exists(electronic),"burned material cannot be discarded in common trash");
 approach(player,dismantler);processing_interact(player);check(dismantler.process_status=="loaded","extinguished electronics return to dismantling");frame();processing_manual_work(player,dismantler,2.5);check(dismantler.buffer.process_state=="metal_plate","extinguished electronics recover usable components");processing_interact(player);var recovery_bench=instance_find(obj_science_bench,0);approach(player,recovery_bench);processing_interact(player);tick(3.01);check(level.robot_total==1&&is_undefined(recovery_bench.buffer),"recovered burned electronics build an automatically departing robot");
 var counter=noone;with(obj_counter)if(y==416)counter=id;check(instance_exists(counter),"editable counter available");give(player,"electronic");processing_handoff(player,counter);tick(5.01);check(counter.stored_item.burning,"electronic ignites on counter");processing_handoff(player,counter);check(!instance_exists(player.carried_item),"burning counter blocks collection");approach(player,rack);processing_interact(player);approach(player,counter);frame();processing_extinguish(player,1.01);check(!counter.stored_item.burning,"counter fire can be extinguished");approach(player,rack);processing_interact(player);processing_handoff(player,counter);approach(player,trash);processing_interact(player);
 give(player,"electronic");approach(player,dismantler);processing_interact(player);tick(5.01);check(dismantler.buffer.burning&&dismantler.process_status=="burning","forgotten electronic ignites on dismantling bench");frame();processing_manual_work(player,dismantler,3);check(dismantler.buffer.process_state=="burned_electronic","burned material cannot be dismantled");
 var before=instance_number(obj_leachate);give(player,"organic");processing_handoff(player,counter);tick(8.01);check(instance_number(obj_leachate)==before&&counter.stored_item.process_state=="organic","organic stored on counter does not decay as floor waste");processing_handoff(player,counter);recycling_consume_item(player);
 give(player,"extinguisher");player.carried_item.tool_owner=rack;rack.tool_loaned=true;processing_handoff(player,counter);check(rack.tool_loaned,"extinguisher stays loaned while stored");processing_handoff(partner,counter);approach(partner,rack);processing_interact(partner);check(!rack.tool_loaned,"other player can return passed extinguisher");
 stage=2;ticks=0;room_goto(rm_level_02);exit;
}
var expected_players=stage>=6?1:2;check(instance_number(obj_recycling_player)==expected_players,"mode player count");
check(level.has_construction==false&&level.robot_minimum==0,"delivery minimum does not require robot construction");
check(!instance_exists(obj_hydraulic_press)&&!variable_instance_exists(level,"active_orders"),"no presses or active orders in any stage");
if(level.level_index==2){check(array_length(level.dispensers)==2,"split level has two raw intakes");check(recycling_position_clear(640,480)==(stage>=6),"co-op split and solo passage preserved");}else check(recycling_position_clear(640,500),"non-split levels retain shared circulation");
if(stage==2)screen_save(working_directory+"processing-room.png");
var data={stage:stage,stations:[],players:[]};for(var i=0;i<array_length(level.stations);i++){var s=level.stations[i];array_push(data.stations,{kind:s.station_kind,x:s.x,y:s.y,w:s.station_width,h:s.station_height});}with(obj_recycling_player)array_push(data.players,{x:x,y:y});show_debug_message("LAYOUT_DATA:"+json_stringify(data));
level.delivered_total=level.minimum_goal-1;level.recycled_total=level.delivered_total;level.time_remaining=0;with(level)recycling_level_tick(0);check(level.phase_state=="lost","round requires minimum finished deliveries");level.phase_state="playing";level.delivered_total=level.minimum_goal;level.recycled_total=level.delivered_total;with(level)recycling_level_tick(0);check(level.phase_state=="won"&&level.result_stars==1&&global.frontend_level_completed[level.level_index],"minimum deliveries earn star and save completion state");with(level)check(processing_earned_stars()==1,"live HUD reports first achieved star");
if(level.level_index==4){check(level.story_mode=="ending","final victory starts ending dialogue");level.story_mode="none";}
level.phase_state="playing";level.delivered_total=level.star_goals[2];level.recycled_total=level.delivered_total;with(level)recycling_level_tick(0);check(level.result_stars==3,"higher delivery target earns three stars");with(level)check(processing_earned_stars()==3,"live HUD reports all achieved stars");
level.story_mode="none";with(level){check(recycling_result_has_next()==(level_index<4),"next phase appears only before final campaign stop");phase_state="lost";check(!recycling_result_has_next(),"failed result cannot advance");phase_state="won";}
stage++;ticks=0;var rooms=[rm_level_01,rm_level_01,rm_level_02,rm_level_03,rm_level_04,rm_level_05,rm_level_03];if(stage<7){if(stage==6)global.game_mode="solo";room_goto(rooms[stage]);}else{room_goto(rm_level_05);}
