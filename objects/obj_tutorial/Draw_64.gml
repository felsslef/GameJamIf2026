var panel_left = 140;
var panel_top = 48;
var panel_width = 1000;
var panel_height = 624;
var dark = make_color_rgb(35, 57, 64);
var teal = make_color_rgb(18, 113, 105);
var interact_key = frontend_key_short_name(frontend_keybinding("p1_interact"));
var action_key = frontend_key_short_name(frontend_keybinding("p1_action"));
var dash_key = frontend_key_short_name(frontend_keybinding("p1_dash"));
var p2_interact_key = frontend_key_short_name(frontend_keybinding("p2_interact"));
var first_page_lines = [
    "A Caçamba de Entrada gera sacos de lixo bruto automaticamente a cada 10 segundos.",
    "Se estiver vazia, pressione " + interact_key + " para acionar a alavanca; pressione",
    interact_key + " novamente para pegar o saco e levá-lo à Mesa de Triagem.",
    "J1 " + frontend_player_movement_hint(1),
    "J1 pegar " + interact_key + " | ação " + action_key + " | dash " + dash_key + "."
];
if (global.game_mode == "coop_local") {
    array_push(first_page_lines, "J2 " + frontend_player_movement_hint(2));
    array_push(first_page_lines, "J2 pegar " + p2_interact_key + " | ação " + frontend_key_short_name(frontend_keybinding("p2_action")) +
        " | dash " + frontend_key_short_name(frontend_keybinding("p2_dash")) + ".");
}
array_push(first_page_lines, "O saco bruto ainda não pode ir à prensa nem ser entregue na Expedição.");
var sorting_page_lines = [
    "Coloque o saco bruto sobre a Mesa de Triagem com " + interact_key + ".",
    "De mãos vazias, fique perto da mesa e segure " + action_key + " até a barra encher.",
    "A triagem leva 2 segundos. Soltar o botão pausa o trabalho; o progresso fica.",
    "O saco desaparece e é substituído por um material aleatório:",
    "Plástico sujo, Lixo orgânico ou Lixo eletrônico."
];
if (global.game_mode == "coop_local") {
    array_push(sorting_page_lines, "J2 segura " + frontend_key_short_name(frontend_keybinding("p2_action")) + " para trabalhar também.");
}

var pages = [
    {title: "1. Coleta do lixo bruto", lines: first_page_lines},
    {title: "2. Triagem manual", lines: sorting_page_lines},
    {title: "3. Processamento e limpeza", lines: [
        "Identifique o material e leve-o ao equipamento correto:",
        "Plástico sujo -> Lavadora: automática, 3 s -> Plástico limpo.",
        "Lixo orgânico -> Biodigestor: automática, 4 s -> Biogás / adubo.",
        "Lixo eletrônico -> Desmontagem: segure " + action_key + " por 2,5 s.",
        "O resultado é uma Placa de metal. Retire o material pronto para liberar a máquina."
    ]},
    {title: "4. Prensa hidráulica", lines: [
        "Plástico limpo e Placa de metal precisam passar pela Prensa.",
        "Coloque o material na prensa com " + interact_key + ".",
        "Sem carregar nada, pressione " + action_key + " para acionar a alavanca.",
        "Aguarde 2 segundos: plástico vira Fardo de plástico; metal vira Fardo de metal.",
        "Retire o fardo pronto da prensa. Biogás / adubo não precisa ser prensado."
    ]},
    {title: "5. Expedição e pedidos", lines: [
        "Os pedidos ativos aparecem no alto da tela.",
        "Leve à Expedição um Fardo de plástico, Fardo de metal ou Biogás / adubo",
        "que corresponda a um pedido ativo.",
        "Pedido atendido: ganha 100 pontos e o pedido sai da lista.",
        "Entrega sem pedido correspondente: o item é descartado e você perde 5 s.",
        "A meta desta fase é atender 3 pedidos antes de o tempo acabar."
    ]},
    {title: "6. Cuidado com os imprevistos", lines: [
        "Orgânico no chão por 8 s vira chorume. Pisar na poça atordoa por 2 s.",
        "Recolha ou processe o orgânico rápido; em uma bancada, ele não apodrece.",
        "Eletrônico no chão ou sem processamento por 5 s entra em curto e pega fogo.",
        "Pegue o extintor no suporte e segure " + action_key + " perto do fogo por 1 s.",
        "Depois recolha o eletrônico queimado e descarte-o no lixo comum.",
        "Dica: segure " + action_key + " na Desmontagem para processar o eletrônico a tempo."
    ]}
];

draw_set_alpha(0.62);
frontend_rect(0, 0, 1280, 720, c_black);
draw_set_alpha(1);
draw_sprite_stretched(spr_tutorialFundo, 0, panel_left, panel_top, panel_width, panel_height);
draw_set_color(dark);
draw_rectangle(panel_left, panel_top, panel_left + panel_width, panel_top + panel_height, true);

var page = pages[tutorial_page];
frontend_text(640, 82, "Tutorial da reciclagem", fnt_ui_title, dark, fa_center);
frontend_text(640, 130, page.title, fnt_ui_body, teal, fa_center);
frontend_text(640, 165, "Parte " + string(tutorial_page + 1) + " de " + string(tutorial_page_count), fnt_ui_small, dark, fa_center);

for (var line_index = 0; line_index < array_length(page.lines); line_index++) {
    frontend_text(250, 220 + line_index * 42, page.lines[line_index], fnt_ui_small, dark);
}

frontend_panel(190, 586, 200, 56, tutorial_page > 0 ? c_white : make_color_rgb(225, 225, 215), dark);
frontend_text(290, 601, "Anterior", fnt_ui_body, dark, fa_center);
frontend_panel(890, 586, 200, 56, tutorial_page < tutorial_page_count - 1 ? c_white : make_color_rgb(225, 225, 215), dark);
frontend_text(990, 601, "Próxima", fnt_ui_body, dark, fa_center);
frontend_text(640, 605, "Setas: navegar | Enter / Espaço: começar", fnt_ui_small, dark, fa_center);

draw_set_alpha(1);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
