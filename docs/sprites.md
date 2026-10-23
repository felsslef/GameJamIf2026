# Sprites do jogo

O projeto possui **77 sprites** registrados no GameMaker.

Lixeiras, bancadas e máquinas usam módulos quadrados de **64 × 64**. O caminhão ocupa dois módulos. Prensa e fardos de plástico/metal são recursos históricos: não aparecem nas rooms ou tutorial.

Abra o recurso na pasta **Sprites** do Asset Browser e use **Edit Image → Import** para substituir a imagem. Preserve a origem e a máscara de colisão quando necessário. Objetos e posições continuam editáveis nas rooms.

A coluna de objetos indica vínculos diretos. Alguns recursos, como as cientistas, ícones e fundos de interface, são escolhidos pelos scripts durante o jogo. Os sprites antigos do tutorial continuam disponíveis para reutilização; o tutorial prático utiliza os objetos da fase e `spr_ui_arrow`.

| Sprite | Tamanho | Quadros | Objetos com vínculo direto |
| --- | --- | --- | --- |
| [spr_bag_glass](../sprites/spr_bag_glass/spr_bag_glass.yy) | 32 × 32 | 1 | `obj_bag_glass`, `obj_material_bag_glass` |
| [spr_bag_metal](../sprites/spr_bag_metal/spr_bag_metal.yy) | 32 × 32 | 1 | `obj_bag_metal`, `obj_material_bag_metal` |
| [spr_bag_paper](../sprites/spr_bag_paper/spr_bag_paper.yy) | 32 × 32 | 1 | `obj_bag_paper`, `obj_material_bag_paper` |
| [spr_bag_plastic](../sprites/spr_bag_plastic/spr_bag_plastic.yy) | 32 × 32 | 1 | `obj_bag_plastic`, `obj_material_bag_plastic` |
| [spr_bin_glass](../sprites/spr_bin_glass/spr_bin_glass.yy) | 64 × 64 | 1 | `obj_bin_glass` |
| [spr_bin_metal](../sprites/spr_bin_metal/spr_bin_metal.yy) | 64 × 64 | 1 | `obj_bin_metal` |
| [spr_bin_paper](../sprites/spr_bin_paper/spr_bin_paper.yy) | 64 × 64 | 1 | `obj_bin_paper`, `obj_recycling_station` |
| [spr_bin_plastic](../sprites/spr_bin_plastic/spr_bin_plastic.yy) | 64 × 64 | 1 | `obj_bin_plastic` |
| [spr_caragua_map](../sprites/spr_caragua_map/spr_caragua_map.yy) | 1672 × 941 | 1 | — |
| [spr_character_background](../sprites/spr_character_background/spr_character_background.yy) | 1280 × 720 | 1 | — |
| [spr_counter](../sprites/spr_counter/spr_counter.yy) | 64 × 64 | 1 | `obj_counter` |
| [spr_dispenser](../sprites/spr_dispenser/spr_dispenser.yy) | 64 × 64 | 1 | `obj_dispenser` |
| [spr_fire](../sprites/spr_fire/spr_fire.yy) | 64 × 64 | 1 | — |
| [spr_game_logo](../sprites/spr_game_logo/spr_game_logo.yy) | 640 × 224 | 1 | — |
| [spr_item_teste](../sprites/spr_item_teste/spr_item_teste.yy) | 32 × 32 | 1 | `obj_item_main` |
| [spr_juCostas](../sprites/spr_juCostas/spr_juCostas.yy) | 64 × 64 | 4 | — |
| [spr_juFrente](../sprites/spr_juFrente/spr_juFrente.yy) | 64 × 64 | 4 | — |
| [spr_juLado](../sprites/spr_juLado/spr_juLado.yy) | 64 × 66 | 4 | — |
| [spr_leachate](../sprites/spr_leachate/spr_leachate.yy) | 64 × 64 | 1 | `obj_leachate` |
| [spr_leleCostas](../sprites/spr_leleCostas/spr_leleCostas.yy) | 64 × 64 | 4 | — |
| [spr_leleFrente](../sprites/spr_leleFrente/spr_leleFrente.yy) | 64 × 64 | 4 | — |
| [spr_leleLado](../sprites/spr_leleLado/spr_leleLado.yy) | 64 × 64 | 4 | — |
| [spr_machine_biodigester](../sprites/spr_machine_biodigester/spr_machine_biodigester.yy) | 64 × 64 | 1 | `obj_biodigester` |
| [spr_machine_dismantler](../sprites/spr_machine_dismantler/spr_machine_dismantler.yy) | 64 × 64 | 1 | `obj_dismantling_bench` |
| [spr_machine_dispatch](../sprites/spr_machine_dispatch/spr_machine_dispatch.yy) | 128 × 64 | 1 | `obj_dispatch_truck` |
| [spr_machine_extinguisher_rack](../sprites/spr_machine_extinguisher_rack/spr_machine_extinguisher_rack.yy) | 64 × 64 | 2 | `obj_extinguisher_rack` |
| [spr_machine_intake](../sprites/spr_machine_intake/spr_machine_intake.yy) | 64 × 64 | 1 | `obj_intake_bin` |
| [spr_machine_press](../sprites/spr_machine_press/spr_machine_press.yy) | 160 × 96 | 1 | `obj_hydraulic_press` |
| [spr_machine_sorting](../sprites/spr_machine_sorting/spr_machine_sorting.yy) | 64 × 64 | 1 | `obj_sorting_table` |
| [spr_machine_trash](../sprites/spr_machine_trash/spr_machine_trash.yy) | 64 × 64 | 1 | `obj_common_trash` |
| [spr_machine_washer](../sprites/spr_machine_washer/spr_machine_washer.yy) | 64 × 64 | 1 | `obj_washer` |
| [spr_manuCostas](../sprites/spr_manuCostas/spr_manuCostas.yy) | 64 × 64 | 4 | — |
| [spr_manuFrente](../sprites/spr_manuFrente/spr_manuFrente.yy) | 64 × 64 | 4 | — |
| [spr_manuLado](../sprites/spr_manuLado/spr_manuLado.yy) | 64 × 66 | 4 | — |
| [spr_mariaCostas](../sprites/spr_mariaCostas/spr_mariaCostas.yy) | 64 × 64 | 4 | — |
| [spr_mariaFrente](../sprites/spr_mariaFrente/spr_mariaFrente.yy) | 64 × 64 | 4 | — |
| [spr_mariaLado](../sprites/spr_mariaLado/spr_mariaLado.yy) | 64 × 66 | 4 | — |
| [spr_material_burned_electronic](../sprites/spr_material_burned_electronic/spr_material_burned_electronic.yy) | 32 × 32 | 1 | `obj_material_burned_electronic` |
| [spr_material_clean_plastic](../sprites/spr_material_clean_plastic/spr_material_clean_plastic.yy) | 32 × 32 | 1 | `obj_material_clean_plastic` |
| [spr_material_dirty_plastic](../sprites/spr_material_dirty_plastic/spr_material_dirty_plastic.yy) | 32 × 32 | 1 | `obj_material_dirty_plastic` |
| [spr_material_electronic](../sprites/spr_material_electronic/spr_material_electronic.yy) | 32 × 32 | 1 | `obj_material_electronic` |
| [spr_material_extinguisher](../sprites/spr_material_extinguisher/spr_material_extinguisher.yy) | 64 × 64 | 1 | `obj_material_extinguisher` |
| [spr_material_fertilizer](../sprites/spr_material_fertilizer/spr_material_fertilizer.yy) | 32 × 32 | 1 | `obj_material_fertilizer` |
| [spr_material_metal_bale](../sprites/spr_material_metal_bale/spr_material_metal_bale.yy) | 32 × 32 | 1 | `obj_material_metal_bale` |
| [spr_material_metal_plate](../sprites/spr_material_metal_plate/spr_material_metal_plate.yy) | 32 × 32 | 1 | `obj_material_metal_plate` |
| [spr_material_organic](../sprites/spr_material_organic/spr_material_organic.yy) | 32 × 32 | 1 | `obj_material_organic` |
| [spr_material_plastic_bale](../sprites/spr_material_plastic_bale/spr_material_plastic_bale.yy) | 32 × 32 | 1 | `obj_material_plastic_bale` |
| [spr_material_raw_waste](../sprites/spr_material_raw_waste/spr_material_raw_waste.yy) | 32 × 32 | 1 | `obj_material_raw_waste`, `obj_process_item` |
| [spr_menu_background](../sprites/spr_menu_background/spr_menu_background.yy) | 1280 × 720 | 1 | — |
| [spr_part_battery](../sprites/spr_part_battery/spr_part_battery.yy) | 32 × 32 | 1 | `obj_part_battery` |
| [spr_part_casing](../sprites/spr_part_casing/spr_part_casing.yy) | 32 × 32 | 1 | `obj_part_casing` |
| [spr_part_circuit](../sprites/spr_part_circuit/spr_part_circuit.yy) | 32 × 32 | 1 | `obj_part_circuit` |
| [spr_part_motor](../sprites/spr_part_motor/spr_part_motor.yy) | 32 × 32 | 1 | `obj_part_motor` |
| [spr_robot](../sprites/spr_robot/spr_robot.yy) | 64 × 64 | 1 | `obj_material_robot`, `obj_robot` |
| [spr_robot_delivery](../sprites/spr_robot_delivery/spr_robot_delivery.yy) | 192 × 96 | 1 | `obj_robot_delivery` |
| [spr_science_bench](../sprites/spr_science_bench/spr_science_bench.yy) | 64 × 64 | 1 | `obj_science_bench` |
| [spr_scientist_ju](../sprites/spr_scientist_ju/spr_scientist_ju.yy) | 64 × 64 | 1 | `obj_recycling_player` |
| [spr_scientist_le](../sprites/spr_scientist_le/spr_scientist_le.yy) | 64 × 64 | 1 | `obj_recycling_player_two` |
| [spr_scientist_manu](../sprites/spr_scientist_manu/spr_scientist_manu.yy) | 64 × 64 | 1 | — |
| [spr_scientist_maria](../sprites/spr_scientist_maria/spr_scientist_maria.yy) | 64 × 64 | 1 | — |
| [spr_story_beach](../sprites/spr_story_beach/spr_story_beach.yy) | 1280 × 720 | 1 | — |
| [spr_testes](../sprites/spr_testes/spr_testes.yy) | 64 × 64 | 1 | `obj_player` |
| [spr_truck](../sprites/spr_truck/spr_truck.yy) | 128 × 64 | 1 | `obj_truck` |
| [spr_truck_dock](../sprites/spr_truck_dock/spr_truck_dock.yy) | 128 × 64 | 1 | — |
| [spr_tutorialFundo](../sprites/spr_tutorialFundo/spr_tutorialFundo.yy) | 64 × 64 | 1 | — |
| [spr_ui_arrow](../sprites/spr_ui_arrow/spr_ui_arrow.yy) | 32 × 32 | 1 | — |
| [spr_ui_fill](../sprites/spr_ui_fill/spr_ui_fill.yy) | 4 × 4 | 1 | — |
| [spr_ui_star](../sprites/spr_ui_star/spr_ui_star.yy) | 40 × 40 | 1 | — |
| [spr_ui_stone_button](../sprites/spr_ui_stone_button/spr_ui_stone_button.yy) | 320 × 80 | 1 | — |
| [spr_ui_timeout](../sprites/spr_ui_timeout/spr_ui_timeout.yy) | 96 × 96 | 1 | — |
| [spr_ui_warning](../sprites/spr_ui_warning/spr_ui_warning.yy) | 32 × 32 | 1 | — |
| [spr_wall](../sprites/spr_wall/spr_wall.yy) | 64 × 64 | 1 | `obj_wall` |
| [spr_waste_glass](../sprites/spr_waste_glass/spr_waste_glass.yy) | 32 × 32 | 1 | `obj_material_sorted_glass`, `obj_waste_glass` |
| [spr_waste_metal](../sprites/spr_waste_metal/spr_waste_metal.yy) | 32 × 32 | 1 | `obj_material_sorted_metal`, `obj_waste_metal` |
| [spr_waste_paper](../sprites/spr_waste_paper/spr_waste_paper.yy) | 32 × 32 | 1 | `obj_material_sorted_paper`, `obj_recycling_item`, `obj_waste_paper` |
| [spr_waste_plastic](../sprites/spr_waste_plastic/spr_waste_plastic.yy) | 32 × 32 | 1 | `obj_material_sorted_plastic`, `obj_waste_plastic` |
| [spr_workshop_floor](../sprites/spr_workshop_floor/spr_workshop_floor.yy) | 1280 × 720 | 1 | — |

Atualizar esta lista: `node tools/catalog-sprites.mjs`.
