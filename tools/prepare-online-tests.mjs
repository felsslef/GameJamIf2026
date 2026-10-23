import fs from 'node:fs';import path from 'node:path';import os from 'node:os';import {execFileSync} from 'node:child_process';
execFileSync(process.execPath,['tools/prepare-processing-tests.mjs','processing'],{stdio:'inherit'});
const root=path.join(os.tmpdir(),'GameJamIf2026-processing-tests');
for(const file of ['Create_0.gml','Step_0.gml'])fs.copyFileSync('tests/online/'+file,path.join(root,'objects/obj_processing_probe',file));
