import fs from 'node:fs';
const read = file => JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '').replace(/,\s*([}\]])/g, '$1'));
const project = read('GameJamIf2026.yyp');
const sprites = project.resources.map(r => r.id).filter(r => r.path.startsWith('sprites/'))
    .map(r => ({...r, data: read(r.path)})).sort((a, b) => a.name.localeCompare(b.name));
const objects = project.resources.map(r => r.id).filter(r => r.path.startsWith('objects/'))
    .map(r => ({...r, data: read(r.path)}));
const lines = [
    '# Sprites do jogo', '',
    `O projeto possui **${sprites.length} sprites** registrados no GameMaker.`, '',
    'Lixeiras, bancadas e máquinas usam módulos quadrados de **64 × 64**. O caminhão ocupa dois módulos. Prensa e fardos de plástico/metal são recursos históricos: não aparecem nas rooms ou tutorial.', '',
    'Abra o recurso na pasta **Sprites** do Asset Browser e use **Edit Image → Import** para substituir a imagem. Preserve a origem e a máscara de colisão quando necessário. Objetos e posições continuam editáveis nas rooms.', '',
    'A coluna de objetos indica vínculos diretos. Alguns recursos, como as cientistas, ícones e fundos de interface, são escolhidos pelos scripts durante o jogo. Os sprites antigos do tutorial continuam disponíveis para reutilização; o tutorial prático utiliza os objetos da fase e `spr_ui_arrow`.', '',
    '| Sprite | Tamanho | Quadros | Objetos com vínculo direto |',
    '| --- | --- | --- | --- |',
];
for (const sprite of sprites) {
    const uses = objects.filter(o => o.data.spriteId?.name === sprite.name).map(o => `\`${o.name}\``).join(', ') || '—';
    lines.push(`| [${sprite.name}](../${sprite.path}) | ${sprite.data.width} × ${sprite.data.height} | ${sprite.data.frames.length} | ${uses} |`);
}
lines.push('', 'Atualizar esta lista: `node tools/catalog-sprites.mjs`.', '');
fs.writeFileSync('docs/sprites.md', lines.join('\n'));
console.log(`Cataloged ${sprites.length} sprites in docs/sprites.md`);
