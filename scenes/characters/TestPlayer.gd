extends CharacterBody2D

# Variables exportadas (puedes modificarlas desde el Inspector)
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad cuando está en el aire
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Salto básico (Usa la acción 'jump' del Input Map)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("jump") and !is_on_floor():
		velocity.y = jump_velocity - 100

	# 3. Bajar de plataformas (Usa la acción 'pass_down' del Input Map)
	if Input.is_action_just_pressed("pass_down") and is_on_floor():
		position.y += 2.0  # Empuja ligeramente hacia abajo para atravesar la pala

	# 4. Movimiento horizontal (Usa 'move_left' y 'move_right')
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 5. Aplicar el movimiento y procesar colisiones
	move_and_slide()
