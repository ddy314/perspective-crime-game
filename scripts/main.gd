extends Node3D
## Initial visual graybox only. The playable perspective bridge belongs in PR #1.

const ISLAND_SIZE := Vector3(3.8, 0.6, 3.8)
const START_ISLAND := Vector3(-4.0, -0.3, 0.0)
const GOAL_ISLAND := Vector3(4.0, -0.3, -2.0)

var _camera: Camera3D
var _dragging: bool = false
var _yaw: float = 0.55
var _pitch: float = 0.42
var _distance: float = 16.0
var _target: Vector3 = Vector3(0.0, 0.0, -1.0)


func _ready() -> void:
	_build_environment()
	_build_graybox()
	_build_camera()
	_build_hud()


func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.075, 0.11)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65, 0.72, 0.84)
	env.ambient_light_energy = 0.8
	world_env.environment = env
	add_child(world_env)

	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	sunlight.light_energy = 1.1
	sunlight.shadow_enabled = true
	add_child(sunlight)


func _build_graybox() -> void:
	_make_island("StartIsland", START_ISLAND, Color(0.25, 0.32, 0.44))
	_make_island("GoalIsland", GOAL_ISLAND, Color(0.36, 0.28, 0.42))
	_make_marker("AnchorA", Vector3(-2.1, 0.25, 0.0), Color(0.25, 0.9, 1.0))
	_make_marker("AnchorB", Vector3(2.1, 0.25, -2.0), Color(1.0, 0.65, 0.28))
	_make_marker("Goal", Vector3(4.7, 0.24, -2.0), Color(0.45, 1.0, 0.55))


func _make_island(island_name: String, center: Vector3, tint: Color) -> void:
	var body := StaticBody3D.new()
	body.name = island_name
	body.position = center
	add_child(body)

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = ISLAND_SIZE
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = ISLAND_SIZE
	collision.shape = box_shape
	body.add_child(collision)


func _make_marker(marker_name: String, location: Vector3, tint: Color) -> void:
	var marker := MeshInstance3D.new()
	marker.name = marker_name
	marker.position = location
	var sphere := SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	marker.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint * 0.35
	marker.material_override = material
	add_child(marker)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "OrbitCamera"
	_camera.fov = 58.0
	_camera.current = true
	add_child(_camera)
	_update_camera()


func _update_camera() -> void:
	if _camera == null:
		return
	var direction := Vector3(
		sin(_yaw) * cos(_pitch),
		sin(_pitch),
		cos(_yaw) * cos(_pitch)
	)
	_camera.position = _target + direction * _distance
	_camera.look_at(_target, Vector3.UP)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	var instructions := Label.new()
	instructions.position = Vector2(24.0, 18.0)
	instructions.text = "PERSPECTIVE CRIME  |  graybox starter\nRight mouse drag: orbit   •   Wheel: zoom\nNext PR: focus, align, lock bridge, walk, escape."
	instructions.add_theme_font_size_override("font_size", 19)
	hud.add_child(instructions)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			Input.set_mouse_mode(
				Input.MOUSE_MODE_CAPTURED if _dragging else Input.MOUSE_MODE_VISIBLE
			)
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_distance = clampf(_distance - 1.0, 7.0, 30.0)
			_update_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_distance = clampf(_distance + 1.0, 7.0, 30.0)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		_yaw -= event.relative.x * 0.007
		_pitch = clampf(_pitch + event.relative.y * 0.007, 0.12, 1.30)
		_update_camera()
