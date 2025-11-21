extends Node3D

var look_direction = Vector3.FORWARD
const LOOK_DAMPENING: float = 2.5

const FOLLOW_DISTANCE: float = 1.0
const FOLLOW_HEIGHT: float = 1.0
const POSITION_DAMPENING: float = 14.0 


const BASE_FOV: float = 75.0
const MAX_SPEED_FOV_OFFSET: float = 15.0
const MAX_ROLL: float = 0.15 
const ROLL_DAMPENING: float = 8.0

const VIBRATION_INTENSITY = 0.005 # Qué tan fuerte vibra (ajusta este valor)
const VIBRATION_SPEED = 10.0      # Qué tan rápido cambia la vibración
var original_transform: Transform3D # Para guardar la posición inicial

@onready var camera_3d: Camera3D = $Camera3D
@onready var target_body: Node3D = get_parent()

func _ready():
	original_transform = transform
	# Puedes añadir aquí otras inicializaciones si las tienes


func _physics_process(delta: float) -> void:
	if not target_body:
		return

	# 1. --- Lógica de Seguimiento ---
	

	var local_offset = Vector3(0, FOLLOW_HEIGHT, -FOLLOW_DISTANCE) 
	
	var target_global_position = target_body.global_transform * local_offset
	
	global_position = global_position.lerp(
		target_global_position, 
		delta * POSITION_DAMPENING
	)

	# 2. --- Lógica de Rotación  ---
	
	var current_velocity = target_body.get_linear_velocity()
	current_velocity.y = 0
	
	if current_velocity.length_squared() > 0.1:
		look_direction = look_direction.lerp(
			-current_velocity.normalized(), 
			LOOK_DAMPENING * delta
		)
		
		
		
	# 3. --- Lógica de FOV  ---
	var max_speed = target_body.MAX_SPEED_KMH / 3.6
	var speed_ratio = current_velocity.length() / max_speed
	speed_ratio = clamp(speed_ratio, 0.0, 1.0) 
	
	var target_fov = BASE_FOV + (MAX_SPEED_FOV_OFFSET * speed_ratio)
	
	camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 5.0) 
	
#	4. --- Logica de Roll (EXPERIMENTAL) ---

	var steer_input = target_body.steering / target_body.MAX_TURN_ANGLE # Normalizamos el ángulo de giro del vehículo
	var target_roll = -steer_input * MAX_ROLL * speed_ratio # Multiplicar por speed_ratio para que solo se incline a alta velocidad

	var current_rotation = global_rotation
	var new_roll = lerp(current_rotation.z, target_roll, delta * ROLL_DAMPENING)

	# Aplicar la rotación Z (Roll) al pivote
	global_rotation = Vector3(current_rotation.x, current_rotation.y, new_roll)
	
	global_transform.basis = get_rotation_from_direction(look_direction)
	
	
	
	


func get_rotation_from_direction(look_direction :Vector3)->Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis, Vector3.UP, -look_direction)
