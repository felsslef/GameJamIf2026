# Saves e ordem aleatória

Fluxo: menu inicial → modo de jogo → três saves → dificuldade (somente ao criar) → personagens → fases.

Cada slot oferece continuar/criar e excluir. Um slot ocupado exige confirmar a exclusão; Esc cancela essa confirmação. Criar um slot vazio abre a escolha de dificuldade, sem gravar nada até a escolha. Voltar deixa o slot vazio. Continuar carrega diretamente a dificuldade gravada e segue para as personagens. A tela também permite salvar manualmente o slot ativo.

Cada save tem uma única dificuldade, fixa desde a criação. Ela aparece no cartão do slot, no mapa, no HUD e no resultado. Não há troca de dificuldade nas configurações.

| Dificuldade | Metas de entregas e estrelas | Metas da fase 1 (pontos) |
| --- | --- | --- |
| Fácil | Valores atuais do editor | 300 / 500 / 700 |
| Médio | 1,5 × os valores atuais, arredondados para cima | 500 / 800 / 1100 |
| Difícil | 2 × os valores atuais | 600 / 1000 / 1400 |

Cada entrega vale 100 pontos. Duração das fases, geração de materiais, capacidade e riscos mantêm as regras atuais. O tutorial mantém as mesmas metas nas três dificuldades. As metas são calculadas a partir das propriedades da room ao entrar, sem acumular multiplicadores em repetições.

O formato de save é versão 3, com `save.difficulty` (`easy`, `medium`, `hard`). Saves anteriores sem esse campo são lidos como Fácil, preservando progresso e estrelas. O salvamento automático respeita a dificuldade já presente no arquivo; criar sobre um slot existente é recusado. Na rede, mapa e partida seguem a dificuldade da anfitriã sem substituir a dificuldade do save local da convidada.

O progresso é salvo automaticamente após uma vitória: fases concluídas e melhor quantidade de estrelas por fase. São três arquivos locais (`progress_1.ini`, `progress_2.ini`, `progress_3.ini`) na pasta de dados do jogo gerenciada pelo GameMaker. O save não retoma uma rodada no meio. Os slots são compartilhados entre os modos; a lógica original de rede permanece intacta e o protótipo LAN não emite as vitórias das fases offline.

O desbloqueio de testes Q não é gravado. Carregar ou criar um save desativa esse desbloqueio.

O dispenser usa ciclos embaralhados: quatro tipos na fase 1 e oito na fase 2 (quatro resíduos e quatro peças). Cada ciclo inclui todos os tipos uma vez em ordem aleatória. A fila inicial também é aleatória e a retirada mantém a ordem restante. As imagens representam itens já enfileirados, não sorteios futuros.

Implementação: `scr_save_slots`, `rm_save_select`, `recycling_next_entry()`. A seed é inicializada uma vez por execução.

Validação: `tools/run-game-tests.ps1 -Suite progression` verifica escolha/cancelamento, três dificuldades em slots independentes, carregamento, dificuldade fixa, migração de saves antigos, vitória nas novas metas e as três metas das cinco fases em cada dificuldade. Os testes usam arquivos isolados e os removem ao terminar. `tools/run-online-tests.ps1` verifica uma anfitriã no Médio com convidada cujo save local permanece no Fácil.

Prévias: [escolha de dificuldade](previews/difficulty-selection.png) e [dificuldades nos slots](previews/save-difficulties.png).
