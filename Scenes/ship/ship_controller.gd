
##This shall take input and apply the appropriate transformation to the operating ship.
extends RigidBody3D

@export var ISACTIVE: bool = true
#@export var GYRO_MAX_SPEED: float = 5 # no angular vel. cap for fun
@export var GYRO_ACCELERATION: float = 250 # gyro torque
@export var GIMBAL_RATE: float = 0.1 # degrees per second while key held
@export var THROTTLE_RATE: float = 10.0 # units per second while key held
@export var MAX_THRUSTER_ANGLE: float = 15
@export var MIN_THROTTLE: float = 0.0
@export var MAX_THROTTLE: float = 10.0
@export var THROTTLE_STATE: bool = true
@export var THROTTLE: float = 5
@export var THRUST_MULTIPLIER: float = 100.0
@export var WARP_DRIVE_INTENSITY: float = 4.0
@export var BODY_MASS: float = 100.0

@onready var thruster: Marker3D = $thruster

func _init() -> void:
	mass = BODY_MASS

func _ready() -> void:
	mass = BODY_MASS
	gravity_scale = 0.0
	constant_force = Vector3.ZERO
	constant_torque = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	linear_damp = 0.0
	angular_damp = 0.0
	sleeping = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# debug, s  kipped if the action already exists in the inputmap)
	#_add_key_action("gyro_pitch_up", KEY_I)
	#_add_key_action("gyro_pitch_down", KEY_K)
	#_add_key_action("gyro_yaw_left", KEY_J)
	#_add_key_action("gyro_yaw_right", KEY_L)
	#_add_key_action("gyro_roll_left", KEY_H)
	#_add_key_action("gyro_roll_right", KEY_M)

func _add_key_action(action: String, key: Key) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)

func applyThrusterForce() -> void:
	if THROTTLE <= 0.0:
		return
	var thruster_direction: Vector3 = -thruster.global_transform.basis.z
	var thrust_force: Vector3 = thruster_direction * THROTTLE * THRUST_MULTIPLIER
	var force_position: Vector3 = thruster.global_position - global_position
	apply_force(thrust_force, force_position)

func applyGyroTorque() -> void:
	var local_torque := Vector3(
		Input.get_axis("gyro_pitch_down", "gyro_pitch_up"),
		Input.get_axis("gyro_yaw_right", "gyro_yaw_left"),
		Input.get_axis("gyro_roll_right", "gyro_roll_left")
	) * GYRO_ACCELERATION
	if local_torque != Vector3.ZERO:
		apply_torque(global_transform.basis * local_torque)

func applyHeldControls(delta: float) -> void:
	var gimbal_axis_y := Input.get_axis("rotate_thruster_clockwise", "rotate_thruster_anticlockwise")
	if gimbal_axis_y != 0.0:
		thruster.rotation.y = clampf(
			thruster.rotation.y + gimbal_axis_y * deg_to_rad(GIMBAL_RATE) * delta,
			deg_to_rad(-MAX_THRUSTER_ANGLE),
			deg_to_rad(MAX_THRUSTER_ANGLE)
		)
	var gimbal_axis_x := Input.get_axis("rotate_thruster_forward", "rotate_thruster_backward")
	if gimbal_axis_x != 0.0:
		thruster.rotation.x = clampf(
			thruster.rotation.x + gimbal_axis_x * deg_to_rad(GIMBAL_RATE) * delta,
			deg_to_rad(-MAX_THRUSTER_ANGLE),
			deg_to_rad(MAX_THRUSTER_ANGLE)
		)
	var throttle_axis := Input.get_axis("decrease_throttle", "increase_throttle")
	if throttle_axis != 0.0:
		print("Throttle changed: ", THROTTLE)
		THROTTLE = clampf(
			THROTTLE + throttle_axis * THROTTLE_RATE * delta,
			MIN_THROTTLE,
			MAX_THROTTLE
		)
	if Input.is_action_just_pressed("rotate_thruster_reset"):
		print("throttle rotation reset")
		thruster.rotation.x = 0
		thruster.rotation.y = 0
	if Input.is_action_pressed("activate_warp_drive"):
		linear_damp = WARP_DRIVE_INTENSITY
		angular_damp = WARP_DRIVE_INTENSITY
	else:
		linear_damp = 0.0
		angular_damp = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not ISACTIVE:
		return
	if event.is_action_pressed("toggle_throttle"):
		THROTTLE_STATE = !THROTTLE_STATE
		print("throttle toggled: ", THROTTLE_STATE, " ", THROTTLE)

func _physics_process(delta: float) -> void:
	if not ISACTIVE:
		return
	applyHeldControls(delta)
	if THROTTLE_STATE and THROTTLE > 0.0:
		applyThrusterForce()
	applyGyroTorque()
