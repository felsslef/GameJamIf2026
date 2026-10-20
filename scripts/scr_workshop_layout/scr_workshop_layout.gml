/// Shared workshop structure: workstations around the perimeter, counters and open aisles.
function workshop_layout_init() {
    // The cooperation level keeps its exclusive bins, sources and central divider.
    if (level_index != 2) {
        for (var i = 0; i < 4; i++) {
            bins[i].x = i < 2 ? 96 : 1184;
            bins[i].y = i mod 2 == 0 ? 320 : 448;
            bins[i].depth = -bins[i].y;
        }
        truck.y = 608;
        truck.depth = -truck.y;
        with (obj_recycling_station) {
            if (station_kind == "bench") {
                x = x < 640 ? 416 : 864;
                y = 192;
                depth = -y;
            }
            if (station_kind == "storage") { x = 1056; y = 608; depth = -y; }
        }
        with (obj_recycling_player) {
            x = playerid == 1 ? 352 : 928;
            y = 512;
        }
    }
    for (var tile_x = 96; tile_x <= 1184; tile_x += 64) {
        workshop_add_counter(tile_x, 192);
        workshop_add_counter(tile_x, 608);
    }
    for (var tile_y = 256; tile_y < 608; tile_y += 64) {
        workshop_add_counter(96, tile_y);
        workshop_add_counter(1184, tile_y);
    }
    // Short islands guide routes without dividing the players into separate areas.
    if (level_index == 0 || level_index == 1) {
        workshop_add_counter(608, 416);
        workshop_add_counter(672, 416);
    } else if (level_index == 3) {
        for (var tile_y = 384; tile_y <= 448; tile_y += 64) {
            workshop_add_counter(448, tile_y);
            workshop_add_counter(832, tile_y);
        }
    } else if (level_index == 4) {
        for (var tile_y = 384; tile_y <= 448; tile_y += 64) {
            workshop_add_counter(512, tile_y);
            workshop_add_counter(768, tile_y);
        }
        workshop_add_counter(576, 448);
        workshop_add_counter(640, 448);
        workshop_add_counter(704, 448);
    }
}

function workshop_add_counter(_x, _y) {
    // Leave equipment footprints free instead of stacking counters underneath them.
    for (var i = 0; i < array_length(stations); i++) {
        var station = stations[i];
        if (abs(_x - station.x) < 32 + station.station_width / 2
            && abs(_y - station.y) < 32 + station.station_height / 2) return noone;
    }
    var counter = recycling_create_station("handoff", _x, _y, 64, 64);
    counter.stored_item = undefined;
    return counter;
}
