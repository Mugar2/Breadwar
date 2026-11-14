extends Node2D
@export var last_direction=0.0
func _ready() -> void:
	last_direction=get_parent().last_direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x+=20*last_direction
	
