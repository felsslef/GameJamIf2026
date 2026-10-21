# Editar sprites e montar fases no GameMaker

O fluxo atual de triagem e tratamento usa novos prefabs `obj_intake_bin`, `obj_sorting_table`, `obj_washer`, `obj_biodigester`, `obj_dismantling_bench`, `obj_hydraulic_press`, `obj_dispatch_truck`, `obj_common_trash` e `obj_extinguisher_rack`. Materiais usam `obj_material_*`; consulte [processing.md](processing.md) para o cat?logo e as vari?veis atuais. Os recursos antigos da tabela abaixo continuam dispon?veis no projeto.


Abra `GameJamIf2026.yyp`. As cinco fases agora estão montadas com instâncias reais no Room Editor. Os desenhos de personagens, lixo, peças, sacos, robô, equipamentos e piso foram convertidos em recursos de sprite com PNGs editáveis. São imagens provisórias reaproveitadas dos desenhos anteriores; você pode substituí-las pelas suas.

## Trocar uma imagem

1. Abra um recurso `spr_*` no Asset Browser.
2. Importe a sua imagem no Sprite Editor, substituindo o quadro atual.
3. Mantenha a origem atual para preservar o alinhamento. Se mudar o tamanho, ajuste também a origem e as dimensões de colisão do equipamento quando necessário.
4. Rode uma fase para conferir. A imagem não é recriada pelo código.

Você também pode atribuir outra sprite ao objeto no Object Editor. Os objetos do cenário usam `draw_self()`. Os ícones de lixo, peças e sacos consultam a sprite do respectivo objeto; essa troca também aparece nas filas e bancadas.

| Elemento | Sprite | Objeto para arrastar na room |
|---|---|---|
| Papel | `spr_waste_paper`, `spr_bin_paper` | `obj_waste_paper`, `obj_bin_paper` |
| Plástico | `spr_waste_plastic`, `spr_bin_plastic` | `obj_waste_plastic`, `obj_bin_plastic` |
| Vidro | `spr_waste_glass`, `spr_bin_glass` | `obj_waste_glass`, `obj_bin_glass` |
| Metal | `spr_waste_metal`, `spr_bin_metal` | `obj_waste_metal`, `obj_bin_metal` |
| Dispenser | `spr_dispenser` | `obj_dispenser` |
| Bancada científica | `spr_science_bench` | `obj_science_bench` |
| Bloco de apoio | `spr_counter` | `obj_counter` |
| Caminhão | `spr_truck` | `obj_truck` |
| Entrega de robôs | `spr_robot_delivery` | `obj_robot_delivery` |
| Circuito, bateria, motor e carcaça | `spr_part_circuit`, `spr_part_battery`, `spr_part_motor`, `spr_part_casing` | `obj_part_circuit`, `obj_part_battery`, `obj_part_motor`, `obj_part_casing` |
| Robô montado | `spr_robot` | `obj_robot` |
| Sacos | `spr_bag_paper`, `spr_bag_plastic`, `spr_bag_glass`, `spr_bag_metal` | `obj_bag_paper`, `obj_bag_plastic`, `obj_bag_glass`, `obj_bag_metal` |
| Personagens | `spr_scientist_ju`, `spr_scientist_le`, `spr_scientist_manu`, `spr_scientist_maria` | `obj_recycling_player`, `obj_recycling_player_two` |
| Piso e cenário | `spr_workshop_floor` | camada `Background` da room |

As sprites das cientistas têm 64x64; resíduos e peças têm 32x32. Equipamentos maiores mantêm as dimensões anteriores. Os nomes e recursos podem ser mantidos ao substituir os PNGs. As quatro sprites de cientistas também aparecem nas cartas de seleção.

## Mover, acrescentar ou remover equipamentos

Abra `rm_level_01` até `rm_level_05`. A camada `Stations` contém as bancadas, lixeiras e equipamentos. Arraste as instâncias para outra posição, remova blocos ou arraste os objetos da pasta `objects/stations` para a room. O jogo respeita o posicionamento do editor, sem reconstruir o cenário ao iniciar.

A camada `Players` define os pontos iniciais das duas jogadoras. A segunda instância é desativada automaticamente no Solo. `Items` recebe os itens que saem do dispenser; também é possível colocar os objetos de lixo e peças manualmente na room.

A fase 3 tem `Stations_Coop` e `Stations_Solo`, com posições e divisórias independentes. No editor, a versão Co-op começa visível; oculte uma camada e mostre a outra para editar cada versão. Em execução, somente as instâncias do modo escolhido permanecem ativas. As propriedades `mode_only` usam 0 para todos os modos, 1 para Co-op Local e 2 para Solo.

Mantenha `obj_recycling_level`, as instâncias de jogadoras e os equipamentos essenciais. Cada fase usa um caminhão compartilhado. O controlador coleta as instâncias no evento Room Start, depois dos eventos Create, inclusive objetos novos acrescentados ao final da ordem de criação.

## Ajustar regras pelo editor

Nas Instance Variables, os equipamentos expõem:

- `capacity`: capacidade da lixeira, dispenser ou caminhão.
- `spawn_interval`: intervalo de geração de itens do dispenser, em segundos.
- `return_duration`: tempo de retorno do caminhão, em segundos.
- `station_width` e `station_height`: dimensões da área de colisão e interação.

`obj_recycling_level` expõe `level_duration`, `minimum_goal`, `star_goal_two`, `star_goal_three`, `robot_minimum`, `robot_star_two`, `robot_star_three` e `overflow_limit`. Cada room já tem os valores correspondentes à sua dificuldade. As filas, os contadores, a montagem e o salvamento continuam sendo lógica GML; as artes e o posicionamento deixam de depender de desenhos e coordenadas gerados por scripts.

Os textos, barras de capacidade e indicadores da interface continuam dinâmicos. Os sprites são placeholders, sem animações novas. Controles atuais (G/H e Num 2/Num 3), saves e código original da rede foram preservados.

## Validação

- `node tools/validate-resources.mjs`: verifica recursos, PNGs, eventos e instâncias.
- Compilação e empacotamento Windows VM.
- Teste executado em uma cópia temporária das cinco fases, Solo/Co-op, menus de personagens, saves, mapa e título.
- Edições de teste pelo arquivo de room/objeto: mover lixeira, alterar capacidade e sprite, remover um bloco e acrescentar outro depois do controlador. Todas foram respeitadas em execução.
- Validados retirada da fila, descarte, sacos, caminhão, robôs, apoio sobre blocos, estrelas e conclusão. Os arquivos reais de save não foram alterados pelos testes.

Prévias: [fase 4](previews/native-sprites-level-04.png) e [cartas](previews/native-sprites-characters.png).
