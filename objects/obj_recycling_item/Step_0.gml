if (is_held) {
    if (instance_exists(holder)) {
        x = holder.x + lengthdir_x(20, holder.move_dir);
        y = holder.y - 38;
        depth = holder.depth - 2;
    } else {
        is_held = false;
        holder = noone;
    }
} else depth = -y - 2;
