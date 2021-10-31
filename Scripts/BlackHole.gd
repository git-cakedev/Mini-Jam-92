extends StaticBody2D

export (float) var mass = 8e16

func _ready():
	add_to_group("has_mass")
	
func get_mass():
	return mass
