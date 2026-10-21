var visual = recycling_draw_item_visual(id);
if (item_kind == "bag") frontend_text(x, visual[2] - 12 * visual[1], string(amount), fnt_ui_small, c_white, fa_center);
draw_set_halign(fa_left);
draw_set_color(c_white);
