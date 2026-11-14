extends CharacterBody2D

# Variables exportadas (puedes modificarlas desde el Inspector)
@export var speed: float = 500.0
@export var jump_velocity: float = -900.0

# Health and Death
@export var life:int=100
@export var is_dead:bool=false

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

#Attack states
var is_charging:bool=false
var is_attacking:bool=false
var is_special_attacking:bool=false

var is_on_cooldown_basic_attack:bool=false

@onready var basic_attack_x_original = abs($Basic_attack_hitbox/CollisionShape2D.position.x)
var can_attack:bool=true
#Sprite control
@export var last_direction:float=1.0 #Exportada para el retroceso

#Cooldown for being damaged
@export var is_damaged:bool=false

func _physics_process(delta: float) -> void:
	print(is_damaged)
	# 1. Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta if not Input.is_action_pressed("pass_down") else get_gravity() * fast_fall_multiplier * gravity_multiplier * delta
		
	else:
		jump_counter=jump_counter_default
		

	# 2.Basic Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$Jump.play()
		
		
	if Input.is_action_just_pressed("jump") and !is_on_floor() and jump_counter!=0:
		velocity.y = jump_velocity - 100
		jump_counter -=1
		
		$Jump.play()
		
	if Input.is_action_just_released("jump") and velocity.y <0:
		velocity.y=velocity.y / 2
	
		

	# 3. Go down platforms
	if Input.is_action_just_pressed("pass_down") and is_on_floor():
		position.y += 2.0  # Empuja ligeramente hacia abajo para atravesar la pala
		
	
	#Attacks
	
	is_charging=Input.is_action_pressed("attack_chargued") and is_on_floor()
	is_attacking=Input.is_action_just_pressed("attack_basic") and not is_charging
	
	
	if is_attacking and not is_on_cooldown_basic_attack and can_attack and not is_damaged:
		$Basic_attack_timer.start()
		is_on_cooldown_basic_attack=true
		can_attack=false
		$Cooldown_attack.start()
		$Basic_attack_hitbox/CollisionShape2D.disabled=false
		$Dash.play()
		
	
	if not is_on_cooldown_basic_attack:
		$Basic_attack_hitbox/CollisionShape2D.disabled=true	
	# 4. Movement
	if is_charging:
		velocity.x=0
	else:
		character_movement()
	
	 
	

	# 5. Apply movement and process collisions
	move_and_slide()
	
	# 6. Sprites
	var is_character_on_attack:bool=is_charging or is_special_attacking or is_on_cooldown_basic_attack
	
	$Sprites.flip_h=last_direction==1.0
	
	
	
	if is_character_on_attack:
		attack_sprites()
	else:
		movement_sprites()	
	
#Functions-----------------------------------------------------------------------------------
	
func movement_sprites()->void:
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
	
	
func attack_sprites()->void:
	if is_on_cooldown_basic_attack:
		$Sprites.play("Basic_attack")
	
func character_movement()->void:
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
	if is_on_cooldown_basic_attack:
			velocity.x=2000 * last_direction

func _on_basic_attack_timer_timeout() -> void:
	is_on_cooldown_basic_attack=false


func _on_cooldown_attack_timeout() -> void:
	can_attack=true


func _on_damage_cooldown_timeout() -> void:
	is_damaged=false
