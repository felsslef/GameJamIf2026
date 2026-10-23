# Alertas e incêndio no tutorial

Os nomes das bancadas, máquinas e suporte do extintor não aparecem mais por proximidade. As barras de trabalho e informações de capacidade continuam disponíveis.

Nos dois segundos finais antes de estragar ou queimar, o material recebe uma exclamação em sprite, desenhada no Draw GUI acima das personagens:

- Orgânico no chão: aviso antes de virar chorume.
- Eletrônico no chão ou na bancada: aviso antes de pegar fogo.
- Materiais carregados e orgânicos guardados nas bancadas não recebem alertas indevidos.

O ícone oscila quatro pixels para cima e para baixo. Com Reduzir movimento, ele fica parado. A função `processing_warning_remaining` usa os mesmos limites do processamento real; não altera os tempos dos materiais.

O tutorial agora tem oito etapas. Após as sete entregas guiadas, um eletrônico fica em uma bancada de apoio e mostra o alerta por dois segundos. Um incêndio controlado começa, o suporte do extintor aparece e o jogador precisa buscar a ferramenta, aproximar-se do fogo, segurar o botão de pegar para apagá-lo e devolver o extintor. Só então o tutorial é concluído e salvo. Os demais riscos e o cronômetro continuam desativados nessa fase de aprendizado.

## Sprite

`sprites/spr_ui_warning/spr_ui_warning.yy`: ícone PNG 32 × 32, substituível no editor de sprites.

Gerado com a ferramenta integrada de imagens (skill imagegen). Prompt final:

> One tiny clean game HUD warning icon, chunky pixel art cartoon, bold dark teal exclamation mark centered on a golden yellow diamond with thick dark outline, small cream highlight at top edge, front facing flat 2D, very simple readable at 32x32 pixels, only one exclamation mark, no other text no scene no extra objects. Transparent background and narrow transparent margins.
