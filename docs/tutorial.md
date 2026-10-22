# Tutorial prático separado

O tutorial é a room `rm_tutorial`, representada por T no mapa, antes da fase 1. Confirmar as personagens abre o mapa; no Co-op Local, ambas devem estar prontas. O jogador escolhe Tutorial ou uma das cinco fases e aperta Jogar. O tutorial pode ser repetido e não bloqueia a primeira fase.

A mesma caçamba, as lixeiras e as máquinas das fases são usadas no treino. As etapas esperam ações reais, sem páginas de texto:

1. Caminhar até a caçamba e pegar papel.
2. Colocar na lixeira azul, retirar o saco e entregá-lo ao caminhão.
3. Repetir com plástico reciclável, vidro e metal, apresentando uma lixeira por vez.
4. Pegar um saco misturado, colocá-lo na triagem e segurar o botão de pegar para separar.
5. Lavar o plástico sujo e entregar o plástico limpo diretamente ao caminhão.
6. Processar orgânico no biodigestor e entregar biogás/adubo sem prensa.
7. Desmontar o eletrônico, colocar os componentes na bancada científica e aguardar três segundos: o robô sai automaticamente e conclui a etapa.

São sete entregas guiadas: quatro sacos separados e três produtos de tratamento. Não há prensa nem compactação. A caçamba fornece somente o material da etapa atual. As estações usam módulos quadrados de 64×64 e aparecem conforme são necessárias. A seta aponta ao próximo objeto; a dica mostra só a ação atual e respeita as teclas configuradas. Errar uma lixeira mantém o item; itens no chão ou nas bancadas podem ser recuperados por qualquer jogadora. A revelação de máquinas mantém as personagens fora das áreas de colisão.

O treino usa os mesmos handlers de interação, montagem dos sacos, bancadas, tratamento e expedição das fases. Não há cronômetro de derrota, acúmulo automático ou incidentes durante o aprendizado. O arremesso permanece desabilitado no treino. O dash funciona por toque duplo na direção, como nas fases. Pausa e F11 continuam disponíveis. As fases normais mantêm limite das lixeiras, caminhão compartilhado, meta de entregas, relógio e incidentes, sem uma lista fixa de funções dos botões.

A conclusão registra `tutorial_completed` no slot ativo, separadamente das cinco fases e de suas estrelas. Os saves antigos continuam usando os mesmos índices de fase. A fase 1 (`rm_level_01`) voltou a ser a partida normal de Porto Novo, com dois minutos e metas 3/5/7.

Objetos e sprites são recursos reais, editáveis nas rooms. O fluxo está em `scr_tutorial_flow`; `obj_tutorial` é colocado no editor da room. Veja [recycling-art.md](recycling-art.md) e [sprites.md](sprites.md).

Validação: `node tools/validate-resources.mjs`. `node tools/prepare-processing-tests.mjs tutorial` prepara uma cópia em TEMP para testar seleção/mapa, as sete entregas guiadas, teclas configuradas, capacidade dos sacos/caminhão, fila, saves antigos e dupla. A suíte padrão de processamento continua cobrindo os tratamentos, incidentes, metas e circulação nas outras fases. O código original de rede permanece separado.
