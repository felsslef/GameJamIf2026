# Tutorial prático separado

O tutorial é a room `rm_tutorial`, representada por T no mapa, antes da fase 1. Confirmar as personagens abre o mapa; no Co-op Local, ambas devem estar prontas. O jogador escolhe Tutorial ou uma das cinco fases e aperta Jogar. O tutorial pode ser repetido e não bloqueia a primeira fase.

A mesma caçamba, as lixeiras e as máquinas das fases são usadas no treino. As etapas esperam ações reais, sem páginas de texto:

1. Executar um dash com deslocamento real. A dica mostra o toque duplo na direção e o atalho configurado; se o toque duplo estiver desativado, mostra apenas direção e atalho. Caminhar sem dash não avança. Qualquer jogadora pode completar a etapa em dupla.
2. Caminhar até a caçamba e pegar papel.
3. Colocar na lixeira azul, retirar o saco e entregá-lo ao caminhão.
4. Com as mãos vazias, interagir novamente com o caminhão para despachar a primeira carga e aguardar seu retorno. A próxima caçamba só é abastecida depois disso.
5. Repetir com plástico reciclável, vidro e metal, apresentando uma lixeira por vez.
6. Pegar um saco misturado, colocá-lo na triagem e segurar o botão de pegar para separar.
7. Lavar o plástico sujo e entregar o plástico limpo diretamente ao caminhão.
8. Processar orgânico no biodigestor e entregar biogás/adubo sem prensa.
9. Desmontar o eletrônico, colocar os componentes na bancada científica e aguardar três segundos: o robô sai automaticamente e conclui a etapa.
10. Observar o aviso de superaquecimento, buscar o extintor, apagar o foco antes de 20 segundos e devolver a ferramenta ao suporte. Ignorar esse limite causa derrota também no tutorial.

São sete entregas guiadas: quatro sacos separados e três produtos de tratamento. Não há prensa nem compactação. A caçamba fornece somente o material da etapa atual. As estações usam módulos quadrados de 64×64 e aparecem conforme são necessárias. A seta aponta ao próximo objeto; a dica mostra só a ação atual e respeita as teclas configuradas. Errar uma lixeira mantém o item; itens no chão ou nas bancadas podem ser recuperados por qualquer jogadora. A revelação de máquinas mantém as personagens fora das áreas de colisão.

O treino usa os mesmos handlers de interação, montagem dos sacos, bancadas, tratamento e expedição das fases. Não há limite de duração da rodada, acúmulo automático ou incidentes aleatórios. O foco de fogo da última lição tem o mesmo limite de 20 segundos das fases, com aviso visível e derrota se for ignorado. O arremesso permanece desabilitado no treino. O dash funciona por toque duplo na direção, como nas fases. Pausa e F11 continuam disponíveis e pausam também a contagem do incêndio no modo local.

A conclusão registra `tutorial_completed` no slot ativo, separadamente das cinco fases e de suas estrelas. Os saves antigos continuam usando os mesmos índices de fase. A fase 1 (`rm_level_01`) voltou a ser a partida normal de Porto Novo, com dois minutos e metas 3/5/7.

Com Daltonismo ativado, as instruções identificam as lixeiras pelas mesmas formas e siglas dos materiais, em vez de depender da cor. A dificuldade do save não aumenta as metas do tutorial.

Prévias: [aprendizado do dash](previews/tutorial-dash.png), [despacho da primeira carga](previews/tutorial-dispatch.png) e [tutorial concluído](previews/tutorial-complete.png).

Objetos e sprites são recursos reais, editáveis nas rooms. O fluxo está em `scr_tutorial_flow`; `obj_tutorial` é colocado no editor da room. Veja [recycling-art.md](recycling-art.md) e [sprites.md](sprites.md).

Validação: `node tools/validate-resources.mjs` e `tools/run-game-tests.ps1 -Suite tutorial`. O teste usa uma cópia em TEMP para verificar seleção/mapa, as sete entregas guiadas, despacho manual e retorno do caminhão, combate ao fogo, teclas configuradas, capacidade dos sacos/caminhão, fila, saves antigos e dupla. `-Suite incidents` verifica o prazo do fogo e a derrota no tutorial. Os saves de teste usam nomes isolados.
