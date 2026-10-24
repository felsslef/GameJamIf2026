# Interface e animações

As trocas entre menus, mapa e fases usam uma passagem lateral em verde-água, com faixas de verde claro e areia, em vez de escurecer a tela. Cada metade dura 0,36 segundo, com curva gradual de aceleração e desaceleração. A troca ocorre com a tela coberta; comandos repetidos são bloqueados e o cronômetro offline não avança durante a transição. F11 continua disponível. A opção de reduzir animações faz a troca imediata. O overlay pertence ao objeto persistente `obj_session_ui` e também cobre os atalhos de voltar, reiniciar e retornar ao título.

Resultados de vitória mostram “Próxima fase”, além de repetir e voltar ao mapa. Enter avança; Esc abre o mapa. No tutorial, avançar abre a fase 1; na fase 5 não há próxima fase. Derrotas não permitem avançar. Os botões ficam ativos quando termina a entrada animada do painel.

A caçamba mostra ocupação, fila, barra de chegada e segundos até o próximo item somente quando alguma jogadora está a até 28 pixels da borda e a caçamba é sua estação de interação. Cheia, troca a cor do painel e mostra o tempo restante antes da sobrecarga. No tutorial, a indicação acompanha a etapa guiada em vez de sugerir geração automática. Os itens são exibidos em 48 pixels nas mãos e no chão, cerca de 39 nas bancadas, 40 no dispenser e no inventário e 36 na prévia da fila, preservando proporção e colisões.

O caminhão sai pela direita ao enviar a carga e retorna à doca no fim do tempo de viagem. Cada trecho dura até 0,8 segundo, com aceleração e desaceleração suaves. A animação usa o sprite existente e acompanha `trip_remaining`, inclusive durante pausas. A doca e sua colisão permanecem no lugar. Com animações reduzidas, o caminhão desaparece e reaparece suavemente sem deslocamento.

Nos últimos 10 segundos, o cronômetro pulsa junto de um tremor curto da câmera e um pulso vermelho suave. Nos últimos 5 segundos o tremor aumenta levemente. A opção de reduzir animações desativa tremor, pulsos e saltos.

A tela de resultado compartilha o mesmo cartão nas fases e no tutorial: faixa com nome do bairro, estrelas grandes com metas, resumo de entregas, robôs e pontos, e destaque para a próxima fase. A entrada do painel, as estrelas e os confetes respeitam a opção de reduzir animações. As teclas Enter, R e Esc e os botões de próxima fase, repetição e mapa continuam disponíveis. A derrota por incêndio mostra a causa e permite tentar novamente.

A opção Daltonismo fica nas configurações do menu inicial e da pausa. É salva em `controls.ini`, seção `accessibility`, chave `colorblind`. Ela acrescenta marcadores de alto contraste às lixeiras, materiais separados, sacos e inventário: círculo/PAP, triângulo/PLA, losango/VID e quadrado/MET. As barras de materiais também recebem uma paleta alternativa. As instruções do tutorial usam as mesmas siglas quando a opção está ativa. [Prévia](previews/colorblind-gameplay.png).

Quando o relógio zera, `spr_ui_timeout` entra com um salto e mostra “Tempo esgotado!” por 1,25 segundo. Depois, o painel de resultado desliza e as estrelas aparecem em sequência. Os botões do resultado ficam disponíveis após o aviso. Derrota por caçamba cheia abre o resultado sem mostrar um aviso falso de tempo esgotado.

Os painéis têm cantos arredondados, sombra e contraste. As fontes `fnt_ui_small`, `fnt_ui_body` e `fnt_ui_title` usam Trebuchet MS com suavização. Os atlas PNG e as métricas foram regenerados por `tools/render-ui-fonts.ps1`. A fonte precisa estar instalada para regenerar esses atlas; o jogo distribuído usa as imagens prontas.

A barra superior tem um espaço de inventário de 48×48 por jogadora, mostrando o sprite do material carregado. Ao segurar o comando de arremesso, uma barra mostra a carga. Soltar lança o item na direção em que a personagem olha. As teclas configuradas são preservadas: no padrão, Ctrl esquerdo para J1 e Ctrl direito para J2. O extintor continua sendo usado pelo botão de pegar.

O arremesso voltou à lógica anterior: velocidade inicial zero, aceleração original e desativação no tutorial. O código original de rede não foi alterado.

O relógio é um recurso PNG de 96×96, com camada editável em `sprites/spr_ui_timeout/`. `tools/import-ui-clock.ps1` registra sua construção como ícone simples; o jogo usa o sprite pronto.
