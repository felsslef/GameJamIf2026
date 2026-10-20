function split_level_init() {
    dispenser.x = 405; dispenser.y = 255; dispenser.depth = -dispenser.y;
    var right_dispenser = recycling_create_station("dispenser", 875, 255, 160, 100);
    dispensers = [dispenser, right_dispenser];
    for (var i = 0; i < 2; i++) {
        var source = dispensers[i];
        source.capacity = 8;
        source.spawn_bag = [];
        source.spawn_timer = 4;
        source.overflow_elapsed = 0;
        source.queue = [];
        repeat (4) array_push(source.queue, split_level_next(source));
    }
    for (var i = 0; i < 4; i++) {
        bins[i].x = i < 2 ? 190 : 1090;
        bins[i].y = i mod 2 == 0 ? 240 : 450;
        bins[i].depth = -bins[i].y;
    }
    var coop = global.game_mode == "coop_local";
    truck.y = 576;
    truck.station_height = 128;
    truck.depth = -truck.y;
    var block_size = 64;
    var block_count = coop ? ceil(room_height / block_size) : 7;
    for (var i = 0; i < block_count; i++) {
        var block_y = block_size / 2 + i * block_size;
        if (coop && abs(block_y - truck.y) < block_size / 2 + truck.station_height / 2) continue;
        var counter = recycling_create_station("handoff", 640, block_y, block_size, block_size);
        counter.stored_item = undefined;
        counter.depth = -counter.y;
    }
    with (obj_recycling_player) {
        x = playerid == 1 ? 430 : 850;
        y = 430;
    }
    feedback = coop ? "Coloque o lixo no bloco para a outra jogadora pegar." : "Passe por baixo dos blocos para acessar as outras lixeiras.";
    feedback_timer = 6;
}

function split_level_next(_source) {
    if (array_length(_source.spawn_bag) == 0) {
        _source.spawn_bag = [0, 1, 2, 3];
        for (var i = 3; i > 0; i--) {
            var swap_index = irandom(i);
            var temp = _source.spawn_bag[i];
            _source.spawn_bag[i] = _source.spawn_bag[swap_index];
            _source.spawn_bag[swap_index] = temp;
        }
    }
    return array_pop(_source.spawn_bag);
}

function split_level_tick(_dt) {
    for (var i = 0; i < 2; i++) {
        var source = dispensers[i];
        source.spawn_timer -= _dt;
        while (source.spawn_timer <= 0 && array_length(source.queue) < source.capacity) {
            array_push(source.queue, split_level_next(source));
            source.spawn_timer += spawn_interval;
        }
        if (array_length(source.queue) >= source.capacity) {
            source.spawn_timer = max(0, source.spawn_timer);
            source.overflow_elapsed += _dt;
        } else source.overflow_elapsed = 0;
        if (source.overflow_elapsed >= overflow_limit) {
            recycling_finish(false, "Um dos dispensers ficou cheio por muito tempo.");
            return;
        }
    }
    if (time_remaining <= 0) recycling_finish(recycled_total >= minimum_goal,
        recycled_total >= minimum_goal ? "Mutirão concluído!" : "A meta de reciclagem não foi atingida.");
}

function split_level_handoff(_player, _counter) {
    if (instance_exists(_player.carried_item)) {
        if (!is_undefined(_counter.stored_item)) { recycling_feedback("Bloco ocupado. Use o outro espaço."); return; }
        var item = _player.carried_item;
        _counter.stored_item = {kind: item.item_kind, trash_type: item.trash_type, amount: item.amount};
        recycling_consume_item(_player);
    } else if (!is_undefined(_counter.stored_item)) {
        var stored = _counter.stored_item;
        // Clear first so simultaneous commands cannot duplicate the item.
        _counter.stored_item = undefined;
        recycling_give_item(_player, stored.kind, stored.trash_type, stored.amount);
    } else recycling_feedback("Coloque um item aqui para passar ao outro lado.");
}

function split_level_draw_station() {
    var dark = make_color_rgb(35, 57, 64);
    frontend_panel(x - station_width / 2, y - station_height / 2,
        station_width, station_height, make_color_rgb(139, 159, 156), dark);
    frontend_rect(x - station_width / 2 + 5, y - station_height / 2 + 5,
        station_width - 10, 5, make_color_rgb(184, 200, 195));
    if (!is_undefined(stored_item)) {
        recycling_draw_item(x, y - 3, stored_item.kind, stored_item.trash_type, stored_item.amount);
    }
}
