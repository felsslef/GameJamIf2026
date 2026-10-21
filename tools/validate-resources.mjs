import fs from 'node:fs';
import path from 'node:path';

const read = file => JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '').replace(/,\s*([}\]])/g, '$1'));
const project = read('GameJamIf2026.yyp');
const resources = new Map(project.resources.map(({id}) => [id.name, id.path]));
const check = (condition, message) => { if (!condition) throw new Error(message); };
let frames = 0;
let instances = 0;
let pngBytes = 0;
for (const [name, file] of resources) {
  check(fs.existsSync(file), `Missing resource: ${file}`);
  const resource = read(file);
  check(resource.name === name, `Resource name mismatch: ${file}`);
  if (resource.resourceType === 'GMSprite') {
    for (const frame of resource.frames) {
      const root = path.dirname(file);
      const paths = [path.join(root, frame.name + '.png'), ...resource.layers.map(layer => path.join(root, 'layers', frame.name, layer.name + '.png'))];
      for (const image of paths) {
        check(fs.existsSync(image), `Missing sprite image: ${image}`);
        const png = fs.readFileSync(image);
        check(png.readUInt32BE(16) === resource.width && png.readUInt32BE(20) === resource.height, `PNG size mismatch: ${image}`);
        pngBytes += png.length;
      }
      frames++;
    }
  }
  if (resource.resourceType === 'GMObject') {
    for (const id of [resource.spriteId, resource.parentObjectId].filter(Boolean)) check(resources.has(id.name), `Missing object dependency: ${id.name}`);
    for (const event of resource.eventList) {
      const eventNames = {0:'Create', 3:'Step', 7:'Other', 8:'Draw', 12:'CleanUp'};
      const prefix = eventNames[event.eventType];
      if (prefix) check(fs.existsSync(path.join(path.dirname(file), `${prefix}_${event.eventNum}.gml`)), `Missing event: ${name} ${prefix}_${event.eventNum}`);
    }
  }
  if (resource.resourceType === 'GMRoom') {
    const placed = resource.layers.flatMap(layer => layer.instances || []);
    const names = new Set(placed.map(instance => instance.name));
    check(names.size === placed.length, `Duplicate instance name: ${name}`);
    check(resource.instanceCreationOrder.length === placed.length, `Creation order length: ${name}`);
    for (const instance of placed) { check(resources.has(instance.objectId.name), `Unknown room object: ${instance.objectId.name}`); instances++; }
    for (const instance of resource.instanceCreationOrder) check(names.has(instance.name), `Invalid creation order reference: ${name}`);
    for (const layer of resource.layers) if (layer.spriteId) check(resources.has(layer.spriteId.name), `Missing room background: ${layer.spriteId.name}`);
  }
}
const order = project.RoomOrderNodes.map(({roomId}) => roomId.name);
check(order[0] === 'rm_main_menu', 'Main menu must start the game');
check(order.indexOf('rm_teste') === order.indexOf('rm_menu') + 1, 'Legacy LAN room order changed');
console.log(`PASS: ${resources.size} resources, ${frames} sprite frames, ${instances} room instances, ${Math.round(pngBytes / 1024)} KiB of PNG files.`);
