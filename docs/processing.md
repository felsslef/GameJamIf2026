# Coleta, separação e tratamento

A prensa foi retirada. Plástico limpo e biogás/adubo vão ao caminhão; robôs saem automaticamente ao terminar a montagem na bancada científica. Nenhum material pode ser descartado no lixo comum. Veja [recycling-feedback.md](recycling-feedback.md).

## Primeira fase

Porto Novo tem quatro lixeiras, uma caçamba, triagem, lavadora, biodigestor, duas bancadas de apoio e caminhão. A fila mistura os quatro recicláveis e sacos brutos; a triagem produz plástico sujo ou orgânico. Eletrônicos, desmontagem, fogo e extintor entram a partir da fase 2.

Pegue o reciclável, coloque na lixeira correspondente, retire o saco com as mãos vazias e entregue ao caminhão. A lixeira tem capacidade 3 e recusa itens extras sem destruir o que está na mão. É possível retirar um saco parcial. A quantidade é preservada na bancada e ocupa a mesma quantidade de espaços no caminhão compartilhado. Cada saco ou produto tratado conta uma entrega, independentemente do material.

## Fases seguintes

As fases 2–5 misturam papel, plástico reciclável, vidro, metal reciclável e sacos brutos na mesma fila. A ordem desenhada corresponde à retirada. Materiais já separados vão às lixeiras; sacos brutos passam pela triagem manual.

| Entrada | Trabalho | Produto entregue |
| --- | --- | --- |
| Papel, plástico reciclável, vidro ou metal reciclável | Lixeira da cor correspondente; retirar o saco | Saco separado |
| Saco bruto → plástico sujo | Segurar Pegar na triagem por 2 s; lavadora automática por 3 s | Plástico limpo |
| Saco bruto → orgânico | Segurar Pegar na triagem por 2 s; biodigestor automático por 4 s | Biogás / adubo |
| Saco bruto → eletrônico | Triagem manual por 2 s; desmontagem por 2,5 s; bancada científica por 3 s | Robô de limpeza |

Cada máquina comporta um material e fica livre após retirar o resultado. O mesmo botão pega, coloca e trabalha: toque para interagir, mantenha pressionado para trabalho manual ou extintor. Soltar o botão ou sair do alcance pausa o trabalho preservando o progresso. Duas jogadoras não aceleram a mesma bancada no mesmo frame. A caçamba gera automaticamente; quando vazia, interagir também gera um item. Matérias-primas não são aceitas na expedição.

O jogo monta a lista de materiais a partir das lixeiras e máquinas presentes na room. A caçamba nunca gera materiais sem equipamento correspondente. A triagem embaralha os materiais disponíveis sem excluir algum indefinidamente.

Uma entrega válida incrementa o contador e toca `snd_delivery_success`. Não há pedidos, descarte por falta de pedido ou penalidade de tempo. O caminhão tem limite compartilhado e tempo de retorno: ao encher, sai automaticamente; com as mãos vazias, é possível enviá-lo antes. Sacos que não cabem e entregas durante a viagem são recusados sem consumo do item.

## Metas

As cinco fases duram 120 segundos. As metas contam entregas de qualquer material finalizado. É possível continuar entregando após atingir o mínimo, até o relógio terminar. Caçamba cheia por tempo excessivo ainda causa derrota. Vitórias salvam a conclusão e as melhores estrelas no slot ativo.

| Fase | Local | 1 estrela | 2 estrelas | 3 estrelas | Intervalo por caçamba |
| --- | --- | --- | --- | --- | --- |
| 1 | Porto Novo | 3 | 5 | 7 | 10 s |
| 2 | Indaiá | 4 | 6 | 8 | 9 s |
| 3 | Centro | 5 | 7 | 9 | 12 s; duas caçambas |
| 4 | Martim de Sá | 6 | 8 | 10 | 8 s |
| 5 | Massaguaçu | 7 | 9 | 12 | 7 s |

O tutorial fica separado, no ponto T, sem relógio de derrota e sem incidentes. Ele ensina sete entregas guiadas e salva sua conclusão separadamente das fases. Veja [tutorial.md](tutorial.md).

## Incidentes nas fases com tratamento

Orgânico no chão por 8 segundos vira chorume; no colo ou na bancada ele não deteriora. A poça atordoa por 2 segundos ao entrar nela, inclusive durante o dash. Permanecer sobre a mesma poça não causa atordoamento infinito.

Eletrônico parado por 5 segundos incendeia. Apague com o extintor segurando Pegar por 1 segundo, devolva a ferramenta e leve o item à desmontagem para recuperar os componentes. Não existe descarte de materiais no lixo comum.

A fase 3 mantém duas lixeiras de cada lado e a divisão no Co-op Local. Qualquer bancada permite passar itens e sacos; no Solo, a passagem entre os lados permanece aberta.

## Edição e apresentação

Lixeiras, bancadas e máquinas usam sprites e colisões de 64×64. O caminhão tem dois módulos; a área de entrega da fase dividida preserva o bloqueio cooperativo. Instâncias, posições, capacidade e duração continuam editáveis no GameMaker. Veja [modular-art.md](modular-art.md) e [sprites.md](sprites.md).

Os rótulos e detalhes da fila aparecem somente para a estação ao alcance de interação. Cores, pictogramas e avisos de cheio permitem reconhecer o restante. Somente o tutorial mostra funções dos botões. As teclas são configuráveis nas opções: no padrão, J1 usa WASD e Shift esquerdo para pegar/colocar/trabalhar; J2 usa setas e Shift direito. Ctrl arremessa. O dash funciona com dois toques na mesma direção em até 0,25 s; Alt continua como atalho configurável. Toques, recarga e colisões são independentes por jogadora.

Validação: `tools/run-game-tests.ps1 -Suite processing`, `-Suite tutorial` e `-Suite production` compilam e verificam cópias isoladas de teste ou o projeto real. `node tools/validate-resources.mjs` valida sprites, objetos e rooms.
