# Início da partida e montagem de robôs

Cada partida começa com um relógio e “3, 2, 1, Já!”. Os controles, as máquinas, o dispenser e os 120 segundos da rodada ficam parados até terminar a contagem. A contagem espera a transição entre telas e respeita a pausa. Com animações reduzidas, mantém os números sem o salto visual.

A fase 1 continua sem eletrônicos. No tutorial e nas fases 2–5, o fluxo é:

1. Separar o saco misturado na triagem.
2. Levar o eletrônico à bancada de desmontagem e segurar Pegar.
3. Retirar os componentes recuperados e colocá-los na bancada científica.
4. Aguardar três segundos: o robô sai automaticamente e conta para a meta.

A bancada recebe um conjunto de componentes por robô e fica livre automaticamente ao concluir a montagem. Componentes ainda não montados são recusados pelo caminhão sem consumo. O robô conta como uma entrega sem precisar ser carregado; as metas e o fluxo sem pedidos continuam iguais. `metal_plate` é o nome interno dos componentes recuperados. `spr_robot` é usado na animação de partida. `obj_science_bench` fica colocado nas rooms, substituindo uma bancada de apoio, com colisão de 64×64. O código antigo de montagem de quatro peças e o código de rede permanecem separados. Veja [recycling-feedback.md](recycling-feedback.md).

A garrafa de refrigerante foi substituída por uma garrafa d’água amassada, clara, com tampa azul. O sprite continua `spr_waste_plastic`, em PNG de 32×32 com camada editável no GameMaker. A imagem original está em [recyclable-water-bottle.png](../assets/source/recyclable-water-bottle.png). A importação usa `tools/import-bottle-art.ps1` para redimensionar com nearest-neighbor e atualizar frame e camada.

Arte criada com a ferramenta integrada `image_gen` e a habilidade imagegen, em modo de edição com transparência. Prompt final:

```text
Use case: precise-object-edit. Asset type: replacement pixel-art sprite for a 32x32 recycling game inventory item. Edit target: the attached existing small plastic cola bottle. Replace the entire object with ONE EMPTY CRUMPLED TRANSPARENT WATER BOTTLE, tilted slightly diagonally, with a vivid BLUE screw cap and icy CYAN transparent plastic highlights, visible horizontal crushed ribs, DARK navy pixel outline. No red, no beverage, no label or branding, no text, no handle, no pump, no detergent jug silhouette. Readable chunky true pixel art, large simple pixel clusters appropriate to a 32x32 sprite enlarged with nearest-neighbor. Preserve a transparent background, isolated single object centered with a small even transparent margin. Match the playful existing game's dark outlined pixel-art style. It must be unmistakably different from a cleaning-product bottle. Only one bottle, no scene, no ground, no shadow, no extra icons.
```

As suítes de tutorial e processamento testam o congelamento durante a contagem, montagem, bancada ocupada, retirada e entrega de robô, além das rotas de reciclagem existentes. A adaptação das suítes pula a contagem inicial nas demais verificações e a testa separadamente usando as funções reais.

A bancada usa o sprite editável `spr_science_bench`, em 64×64, com desenho de robô, ferramentas e detalhes em verde-água. Fonte em [scientific-robot-workbench.png](../assets/source/scientific-robot-workbench.png), gerada pela ferramenta integrada `image_gen`. O importador recorta somente as margens transparentes e ajusta o PNG com nearest-neighbor. Prompt final:

```text
Use case: stylized-concept. Asset type: ONE 64x64 pixel-art sprite for a modular SCIENTIFIC ROBOT ASSEMBLY WORKBENCH in a top-down recycling co-op game. Exactly one single SQUARE grey metal counter module, overhead camera looking STRAIGHT DOWN, identical 64x64 square footprint to Overcooked counters in a 2D pixel-art game. Chunky crisp pixel clusters, dark navy two-pixel outline, thin teal trim, simple light-grey work surface. ONE large clear unfinished friendly robot-head schematic or robot face built into the worktop CENTER, with ONE small orange screwdriver and ONE blue circuit module at the sides. This is a SCIENTIST ROBOT BUILDING STATION, distinguish from electronics dismantling: emphasize the cute robot face and teal science colors, not broken junk. Keep surfaces uncluttered and symbols BIG enough to read when reduced to 64px. No text, letters, numbers, writing, labels, people, perspective, floor, large cast shadows, legs or tall machine. Isolated square object centered, small even transparent margin, genuinely transparent PNG background. It must connect edge-to-edge with square grey counters; do not make a wide rectangular desk.
```
