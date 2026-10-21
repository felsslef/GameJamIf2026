/// Read the editable instances already placed in the room. Never create or reposition furniture.
function workshop_layout_init() {
    if (layer_exists("Stations_Solo")) layer_set_visible("Stations_Solo", global.game_mode != "coop_local");
    if (layer_exists("Stations_Coop")) layer_set_visible("Stations_Coop", global.game_mode == "coop_local");
    stations = [];
    bins = [];
    dispensers = [];
    dispenser = noone;
    truck = noone;
    with (obj_recycling_station) array_push(other.stations, id);
    array_sort(stations, function(a,b) { return a.station_order - b.station_order; });
    for (var i = 0; i < array_length(stations); i++) {
        var station = stations[i];
        switch (station.station_kind) {
            case "bin": array_push(bins, station); break;
            case "dispenser": array_push(dispensers, station); break;
            case "truck": truck = station; break;
        }
    }
    if (array_length(dispensers) > 0) dispenser = dispensers[0];
    if (level_index == 2) feedback = global.game_mode == "coop_local"
        ? "Coloque o lixo nos blocos para a outra jogadora pegar."
        : "Passe por baixo dos blocos para acessar o outro lado.";
}
