# Frontend

Open `GameJamIf2026.yyp` in GameMaker. The first room is `rm_main_menu`.
The working title is **Maré da Ciência**. New code/resource names are English;
player-facing strings are Brazilian Portuguese.

## Screens

The title follows the supplied sketch: white background, centered title and
three outlined buttons (Jogar, Opções, Sair). The other menus stay minimal. The level screen uses an illustrated coastal map.

- `rm_game_mode`: Solo, Co-op Local, Co-op Rede.
- `rm_character_select`: one card in solo/LAN, two independent simultaneous cards in local co-op. Turn a card to read its biography and confirm to show Pronto. See `docs/character-select.md`.
- `rm_level_select`: cartoon Caraguá map, connected stops, padlocks and Jogar/Voltar. See `docs/level-map.md`.
- `rm_options`: menu-animation preference for this session.
- `rm_level_01`: first playable offline round, with dispenser, four bins, truck, two-minute timer and a recycling target. See `docs/first-level.md`.
- `rm_menu`: existing LAN lobby with a minimal visual overlay. Original discovery,
  create/join handling and mouse hitboxes remain in `obj_menu`.

## Controls

- Mouse, WASD or arrows select ordinary menu buttons; Enter/Space activates.
- Character cards use independent controls: P1 A/D choose, W/S turn, E confirm; P2 left/right choose, up/down turn, Enter confirm. Space continues once all are ready.
- Esc returns to the previous screen, including the LAN lobby. Returning from the map restores the simultaneous cards.
- F11 toggles fullscreen in every room, including gameplay and the pause menu.
- Fullscreen is controlled only with F11; there is no fullscreen button.
- Esc during gameplay opens a menu with Continuar and Tela inicial. Esc again
  resumes; Tela inicial leaves the current session and returns to the title.

## Gameplay menu

`obj_session_ui` is persistent and rejects duplicate instances. It is placed in
`rm_main_menu` and `rm_teste`, so running the test room directly works too.
Its Begin Step event handles F11 and the in-game menu. Draw GUI End renders
the gameplay menu above the other UI.

Solo and local co-op pause by deactivating the other room instances and drawing
a cached application-surface frame. Closing the menu restores the instances.
The menu tolerates a lost snapshot surface, including fullscreen changes.

In LAN mode the menu does not stop the shared game or network controller.
Only the local player's input behavior is temporarily replaced, then restored;
`is_local`, packet formats and network events remain unchanged. Returning to the
title closes the session's TCP handles; room exit releases the room's UDP
broadcaster. LAN discovery Esc closes the listener before returning to levels.

## Source layout

- `scr_frontend_data`: palette, scientist/level data, button positions.
- `scr_frontend_navigation`: selection, Esc navigation and prototype handoff.
- `scr_character_select`: independent card input, readiness, flipping and layout.
- `scr_frontend_draw`: simple UI and procedural 32x32 scientist placeholders.
- `scr_level_map`: illustrated map, marker states, routes and locked-stop entry handling.
- `scr_recycling_level` / `scr_recycling_draw`: first-level gameplay and provisional rendering.
- `scr_session_ui`: fullscreen shortcut, gameplay menu and session exit.
- `obj_frontend`: per-screen input/rendering controller.
- `obj_lobby_ui`: visual and Esc adapter for the original lobby.
- `obj_session_ui`: persistent fullscreen/gameplay-menu controller.
- `fnt_ui_small`, `fnt_ui_body`, `fnt_ui_title`: compiled Portuguese-capable fonts.

The original 13 GML files, including `obj_menu`, `obj_network`, player creation,
movement and item logic, remain byte-for-byte unchanged. `rm_teste` gains only
the UI controller instance. The original lobby remains immediately before
`rm_teste` in room order, preserving its `room_goto_next()` behavior.

## Scope

Stops 1 and 2 are playable offline. Wins save completion and best stars to the selected slot. Stops 3?5 remain prototypes; LAN retains its original path. See [save-slots.md](save-slots.md) for the three-slot screen between modes and characters.

`global.frontend_level` and `global.frontend_characters` retain zero-based menu
selections. The first offline level draws the selected scientist; the old prototype does not. Selections are not synchronized
over LAN. Scientist specialties and biographies are fictional placeholders for
the real biographies. No final character sprites were created. The level map uses a generated background asset; its source and prompt are recorded in `docs/map-art.md`.

## Validation

The project compiles/packages with runtime 2024.14.4.268. An isolated temporary
runtime probe uses controlled keyboard input to exercise Esc navigation, F11 in
menus/lobby/gameplay/pause, biography toggling,
selection restoration, solo/local player counts, duplicate scientist handling,
pause/resume, title return and the persistent-controller singleton.

The LAN host prototype is also checked for continuing network steps while its
menu is open, restoring local input on resume, closing session handles on title
return and reopening discovery after Esc. A real two-computer join session has
not been tested. No test input overrides are included in the actual project.

Screenshots in `docs/previews` show the current screens.


A segunda fase offline (Indai?) agora inclui montagem e entrega de rob?s. Consulte [second-level.md](second-level.md) para receita, metas e controles.

A fase 3 offline agora possui dois dispensers e troca de itens sobre blocos, com lados separados em Co-op Local e passagem no Solo. Consulte [third-level.md](third-level.md).


All five offline stages are now playable. Stages 4 and 5 combine recycling and robot construction in open arenas with higher goals and tighter logistics. See [final-levels.md](final-levels.md). The original LAN prototype remains separate.

As arenas agora usam bancadas no perimetro e ilhas centrais para organizar os corredores, mantendo os graficos simples. Veja [workshop-layout.md](workshop-layout.md).
