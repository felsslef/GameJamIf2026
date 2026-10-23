if (online_game() && !global.is_host) exit;
var frame_dt = max(0, delta_time / 1000000);

// Age out old trail samples, then add the item's current position while flying.
var fresh_trail_x = [];
var fresh_trail_y = [];
var fresh_trail_age = [];
var fresh_trail_power = [];
for (var trail_index = 0; trail_index < array_length(throw_trail_x); trail_index++) {
    var sample_age = throw_trail_age[trail_index] + frame_dt;
    if (sample_age < 0.18) {
        array_push(fresh_trail_x, throw_trail_x[trail_index]);
        array_push(fresh_trail_y, throw_trail_y[trail_index]);
        array_push(fresh_trail_age, sample_age);
        array_push(fresh_trail_power, throw_trail_power[trail_index]);
    }
}
throw_trail_x = fresh_trail_x;
throw_trail_y = fresh_trail_y;
throw_trail_age = fresh_trail_age;
throw_trail_power = fresh_trail_power;

if (is_thrown && throw_peak_spd > 0) {
    var trail_power = clamp(throw_spd / throw_peak_spd, 0, 1);
    var trail_count = array_length(throw_trail_x);
    if (trail_power > 0.03 && (trail_count == 0
        || point_distance(x, y, throw_trail_x[trail_count - 1], throw_trail_y[trail_count - 1]) >= 4)) {
        array_push(throw_trail_x, x);
        array_push(throw_trail_y, y);
        array_push(throw_trail_age, 0);
        array_push(throw_trail_power, trail_power);
    }

    var max_trail_count = 3 + ceil(trail_power * 6);
    trail_count = array_length(throw_trail_x);
    if (trail_count > max_trail_count) {
        var trimmed_x = [];
        var trimmed_y = [];
        var trimmed_age = [];
        var trimmed_power = [];
        for (var keep_index = trail_count - max_trail_count; keep_index < trail_count; keep_index++) {
            array_push(trimmed_x, throw_trail_x[keep_index]);
            array_push(trimmed_y, throw_trail_y[keep_index]);
            array_push(trimmed_age, throw_trail_age[keep_index]);
            array_push(trimmed_power, throw_trail_power[keep_index]);
        }
        throw_trail_x = trimmed_x;
        throw_trail_y = trimmed_y;
        throw_trail_age = trimmed_age;
        throw_trail_power = trimmed_power;
    }
}

if (is_held) {
    if (instance_exists(holder)) {
        // Keep the item centered on the player's hand line, in the facing direction.
        // The small upward correction aligns it with the hands instead of the feet.
        x = holder.x + lengthdir_x(22, holder.move_dir);
        y = holder.y + lengthdir_y(22, holder.move_dir) - 8;
        // Items in front of the character when facing down, behind when facing up.
        depth = -y - 2;
    } else {
        is_held = false;
        holder = noone;
    }
} else if (is_thrown) {
    // Build up speed briefly, then slow down from friction.
    throw_age += frame_dt;
    if (throw_age < throw_accel_duration) {
        throw_spd = throw_peak_spd * (throw_age / throw_accel_duration);
    } else {
        throw_spd = max(0, throw_spd - 700 * frame_dt);
    }
    var travel = throw_spd * frame_dt;
    var start_x = x;
    var start_y = y;
    var next_x = x;
    var next_y = y;
    var min_x = 64 * room_width / 1280;
    var max_x = room_width - min_x;
    var min_y = 154 * room_height / 720;
    var max_y = room_height - 56 * room_height / 720;
    var level = obj_recycling_level;
    var segments = max(1, ceil(travel / 8));
    var hit_station = noone;
    var hit_edge = false;

    // Substeps prevent a fast throw from skipping a small interactable station.
    for (var step_index = 1; step_index <= segments; step_index++) {
        var progress = step_index / segments;
        next_x = start_x + lengthdir_x(travel * progress, throw_dir);
        next_y = start_y + lengthdir_y(travel * progress, throw_dir);
        if (next_x < min_x || next_x > max_x || next_y < min_y || next_y > max_y) {
            next_x = clamp(next_x, min_x, max_x);
            next_y = clamp(next_y, min_y, max_y);
            hit_edge = true;
            break;
        }
        for (var i = 0; i < array_length(level.stations); i++) {
            var station = level.stations[i];
            if (station.station_kind != "divider" && recycling_station_distance(next_x, next_y, station) <= 8) {
                hit_station = station;
                break;
            }
        }
        if (hit_station != noone) break;
    }

    x = next_x;
    y = next_y;
    if (hit_station != noone) {
        is_thrown = false;
        throw_spd = 0;
        if (recycling_thrown_item_can_interact(id, hit_station)) {
            recycling_thrown_item_interact(id, hit_station);
        }
    } else if (hit_edge) {
        is_thrown = false;
        throw_spd = 0;
    } else {
        if (throw_spd <= 0) is_thrown = false;
    }
    depth = -y - 2;
} else depth = -y - 2;
