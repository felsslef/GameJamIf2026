if (global.game_mode != "coop_online") exit;

// Define qual socket usar para envio
var send_socket = global.is_host ? global.client_socket : global.client_socket;

// No cliente, envia se tiver socket criado; no Host, só envia se o cliente conectou
if (send_socket != noone && send_socket >= 0) {

    // 1. ENVIA POSIÇÃO DO JOGADOR LOCAL
    var my_player = noone;
    with (obj_player) {
        if (is_local) my_player = id;
    }

    if (my_player != noone) {
        var buf = buffer_create(256, buffer_grow, 1);
        buffer_seek(buf, buffer_seek_start, 0);
        
        buffer_write(buf, buffer_u8, 1); // Header 1: Player
        buffer_write(buf, buffer_u8, my_player.playerid);
        buffer_write(buf, buffer_f32, my_player.x);
        buffer_write(buf, buffer_f32, my_player.y);
        buffer_write(buf, buffer_f32, my_player.move_dir);
        buffer_write(buf, buffer_bool, my_player.is_dashing);

        network_send_packet(send_socket, buf, buffer_tell(buf));
        buffer_delete(buf);
    }

    // 2. ENVIA ESTADO DOS ITENS
    with (obj_item_main) {
        // Envia apenas se o item estiver sendo segurado pelo player local ou estiver voando
        var is_my_item = (is_held && instance_exists(holder) && holder.is_local) || is_thrown;
        
        if (is_my_item || global.is_host) {
            var item_buf = buffer_create(256, buffer_grow, 1);
            buffer_seek(item_buf, buffer_seek_start, 0);

            buffer_write(item_buf, buffer_u8, 2); // Header 2: Item
            buffer_write(item_buf, buffer_f32, item_id);
            buffer_write(item_buf, buffer_f32, x);
            buffer_write(item_buf, buffer_f32, y);
            buffer_write(item_buf, buffer_bool, is_held);
            buffer_write(item_buf, buffer_u8, (is_held && instance_exists(holder)) ? holder.playerid : 0);
            buffer_write(item_buf, buffer_bool, is_thrown);

            network_send_packet(send_socket, item_buf, buffer_tell(item_buf));
            buffer_delete(item_buf);
        }
    }
}

// O Host envia um sinal UDP com o nome da sala a cada 60 frames (1 segundo)
if (global.game_mode == "coop_online" && global.is_host) {
    broadcast_timer++;
    if (broadcast_timer >= 60) {
        broadcast_timer = 0;
        
        var b_buf = buffer_create(128, buffer_grow, 1);
        buffer_seek(b_buf, buffer_seek_start, 0);
        buffer_write(b_buf, buffer_string, global.room_name);
        
        // Transmite para o IP de broadcast (255.255.255.255) na porta 6511
        network_send_broadcast(udp_broadcaster, 6511, b_buf, buffer_tell(b_buf));
        buffer_delete(b_buf);
    }
}