# Saves e ordem aleatória

Fluxo: menu inicial → modo de jogo → três saves → personagens → fases.

Cada slot oferece continuar/criar e Novo jogo. Um slot ocupado exige clicar novamente em Confirmar antes de substituir o progresso; Esc cancela essa confirmação. A tela também permite salvar manualmente o slot ativo.

O progresso é salvo automaticamente após uma vitória: fases concluídas e melhor quantidade de estrelas por fase. São três arquivos locais (`progress_1.ini`, `progress_2.ini`, `progress_3.ini`) na pasta de dados do jogo gerenciada pelo GameMaker. O save não retoma uma rodada no meio. Os slots são compartilhados entre os modos; a lógica original de rede permanece intacta e o protótipo LAN não emite as vitórias das fases offline.

O desbloqueio de testes Q não é gravado. Carregar ou criar um save desativa esse desbloqueio.

O dispenser usa ciclos embaralhados: quatro tipos na fase 1 e oito na fase 2 (quatro resíduos e quatro peças). Cada ciclo inclui todos os tipos uma vez em ordem aleatória. A fila inicial também é aleatória e a retirada mantém a ordem restante. As imagens representam itens já enfileirados, não sorteios futuros.

Implementação: `scr_save_slots`, `rm_save_select`, `recycling_next_entry()`. A seed é inicializada uma vez por execução.

Validação: compilação Windows VM; teste no runner das três gravações independentes, confirmação de substituição, carregamento, fluxo de telas, salvamento automático de vitória e distribuição dos ciclos embaralhados. Uma segunda execução confirmou persistência após reiniciar. Os testes utilizaram nomes exclusivos de arquivo e removeram esses arquivos ao terminar.
