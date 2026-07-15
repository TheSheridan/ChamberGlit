extends Marker2D


@onready var _sgt = $"/root/auto_singleton"

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"name": name,
		
		"pos_x": position.x,
		"pos_y": position.y,
		
		"stats": _sgt.bella_stats,
	}
	return save_dict
