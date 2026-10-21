import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
const file=process.argv[2] || path.join(os.tmpdir(),'GameJamIf2026-processing-tests','run.log');
const log=fs.readFileSync(file,'utf8');
if(!log.includes('PROCESSING_PROBE_PASSED') || log.includes('FAIL:'))throw new Error('Processing runtime tests must pass first');
for(const line of log.split('\n').filter(s=>s.startsWith('LAYOUT_DATA:'))){
 const {stations,players,stage}=JSON.parse(line.slice(12));
 const distance=(x,y,s)=>Math.hypot(x-Math.max(s.x-s.w/2,Math.min(s.x+s.w/2,x)),y-Math.max(s.y-s.h/2,Math.min(s.y+s.h/2,y)));
 const clear=(x,y)=>x>=64&&x<=1216&&y>=154&&y<=664&&stations.every(s=>distance(x,y,s)>=15);
 const reach=start=>{
  const sx=Math.round((start.x-64)/8),sy=Math.round((start.y-154)/8),queue=[[sx,sy]],seen=new Set([sx+','+sy]),hits=new Set();
  for(let h=0;h<queue.length;h++){
   const [gx,gy]=queue[h],x=64+gx*8,y=154+gy*8;let closest=-1,nearest=58;
   stations.forEach((s,i)=>{const d=distance(x,y,s);if(d<nearest){nearest=d;closest=i;}});if(closest>=0)hits.add(closest);
   for(const[dx,dy]of[[1,0],[-1,0],[0,1],[0,-1]]){const nx=gx+dx,ny=gy+dy,k=nx+','+ny;if(!seen.has(k)&&clear(64+nx*8,154+ny*8)){seen.add(k);queue.push([nx,ny]);}}
  }
  return{seen,hits};
 };
 const areas=players.map(reach);
 for(let i=0;i<stations.length;i++){
  const s=stations[i];
  if(s.kind!=='handoff'&&!areas.some(a=>a.hits.has(i)))throw new Error(`Stage ${stage}: ${s.kind} is inaccessible`);
  if(s.kind==='dispatch'&&!areas.every(a=>a.hits.has(i)))throw new Error(`Stage ${stage}: truck must be shared`);
  for(let j=i+1;j<stations.length;j++){const t=stations[j];if(Math.abs(s.x-t.x)<(s.w+t.w)/2&&Math.abs(s.y-t.y)<(s.h+t.h)/2)throw new Error(`Stage ${stage}: equipment overlaps`);}
 }
 if(!players.every(p=>clear(p.x,p.y)))throw new Error(`Stage ${stage}: blocked player spawn`);
 if(players.length===2){const p=players[1],k=Math.round((p.x-64)/8)+','+Math.round((p.y-154)/8);if(areas[0].seen.has(k)===(stage===3))throw new Error(`Stage ${stage}: invalid side separation`);}
 console.log(`PASS stage ${stage}: equipment reachable, no overlaps, correct player circulation.`);
}
