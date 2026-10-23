# Coleta Maluca

O título e os nomes de exibição das plataformas foram atualizados. O arquivo do projeto continua `GameJamIf2026.yyp`.

## História

- Fase 1: Ju, Lê, Manu e Maria apresentam a poluição causada pelos humanos, o cuidado com Caraguá, a separação dos resíduos e a construção de robôs.
- Fase 2: as cientistas explicam como os componentes recuperados permitem construir robôs para automatizar o trabalho. O diálogo valoriza suas ideias, inteligência e colaboração.
- Vitória na fase 5: diálogo de encerramento, seguido de uma cena de quatro robôs recolhendo resíduos na praia. Depois de dez segundos, Continuar abre o resultado da fase. Derrotas não exibem o encerramento.

Use Enter, Espaço ou clique em Continuar. As falas aparecem novamente ao repetir essas fases. O cronômetro, o movimento e o processamento ficam suspensos durante a história. Após os diálogos iniciais vem a contagem regressiva normal. O progresso da vitória é salvo antes do encerramento.

As falas aparecem letra por letra (42 caracteres por segundo), com pequenas pausas na pontuação e um som curto de escrita (`snd_dialogue_blip`). O botão mostra “Mostrar tudo” enquanto a fala é escrita: Enter, Espaço ou clique revelam o restante sem avançar. Um segundo comando avança a conversa. A quebra de linhas é calculada antes da animação, evitando que as palavras mudem de posição. Reduzir movimento revela o texto imediatamente, sem os sons de escrita.

Textos e animação: `scripts/scr_story/scr_story.gml`. Os robôs e resíduos da cena usam sprites existentes; a praia é uma nova imagem. A opção de reduzir movimento também se aplica aos robôs da cena.

Os nomes usam a fonte própria `fnt_dialogue_name` (Segoe Print Bold, 24 pt), com atlas PNG incluído no projeto e suporte aos acentos. O nome aparece diretamente no painel, sem placa verde, separado do retrato e da fala por margens. Para reconstruir somente essa fonte: execute `tools/render-ui-fonts.ps1 -Fonts fnt_dialogue_name`.

Os retratos dos diálogos usam `spr_portrait_ju`, `spr_portrait_le`, `spr_portrait_manu` e `spr_portrait_maria`: PNGs de 64 × 64 recortados das sprites existentes, mostrando só a cabeça em uma moldura quadrada. Podem ser substituídos no editor de sprites sem alterar os desenhos de corpo inteiro usados nas fases.

## Dispenser

O aviso aparece somente perto da caçamba, acima dela, no Draw GUI. Mostra a ocupação e Cheia!/Há espaço. A prévia flutuante da fila e o aviso inferior foram removidos; a personagem não cobre o painel.

## Novas sprites

- `sprites/spr_ui_stone_button`: botão principal cinza pedra, cartoon, sem texto gravado. Estados de foco e pressão usam a mesma imagem com tonalidade e deslocamento.
- `sprites/spr_story_beach`: cenário da cutscene final, 1280 × 720.

Imagens geradas com a ferramenta integrada de geração de imagens (skill imagegen), importadas como PNGs e recursos GameMaker. Os prompts finais foram:

**Botão:** One single blank wide horizontal rounded rectangular game UI button, front view, friendly cartoon grey stone, smooth pale warm gray center with plenty of empty space for a text label, chunky charcoal outline, beveled light top edge and dark lower edge, restrained tiny chips only at corners, simple clean pixel art suitable for 320x80 sprite, no text no symbols no other objects. Button fills canvas with narrow transparent margin. Transparent background.

**Praia:** Game background only, landscape 16:9, simple charming pixel art Brazilian beach inspired by Caraguatatuba: turquoise sea in upper third, green Serra do Mar mountains on distant horizon, broad pale golden sandy beach filling lower two thirds, small palms at far sides. Straight-on elevated top-down game view, bright friendly cartoon palette, clean open sand for animated characters. No people, no robots, no objects on sand, no text no UI. Full bleed background.

Também foram restaurados caminhos ausentes de imagens de camada das sprites da Maria usando os PNGs já existentes, sem alterar a arte.
