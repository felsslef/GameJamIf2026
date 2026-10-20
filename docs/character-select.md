# Character selection

`rm_character_select` now presents one independently controlled card per local
player. Solo has one centered card. Local co-op has two cards side by side and
processes both input sets during the same Step event. LAN has one local card;
no remote readiness synchronization or network changes are introduced.

## Controls

| Action | Player 1 | Player 2 (local co-op) |
| --- | --- | --- |
| Previous / next scientist | A / D | Left / right |
| Turn card to read biography | W / S | Up / down |
| Confirm / undo confirmation | E | Enter |

Solo accepts either input set: A/D or left/right to choose, W/S or up/down to
turn, E or Enter to confirm. Space or the Continue button opens the map once
all visible slots are ready. Esc and the upper-left arrow return to game modes.
F11 remains the only fullscreen control.

With the mouse, use each card's arrows to choose, click the card to turn it,
and click the name/status underneath to confirm or undo.

## Card states

- An unconfirmed card shows the scientist's name underneath.
- Confirmation changes that text to `Pronto` and locks character cycling.
- A ready card can still turn to show the biography.
- Confirming again removes readiness and allows cycling.
- Each player has separate choice, readiness, card side and flip timer.
- The short flip animation compresses the card and swaps its visible face at
  the midpoint. Reduced-motion mode switches faces immediately.
- A scientist confirmed by one player cannot be confirmed by the other. Cycling
  skips the other ready player's scientist. If both confirm the same scientist
  in one frame, the first slot claims it and the second receives a brief notice.
- No automatic transition hides `Pronto`. Players explicitly choose Continue.

Confirmed choices are copied into `global.frontend_characters` only when the
team continues to the map. Going back from the map restores those choices and
asks both players to confirm again. There is no longer a sequential player-1
then player-2 selection step.

## Implementation

`scr_character_select` owns card layout, button actions, independent keyboard
input, readiness, flip animation and rendering. The existing frontend controller
routes the character screen to this script. Other screens and the original
13 gameplay/network GML files remain unchanged.

Character illustrations are still simple procedural placeholders. Biographies
are the existing fictional draft biographies, pending the real text.

## Validation

An isolated temporary GameMaker runtime probe passed these scenarios:

- Opposite WASD/arrow choices and flips in the same frame.
- Simultaneous E/Enter confirmation and independent cancellation.
- Ready labels remain visible; ready cards turn but cannot change character.
- Duplicate confirmation is rejected without committing pending selections.
- Both selections are committed together on Continue, then the map opens.
- Map Back restores both cards; Esc returns to mode selection.
- Solo has one card, supports both input sets and cannot continue unconfirmed.
- Card/status mouse actions, reduced-motion flipping and F11 work.
- LAN displays one local card and leaves networking unchanged.

The project compiles/packages with runtime 2024.14.4.268. Test input overrides
exist only in the temporary probe, not in the actual project.
