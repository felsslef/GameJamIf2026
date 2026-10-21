# Segunda fase — reciclagem e construção

Indaiá mantém as quatro lixeiras, os sacos, o caminhão e as regras de reciclagem de Porto Novo. A construção é acrescentada à mesma rodada, em Solo e Co-op Local. O código original de rede permanece inalterado.

Um único dispenser mistura lixo e peças eletrônicas na mesma fila. Os códigos internos 0–3 representam resíduos e 4–7 representam circuito, bateria, motor e carcaça. A retirada preserva a ordem exibida. O primeiro ícone está contornado.

- Tempo: 120 segundos.
- Meta mínima: 12 resíduos enviados pelo caminhão **e** 2 robôs entregues.
- Estrelas: 12 resíduos + 2 robôs; 21 + 3; 30 + 4.
- Dispenser: capacidade 8; um item a cada 2 segundos, com lixo e peças em ciclos embaralhados. Cheio por 12 segundos encerra a rodada.
- Lixeiras: capacidade 3. Os sacos devem ser carregados no caminhão e enviados para contar como reciclados.
- Caminhão: capacidade 12; retorno em 8 segundos.
- Duas bancadas recebem uma peça de cada tipo. A montagem leva 3 segundos e a bancada fica ocupada até retirar o robô.
- Robôs devem ser levados à área de entrega. O contador de robôs é separado do contador de reciclagem.
- Peças repetidas e itens incompatíveis são recusados sem consumo. Itens podem ser colocados no chão e recuperados.

As duas metas são avaliadas ao final do tempo. Concluir desbloqueia o terceiro ponto, ainda um protótipo. Progresso salvo no slot selecionado. Consulte [save-slots.md](save-slots.md).

J1: WASD, G para dash e H para a??o. J2: setas, NumPad 1 para dash e NumPad 2 para a??o. Esc: pausa. F11: tela cheia.

Configuração adicional: `construction_level_init()` em `scripts/scr_construction/scr_construction.gml`. A primeira fase mantém seus valores.

Validação em cópia temporária: compilação Windows VM e execução da fila mista, separação nas lixeiras, montagem, entrega, saco/caminhão, contadores independentes, exigência das duas metas e regressão da fila da primeira fase.
