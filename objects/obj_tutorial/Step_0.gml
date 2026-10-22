if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    instance_destroy();
    exit;
}

var previous_page = keyboard_check_pressed(vk_left);
var next_page = keyboard_check_pressed(vk_right);
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
if (mouse_check_button_pressed(mb_left)) {
    previous_page = previous_page || point_in_rectangle(mouse_x_gui, mouse_y_gui, 190, 586, 390, 642);
    next_page = next_page || point_in_rectangle(mouse_x_gui, mouse_y_gui, 890, 586, 1090, 642);
}

if (previous_page) tutorial_page = max(0, tutorial_page - 1);
else if (next_page) tutorial_page = min(tutorial_page_count - 1, tutorial_page + 1);
