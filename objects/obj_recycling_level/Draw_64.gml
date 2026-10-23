if (!story_active()) {
processing_draw_robot_departures();
recycling_draw_hud();

if (phase_state == "playing") recycling_draw_inventory();
recycling_draw_start();

processing_draw_intake_popups();
processing_draw_station_overlays();
processing_draw_warnings();
}
story_draw();
