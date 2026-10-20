if (is_held && instance_exists(holder)) {
    // Posição controlada pelo player
} 
else if (is_thrown) {
    var vx = lengthdir_x(throw_spd, throw_dir);
    var vy = lengthdir_y(throw_spd, throw_dir);

    var hit_list = move_and_collide(vx, vy, obj_wall);

    // Colisão e rebate com paredes
    if (array_length(hit_list) > 0) {
        if (place_meeting(x + vx, y, obj_wall)) {
            throw_dir = 180 - throw_dir;
        }
        if (place_meeting(x, y + vy, obj_wall)) {
            throw_dir = 360 - throw_dir;
        }
        throw_spd *= 0.6; // Perda de velocidade no impacto
    }

    // Fricção no chão (reduz a velocidade a cada frame)
    throw_spd -= 0.4;

    // Quando o movimento fica quase nulo, o item para de deslizar
    if (throw_spd <= 0) {
        throw_spd = 0;
        is_thrown = false;
    }
}