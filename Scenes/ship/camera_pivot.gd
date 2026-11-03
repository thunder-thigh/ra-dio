extends Node3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.50
@export var tilt_limit = deg_to_rad(75)
# Comment out this existing camera line.
# @onready var _camera := $Target/Camera3D as Camera3D

@onready var _camera_pivot := %CameraPivot as Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	#print(str(event))
	if event is InputEventMouseMotion:
		#print("sdsds")
		_camera_pivot.rotation.x -= event.screen_relative.y * 0.01 * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.y += -event.screen_relative.x * 0.01 * mouse_sensitivity
