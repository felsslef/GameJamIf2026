# Ícone, opções e progresso

- `art/app_icon.png`: arte transparente do símbolo de reciclagem robótico.
- `options/windows/icons/icon.ico`: ícone Windows com imagens de 16, 24, 32, 48, 64, 128 e 256 pixels.
- `options/linux/icons/64.png`: ícone Linux.

As opções Windows e Linux apontam para os arquivos locais e iniciam em tela cheia. F11 continua alternando a tela; não há botão de tela cheia. Os testes automáticos usam uma cópia em janela para não mudar a tela de trabalho.

Opções e configuração de teclas reutilizam a arte do laboratório, com painéis creme/verde e botões legíveis. As áreas de interação e os comandos foram mantidos.

O contador de entregas, tanto na partida quanto no resultado, usa a meta da terceira estrela como denominador. Exemplo: metas 4/6/8 e sete entregas resultam em `7/8`. Os requisitos para vencer e ganhar estrelas não foram alterados.

As mensagens rotineiras de ações deixaram de ser exibidas no rodapé. As instruções guiadas do tutorial continuam. As barras de processamento, trabalho manual, combate ao fogo, estado pronto e capacidade das lixeiras são desenhadas no Draw GUI, acima das personagens, com o ícone do material. O alerta de superaquecimento fica acima desse painel.

O ícone foi gerado pela ferramenta integrada de imagens (skill imagegen), com este prompt final:

> Standalone app icon for the game Coleta Maluca. A bold clearly recognizable recycling symbol made of three curved teal green metallic robot arrows chasing in a triangle, mechanical joints and small cream highlights, a tiny friendly dark robot face with two cyan eyes inside the triangle. Chunky clean cartoon pixel art, thick dark teal outline, simple readable silhouette at 32x32, bright mint and green palette, front view flat 2D, centered square composition with narrow safe margin. No words no letters no additional symbols no scenery. Transparent background.
