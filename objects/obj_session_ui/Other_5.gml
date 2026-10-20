// Release the per-room discovery broadcaster. TCP handles survive lobby -> game.
session_ui_close_menu();
with (obj_network) {
    if (variable_instance_exists(id, "udp_broadcaster") && udp_broadcaster >= 0) {
        network_destroy(udp_broadcaster);
        udp_broadcaster = noone;
    }
}
