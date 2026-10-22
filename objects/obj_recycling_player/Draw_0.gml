// Short mint afterimages make the dash direction and speed easy to read.
for (var trail_index = 0; trail_index < array_length(dash_trail_x); trail_index++) {
    var trail_fade = 1 - clamp(dash_trail_age[trail_index] / 0.18, 0, 1);
    var trail_scale = 0.88 + dash_trail_strength[trail_index] * 0.12;
    draw_sprite_ext(sprite_index, image_index, dash_trail_x[trail_index], dash_trail_y[trail_index],
        image_xscale * trail_scale, image_yscale * trail_scale, image_angle,
        make_color_rgb(112, 226, 199), 0.28 * trail_fade * dash_trail_strength[trail_index]);
}
draw_self();

frontend_text(x, y + 8, "J" + string(playerid), fnt_ui_small, make_color_rgb(36,41,40), fa_center);
draw_set_font(-1);
draw_set_color(c_white);
