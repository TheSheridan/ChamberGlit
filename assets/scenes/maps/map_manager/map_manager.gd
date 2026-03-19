extends Node2D


var current_scene : Node = null
var current_scene_path : String = ""


func load_scene(scene_path: String):
    if current_scene:
        current_scene.queue_free()

    current_scene_path = scene_path
    current_scene = load(scene_path).instantiate()
    add_child(current_scene)

func unload_scene():
    if current_scene:
        current_scene.queue_free()
        current_scene = null
