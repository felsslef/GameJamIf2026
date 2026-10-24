# Trilha sonora — Coleta Maluca

Duas composições instrumentais originais, sintetizadas localmente, sem samples externos ou músicas de terceiros:

| Faixa | Recurso | Andamento | Duração | Uso |
| --- | --- | --- | --- | --- |
| Coleta Maluca — Tema | `mus_coleta_theme` | 140 BPM | 54,86 s | Menus e resultados |
| Mutirão a Todo Vapor | `mus_recycling_rush` | 168 BPM | 45,71 s | Tutorial e fases |

As faixas usam melodias próprias em quatro seções, baixo pulsante, acordes em contratempo, bateria sintetizada, arpejos e pequenas viradas. O tema é mais aberto; a música de fase tem mais subdivisões e percussão, para reforçar o ritmo frenético. Ambas têm 32 compassos em 4/4 e repetição contínua, incluindo o eco que atravessa a emenda do loop.

Arquivos de áudio:

- `sounds/mus_coleta_theme/mus_coleta_theme.wav`
- `sounds/mus_recycling_rush/mus_recycling_rush.wav`

São WAVs estéreo, 44,1 kHz, 16 bits. O GameMaker os comprime na compilação. Pico de áudio limitado a 0,88, sem clipping. A composição e a síntese podem ser reproduzidas com `node tools/compose-music.mjs`.

`session_music_update`, em `scr_session_ui`, administra as faixas no controlador persistente: troca suave entre menus e fases, redução de volume durante diálogos e pausa, preservação da música entre telas do mesmo tipo e encerramento dos canais antigos. As configurações oferecem volumes geral, de música e de efeitos entre 0% e 100%, aplicados imediatamente e salvos em `audio.ini`. Os efeitos preservam a proporção original do mix. As mesmas opções estão disponíveis pelo menu de pausa.

## Urgência e história

O tremor e o flash vermelho usam `recycling_urgency_pulse`, com pulsos de 0,24 s nos últimos 10 segundos. A amplitude máxima passou de 1,5/3 para 6/10 pixels, ficando mais intensa nos cinco segundos finais. Reduzir movimento mantém o tremor desativado.

A primeira fala de Ju começa com “Depois da temporada”.
