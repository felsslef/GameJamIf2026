ticks++;
if(ticks==200){show_debug_message("NET_DIAG "+string(global.is_host)+" connected "+string(global.online_connected));if(variable_global_exists("online_input"))show_debug_message(json_stringify(global.online_input));with(obj_recycling_player)show_debug_message("actor "+string(playerid)+" local "+string(is_local)+" x "+string(x));if(instance_exists(obj_recycling_level))show_debug_message(obj_recycling_level.story_mode+" countdown "+string(obj_recycling_level.start_countdown));}
if(!instance_exists(obj_recycling_level))exit;
var level=obj_recycling_level;
if(global.is_host){
 level.dispenser.spawn_timer=1000;
 level.delivered_total=2;level.recycled_total=2;
 if(ticks==30) {
  var sorting=instance_find(obj_sorting_table,0);sorting.buffer=processing_payload_new("raw_waste");sorting.process_status="loaded";sorting.process_duration=2;sorting.process_progress=1;
  with(obj_recycling_player)if(playerid==2){x=700;y=470;}
 }
 if(ticks>150 && global.online_connected && !verified) {
  var moved=false;with(obj_recycling_player)if(playerid==2 && x>740)moved=true;
  if(moved){verified=true;show_debug_message("ONLINE_HOST_INPUT_PASSED");}
 }
}else {
 global.keys_held=ticks<220?[frontend_keybinding("p1_right")]:[];
 if(ticks>150 && level.delivered_total==2 && !verified) {
  var sorting=instance_find(obj_sorting_table,0);
  if(!is_undefined(sorting.buffer) && sorting.process_progress==1 && instance_number(obj_recycling_player)==2){verified=true;show_debug_message("ONLINE_CLIENT_STATE_PASSED");}
 }
}
if(ticks>360){if(!verified)show_debug_message("ONLINE_TEST_FAILED");game_end();}
