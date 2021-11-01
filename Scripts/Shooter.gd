extends KinematicBody2D

const G = 6.67e-11

var target: Vector2
var velocity = Vector2.ZERO
var influence_bodies: Array

export (int) var SPEED = 5000
export (int) var RANGE = 5000
export (int) var VALUE = 25


func _ready():
	$"KillBox".add_to_group("enemy")
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	get_node("KillBox").connect("area_entered", self, "_on_collision")
	target = Vector2.ZERO
	$"Area2D/CollisionShape2D".shape.radius = RANGE
	

func _physics_process(delta):
	#if target == Vector2.ZERO:	return
	influence_bodies = $"Area2D".get_overlapping_bodies()
	
	for body in influence_bodies:
		if body.is_in_group("player"):
			velocity += evade(body)
			
		if body.is_in_group("has_mass"):
			var body_pos = body.get_global_position()
			var dir = position.direction_to(body_pos)
			var force = (G * body.get_mass())
			force = force / pow((body_pos.distance_to(position)), 2)
			velocity += (force * dir)
	
	var direction = global_position.direction_to(target)
	velocity = velocity * delta
	move_and_slide(velocity, Vector2.UP)

func get_value():
	return VALUE

func evade(body: Node):
	var dir = position.direction_to(body.get_global_position())
	dir = dir * (-1) # opposite direction
	var v = dir * SPEED
	return v

func _on_screen_exited():
	queue_free()

func _on_collision(body):
	if body.is_in_group("kill"):
		queue_free()
