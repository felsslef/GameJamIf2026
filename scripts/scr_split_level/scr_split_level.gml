/// Item transfer shared by every counter; layouts and mode variants live in the rooms.
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
