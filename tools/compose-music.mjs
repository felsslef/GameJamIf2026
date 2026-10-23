// Original score, rendered locally. MIDI numbers describe notes; there are no samples.
import fs from 'node:fs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/,\s*([}\]])/g,'$1'));
const rate=44100, tau=2*Math.PI;
function compose(name,bpm,fast){
 const beat=60/bpm,seconds=32*4*beat,frames=Math.round(seconds*rate);
 const left=new Float32Array(frames),right=new Float32Array(frames);
 let seed=92417;const noise=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2147483648-1;};
 function note(type,midi,start,length,amp,pan=0){
  const duration=length*beat,begin=Math.round(start*beat*rate),freq=440*2**((midi-69)/12);
  const gl=Math.sqrt((1-pan)/2),gr=Math.sqrt((1+pan)/2);
  for(let n=0;n<duration*rate;n++){
   const t=n/rate,u=t/duration,phase=t*freq;let sample=0,env=Math.min(1,t/0.006)*Math.min(1,(duration-t)/0.025);
   if(type==='lead')sample=(Math.sin(tau*phase)+.28*Math.sin(tau*phase*2)+.12*Math.sin(tau*phase*3))*env*(.75+.25*Math.exp(-t*12));
   if(type==='bass')sample=(Math.sin(tau*phase)+.23*Math.sin(tau*phase*2))*env*Math.exp(-t*2);
   if(type==='pluck')sample=(Math.sin(tau*phase)+.3*Math.sin(tau*phase*3))*env*Math.exp(-t*12);
   if(type==='chord')sample=(Math.sin(tau*phase)+.16*Math.sin(tau*phase*2))*env*Math.exp(-t*4);
   if(type==='kick')sample=Math.sin(tau*(48*t+7*(1-Math.exp(-t*32))))*Math.exp(-t*18)+noise()*.06*Math.exp(-t*150);
   if(type==='snare')sample=(noise()*.7+Math.sin(tau*185*t)*.3)*Math.exp(-t*22)*Math.min(1,t/.001);
   if(type==='hat')sample=noise()*Math.exp(-t*85)*Math.min(1,t/.001);
   if(type==='bell')sample=(Math.sin(tau*620*t)*.55+Math.sin(tau*943*t)*.45)*Math.exp(-t*25)*env;
   const v=sample*amp,index=(begin+n)%frames;left[index]+=v*gl;right[index]+=v*gr;
   if(type==='lead'||type==='pluck'){const delayed=(index+Math.round(beat*.75*rate))%frames;left[delayed]+=v*.12*gr;right[delayed]+=v*.12*gl;}
  }
 }
 const chords=fast?[[52,55,59],[48,52,55],[55,59,62],[50,54,57]]:[[55,59,62],[50,54,57],[52,55,59],[48,52,55]];
 const motifs=fast?[
  [76,79,83,79,78,79,74,78,76,79,83,86,83,79,78,74],
  [79,83,86,83,81,79,78,74,76,78,79,83,81,78,74,71],
  [83,86,88,86,83,81,79,78,79,83,81,79,78,74,76,79],
  [81,78,74,78,79,78,76,74,71,74,78,81,79,78,76,74]
 ]:[
  [79,0,83,86,83,81,79,0,76,79,81,0,79,76,74,0],
  [78,0,81,86,81,78,76,0,74,78,81,0,79,78,74,0],
  [76,79,83,0,86,83,79,0,78,79,83,0,81,79,76,0],
  [76,0,79,84,83,79,76,0,74,76,79,81,79,76,74,78]
 ];
 for(let bar=0;bar<32;bar++){
  const base=bar*4,chord=chords[Math.floor(bar/2)%4],section=Math.floor(bar/8),root=chord[0]-12;
  for(let b=0;b<4;b++){
   note('kick',0,base+b,.55,fast?.34:.3);
   if(b%2===1)note('snare',0,base+b,.5,.17);
   for(let h=0;h<2;h++)note('hat',0,base+b+h*.5,.2,h===0?.045:.068,h===0?-.4:.4);
   note('bass',root+(b===2?12:0),base+b,.42,.24);
   note('bass',b%2?root+7:root+12,base+b+.5,.34,.15);
   if(fast&&b%2===0)note('bell',0,base+b+.75,.25,.055,.55);
  }
  for(const offset of [.5,1.5,2.5,3.5])for(const pitch of chord)note('chord',pitch+12,base+offset,.26,.055,-.35);
  const motif=motifs[Math.floor(bar/2)%4];
  const phraseOffset=(bar%2)*8;
  for(let k=0;k<8;k++){
   const pitch=motif[phraseOffset+k];
   if(pitch)note('lead',pitch+(section===2?-12:0),base+k*.5,.42,section===2?.115:.15,.12);
  }
  if(fast||section===1||section===3)for(let k=0;k<16;k++)note('pluck',chord[k%3]+(k%4===3?24:12),base+k*.25,.2,.045,k%2?.6:-.6);
  if(bar%8===7)for(let k=0;k<4;k++)note('snare',0,base+3+k*.25,.24,.075+k*.015,k%2?.3:-.3);
 }
 let peak=0,energy=0;
 for(let i=0;i<frames;i++)peak=Math.max(peak,Math.abs(left[i]),Math.abs(right[i]));
 const gain=.88/peak,buffer=Buffer.alloc(44+frames*4);
 buffer.write('RIFF');buffer.writeUInt32LE(buffer.length-8,4);buffer.write('WAVEfmt ',8);buffer.writeUInt32LE(16,16);buffer.writeUInt16LE(1,20);buffer.writeUInt16LE(2,22);buffer.writeUInt32LE(rate,24);buffer.writeUInt32LE(rate*4,28);buffer.writeUInt16LE(4,32);buffer.writeUInt16LE(16,34);buffer.write('data',36);buffer.writeUInt32LE(frames*4,40);
 for(let i=0;i<frames;i++){const l=left[i]*gain,r=right[i]*gain;energy+=(l*l+r*r)/2;buffer.writeInt16LE(Math.round(l*32767),44+i*4);buffer.writeInt16LE(Math.round(r*32767),46+i*4);}
 fs.mkdirSync(`sounds/${name}`,{recursive:true});fs.writeFileSync(`sounds/${name}/${name}.wav`,buffer);
 const sound=read('sounds/snd_delivery_success/snd_delivery_success.yy');sound.name=sound['%Name']=name;sound.soundFile=name+'.wav';sound.duration=frames/rate;sound.sampleRate=rate;sound.channelFormat=1;sound.compression=1;sound.volume=1;
 fs.writeFileSync(`sounds/${name}/${name}.yy`,JSON.stringify(sound,null,2));
 console.log(JSON.stringify({name,bpm,seconds:frames/rate,peak:.88,rms:Math.sqrt(energy/frames),bytes:buffer.length}));
 return name;
}
const names=[compose('mus_coleta_theme',140,false),compose('mus_recycling_rush',168,true)];
const project=read('GameJamIf2026.yyp');
for(const name of names)if(!project.resources.some(r=>r.id.name===name))project.resources.push({id:{name,path:`sounds/${name}/${name}.yy`}});
fs.writeFileSync('GameJamIf2026.yyp',JSON.stringify(project,null,2));
