ticks=0;verified=false;
global.game_mode="coop_online";global.frontend_mode="coop_online";
global.is_host=true;
for(var arg_index=1;arg_index<=parameter_count();arg_index++)if(string_pos("online-client",parameter_string(arg_index))>0)global.is_host=false;
global.frontend_characters=[0,1];
frontend_online_selection_start(global.is_host);
global.online_selection.screen="game";global.online_selection.level=1;
global.keys_pressed=[];global.keys_released=[];global.keys_held=[];
global.probe_pressed=function(_key){return false;};global.probe_released=function(_key){return false;};
global.probe_held=function(_key){return array_contains(global.keys_held,_key);};
instance_create_depth(0,0,0,obj_network);
if(global.is_host)global.server=network_create_server(network_socket_tcp,6510,1);
else {global.client_socket=network_create_socket(network_socket_tcp);network_connect(global.client_socket,"127.0.0.1",6510);}
room_goto(rm_level_02);
