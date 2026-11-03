extends Node3D

@export var ship_scene : PackedScene = preload("res://Scenes/ship/ship.tscn")
@onready var ships_container: Node3D = $Ships

var ships_list: Dictionary = {}
var active_object: int
var _camera_pivot: Node3D

# Called when the node enters the scene tree for the first
func spawnListedParented3DScene(scene_to_load: PackedScene, list: Dictionary, parent: Node3D, spawn_transform: Transform3D = Transform3D.IDENTITY) -> int:
	var loaded_scene := scene_to_load.instantiate()
	if (!loaded_scene):
		push_error("scene: %s could not be loaded", scene_to_load.get_node_name(0))
		return -1;
	parent.add_child(loaded_scene)
	loaded_scene.transform = spawn_transform
	var scene_id = loaded_scene.get_instance_id()
	list[scene_id] = loaded_scene
	return scene_id
	
func spawnListedParentless3DScene(scene_to_load: PackedScene, spawn_transform: Transform3D = Transform3D.IDENTITY) -> int:
	var loaded_scene := scene_to_load.instantiate()
	if (!loaded_scene):
		push_error("scene: %s could not be loaded", scene_to_load.get_node_name(0))
		return -1;
	loaded_scene.transform = spawn_transform
	var scene_id = loaded_scene.get_instance_id()
	return scene_id

func setActiveObjectCam(parent_id: int) -> void:
	if (typeof(instance_from_id(parent_id).get_child(0).get_child(0).get_child(0))!=typeof(Camera3D)):
		push_error("No camera object exists as it's first")
		return
	instance_from_id(parent_id).get_child(0).get_child(0).get_child(0).make_current()

func _ready() -> void:
	if (!ship_scene):
		push_error("Assign Ship.tscn to ship_scene")
		return
	var ship1: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)
	print("ship id: " + str(ship1))
	active_object = ship1
	setActiveObjectCam(active_object)
	var temp = instance_from_id(active_object)
	_camera_pivot = temp.get_node("CameraPivot")
	#var ship2: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)
	#var ship3: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)
	#var ship4: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)
	#var ship5: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)
	#var ship6: int = spawnListedParented3DScene(ship_scene, ships_list, $Ships)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _unhandled_input(event: InputEvent) -> void:
#	#print(str(event))
#	if event is InputEventMouseMotion:
#		print("sdsds")
#		_camera_pivot.rotation.x -= event.screen_relative.y * 0.01 * GlobalSettings.mouse_sensitivity
#		# Prevent the camera from rotating too far up or down.
#		_camera_pivot.rotation.y += -event.screen_relative.x * 0.01 * GlobalSettings.mouse_sensitivity
#
