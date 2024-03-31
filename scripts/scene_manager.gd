extends Node

var _container: Control = null

func _get_container():
	var current_scene = get_tree().current_scene
	_container = current_scene.get_node("SubViewportContainer/SubViewport/Container")
	
func _remove_scene():
	var current_scene = _container.get_child(0)
	
	_container.remove_child(current_scene)
	current_scene.queue_free()
	
func _add_scene(scene_name):
	var new_scene = load(scene_name).instantiate()
	_container.add_child(new_scene)
	
func change_scene(scene_name):
	if not _container:
		_get_container()
		
	_remove_scene()
	_add_scene(scene_name)
