extends CharacterBody2D

# Variables exportadas (puedes modificarlas desde el Inspector)
@export var speed: float = 500.0
@export var jump_velocity: float = -900.0

#Aumented gravity multiplier for a faster play style
@export var gravity_multiplier:float=1.3
#Jump counter
@export var jump_counter_default:int=1
var jump_counter:int = 1
var jump_counter_frame:int=1

#Inertia acceleration
@export var character_inertia:float= 20.0
@export var character_change_jump_direction_inertia:float=100.0
var is_turned:bool=false #Used for changing direction less roughly

#Dash Control

var is_dashing:bool=false
@export var dash_speed:float=900

#Fast fall
var fast_fall_multiplier:float=gravity_multiplier * 2

#Sprite control
var last_direction:float=1.0

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad cuando está en el aire
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta if not Input.is_action_pressed("pass_down") else get_gravity() * fast_fall_multiplier * delta
		
	else:
		jump_counter=jump_counter_default
		

	# 2. Salto básico (Usa la acción 'jump' del Input Map)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
		
	if Input.is_action_just_pressed("jump") and !is_on_floor() and jump_counter!=0:
		velocity.y = jump_velocity - 100
		jump_counter -=1
		
	if Input.is_action_just_released("jump") and velocity.y <0:
		velocity.y=velocity.y / 2
	
		

	# 3. Bajar de plataformas (Usa la acción 'pass_down' del Input Map)
	if Input.is_action_just_pressed("pass_down") and is_on_floor():
		position.y += 2.0  # Empuja ligeramente hacia abajo para atravesar la pala

	# 4. Movimiento horizontal (Usa 'move_left' y 'move_right')
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		
		if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and Input.is_action_pressed("Run") and is_on_floor():
			is_dashing=true
		
		if (not Input.is_action_pressed("Run")):
			is_dashing=false
		
		if  is_on_floor():
			if is_dashing:
				velocity.x=dash_speed * direction
			else:
				velocity.x= speed * direction
		else:
			var jump_speed=dash_speed if is_dashing else speed
			if Input.is_action_just_pressed("jump") and jump_counter_frame!=0:
				velocity.x=jump_speed * direction
			
			else:	
				velocity.x = move_toward(velocity.x,direction * jump_speed,20)
		last_direction=direction
	else:
		is_dashing=false
		velocity.x = move_toward(velocity.x, 0, character_inertia)
	jump_counter_frame=jump_counter
	 
	

	# 5. Aplicar el movimiento y procesar colisiones
	move_and_slide()
	
	# 6. Sprites
	
	$Sprites.flip_h=last_direction==1.0
	
	if is_on_floor():
		if velocity.x==0:
			$Sprites.play("Idle")
		else:
			if is_dashing:
				$Sprites.play("Run")
			else:
				$Sprites.play("Walk")
	else:
		if velocity.y<0:
			$Sprites.play("Jump")
		else:
			$Sprites.play("Fall")
	
	
	
	
	



	
