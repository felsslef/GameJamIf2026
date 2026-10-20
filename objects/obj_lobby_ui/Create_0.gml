// Presentation adapter. The original obj_menu network code is unchanged.
frontend_init();
if (global.frontend_network_entry) {
    global.frontend_network_entry = false;
    with (obj_menu) {
        menu_state = "lobby_online";
        if (udp_listener == noone) udp_listener = network_create_socket_ext(network_socket_udp, 6511);
    }
}
