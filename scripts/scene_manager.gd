extends Node


func _get_container():
	var current_scene = get_tree().current_scene
	return current_scene.get_node("SubViewportContainer/SubViewport/Container")
	
func _remove_scene(container):
	var current_scene = container.get_child(0)
	
	container.remove_child(current_scene)
	current_scene.queue_free()
	
func _add_scene(container, scene_name):
	var new_scene = load(scene_name).instantiate()
	container.add_child(new_scene)
	
func change_scene(scene_name, delay = 0):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	var container = _get_container()
	
	if not container:
		get_tree().change_scene_to_file(scene_name)
		return
		
	_remove_scene(container)
	_add_scene(container, scene_name)
