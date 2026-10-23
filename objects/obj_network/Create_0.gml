if(instance_number(obj_network)>1){instance_destroy();exit;}
connected = false;
udp_broadcaster = network_create_socket(network_socket_udp);
broadcast_timer = 0;
