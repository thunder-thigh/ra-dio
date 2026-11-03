extends Node3D

@export var ship_scene: PackedScene = preload("res://Scenes/ship/ship.tscn")
@export var debris_scene: PackedScene = preload("res://Scenes/debris/debris.tscn")
@onready var ships_container: Node3D = $Ships
var ships_list: Dictionary = {}
var active_object: int
var _camera_pivot: Node3D

# random block placement
@export var INITIAL_DEBRIS_COUNT: int = 1500
@export var MAX_DEBRIS_COUNT: int = 1500
@export var DEBRIS_MIN_DISTANCE: float = 80.0
@export var DEBRIS_SPAWN_RADIUS: float = 2000.0
@export var DEBRIS_DESPAWN_DISTANCE: float = 2000.0

var debris_list: Dictionary = {}
var debris_container: Node3D

func spawnListedParented3DScene(scene_to_load: PackedScene, list: Dictionary, parent: Node3D, spawn_transform: Transform3D = Transform3D.IDENTITY) -> int:
	var loaded_scene := scene_to_load.instantiate()
	if !loaded_scene:
		push_error("Scene could not be instantiated")
		return -1
	parent.add_child(loaded_scene)
	loaded_scene.transform = spawn_transform
	var scene_id = loaded_scene.get_instance_id()
	list[scene_id] = loaded_scene
	return scene_id

func spawnListedParentless3DScene(scene_to_load: PackedScene, spawn_transform: Transform3D = Transform3D.IDENTITY) -> int:
	var loaded_scene := scene_to_load.instantiate()
	if !loaded_scene:
		push_error("Scene could not be instantiated")
		return -1
	loaded_scene.transform = spawn_transform
	return loaded_scene.get_instance_id()

func setActiveObjectCam(parent_id: int) -> void:
	var parent = instance_from_id(parent_id)
	if !is_instance_valid(parent):
		return
	if typeof(parent.get_child(0).get_child(0).get_child(0)) != typeof(Camera3D):
		push_error("No camera object exists as it's first")
		return
	parent.get_child(0).get_child(0).get_child(0).make_current()

func spawnDebris() -> void:
	if !debris_scene or debris_list.size() >= MAX_DEBRIS_COUNT:
		return
	var ship = instance_from_id(active_object) as Node3D
	if !is_instance_valid(ship):
		return
	var direction = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var distance = randf_range(DEBRIS_MIN_DISTANCE, DEBRIS_SPAWN_RADIUS)
	var spawn_position = ship.global_position + direction * distance
	var debris_id = spawnListedParented3DScene(debris_scene, debris_list, debris_container)
	if debris_id == -1:
		return
	var debris = instance_from_id(debris_id) as Node3D
	debris.global_position = spawn_position
	debris.global_rotation = Vector3(randf_range(0.0, TAU), randf_range(0.0, TAU), randf_range(0.0, TAU))

func cleanupDebris() -> void:
	var ship = instance_from_id(active_object) as Node3D
	if !is_instance_valid(ship):
		return
	for debris_id in debris_list.keys():
		var debris = debris_list[debris_id] as Node3D
		if !is_instance_valid(debris):
			debris_list.erase(debris_id)
			continue
		if ship.global_position.distance_to(debris.global_position) > DEBRIS_DESPAWN_DISTANCE:
			debris.queue_free()
			debris_list.erase(debris_id)


func replenishDebris() -> void:
	var missing = MAX_DEBRIS_COUNT - debris_list.size()
	for i in range(missing):
		spawnDebris()

func getDebrisCount() -> int:
	return debris_list.size()

func _ready() -> void:
	if !ship_scene:
		push_error("Assign Ship.tscn to ship_scene")
		return
	randomize()
	var ship1: int = spawnListedParented3DScene(ship_scene, ships_list, ships_container)
	print("ship id: " + str(ship1))
	active_object = ship1
	setActiveObjectCam(active_object)
	var temp = instance_from_id(active_object)
	_camera_pivot = temp.get_node("CameraPivot")
	debris_container = Node3D.new()
	debris_container.name = "Debris"
	add_child(debris_container)
	MAX_DEBRIS_COUNT = INITIAL_DEBRIS_COUNT
	for i in range(INITIAL_DEBRIS_COUNT):
		spawnDebris()
	print("Initial debris count: ", debris_list.size())

func _process(delta: float) -> void:
	cleanupDebris()
	replenishDebris()
