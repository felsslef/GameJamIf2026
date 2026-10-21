# First playable level: Porto Novo

> Edição atual: sprites e instâncias estão no editor do GameMaker. Capacidades, metas e posições são configuradas nas rooms; consulte [gamemaker-editor.md](gamemaker-editor.md).


Enter stop 1 from the map in Solo or Co-op Local. It now opens `rm_level_01`.
LAN still opens the unchanged `rm_menu` -> `rm_teste` prototype; the new station,
bin, timer and score state is not synchronized by the existing LAN protocol.
No original network or gameplay GML was changed.

## Round rules

- Duration: 120 active seconds. The pause menu stops the offline round timer.
- Minimum: 12 waste units sent for recycling before time runs out.
- Dispenser: starts with one of each type, produces another unit every 4 seconds
  in a repeating four-type sequence, and holds at most 8 units.
- A full dispenser shows a 12-second warning. Remaining full for that long ends
  the round in defeat. Taking a unit clears the warning counter.
- Four bins: paper (blue), plastic (red), glass (green), metal (yellow).
- Each bin holds 3 units. Wrong-type waste or an extra unit in a full bin is
  rejected; the player keeps the held item.
- With empty hands, interact with a nonempty bin to carry its contents as a bag.
  Partial bags are allowed; the amount in the bag is preserved.
- Truck: capacity 12 units. It accepts bags, not loose unsorted waste. A bag that
  does not fit is rejected intact, with no partial/truncated load.
- With empty hands, interact with a loaded truck to send it for recycling.
  Scoring happens once at dispatch. The truck returns after 8 seconds and cannot
  accept new bags while absent. Its parked load alone does not count as recycled.
- Reaching the minimum does not end the round early: keep the dispenser clear
  until the timer expires. Overflow is still a defeat even after meeting the goal.
- End-of-round stars: 12 / 21 / 30 recycled units award 1 / 2 / 3 stars.
- A win marks stop 1 completed, opens playable stop 2 and saves completion and best stars to the selected slot. See `save-slots.md`.

## Controls

| Action | Solo / local player 1 | Local player 2 |
| --- | --- | --- |
| Move | WASD | Arrow keys |
| Pick up, place, take bag, send truck | H | NumPad 3 |
| Dash | G | NumPad 2 |

Interact near the station (within 58 pixels of its boundary). With an item and
no nearby station, the command drops it on the floor; the same command picks it
up again within 42 pixels. Loose items are preferred when within pickup range.
Players and loose items cannot duplicate the same held item through simultaneous
pickup. Station footprints and arena boundaries block player movement.

Esc opens the existing pause menu and can return to the title. F11 is the only
fullscreen control. After the round, choose Tentar de novo / Mapa; R retries and
Enter or Esc returns to the map. The pause menu does not cover the result screen.

## Resources

- `rm_level_01`: 1280x720 offline room with controller and pause manager.
- `obj_recycling_level`: round configuration, dispenser/truck ticking, score,
  spawning, results and HUD.
- `obj_recycling_station`: dispenser, typed bins and truck instances.
- `obj_recycling_player`: child of the existing `obj_player`. It inherits the
  original Create and Step, but supplies the level-specific behavior through
  the existing `estado` function field and draws the selected scientist.
- `obj_recycling_item`: loose waste, carried waste and filled bags.
- `scr_recycling_level`: round/interaction/movement logic.
- `scr_recycling_draw`: sprite drawing and dynamic HUD.

All balancing values are at the start of `recycling_level_init` in
`scripts/scr_recycling_level/scr_recycling_level.gml`.
The 13 original GML files remain unchanged, including original movement,
throw/dash behavior and every original networking event. The old prototype still
uses its original controls; this new first level uses the single-command scheme.

## Validation

GameMaker runtime 2024.14.4.268 compiled and packaged the project. An isolated
temporary runtime probe passed:

- Map handoff, timer/goal initialization, Solo and two-player Local spawning.
- FIFO pickup, correct placement, rejection of wrong/full bins, floor drop/re-pickup.
- Bag extraction, partial bag quantities, truck capacity, absence/return,
  dispatch-only scoring and repeated-command protection against double scoring.
- Walking/collision, independent P2 controls and shared dispenser pickup.
- Paused timer, overflow relief, overflow defeat and timeout below target.
- Win and session-only map unlock, retry reset, 1/3-star thresholds, result navigation
  and F11 on results.

Test fixtures and synthetic keyboard overrides exist only in the temporary copy.
This is a functional first pass with simple procedural art; final gameplay sprites,
LAN station synchronization and the remaining playable levels are
not implemented here.

## Dash nas fases 1 e 2

Pressione G para J1 ou NumPad 2 para J2 no Co-op Local. O dash usa a direção atual ou a última direção ao parar. Segurar a tecla não repete o dash. Usa os atributos herdados do jogador original: velocidade 12, duração 8 frames e intervalo entre ativações de 25 frames, com referência de 60 FPS. O dash mantém a direção escolhida e verifica a colisão em passos curtos. Cada jogadora tem seu próprio estado; a pausa congela esses temporizadores.

Validação no runner: toque simples, direções diferentes, toques espaçados, velocidade/duração herdadas, recarga, colisão com dispenser e estados independentes em Co-op Local. A lógica original de rede e do protótipo permanece intacta.

As fases 1 e 2 usam arenas de 1600×900, com câmera mostrando toda a área em um viewport de 1280×720. O HUD continua em 1280×720. Equipamentos e pontos iniciais são distribuídos proporcionalmente; o piso e os limites acompanham as dimensões da room. A movimentação passou para 6 e o dash para 18 pixels por frame de referência (60 FPS). A duração e a recarga do dash foram mantidas. Esses valores são específicos de `obj_recycling_player`.

O tamanho das fases 1 e 2 voltou para 1280x720, incluindo a camera. A distribuicao proporcional retorna os equipamentos as posicoes anteriores. Velocidade 6 e dash 18 foram mantidos.
