# Fases 4 e 5 — arenas abertas

> Edição atual: sprites e instâncias estão no editor do GameMaker. Capacidades, metas e posições são configuradas nas rooms; consulte [gamemaker-editor.md](gamemaker-editor.md).


Martim de Sá (fase 4) e Massaguaçu (fase 5) combinam as mecânicas de reciclagem e construção da fase 2. Não há divisória, lados exclusivos ou blocos de troca. Cada fase mantém quatro lixeiras, um dispenser misto, duas bancadas e uma área de entrega de robôs. Disponíveis em Solo e Co-op Local; rede mantém o protótipo original.

| Configuração | Fase 4 | Fase 5 |
|---|---|---|
| Tempo | 120 s | 120 s |
| 1 estrela: resíduos / robôs | 16 / 3 | 20 / 4 |
| 2 estrelas: resíduos / robôs | 24 / 4 | 28 / 5 |
| 3 estrelas: resíduos / robôs | 32 / 5 | 36 / 6 |
| Intervalo entre itens | 1,8 s | 1,5 s |
| Capacidade do dispenser | 7 | 6 |
| Tolerância cheio | 10 s | 8 s |
| Capacidade do caminhão | 12 | 9 |
| Retorno do caminhão | 10 s | 12 s |

As duas metas são obrigatórias ao fim do tempo. Resíduos contam no envio do caminhão; robôs contam na entrega. A montagem continua exigindo quatro tipos de peça, demora três segundos e ocupa a bancada até retirar o robô. A fila aleatória usa ciclos completos para garantir disponibilidade dos tipos.

Vitórias salvam conclusão e melhores estrelas no slot ativo. A fase 4 libera a fase 5; a vitória na fase 5 registra a última fase da campanha. O atalho Q continua disponível no mapa para testar todas as fases sem gravar o desbloqueio artificial.

Configuração nas variáveis das instâncias de cada room. Salas: `rm_level_04` e `rm_level_05`, ambas 1280x720. As fases 1–3 mantêm suas regras.

Validação: compilação Windows VM e teste de entrada pelo mapa, ausência de divisória, passagem livre, configuração de cada dificuldade, montagem e entrega, exigência das duas metas, vitória, estrelas e modos Solo/Co-op Local.
