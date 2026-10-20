var type = async_load[? "type"];

if (type == network_type_data && menu_state == "lobby_online") {
    var buffer = async_load[? "buffer"];
    var ip = async_load[? "ip"];
    
    buffer_seek(buffer, buffer_seek_start, 0);
    var name = buffer_read(buffer, buffer_string);

    // Atualiza ou adiciona a sala na lista
    var found = false;
    for (var i = 0; i < array_length(rooms_list); i++) {
        if (rooms_list[i].ip == ip) {
            rooms_list[i].name = name;
            rooms_list[i].timer = 120; // Reset no tempo de vida da sala
            found = true;
            break;
        }
    }

    if (!found) {
        array_push(rooms_list, { name: name, ip: ip, timer: 120 });
    }
}