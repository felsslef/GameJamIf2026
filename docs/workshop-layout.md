# Estrutura das arenas

> Edição atual: sprites e instâncias estão no editor do GameMaker. Capacidades, metas e posições são configuradas nas rooms; consulte [gamemaker-editor.md](gamemaker-editor.md).


As cinco fases usam uma área de trabalho com bancadas nas bordas, piso quadriculado, equipamentos integrados ao perímetro e ilhas centrais. As bancadas livres têm 64x64 e permitem colocar e pegar um item com E / Enter.

- Fases 1 e 2: pequena ilha junto ao dispenser, circulação dos dois lados.
- Fase 3: mantém os lados separados em Co-op Local; o caminhão compartilhado ocupa uma abertura própria na divisória. No Solo, a passagem permanece livre.
- Fase 4: duas ilhas curtas com corredores entre elas.
- Fase 5: ilha em U, com caminhos contornando a bancada.

Metas, capacidades, controles, salvamento e regras de cada fase permanecem os mesmos. O posicionamento está nas rooms e a arte usa sprites editáveis. `scr_workshop_layout` apenas coleta as instâncias já colocadas no editor.

Validação: compilação Windows VM, execução das cinco fases em Co-op Local e da fase 3 em Solo; conferência visual e busca de caminhos em grade de 8 pixels usando as colisões reais. Foram verificados pontos iniciais livres, equipamentos acessíveis, ausência de sobreposições e circulação compartilhada, com separação somente na fase 3 em dupla.

Prévias: [fase 4](previews/workshop-level-04.png), [fase 5](previews/workshop-level-05.png).
