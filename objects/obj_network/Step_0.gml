if (global.game_mode != "coop_online") exit;

var target_socket = global.is_host ? global.client_socket : global.client_socket;

if (target_socket != noone && target_socket >= 0) {
    // Procura o jogador local nesta máquina
    var my_player = noone;
    with (obj_player) {
        if (is_local) my_player = id;
    }

    if (my_player != noone) {
        var buf = buffer_create(256, buffer_grow, 1);
        buffer_seek(buf, buffer_seek_start, 0);
        
        // Escreve dados do jogador
        buffer_write(buf, buffer_u8, 1); // ID da mensagem: Pos_Player
        buffer_write(buf, buffer_u8, my_player.playerid);
        buffer_write(buf, buffer_f32, my_player.x);
        buffer_write(buf, buffer_f32, my_player.y);
        buffer_write(buf, buffer_f32, my_player.move_dir);
        buffer_write(buf, buffer_bool, my_player.is_dashing);

        network_send_packet(target_socket, buf, buffer_tell(buf));
        buffer_delete(buf);
    }
}