# Fase 3 — de mão em mão

Centro tem dois dispensers independentes e uma divisória de blocos. Em Co-op Local, J1 permanece à esquerda e J2 à direita. A divisória bloqueia caminhada e dash de ponta a ponta.

- Esquerda: lixeiras de papel e plástico.
- Direita: lixeiras de vidro e metal.
- Os dois dispensers fornecem os quatro tipos em ciclos aleatórios independentes.
- A divisória inteira usa blocos iguais de 64x64, cada um com capacidade para um item. Todos usam a mesma aparência e o mesmo comando de colocar e pegar.
- Com um item nas mãos, aproxime-se do bloco e use E (J1) ou Enter (J2) para colocá-lo. A outra jogadora usa seu comando com as mãos vazias para pegar.
- Bloco ocupado recusa um segundo item. Sacos também podem ser passados. A retirada esvazia o espaço antes de entregar o item, evitando duplicação.
- O caminhão é compartilhado e pode ser acessado pelos dois lados da divisória. Carga, envio, capacidade 12 e retorno de 8 segundos seguem as fases anteriores.
- Cada dispenser tem capacidade 8 e gera um resíduo a cada 4 segundos. Qualquer um cheio por 12 segundos encerra a rodada.
- Tempo: 2 minutos. Estrelas: 12, 21 e 30 resíduos enviados pelo caminhão. Não há exigência de robôs nesta fase.
- Uma vitória salva o progresso no slot ativo e libera a fase 4, ainda um protótipo.

No Solo há uma passagem abaixo dos blocos, permitindo acessar as quatro lixeiras e os dois dispensers com uma personagem. A mecânica de troca continua disponível.

Recursos: `rm_level_03`, `scr_split_level`; esta fase reutiliza o controlador, os jogadores e as estações de reciclagem. A lógica original de rede permanece intacta; o caminho LAN continua usando o protótipo existente.

Validação: compilação Windows VM e teste no runner de divisão dos jogadores, lixeiras por lado, fila e temporizador independentes, transferência completa de resíduo, descarte no lado oposto, caminhão compartilhado, dash bloqueado, derrota por sobrecarga, vitória/desbloqueio e passagem Solo.
