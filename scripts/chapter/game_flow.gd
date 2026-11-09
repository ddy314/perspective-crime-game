extends Node3D
const Art = preload("res://scripts/chapter/paper_art.gd")
const Module = preload("res://scripts/chapter/chapter_module.gd")
const Router = preload("res://scripts/chapter/input_router.gd")
const Panels = preload("res://scripts/chapter/narrative_panels.gd")
const Hud = preload("res://scripts/chapter/chapter_hud.gd")
var camera: Camera3D
var district
var router
var hud
var layer: CanvasLayer
var actor: Node3D
var actor_id := "A"
var checkpoint := 0
var mode := "comic"
var walking := false
var active_mechanism = null
var travel: Tween
var elapsed := 0.0
var invalid_timer := 0.0
var invalid_at := Vector2.ZERO
var sound: AudioStreamPlayer
var chime: AudioStreamPlayer
var muted := false
var capture_dir := ""
var no_save := false
func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--no-save": no_save = true
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
	build_backdrop()
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CANVAS
	env.environment.background_canvas_max_layer = -1
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c4e2d6")
	env.environment.ambient_light_energy = .4
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-30,0)
	sun.light_color = Color("fff3df")
	sun.light_energy = .8
	sun.shadow_enabled = true
	add_child(sun)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 20.0
	camera.position = Vector3(12,15,22)
	add_child(camera)
	camera.look_at(Vector3(0,-1,0))
	camera.current = true
	layer = CanvasLayer.new()
	add_child(layer)
	router = Router.new()
	add_child(router)
	router.tapped.connect(tap)
	router.drag_started.connect(begin_drag)
	router.dragged.connect(drag)
	router.drag_finished.connect(end_drag)
	hud = Hud.new()
	hud.flow = self
	layer.add_child(hud)
	sound = AudioStreamPlayer.new()
	sound.stream = load("res://assets/audio/ambience.wav")
	sound.volume_db = -15
	add_child(sound)
	sound.finished.connect(func(): sound.play())
	sound.play()
	chime = AudioStreamPlayer.new()
	chime.stream = load("res://assets/audio/align.wav") if ResourceLoader.exists("res://assets/audio/align.wav") else null
	add_child(chime)
	if not no_save:
		var config := ConfigFile.new()
		if config.load("user://letter.cfg") == OK: checkpoint = clampi(config.get_value("chapter", "district", 0), 0, 2)
	load_district(checkpoint)
	show_comic(false)
func load_district(number: int) -> void:
	router.cancel()
	active_mechanism = null
	walking = false
	if is_instance_valid(travel): travel.kill()
	if is_instance_valid(district):
		remove_child(district)
		district.queue_free()
	if is_instance_valid(actor):
		remove_child(actor)
		actor.queue_free()
	checkpoint = number
	district = Module.new()
	add_child(district)
	district.setup(number, camera)
	actor = Art.messenger(self)
	actor_id = "A"
	actor.position = district.points.A
	if not no_save:
		var config := ConfigFile.new()
		config.set_value("chapter", "district", checkpoint)
		config.save("user://letter.cfg")
func show_comic(ending: bool) -> void:
	mode = "comic"
	hud.hide()
	var comic = Panels.new()
	comic.ending = ending
	layer.add_child(comic)
	comic.dismissed.connect(func():
		comic.queue_free()
		if ending: load_district(0)
		mode = "play"
		hud.show()
	)
func _process(delta: float) -> void:
	elapsed += delta
	invalid_timer = maxf(0, invalid_timer-delta)
	if is_instance_valid(district):
		district.rebuild()
		district.update_reachable(actor_id, elapsed)
	if is_instance_valid(actor):
		actor.rotation.z = sin(elapsed * (12 if walking else 1.5)) * (.035 if walking else .012)
		for foot_index in [5, 6]:
			actor.get_child(foot_index).position.y = .09 + (absf(sin(elapsed*12 + foot_index*PI/2))*.08 if walking else 0.0)
	hud.queue_redraw()
func feedback(at: Vector2) -> void:
	invalid_at = at
	invalid_timer = 1.0
func tap(p: Vector2) -> void:
	if mode != "play" or walking or hud.help.visible: return
	if actor_id == "B" and is_instance_valid(district.lock_marker) and camera.unproject_position(district.lock_marker.global_position).distance_to(p) < 26:
		if not district.toggle_brace(actor_id): feedback(p)
		else: play_chime()
		return
	var closest := ""
	var distance := 32.0
	for id in district.points:
		var candidate: float = camera.unproject_position(district.points[id]).distance_to(p)
		# At an aligned seam, prefer the far-side landing when already on its near side.
		if candidate < distance and id != actor_id:
			distance = candidate
			closest = id
	if closest.is_empty():
		feedback(p)
		return
	walk_to(closest)
func walk_to(id: String) -> bool:
	if mode != "play" or walking: return false
	district.rebuild()
	var route: Array = district.graph.route(actor_id, id)
	if route.size() < 2:
		feedback(camera.unproject_position(district.points[id]))
		return false
	walking = true
	active_mechanism = null
	for mechanism in district.mechanisms: mechanism.busy = true
	travel = create_tween()
	for i in range(1, route.size()):
		var target: Vector3 = district.points[route[i]]
		var previous: Vector3 = district.points[route[i-1]]
		travel.tween_property(actor, "position", target, maxf(.3, previous.distance_to(target)/3.1)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		travel.tween_callback(func(): actor_id = route[i])
	travel.tween_callback(func():
		walking = false
		for mechanism in district.mechanisms: mechanism.busy = false
		play_chime()
		if actor_id == district.exit_id: advance()
	)
	return true
func begin_drag(p: Vector2) -> void:
	if mode != "play" or walking or hud.help.visible: return
	var distance := 46.0
	for mechanism in district.mechanisms:
		var candidate: float = camera.unproject_position(mechanism.handle.global_position).distance_to(p)
		if mechanism.kind == "slide" and actor_id == "D": continue
		if candidate < distance:
			active_mechanism = mechanism
			distance = candidate
	if active_mechanism == null: feedback(p)
func drag(delta: Vector2) -> void:
	if active_mechanism == null or walking: return
	# Positive horizontal drag turns the hinge; slides follow their visible rail.
	active_mechanism.adjust((delta.x - delta.y*.4) * .012)
func end_drag() -> void:
	if active_mechanism != null:
		active_mechanism.settle()
		active_mechanism = null
func advance() -> void:
	if checkpoint == 2:
		if not no_save:
			var config := ConfigFile.new()
			config.set_value("chapter", "district", 0)
			config.save("user://letter.cfg")
		show_comic(true)
	else:
		mode = "transition"
		var fade := ColorRect.new()
		fade.color = Color("e9dfc4")
		fade.mouse_filter = Control.MOUSE_FILTER_STOP
		fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fade.modulate.a = 0
		layer.add_child(fade)
		var t := create_tween()
		t.tween_property(fade,"modulate:a",1.0,.45)
		t.tween_callback(func(): load_district(checkpoint+1))
		t.tween_property(fade,"modulate:a",0.0,.55)
		t.tween_callback(func(): fade.queue_free(); mode = "play")
func restart() -> void:
	if mode != "play": return
	load_district(checkpoint)
func toggle_sound() -> void:
	muted = not muted
	sound.volume_db = -80 if muted else -15
	chime.volume_db = -80 if muted else -4
func play_chime() -> void:
	if chime.stream != null: chime.play()
func hint_text() -> String:
	if checkpoint == 2 and not district.lock_open and actor_id == "B": return "The brass pin can hold the first street while the second turns."
	if checkpoint > 0 and actor_id in ["C", "D"]: return "Slide the tall facade until the two landing medallions become one."
	return "Turn a brass grip until the teal street meets an ivory landing. Then click the landing."
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if event.keycode == KEY_F12 and not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
		get_viewport().get_texture().get_image().save_png(capture_dir.path_join("chapter-%d-%d.png" % [checkpoint, Time.get_ticks_msec()]))
	elif event.keycode == KEY_R: restart()
	elif event.keycode == KEY_M: toggle_sound()
	elif event.keycode == KEY_ESCAPE: hud.help.hide(); cancel_gesture()

func cancel_gesture() -> void:
	end_drag()
	router.cancel()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(router): cancel_gesture()

func build_backdrop() -> void:
	var background := CanvasLayer.new()
	background.layer = -10
	add_child(background)
	var base := ColorRect.new()
	base.color = Color("183e4d")
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(base)
	if ResourceLoader.exists("res://assets/chapter_sky.png"):
		var sky := TextureRect.new()
		sky.texture = load("res://assets/chapter_sky.png")
		sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sky.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sky.modulate = Color(.65,.72,.75,1)
		background.add_child(sky)

func _exit_tree() -> void:
	if is_instance_valid(sound): sound.stop()
	if is_instance_valid(chime): chime.stop()
