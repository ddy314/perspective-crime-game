extends SceneTree
## Reproducible real renderer/input demonstration, not a blind playtest.
## Run graphically with --write-movie <outside-repo>/chapter.avi --fixed-fps 30
## --script tests/chapter_capture.gd -- --no-save --capture-dir=<outside-repo>
const Scene = preload("res://scenes/chapter.tscn")
var level
func _initialize() -> void: call_deferred("run")
func pause(seconds: float) -> void: await create_timer(seconds).timeout
func capture(label_text: String) -> void:
	if level.capture_dir.is_empty(): return
	DirAccess.make_dir_recursive_absolute(level.capture_dir)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(level.capture_dir.path_join(label_text + ".png"))
func dismiss() -> void:
	for child in level.layer.get_children():
		if child.has_signal("dismissed"): child.dismissed.emit()
	await pause(.3)
func drag_to(index: int, target: float) -> void:
	var mechanism = level.district.mechanisms[index]
	var position: Vector2 = level.camera.unproject_position(mechanism.handle.global_position)
	var displacement := Vector2((target-mechanism.value)/.012,0)
	level.router.pointer(true, position)
	for i in range(1,31):
		level.router.motion(position + displacement*i/30.0)
		await pause(1.0/30.0)
	level.router.pointer(false, position+displacement)
	await pause(.35)
func walk(id: String) -> void:
	var p: Vector2 = level.camera.unproject_position(level.district.points[id])
	level.router.pointer(true,p)
	level.router.pointer(false,p)
	for i in range(400):
		if not level.walking and level.mode != "transition": break
		await pause(.05)
	await pause(.4)
func run() -> void:
	if not "--no-save" in OS.get_cmdline_user_args(): quit(2); return
	root.size = Vector2i(1280,800)
	level = Scene.instantiate()
	root.add_child(level)
	await pause(2)
	await capture("opening")
	await dismiss()
	for district_index in range(3):
		await pause(.5)
		await capture("district-%d-entry" % district_index)
		await drag_to(0,0)
		await walk("B")
		if district_index == 2:
			var pin: Vector2 = level.camera.unproject_position(level.district.lock_marker.global_position)
			level.router.pointer(true,pin)
			level.router.pointer(false,pin)
			await pause(.6)
		await drag_to(1,PI/2)
		await walk("C")
		await drag_to(2,0)
		await capture("district-%d-aligned" % district_index)
		await walk("D")
		await walk("E")
	await pause(1)
	await capture("ending")
	await pause(2)
	print("CHAPTER_RENDER_COMPLETE districts=3")
	level.sound.stop()
	level.chime.stop()
	quit()
