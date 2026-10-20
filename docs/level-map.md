# Caraguá level-map screen

The map uses completion flags loaded from one of three local saves. Offline levels 1 and 2 update and save these flags on victory. Levels 3?5 remain prototypes. Q unlocks all stops for testing without writing that unlock to disk. See `docs/save-slots.md`.

The screen has five illustrated coastal stops: Porto Novo, Indaiá, Centro,
Martim de Sá and Massaguaçu. The background is a fictional cartoon inspired by
Caraguatatuba, not a geographic/navigation map. Locations were ordered along
the coastal route using the municipal coastal-management reference:
https://www.gov.br/gestao/pt-br/assuntos/patrimonio-da-uniao/destinacao-de-imoveis/gestao-de-praias/pgi_sp_caraguatatuba.pdf

## Presentation states

`global.frontend_level_completed` contains five booleans, initially all false.
The first flag is now updated by a first-level win. Later flags are still future UI data; none are persisted to disk.

- The first stop is available; later stops display padlocks.
- A later stop is available when the preceding stops are marked completed.
- Unfinished routes are dotted; routes after completed stops become continuous.
- Completed stops use a green pin and check mark.
- Locked stops can be inspected; their Jogar action is blocked in the menu.

The first-level result supplies its completion flag. There is deliberately no button,
shortcut or fake victory that unlocks stops in the actual game.
A zero-based illustrative preview state would be:

```gml
global.frontend_level_completed = [true, true, false, false, false];
```

This displays completed stops 1-2, an available stop 3 and locked stops 4-5.
Changing this display data does not implement level completion or save a game.

## Rendering

- `spr_caragua_map`: generated cartoon background, copied into the project.
- `scr_level_map`: code-drawn pins, locks, routes, labels and bottom controls.
- `level_nodes` in `scr_frontend_data`: UI-space marker centers, at 1280x720.
- `frontend_level_is_available`: controls menu presentation and entry gating.

F11 remains the only fullscreen control. Esc returns to scientist selection.
Original gameplay and networking GML are unchanged. The first available stop opens `rm_level_01` offline; other stops use `rm_teste`. LAN retains its existing lobby/prototype path.

## Validation

GameMaker runtime 2024.14.4.268 compiled and packaged the project successfully.
A temporary runtime probe checked the initial locked states, blocked entry into
a locked stop, illustrative one/two-stop completion states, entry into an
available stop, absence of automatic gameplay completion, F11 and Esc.
The test passed. All original GML files were verified unchanged.

- `docs/previews/level-select.png`: actual initial state.
- `docs/previews/level-select-locked.png`: inspecting a locked stop.
- `docs/previews/level-select-progress.png`: example future completion state,
  set only by the temporary test; it is not saved or enabled by gameplay.

The source artwork and the final generation/edit prompt are in `docs/map-art.md`.

Atalho de testes: pressione Q no menu de fases para liberar todos os pontos durante a sessão. O atalho não marca fases como concluídas e não altera as linhas de progresso. As fases 3 a 5 continuam usando o protótipo existente.
