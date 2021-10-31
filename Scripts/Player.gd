extends KinematicBody2D

var mouse_pos
var direction
var move = false
var velocity = Vector2.ZERO
var influence_bodies: Array
var fuel = 100.0
var score = 0

export (int) var SPEED = 600
export (float) var RANGE = 2600.0
export (float) var MAX_FUEL = 100.0
export (float) var FUEL_USE = 0.5
#export (float) var MASS = 100

const G = 6.67e-11

func _ready():
	get_node("KillBox").connect("area_entered", self, "_on_collision")
	$"Area2D/CollisionShape2D".shape.radius = RANGE

func _physics_process(delta):
	mouse_pos = get_local_mouse_position()
	rotation += mouse_pos.angle() + PI/2
	#var prev = influence_bodies
	influence_bodies = $"Area2D".get_overlapping_bodies()
	#if not(prev == influence_bodies):
	#	print(influence_bodies)
	
	for body in influence_bodies:
		if body.is_in_group("has_mass"):
			var body_pos = body.get_global_position()
			var dir = position.direction_to(body_pos)
			var force = (G * body.get_mass())
			force = force / pow((body_pos.distance_to(position)), 2)
			velocity += (force * dir) * delta
	
	if move and fuel>0:
		direction = position.direction_to(get_global_mouse_position())
		velocity += (direction * SPEED) * delta
		set_fuel(fuel - FUEL_USE)
	
	move_and_slide(velocity, Vector2.UP)

func set_fuel(amount):
	fuel = amount
	$"../MarginContainer/FuelCount".set_text(str(floor(fuel)))

func set_score(amount):
	score = amount
	$"../MarginContainer/Score".set_text(str(score))

func _input(event):
	if event.is_action_pressed("click"):
		#direction = global_position.direction_to(mouse_pos)
		move = true
	if event.is_action_released("click"):
		#direction = Vector2.ZERO
		move = false
	if event.is_action_pressed("stop"):
		velocity = Vector2.ZERO

func _on_collision(body):
	if body.is_in_group("kill"):
		queue_free()
	if body.is_in_group("enemy"):
		var val = body.get_parent().get_value()
		var fill = fuel + val
		if fill > MAX_FUEL: fill = MAX_FUEL
		set_fuel(fill)
		set_score(score + val)
