extends SceneTree
## Run: godot --headless --path . --script tests/playthrough.gd
var failures := 0
var level: Node3D

func check(ok: bool, label: String) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok:
		failures += 1

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1280, 720)
	level = load("res://scenes/main.tscn").instantiate()
	root.add_child(level)
	await frames(3)
	key(KEY_E, true)
	await frames(2)
	key(KEY_E, false)
	check(not is_instance_valid(level.bridge), "actual E input at initial misalignment creates nothing")
	check(not level.try_build(false), "E without focus creates nothing")
	var before: Vector3 = level.player.position
	key(KEY_W, true)
	await frames(8)
	key(KEY_W, false)
	var forward: Vector3 = -level.camera.global_basis.z
	forward.y = 0.0
	check((level.player.position - before).dot(forward.normalized()) > 0.2, "W input walks camera-relative through physics")
	level.reset_level()
	level.pitch = -10.0
	level.distance = 100.0
	level.update_camera()
	check(is_equal_approx(level.pitch, 0.02) and is_equal_approx(level.distance, 24.0), "camera bounds clamp orbit and zoom")
	level.reset_level()
	# No bridge: walk into the void through exactly the ordinary movement code.
	level.player.test_direction = Vector3.RIGHT
	await frames(65)
	check(level.player.position.y < -0.5, "unbridged gap has no hidden floor")
	level.player.test_direction = Vector3.ZERO
	await frames(65)
	check(level.player.position.x < -2.0, "fall resets to safe island")
	level.reset_level()
	await frames(2)
	level.yaw = PI / 2.0
	level.pitch = 0.02
	level.update_camera()
	check(level.alignment_valid(), "real camera projection reaches tolerance")
	print("Alignment separation: ", level.separation)
	var blocker = level.make_box("TestOccluder", Vector3(7, 1.5, 0), Vector3(1, 3, 3), Color.WHITE)
	await frames(2)
	check(not level.try_build(true), "solid occluder rejects alignment")
	blocker.free()
	await frames(2)
	# Keep main process from updating the camera while testing rejected views.
	level.set_process(false)
	level.camera.look_at(level.camera.position + Vector3.RIGHT)
	check(not level.try_build(true), "behind-camera anchors rejected")
	level.update_camera()
	level.camera.fov = 1.0
	level.camera.look_at(Vector3(0, 4, 0))
	check(not level.try_build(true), "offscreen anchors rejected")
	level.camera.fov = 58.0
	level.update_camera()
	level.set_process(true)
	for attempt in 2:
		level.yaw = PI / 2.0
		level.pitch = 0.02
		level.update_camera()
		key(KEY_SHIFT, true)
		key(KEY_E, true)
		await frames(2)
		key(KEY_E, false)
		key(KEY_SHIFT, false)
		check(is_instance_valid(level.bridge), "Shift+E input builds physical bridge attempt %d" % (attempt + 1))
		check(not level.try_build(true), "repeated E does not duplicate bridge")
		check(level.bridge.get_child(1) is CollisionShape3D, "bridge collision is a direct child")
		level.yaw = 0.55
		level.pitch = 0.6
		level.update_camera()
		await frames(30)
		level.player.test_direction = Vector3.RIGHT
		var lowest_y := 100.0
		for i in 150:
			await physics_frame
			lowest_y = minf(lowest_y, level.player.position.y)
		check(lowest_y > 0.45, "crossing stays on actual collision after camera changes")
		await process_frame
		check(level.won and level.player.position.x > 3.6 and "LEVEL COMPLETE" in level.status.text, "walking reaches visible win label")
		check(is_instance_valid(level.bridge), "bridge persists at completion")
		key(KEY_R, true)
		await frames(3)
		key(KEY_R, false)
		check(not level.won and not is_instance_valid(level.bridge) and level.player.position.distance_to(level.SPAWN) < 0.2, "R resets bridge, win, camera, player")
	print("RESULT: %d failure(s)" % failures)
	quit(0 if failures == 0 else 1)
