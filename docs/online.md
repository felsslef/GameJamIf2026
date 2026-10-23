# Co-op Rede atualizado

O lobby reutiliza o laboratório, a logo e os botões de pedra. Criar sala abre diretamente a escolha das cientistas; a outra jogadora entra pela descoberta de salas na mesma rede. As mensagens de falha aparecem no lobby. A seleção online usa os comandos da Jogadora 1 em cada computador, ou clique nas cartas; ambas precisam confirmar antes do mapa. A anfitriã escolhe e inicia a fase.

O computador anfitrião executa a simulação das duas jogadoras. O cliente envia comandos normalizados de movimento, dash, interação e arremesso; não executa outra simulação independente. A anfitriã envia atualizações a cada 50 ms, incluindo personagens, itens carregados/lançados, fila da caçamba, máquinas, fogo, chorume, robôs, caminhão, cronômetro, estrelas, diálogos e resultados. As réplicas de itens são reutilizadas; carregamento e suporte do extintor são associados às instâncias locais.

A fase 3 usa a divisão cooperativa também na rede. A anfitriã controla diálogos, repetição, próxima fase e retorno ao mapa. A outra jogadora acompanha as transições e vê o aviso de espera no resultado. Ao perder a conexão, a fase para e mostra um aviso; Esc permite sair pelo menu. O menu de pausa bloqueia apenas os comandos da jogadora que o abriu. O modo online não transforma a pausa em uma pausa global da partida.

TCP 6510 para a sessão; UDP 6511 para descoberta. A conexão síncrona do cliente é confirmada pelo primeiro pacote de estado da anfitriã. Não há matchmaking pela internet nem reconexão automática.

## Verificação

`tools/run-online-tests.ps1` compila uma cópia isolada e abre duas instâncias reais via TCP em 127.0.0.1. Verifica entrada remota e transmissão do progresso de uma bancada, pontuação e presença das duas personagens. Fixtures em `tests/online`. As suítes existentes de processamento e tutorial verificam que o modo local continua funcionando.

O teste local não substitui uma sessão em dois computadores: descoberta UDP, permissões de firewall e latência da rede física ainda precisam ser conferidas nesse ambiente. A implementação prioriza consistência; não usa previsão do movimento no cliente.
