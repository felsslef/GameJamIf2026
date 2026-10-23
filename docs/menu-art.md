# Arte dos menus

As três imagens foram geradas pela ferramenta integrada (skill imagegen) e importadas como sprites GameMaker com PNGs de frame e camada. A logo tem transparência real. Os fundos têm 1280 × 720; a logo, 640 × 224. Os controles e a seleção simultânea continuam com a mesma lógica.

## spr_menu_background

Recurso: `sprites/spr_menu_background/spr_menu_background.yy`.

Prompt final:

> Create a full bleed 16:9 background illustration for the main menu of a Brazilian cooperative recycling game. Charming simple chunky pixel art, cartoon proportions, limited warm palette, inspired by Caraguatatuba beach: turquoise ocean, soft green Serra do Mar mountains and small coastal town in background, sand and coastal promenade foreground. LEFT EDGE a friendly little recycling robot collecting a discarded bottle beside blue red green and yellow square recycling bins. RIGHT EDGE a small scientific workbench with reused electronic components and a palm tree. No human characters. Composition crucial: the entire middle 40 percent of the image is quiet uncluttered pale sandy promenade, with no objects, enough clear space for three centered vertically stacked menu buttons between y=300 and y=570. Upper center is quiet pale sky for a separate game logo at y=25 to 260. Avoid white blank canvas, use warm sandy cream and turquoise. Broad simple shapes, not overly detailed or painterly, no text no lettering no UI no logo. Landscape 16:9.

## spr_character_background

Recurso: `sprites/spr_character_background/spr_character_background.yy`.

Prompt final:

> Create a full bleed landscape 16:9 game character selection background. Friendly simple chunky pixel art cartoon environmental science workshop in Caraguatatuba Brazil, matching a colorful recycling cooperative game. Cozy mint and teal laboratory with warm wood floor, broad windows across upper wall showing blue ocean and green coastal mountains. Decorative scientific equipment, potted plants, tools and recovered electronics confined to extreme LEFT and RIGHT edges. Empty middle 75 percent, especially x=200 to1080 y=120 to660, deliberately low contrast muted pale seafoam wall and warm light wood floor with very little detail, to keep two character cards and instructions readable. No people no robots no text no lettering no cards no interface. Soft cheerful daylight, broad readable shapes, restrained details, no white blank background. Landscape16:9.

## spr_game_logo

Recurso: `sprites/spr_game_logo/spr_game_logo.yy`.

Prompt final:

> A standalone game title logo reading exactly 'COLETA MALUCA', spelled correctly, only these two words, arranged on two centered lines COLETA above MALUCA. Friendly energetic chunky hand-lettered cartoon pixel-art lettering with a clean dark teal outline and small offset shadow, cream highlights. Top word turquoise green, lower word sunny golden yellow, gentle irregular letter angles but excellent readability. Two tiny thematic accents only: a sprouting green leaf and a small silver gear at sides, not replacing letters. Suitable for a Brazilian cooperative recycling videogame. Wide compact silhouette, front-facing flat 2D, crisp limited-palette pixel art, no fine texture no subtitle no frame no background scene no extra text. Transparent background with generous transparent margins.

A tela inicial usa a logo e a orla. A seleção usa o laboratório, com cartões em creme e verde e painéis de contraste para os nomes e comandos. As artes podem ser substituídas no editor de sprites do GameMaker.

## Seleção de modo e saves

A seleção de modo usa a orla e três cartões com as sprites das cientistas, uma descrição curta e botões de pedra. A seleção de saves usa o laboratório e três cartões com fases concluídas, estrelas, indicação do arquivo em uso e ações de continuar/criar/novo jogo. A confirmação para substituir um save continua funcionando e recebe destaque em coral. O rodapé mantém Voltar e Salvar progresso, quando disponível.

Essas telas reutilizam as sprites existentes. O desenho está em `frontend_draw_journey_select`, no script `scr_frontend_draw`; as áreas clicáveis acompanham os novos cartões. O formato dos saves e as ações de carregamento, criação e gravação permanecem os mesmos.
