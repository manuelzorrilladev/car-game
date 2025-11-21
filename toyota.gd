extends VehicleBody3D

# --- PROPIEDADES AJUSTABLES PARA EL DRIFT ---

# La fricción lateral ideal para un drift controlable suele ser 0.2 a 0.5
const DRIFT_FRICTION_FACTOR = 0.3 
# Un valor más alto significa que las ruedas frontales soportan más agarre,
# permitiendo un mejor contragiro y control
const ARCADE_SLIP = 2.0 

# --- CONSTANTES DE VEHÍCULO (DEJADAS IGUALES) ---

const ENGINE_POWER = 2500.0   
const MAX_STEER = 0.8         
const BRAKE_POWER = 100.0     
const MAX_TURN_ANGLE = 0.8    
const MAX_SPEED_KMH = 180.0
const COAST_BRAKE_POWER = 35.0 # Freno automático (al soltar el acelerador)

@onready var front_left_wheel = $FrontLeft
@onready var front_right_wheel = $FrontRight
@onready var rear_left_wheel = $BackLeft
@onready var rear_right_wheel = $BackRight

var is_drifting = false # Nuevo estado para gestionar el freno de mano
var original_transform: Transform3D # (Dejado igual)


func _ready():
	original_transform = transform

func _physics_process(delta):
	var steer_input = Input.get_axis("turn_right", "turn_left")
	var accel_input = Input.get_axis("run_backwards", "run_foward")
	var brake_input = Input.is_action_pressed("brake") 
	var drift_input = Input.is_action_pressed("drift")
	
	var current_speed_ms = linear_velocity.length()
	var current_speed_kmh = current_speed_ms * 3.6
	
	# 1. GESTIÓN DEL STEERING (DIRECCIÓN)
	steering = move_toward(steering, steer_input * MAX_TURN_ANGLE, delta * 3.0)
	front_left_wheel.steering = steering
	front_right_wheel.steering = steering
	
	# 2. GESTIÓN DE LA FUERZA DEL MOTOR (ENGINE_FORCE)
	var engine_force_value = 0.0
	if brake_input:
		engine_force_value = 0.0
	elif current_speed_kmh < MAX_SPEED_KMH:
		engine_force_value = accel_input * ENGINE_POWER
	else:
		engine_force_value = min(0.0, accel_input) * ENGINE_POWER

	# 3. GESTIÓN DE FRENOS (BRAKE)
	var brake_value = 0.0
	if brake_input:
		brake_value = BRAKE_POWER
	elif accel_input == 0.0 and current_speed_ms > 0.1:
		# Freno de costa/fricción
		brake_value = COAST_BRAKE_POWER
	
	# 4. LÓGICA DE DRIFT MEJORADA
	
	if drift_input and current_speed_kmh > 15.0: # Requerir una velocidad mínima mayor
		# A. Reducir fricción trasera para deslizar
		rear_left_wheel.wheel_friction_slip = DRIFT_FRICTION_FACTOR
		rear_right_wheel.wheel_friction_slip = DRIFT_FRICTION_FACTOR
		
		# B. Aplicar un pequeño freno de mano (si no está ya drifteando)
		if not is_drifting:
			rear_left_wheel.brake = BRAKE_POWER * 0.5 
			rear_right_wheel.brake = BRAKE_POWER * 0.5
			is_drifting = true
		else:
			# Si ya está drifteando, dejar que la fricción y la potencia mantengan el drift
			rear_left_wheel.brake = 0.0
			rear_right_wheel.brake = 0.0
			
	else: # Modo de conducción normal (sin drift)
		is_drifting = false
		
		# A. Configuración de fricción normal/arcade
		front_left_wheel.wheel_friction_slip = ARCADE_SLIP
		front_right_wheel.wheel_friction_slip = ARCADE_SLIP
		rear_left_wheel.wheel_friction_slip = ARCADE_SLIP
		rear_right_wheel.wheel_friction_slip = ARCADE_SLIP
		
	# 5. APLICAR VALORES FINALES A LAS RUEDAS
	
	# Aplicar fuerza del motor SOLO a las ruedas traseras (Tracción Trasera)
	rear_left_wheel.engine_force = engine_force_value
	rear_right_wheel.engine_force = engine_force_value
	
	# Aplicar freno general, asegurándose de que el freno de mano se aplica si es necesario
	# NOTA: En la lógica de drift, el freno se establece a 0.0 si 'is_drifting' es true,
	# así que esto aplicará solo el freno general/COAST si no está drifteando o si se presiona 'brake_input'
	
	front_left_wheel.brake = brake_value
	front_right_wheel.brake = brake_value
	rear_left_wheel.brake = brake_value
	rear_right_wheel.brake = brake_value
