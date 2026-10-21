// Editable values are Object/Instance Variables in the GameMaker editor.
station_kind = "bin";
image_speed = 0;
load = 0;
queue = [];
spawn_bag = [];
spawn_timer = spawn_interval;
overflow_elapsed = 0;
trip_remaining = 0;
parts = [false, false, false, false];
build_remaining = 0;
module_ready = false;
stored_item = undefined;
depth = -y;
var coop = variable_global_exists("game_mode") && global.game_mode == "coop_local";
if ((mode_only == 1 && !coop) || (mode_only == 2 && coop)) instance_destroy();

// Processing equipment owns one payload at a time.
buffer = undefined;
process_status = "empty";
process_progress = 0;
process_remaining = 0;
work_frame = -100;
tool_loaned = false;
