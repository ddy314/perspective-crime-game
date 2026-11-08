extends CharacterBody3D
## Movement always goes through Godot physics, including automated traversal tests.
var camera: Camera3D
var enabled := true
var test_direction := Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction := test_direction
	if enabled and direction == Vector3.ZERO:
		var input := Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		var right := camera.global_basis.x
		var forward := camera.global_basis.z
		right.y = 0.0
		forward.y = 0.0
		direction = (right.normalized() * input.x + forward.normalized() * input.y).limit_length()
	if not enabled:
		direction = Vector3.ZERO
	velocity.x = direction.x * 3.5
	velocity.z = direction.z * 3.5
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	move_and_slide()
