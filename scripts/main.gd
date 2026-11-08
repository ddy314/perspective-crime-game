extends Node3D
## One level, two projection anchors, one persistent physical connection.
const Player = preload("res://scripts/player.gd")
const A := Vector3(-2.2, 1.4, 0.0)
const B := Vector3(2.2, 1.4, 0.0)
const SPAWN := Vector3(-4.0, 0.65, 0.0)
const GOAL := Vector3(4.3, 0.0, 0.0)
var camera: Camera3D
var player: CharacterBody3D
var bridge: StaticBody3D
var yaw := 0.55
var pitch := 0.42
var distance := 16.0
var dragging := false
var won := false
var status: Label
var detail: Label
var progress: ProgressBar
var separation := INF
var reason := "Hold Shift to inspect the anchors"

func _ready() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("101926")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b4cce0")
	environment.environment.ambient_light_energy = 0.7
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.shadow_enabled = true
	add_child(light)
	make_box("StartIsland", Vector3(-4, -0.4, 0), Vector3(4, 0.8, 4), Color("334c60"))
	make_box("GoalIsland", Vector3(4, -0.4, 0), Vector3(4, 0.8, 4), Color("514563"))
	marker(A, Color("36e6f5"))
	marker(B, Color("ffb65b"))
	# Anchor pylons are visual only; their elevated tips have clear lines of sight.
	visual_box(Vector3(A.x, 0.65, 0), Vector3(0.05, 1.3, 0.05), Color("36e6f5"))
	visual_box(Vector3(B.x, 0.65, 0), Vector3(0.05, 1.3, 0.05), Color("ffb65b"))
	visual_box(GOAL + Vector3(0, 0.02, 0), Vector3(1.1, 0.04, 1.4), Color("66ffaa"))
	visual_box(GOAL + Vector3(0, 1.2, -0.7), Vector3(0.10, 2.4, 0.10), Color("66ffaa"))
	visual_box(GOAL + Vector3(0, 1.2, 0.7), Vector3(0.10, 2.4, 0.10), Color("66ffaa"))
	visual_box(GOAL + Vector3(0, 2.4, 0), Vector3(0.10, 0.10, 1.5), Color("66ffaa"))
	camera = Camera3D.new()
	camera.fov = 58.0
	add_child(camera)
	camera.current = true
	update_camera()
	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.camera = camera
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.25
	capsule.height = 1.1
	shape.shape = capsule
	player.add_child(shape)
	var mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.25
	capsule_mesh.height = 1.1
	mesh.mesh = capsule_mesh
	mesh.material_override = material(Color("f2f4ff"))
	player.add_child(mesh)
	player.position = SPAWN
	build_hud()

func material(tint: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = 0.85
	return mat

func visual_box(center: Vector3, size: Vector3, tint: Color, parent: Node = self) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material(tint)
	mesh.position = center
	parent.add_child(mesh)
	return mesh

func make_box(label: String, center: Vector3, size: Vector3, tint: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = center
	add_child(body)
	visual_box(Vector3.ZERO, size, tint, body)
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collider.shape = box
	body.add_child(collider)
	return body

func marker(location: Vector3, tint: Color) -> void:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.16
	sphere.height = 0.32
	mesh.mesh = sphere
	mesh.position = location
	var mat := material(tint)
	mat.emission_enabled = true
	mat.emission = tint
	mesh.material_override = mat
	add_child(mesh)

func update_camera() -> void:
	pitch = clampf(pitch, 0.02, 1.25)
	distance = clampf(distance, 10.0, 24.0)
	yaw = wrapf(yaw, -PI, PI)
	var target := (A + B) * 0.5
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
	camera.look_at(target)

func alignment_valid() -> bool:
	separation = INF
	var rect := get_viewport().get_visible_rect()
	for point in [A, B]:
		if camera.is_position_behind(point) or not camera.is_position_in_frustum(point) or not rect.has_point(camera.unproject_position(point)):
			reason = "Anchors must both be on screen"
			return false
		# Solid geometry blocks focus. Ignore only the player; glowing tips/pylons
		# have no collision so one tip cannot hide the other at the solution.
		var query := PhysicsRayQueryParameters3D.create(camera.global_position, point)
		query.exclude = [player.get_rid()]
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			reason = "Anchor obstructed by solid geometry"
			return false
	separation = camera.unproject_position(A).distance_to(camera.unproject_position(B))
	var tolerance := 26.0 * rect.size.y / 720.0
	var valid := separation <= tolerance
	reason = "READY: press E to build" if valid else "Lower the camera and orbit until the lights overlap"
	return valid

func try_build(focused: bool) -> bool:
	if not focused or won or is_instance_valid(bridge) or not alignment_valid():
		return false
	var delta := B - A
	if absf(delta.y) > 0.05:
		return false
	var deck_a := Vector3(A.x, 0, A.z)
	var deck_b := Vector3(B.x, 0, B.z)
	bridge = make_box("PerspectiveBridge", (deck_a + deck_b) * 0.5 - Vector3(0, 0.15, 0), Vector3(1.35, 0.3, deck_a.distance_to(deck_b) + 0.6), Color("d0b77e"))
	bridge.rotation.y = atan2(delta.x, delta.z)
	return true

func reset_level() -> void:
	if is_instance_valid(bridge):
		bridge.free()
	bridge = null
	won = false
	player.enabled = true
	player.test_direction = Vector3.ZERO
	player.position = SPAWN
	player.velocity = Vector3.ZERO
	yaw = 0.55
	pitch = 0.42
	distance = 16.0
	update_camera()
	release_mouse()

func release_mouse() -> void:
	dragging = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		release_mouse()

func _physics_process(_delta: float) -> void:
	if player.position.y < -6.0:
		player.position = SPAWN
		player.velocity = Vector3.ZERO
	if not won and is_instance_valid(bridge) and player.is_on_floor() and Vector2(player.position.x - GOAL.x, player.position.z - GOAL.z).length() < 0.65:
		won = true
		player.enabled = false

func _process(delta: float) -> void:
	var speed := 0.4 if Input.is_physical_key_pressed(KEY_SHIFT) else 1.0
	yaw += (float(Input.is_physical_key_pressed(KEY_LEFT)) - float(Input.is_physical_key_pressed(KEY_RIGHT))) * delta * speed
	pitch += (float(Input.is_physical_key_pressed(KEY_UP)) - float(Input.is_physical_key_pressed(KEY_DOWN))) * delta * speed
	update_camera()
	var ready := alignment_valid()
	var focused := Input.is_physical_key_pressed(KEY_SHIFT)
	if won:
		status.text = "LEVEL COMPLETE  /  THE ALIBI HOLDS"
		detail.text = "You crossed real geometry. Press R to play again."
	elif is_instance_valid(bridge):
		status.text = "BRIDGE COMMITTED"
		detail.text = "Raise the camera with Up. Walk to the green exit with WASD."
	elif focused:
		status.text = reason
		detail.text = "Projection gap: %.1f px  /  tolerance: %.1f px" % [separation, 26.0 * get_viewport().get_visible_rect().size.y / 720.0] if is_finite(separation) else "Both glowing tips need an unobstructed view."
	else:
		status.text = "01 / THE ALIBI"
		detail.text = "Hold Shift. Lower the view, then line up the cyan and amber lights."
	status.modulate = Color("72ffd0") if ready or won else Color.WHITE
	progress.value = clampf(100.0 - separation / 3.0, 0.0, 100.0)
	progress.visible = focused and not is_instance_valid(bridge)

func build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 24)
	layer.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var title := Label.new()
	title.text = "P E R S P E C T I V E   C R I M E"
	title.add_theme_font_size_override("font_size", 16)
	column.add_child(title)
	status = Label.new()
	status.add_theme_font_size_override("font_size", 25)
	column.add_child(status)
	detail = Label.new()
	column.add_child(detail)
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 6)
	column.add_child(progress)
	var hints := Label.new()
	hints.text = "WASD walk   |   Right-drag / arrows orbit   |   Wheel zoom\nHold Shift focus   |   E build   |   R restart   |   Esc release mouse"
	column.add_child(hints)
	ignore_hud_mouse(panel)

func ignore_hud_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in control.get_children():
		if child is Control:
			ignore_hud_mouse(child)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			reset_level()
		elif event.physical_keycode == KEY_ESCAPE:
			release_mouse()
		elif event.physical_keycode == KEY_E:
			try_build(Input.is_physical_key_pressed(KEY_SHIFT))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if dragging else Input.MOUSE_MODE_VISIBLE
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance -= 1.0
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance += 1.0
	elif event is InputEventMouseMotion and dragging:
		var sensitivity := 0.002 if Input.is_physical_key_pressed(KEY_SHIFT) else 0.007
		yaw -= event.relative.x * sensitivity
		pitch += event.relative.y * sensitivity
