# Reaproveitamento, robôs e expedição

Nenhum material é consumido pelo lixo comum, incluindo sacos, produtos tratados, componentes, robôs e eletrônicos queimados. Arremessar contra o lixo comum também não descarta. Depois de apagar um incêndio, leve o eletrônico queimado à desmontagem para recuperar componentes utilizáveis.

Ao terminar os três segundos de montagem, a bancada científica libera o robô automaticamente, soma uma produção e uma entrega, toca o som de sucesso e fica livre. O robô tem uma animação curta de partida; não precisa ser carregado nem colocado no caminhão. O tutorial termina essa lição com a saída automática do robô.

Na barra superior, três estrelas mostram as metas da fase e o avanço em cada uma; estrelas alcançadas ficam douradas e o contador informa quantas foram atingidas. O painel de resultado tem 800×440, mantendo margem para todos os botões de vitória.

O caminhão sai para a direita e retorna virado para a esquerda. Seu espaço usa o sprite de chão `spr_truck_dock`, com marcação de carga, em vez de blocos de bancada. A área de colisão da doca permanece editável e mantém a separação cooperativa da fase 3.

A arte da doca está em [truck-dock.png](../assets/source/truck-dock.png); o recurso final está em `sprites/spr_truck_dock/`, em PNG de 128×64 com camada editável. `tools/import-dock-art.ps1` recorta margens transparentes e redimensiona com nearest-neighbor. Foi usada a ferramenta integrada `image_gen`, seguindo a habilidade imagegen. Prompt final:

```text
Use case: stylized-concept. Asset type: ONE flat TOP-DOWN 128x64 pixel-art ground decal sprite for a recycling truck loading bay in a cartoon 2D co-op game. A flat RECTANGULAR horizontal asphalt-grey PARKING / LOADING AREA, width exactly twice height. Thin cream-white painted parking outline with broken yellow painted safety stripes along the two short side edges. One small simple white directional arrow pointing RIGHT painted on the ground. Neutral muted grey-blue asphalt center, subtle pixel texture, clear dark grey border, limited palette, chunky crisp pixel-art designed to remain legible at 128x64. Flush ground marking ONLY, NO vehicles, NO trucks, NO blocks, NO counters, NO raised platform, NO 3D height, NO perspective, NO cones or people, NO text, labels, letters or numbers. Genuine transparent background outside the rectangle, isolated centered with minimal even transparent margin. Camera straight down overhead. Clean, simple, unobtrusive game sprite, appropriate to replace ugly counter blocks under an animated truck.
```
