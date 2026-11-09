extends Node3D
## Independent forward district, rebuilt from a checkpoint without prior apparatus.
const Art = preload("res://scripts/chapter/paper_art.gd")
const Graph = preload("res://scripts/chapter/walkable_graph.gd")
const Mechanism = preload("res://scripts/chapter/spatial_mechanism.gd")
const Seam = preload("res://scripts/chapter/projection_seam.gd")
var index := 0
var points: Dictionary = {}
var mechanisms: Array = []
var fixed: Array = []
var rings: Dictionary = {}
var buildings: Array = []
var graph = Graph.new()
var exit_id := "E"
var seam_ids: Array = []
var receiver: Node3D
var receiver_base := Vector3.ZERO
var camera: Camera3D
var lock_open := false
var lock_marker: Node3D
var synchronizing := false
var gate: Node3D
var brace_gate: Node3D
func setup(number: int, view: Camera3D) -> void:
	index = number
	camera = view
	points = {"A": Vector3(-5, 0, 3), "B": Vector3(-1, 0, 3), "C": Vector3(-1, 0, -1)}
	if index == 0:
		points["D"] = Vector3(3, 0, -1)
		points["E"] = Vector3(3, 0, -5)
		add_mechanism("hinge", "A", "B", -PI/2)
		add_mechanism("hinge", "B", "C", PI)
		add_mechanism("hinge", "C", "D", PI/2)
		fixed = [["D", "E"]]
	else:
		receiver_base = points.C + Vector3(12, 16, 22).normalized() * 5.0
		points["D"] = receiver_base + Vector3(2, 0, 0)
		points["E"] = receiver_base + Vector3(0, 0, -4)
		add_mechanism("hinge", "A", "B", PI/2)
		add_mechanism("hinge", "B", "C", 0)
		var slide = Mechanism.new()
		add_child(slide)
		slide.setup("slide", receiver_base, 2.0)
		slide.changed.connect(rebuild)
		mechanisms.append(slide)
		seam_ids = ["C", "D"]
		fixed = [["D", "E"]]
		# The final district couples both hinged streets until a physical brace is pinned.
		if index == 2:
			mechanisms[0].changed.connect(func(): couple(0, 1))
			mechanisms[1].changed.connect(func(): couple(1, 0))
			brace_gate = Node3D.new()
			add_child(brace_gate)
			brace_gate.position = points.C
			Art.box(brace_gate, Vector3(1.2, .12, .12), Vector3(0, .6, 0), Art.CORAL)
			for x in [-.55, .55]: Art.box(brace_gate, Vector3(.1, .7, .1), Vector3(x, .3, 0), Art.GOLD)
			lock_marker = Node3D.new()
			add_child(lock_marker)
			lock_marker.position = points.B + Vector3(0, .35, 1.0)
			Art.cylinder(lock_marker, .27, .12, Vector3.ZERO, Art.GOLD)
			Art.box(lock_marker, Vector3(.12, .55, .12), Vector3(0, .3, 0), Art.CORAL)
	for id in points:
		var island := Node3D.new()
		add_child(island)
		island.position = points[id]
		if id == "D" and index > 0: receiver = island
		Art.box(island, Vector3(1.5, .32, 1.5), Vector3(0, -.2, 0), Art.IVORY)
		var foot = Art.box(island, Vector3(1.15, 1.6, 1.15), Vector3(0, -1.15, 0), Art.TEAL if id in ["B", "D"] else Art.IVORY)
		foot.rotation.y = .035
		Art.box(island, Vector3(.9, .12, .9), Vector3(0, -2.0, 0), Art.GOLD)
		var ring = Art.cylinder(island, .44, .025, Vector3(0, .015, 0), Art.GOLD)
		rings[id] = ring
		for x in [-.5, .5]:
			Art.box(island, Vector3(.12, .3, .12), Vector3(x, .1, -.55), Art.GOLD)
	for edge in fixed:
		if index > 0: continue
		street(points[edge[0]], points[edge[1]])
	gate = Node3D.new()
	add_child(gate)
	gate.position = points.E
	for x in [-.53, .53]: Art.box(gate, Vector3(.16, 1.6, .16), Vector3(x, .8, 0), Art.GOLD)
	Art.box(gate, Vector3(1.25, .18, .18), Vector3(0, 1.6, 0), Art.GOLD)
	Art.box(gate, Vector3(.45, .3, .08), Vector3(0, 1.25, 0), Art.IVORY)
	if index > 0: street(receiver_base, points.E)
	decorate()
	rebuild()
func add_mechanism(kind: String, a: String, b: String, start: float) -> void:
	var mechanism = Mechanism.new()
	add_child(mechanism)
	mechanism.a = a
	mechanism.b = b
	mechanism.setup(kind, points[a], start)
	mechanism.changed.connect(rebuild)
	mechanisms.append(mechanism)
func couple(source: int, destination: int) -> void:
	if synchronizing or lock_open: return
	synchronizing = true
	mechanisms[destination].value = mechanisms[source].value
	mechanisms[destination].apply()
	synchronizing = false
func toggle_brace(actor_id: String) -> bool:
	if index != 2 or actor_id != "B": return false
	lock_open = not lock_open
	mechanisms[0].locked = lock_open
	lock_marker.rotation.z = PI/2 if lock_open else 0.0
	return true
func street(a: Vector3, b: Vector3) -> void:
	var strip = Art.box(self, Vector3(.8, .14, a.distance_to(b)), (a+b)/2 - Vector3(0,.11,0), Art.IVORY)
	strip.look_at(b)
	for i in range(1, 9):
		var dot = Art.cylinder(self, .035, .02, a.lerp(b, i/9.0) + Vector3(0,.01,0), Art.GOLD)
		dot.name = "RouteStitch"
func rebuild() -> void:
	if index > 0 and mechanisms.size() >= 3:
		points.D = mechanisms[2].endpoint()
		if is_instance_valid(receiver): receiver.position = points.D
	if is_instance_valid(brace_gate): brace_gate.scale.y = .1 if absf(mechanisms[0].value) < .1 else 1.0
	graph = Graph.new()
	for id in points: graph.add_point(id, points[id])
	for edge in fixed:
		if index == 0 or absf(mechanisms[2].value) < .2: graph.connect_points(edge[0], edge[1])
	for mechanism in mechanisms:
		if mechanism.kind == "hinge" and mechanism.endpoint().distance_to(points[mechanism.b]) < .25:
			if index != 2 or mechanism.a != "B" or absf(mechanisms[0].value) < .1:
				graph.connect_points(mechanism.a, mechanism.b)
	if seam_ids.size() == 2 and Seam.aligned(camera, points.C, points.D): graph.connect_points("C", "D")
func update_reachable(actor_id: String, time: float) -> void:
	for id in rings:
		var reachable: bool = not graph.route(actor_id, id).is_empty()
		var color: Color = Art.GOLD if reachable else Art.TEAL.darkened(.35)
		if id == actor_id: color = Art.CORAL
		rings[id].material_override.albedo_color = color
		rings[id].scale = Vector3.ONE * (1.0 + .06 * sin(time*3.0) if reachable and id != actor_id else 1.0)
func decorate() -> void:
	# Folded-paper skyline stays decorative and below the playable plane.
	for i in range(16):
		var angle := i * TAU / 16.0
		var p := Vector3(cos(angle)*9.0, -3.5 - (i%3)*.7, sin(angle)*8.0)
		var tower := Node3D.new()
		add_child(tower)
		tower.position = p
		var h := 1.4 + (i%4)*.6
		Art.box(tower, Vector3(.8, h, .8), Vector3(0,-h/2,0), Art.TEAL.darkened(.2) if i%2 else Art.IVORY.darkened(.15))
		var roof = Art.box(tower, Vector3(.62,.62,.62), Vector3(0,.0,0), Art.GOLD)
		roof.rotation.z = PI/4
		for y in range(3): Art.box(tower, Vector3(.19,.25,.02), Vector3(0,-.4-y*.5,.41), Art.GOLD)
		buildings.append(tower)
