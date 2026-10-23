import fs from 'node:fs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/,\s*([}\]])/g,'$1'));
const name='snd_dialogue_blip',rate=22050,n=Math.round(rate*.028),b=Buffer.alloc(44+n*2);
b.write('RIFF');b.writeUInt32LE(b.length-8,4);b.write('WAVEfmt ',8);b.writeUInt32LE(16,16);b.writeUInt16LE(1,20);b.writeUInt16LE(1,22);b.writeUInt32LE(rate,24);b.writeUInt32LE(rate*2,28);b.writeUInt16LE(2,32);b.writeUInt16LE(16,34);b.write('data',36);b.writeUInt32LE(n*2,40);
for(let i=0;i<n;i++){const t=i/rate,envelope=Math.sin(Math.PI*i/n)**2;const v=(Math.sin(2*Math.PI*740*t)+.2*Math.sin(2*Math.PI*1480*t))*envelope*.24;b.writeInt16LE(Math.round(v*32767),44+i*2);}
fs.mkdirSync(`sounds/${name}`,{recursive:true});fs.writeFileSync(`sounds/${name}/${name}.wav`,b);
const sound=read('sounds/snd_delivery_success/snd_delivery_success.yy');sound.name=sound['%Name']=name;sound.soundFile=name+'.wav';sound.duration=n/rate;sound.volume=.45;
fs.writeFileSync(`sounds/${name}/${name}.yy`,JSON.stringify(sound,null,2));
const project=read('GameJamIf2026.yyp');if(!project.resources.some(r=>r.id.name==name))project.resources.push({id:{name,path:`sounds/${name}/${name}.yy`}});fs.writeFileSync('GameJamIf2026.yyp',JSON.stringify(project,null,2));
