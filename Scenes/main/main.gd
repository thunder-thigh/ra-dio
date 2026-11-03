extends Control

var level_instance : Control
var main : Control = self

@export var testing_planet_scene: PackedScene =preload("res://Scenes/testing_planet/testing_planet.tscn")
@export var city_planet_scene: PackedScene =preload("res://Scenes/city_planet/city_planet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
		
	
func load_level(level_name: String):
	var level_path: String = 'res://Scenes/{0}/{0}.tscn' % [level_name, level_name]
	var level_resource: = load(level_path)
	if (level_resource):
		level_instance = level_resource.instance()
		main.add_child(level_instance)

func loadPackedScene(scene_to_load: PackedScene) -> void:
	var error = get_tree().change_scene_to_packed(scene_to_load)
	if error != OK:
		push_error("Could not load packed Scene: " + str(error))

func _on_load_testing_planet_pressed() -> void:
	loadPackedScene(testing_planet_scene)
	print("button pressed")
	pass # Replace with function body.

func _on_load_city_planet_pressed() -> void:
	loadPackedScene(city_planet_scene)
	pass # Replace with function body.
