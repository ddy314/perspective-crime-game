extends SceneTree
## Run: godot4 --headless --path . --script tests/chapter_playthrough.gd -- --no-save
## Uses live scene geometry and camera; does not replace rendered human playtesting.
const Scene = preload("res://scenes/chapter.tscn")
const Router = preload("res://scripts/chapter/input_router.gd")
const Graph = preload("res://scripts/chapter/walkable_graph.gd")
const Seam = preload("res://scripts/chapter/projection_seam.gd")
var level
var checks := 0
var failures := 0
var events: Array = []
func check(ok: bool, label_text: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + label_text)
func frames(count: int) -> void:
	for i in count: await process_frame
func wait_still() -> void:
	for i in 1800:
		if not level.walking and level.mode != "transition": return
		await process_frame
	check(false, "bounded traversal/transition completes")
func turn(index: int, value: float) -> void:
	var mechanism = level.district.mechanisms[index]
	mechanism.adjust(value - mechanism.value)
	mechanism.settle()
	level.district.rebuild()
func dismiss_comic() -> void:
	for child in level.layer.get_children():
		if child.has_signal("dismissed"): child.dismissed.emit()
	await frames(2)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	if not "--no-save" in OS.get_cmdline_user_args():
		push_error("Refusing to run without --no-save")
		quit(2)
		return
	root.size = Vector2i(1280, 800)
	Engine.time_scale = 30.0
	var graph = Graph.new()
	for id in ["a", "b", "c", "d"]: graph.add_point(id, Vector3.ZERO)
	graph.connect_points("a", "b")
	graph.connect_points("b", "c")
	graph.connect_points("c", "a")
	check(graph.route("a", "c") == ["a", "c"], "graph shortest route through cycle")
	check(graph.route("a", "d").is_empty() and graph.route("missing", "a").is_empty(), "graph rejects disconnected/unknown destinations")
	check(graph.route("a", "a") == ["a"], "graph self-route is stable")
	var router = Router.new()
	root.add_child(router)
	router.tapped.connect(func(_p): events.append("tap"))
	router.drag_started.connect(func(_p): events.append("start"))
	router.dragged.connect(func(_p): events.append("drag"))
	router.drag_finished.connect(func(): events.append("finish"))
	router.pointer(true, Vector2.ZERO)
	router.motion(Vector2(8, 0))
	router.pointer(false, Vector2(8, 0))
	check(events == ["tap"], "sub-threshold motion remains a tap")
	events.clear()
	router.pointer(true, Vector2.ZERO)
	router.motion(Vector2(9, 0))
	router.pointer(false, Vector2(9, 0))
	check(events == ["start", "drag", "finish"], "threshold drag never emits a tap")
	events.clear()
	router.pointer(true, Vector2.ZERO)
	router.cancel()
	router.pointer(false, Vector2.ZERO)
	check(events.is_empty() and not router.down and not router.dragging, "cancelled press never becomes a tap")
	router.queue_free()
	level = Scene.instantiate()
	root.add_child(level)
	await frames(4)
	check(level.no_save and level.checkpoint == 0, "isolated no-save launch starts at district zero")
	check(level.mode == "comic" and not level.walk_to("B"), "opening comic gates navigation")
	await dismiss_comic()
	check(level.mode == "play", "opening dismissal enters play")
	var handle_screen: Vector2 = level.camera.unproject_position(level.district.mechanisms[0].handle.global_position)
	level.router.pointer(true, handle_screen)
	level.router.motion(handle_screen + Vector2(15, 0))
	check(level.active_mechanism != null and level.router.dragging, "pointer drag captures a projected brass grip")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	level._unhandled_key_input(escape)
	check(not level.router.down and level.active_mechanism == null, "Escape releases pointer and active architecture together")
	level.restart()
	for district_index in range(3):
		check(level.checkpoint == district_index, "forward progression reaches district %d" % district_index)
		check(level.actor_id == "A" and not level.walking, "district %d begins at safe entry" % district_index)
		check(level.district.graph.route("A", "E").is_empty(), "district %d unsolved exit inaccessible" % district_index)
		check(not level.walk_to("E"), "district %d rejects inaccessible traversal" % district_index)
		if district_index == 2:
			check(not level.district.toggle_brace("A"), "brace requires actor at central landing")
		turn(0, 0)
		if district_index == 2:
			check(is_equal_approx(level.district.mechanisms[1].value, 0), "compound hinges couple before brace")
		check(level.district.mechanisms[0].endpoint().distance_to(level.district.points.B) < .001, "district %d first hinge physically joins landing" % district_index)
		if district_index == 2:
			level.tap(level.camera.unproject_position(level.district.points.B))
			check(level.walking, "district 2 projected B tap starts walking instead of hitting brace")
		else:
			check(level.walk_to("B"), "district %d starts valid traversal" % district_index)
		var before: float = level.district.mechanisms[0].value
		level.district.mechanisms[0].adjust(.6)
		check(level.walking and is_equal_approx(before, level.district.mechanisms[0].value), "district %d freezes geometry while walking" % district_index)
		check(not level.walk_to("A"), "district %d blocks overlapping traversal" % district_index)
		if district_index == 0:
			level.restart()
			await frames(15)
			check(not level.walking and level.actor_id == "A" and level.actor.position.distance_to(level.district.points.A) < .001, "restart kills travel and resets actor without stale callbacks")
			turn(0, 0)
			check(level.walk_to("B"), "restarted district remains traversable")
		await wait_still()
		check(level.actor_id == "B", "district %d traversal arrives at B" % district_index)
		if district_index == 2:
			turn(1, PI/2)
			check(level.district.graph.route("B", "C").is_empty(), "coupled hinge solution cannot bypass brass brace")
			turn(0, 0)
			check(level.district.toggle_brace("B") and level.district.lock_open, "brace pins first hinge")
			level.district.mechanisms[0].adjust(.7)
			check(is_equal_approx(level.district.mechanisms[0].value, 0), "pinned first hinge rejects manipulation")
		turn(1, PI/2)
		if district_index == 2:
			check(is_equal_approx(level.district.mechanisms[0].value, 0), "brace permits independent second hinge")
		check(level.district.mechanisms[1].endpoint().distance_to(level.district.points.C) < .001, "district %d second hinge physically joins landing" % district_index)
		check(level.walk_to("C"), "district %d travels to C" % district_index)
		await wait_still()
		check(level.actor_id == "C", "district %d traversal arrives at C" % district_index)
		if district_index == 0:
			turn(2, 0)
		else:
			check(not Seam.aligned(level.camera, level.district.points.C, level.district.points.D), "district %d initial slide fails actual camera projection" % district_index)
			turn(2, 0)
			var screen_gap: float = level.camera.unproject_position(level.district.points.C).distance_to(level.camera.unproject_position(level.district.points.D))
			check(screen_gap < .01 and level.district.points.C.distance_to(level.district.points.D) > 4.9, "district %d joins projected landings across real depth gap" % district_index)
			check(Seam.aligned(level.camera, level.district.points.C, level.district.points.D), "district %d camera validates seam" % district_index)
			check(not Seam.aligned(level.camera, Vector3(10000, 0, 0), Vector3(10000, 0, 0)), "offscreen coincidence is not a seam")
		check(level.district.graph.route("C", "E") == ["C", "D", "E"], "district %d solved graph has real exit route" % district_index)
		if district_index > 0:
			check(level.walk_to("D"), "district %d crosses camera seam to receiver" % district_index)
			await wait_still()
			check(level.actor_id == "D" and level.actor.position.distance_to(level.district.points.D) < .001, "district %d actor reaches receiver in world space" % district_index)
			level.begin_drag(level.camera.unproject_position(level.district.mechanisms[2].handle.global_position))
			var receiver_before: Vector3 = level.district.points.D
			level.drag(Vector2(25, 0))
			level.end_drag()
			check(level.district.points.D.distance_to(receiver_before) < .001, "occupied receiver cannot slide out from under actor")
		check(level.walk_to("E"), "district %d exits through route" % district_index)
		await wait_still()
	check(level.mode == "comic" and level.actor_id == "E", "final delivery opens ending comic")
	await dismiss_comic()
	check(level.checkpoint == 0 and level.actor_id == "A" and level.mode == "play", "ending replay starts clean chapter")
	print("CHAPTER TEST RESULTS: %d checks, %d failures" % [checks, failures])
	level.sound.stop()
	level.chime.stop()
	level.queue_free()
	await create_timer(.2, true, false, true).timeout
	quit(1 if failures else 0)
