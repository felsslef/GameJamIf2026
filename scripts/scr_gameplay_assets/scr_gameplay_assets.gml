/// Replace the spr_* resources in the Sprite Editor; artwork is never rebuilt at runtime.
function recycling_scientist_sprite(_type) {
    return [spr_juFrente, spr_leleFrente, spr_manuFrente, spr_scientist_maria][clamp(_type,0,3)];
}
function recycling_waste_sprite(_type) {
    return object_get_sprite([obj_waste_paper, obj_waste_plastic, obj_waste_glass, obj_waste_metal][clamp(_type,0,3)]);
}
function recycling_part_sprite(_type) {
    return object_get_sprite([obj_part_circuit, obj_part_battery, obj_part_motor, obj_part_casing][clamp(_type,0,3)]);
}
function recycling_bag_sprite(_type) {
    return object_get_sprite([obj_bag_paper, obj_bag_plastic, obj_bag_glass, obj_bag_metal][clamp(_type,0,3)]);
}
function recycling_item_object(_kind, _type) {
    switch (_kind) {
        case "bag": return [obj_bag_paper, obj_bag_plastic, obj_bag_glass, obj_bag_metal][_type];
        case "part": return [obj_part_circuit, obj_part_battery, obj_part_motor, obj_part_casing][_type];
        case "robot": return obj_robot;
        default: return [obj_waste_paper, obj_waste_plastic, obj_waste_glass, obj_waste_metal][_type];
    }
}
