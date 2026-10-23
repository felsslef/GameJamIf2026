// Short mint afterimages make the dash direction and speed easy to read.
for (var trail_index = 0; trail_index < array_length(dash_trail_x); trail_index++) {
    var trail_fade = 1 - clamp(dash_trail_age[trail_index] / 0.18, 0, 1);
    draw_sprite_ext(sprite_index, image_index, round(dash_trail_x[trail_index]), round(dash_trail_y[trail_index]),
        image_xscale, image_yscale, image_angle,
        make_color_rgb(112, 226, 199), 0.28 * trail_fade * dash_trail_strength[trail_index]);
}
draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale,
    image_angle, image_blend, image_alpha);

frontend_text(round(x), round(y) + 8, "J" + string(playerid), fnt_ui_small, make_color_rgb(36,41,40), fa_center);
processing_draw_station_text_over_player(id);
draw_set_font(-1);
draw_set_color(c_white);
