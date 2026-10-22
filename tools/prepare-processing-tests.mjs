// Prepares an isolated GameMaker project. It never edits production code or real save files.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
const root=process.cwd();
const suite=process.argv[2]||'processing';
if(!['processing','tutorial'].includes(suite))throw Error('Unknown test suite');
const dest=path.join(os.tmpdir(),`GameJamIf2026-${suite}-tests`);
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,'').replace(/,\s*([}\]])/g,'$1'));
const save=(p,x)=>fs.writeFileSync(p,JSON.stringify(x,null,2));
fs.mkdirSync(dest,{recursive:true});
for(const folder of ['scripts','rooms','objects','sprites','fonts','options','sounds'])fs.cpSync(path.join(root,folder),path.join(dest,folder),{recursive:true});
fs.copyFileSync('GameJamIf2026.yyp',path.join(dest,'GameJamIf2026.yyp'));
const name='obj_processing_probe';
const object=read('objects/obj_frontend/obj_frontend.yy');
object.name=object['%Name']=name;object.persistent=true;object.eventList=object.eventList.filter(e=>e.eventType===0||e.eventType===3);
const objectPath=path.join(dest,'objects',name);
fs.mkdirSync(objectPath,{recursive:true});save(path.join(objectPath,name+'.yy'),object);
for(const file of ['Create_0.gml','Step_0.gml'])fs.copyFileSync(`tests/${suite}/`+file,path.join(objectPath,file));
fs.appendFileSync(path.join(objectPath,'Create_0.gml'),'\nglobal.keys_released=[];global.probe_released=function(_key){return array_contains(global.keys_released,_key);};\n');
if(suite==='tutorial') {
    const step=path.join(objectPath,'Step_0.gml');
    fs.writeFileSync(step,fs.readFileSync(step,'utf8').replace('if (ticks < 7)', 'if (ticks < 60)'));
}
const project=read(path.join(dest,'GameJamIf2026.yyp'));
project.resources.push({id:{name,path:`objects/${name}/${name}.yy`}});save(path.join(dest,'GameJamIf2026.yyp'),project);
const roomPath='rooms/rm_main_menu/rm_main_menu.yy';const room=read(path.join(dest,roomPath));const layer=room.layers.find(l=>l.instances);
const instance=structuredClone(layer.instances[0]);instance.name=instance['%Name']='inst_processing_probe';instance.objectId={name,path:`objects/${name}/${name}.yy`};layer.instances.push(instance);room.instanceCreationOrder.push({name:instance.name,path:roomPath});save(path.join(dest,roomPath),room);
const optionsPath=path.join(dest,'options/windows/options_windows.yy');const options=read(optionsPath);options.option_windows_disable_sandbox=true;save(optionsPath,options);
const inputPath=path.join(dest,'scripts/scr_recycling_level/scr_recycling_level.gml');fs.writeFileSync(inputPath,fs.readFileSync(inputPath,'utf8').replace('start_countdown = 3.65;', 'start_countdown = 0;').replaceAll('keyboard_check_released(','global.probe_released(').replaceAll('keyboard_check_pressed(','global.probe_pressed(').replaceAll('keyboard_check(','global.probe_held('));
if(suite==='tutorial'){
    const savePath=path.join(dest,'scripts/scr_save_slots/scr_save_slots.gml');
    fs.writeFileSync(savePath,fs.readFileSync(savePath,'utf8').replace('return "progress_"','return working_directory + "probe_tutorial_progress_"'));
}
console.log(dest);
