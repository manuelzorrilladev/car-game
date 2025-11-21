extends VehicleBody3D


const ENGINE_POWER = 5000.0   
const MAX_STEER = 0.8          
const BRAKE_POWER = 100.0      
const MAX_TURN_ANGLE = 0.8    
const MAX_SPEED_KMH = 200.0 
const COAST_BRAKE_POWER = 35.0


var original_transform: Transform3D 


const DRIFT_FRICTION_FACTOR = 0.1 # Factor de fricción lateral cuando drifteamos (0.1 es muy resbaladizo)
const NORMAL_FRICTION = 1.0       # Valor de fricción lateral normal (por defecto)

@onready var front_left_wheel = $FrontLeft
@onready var front_right_wheel = $FrontRight
@onready var rear_left_wheel = $BackLeft
@onready var rear_right_wheel = $BackRight

var look_at
var camera_manual_rotation_y = 0.0

func _ready():
	original_transform = transform



func _physics_process(delta):
	var steer_input = Input.get_axis("turn_right", "turn_left")
	
	steering = move_toward(steering, steer_input * MAX_TURN_ANGLE, delta * 3.0)
	
	front_left_wheel.steering = steering
	front_right_wheel.steering = steering
	
	var accel_input = Input.get_axis("run_backwards", "run_foward")
	var brake_input = Input.is_action_pressed("brake") 
	
	var current_speed_ms = linear_velocity.length()
	var current_speed_kmh = current_speed_ms * 3.6
	
	
	if brake_input:
		engine_force = 0.0
	else:
		if current_speed_kmh < MAX_SPEED_KMH:
			engine_force = accel_input * ENGINE_POWER
		else:
			engine_force = min(0.0, accel_input) * ENGINE_POWER
	
	var brake = 0.0
	if brake_input:
		brake = BRAKE_POWER
	elif accel_input == 0.0 and linear_velocity.length() > 0.1:

		brake = COAST_BRAKE_POWER
	
	var drift_input = Input.is_action_pressed("drift")
	var normal_friction_slip = 1.0 # Puedes usar 1.0 o un valor muy alto como 5.0
	if drift_input and current_speed_kmh > 10.0: 
		rear_left_wheel.wheel_friction_slip = DRIFT_FRICTION_FACTOR
		rear_right_wheel.wheel_friction_slip = DRIFT_FRICTION_FACTOR
		
		rear_left_wheel.brake = BRAKE_POWER * 0.5 
		rear_right_wheel.brake = BRAKE_POWER * 0.5
		
		
		
	else:
		rear_left_wheel.wheel_friction_slip = NORMAL_FRICTION
		rear_right_wheel.wheel_friction_slip = NORMAL_FRICTION
		
		const ARCADE_SLIP = 4.0 # Un valor alto para evitar el frenado por giro
		
		front_left_wheel.wheel_friction_slip = ARCADE_SLIP
		front_right_wheel.wheel_friction_slip = ARCADE_SLIP
		rear_left_wheel.wheel_friction_slip = ARCADE_SLIP
		rear_right_wheel.wheel_friction_slip = ARCADE_SLIP
		# Asegurarse de que el freno de drift se libera
		
	
	rear_left_wheel.brake = max(rear_left_wheel.brake, brake)
	rear_right_wheel.brake = max(rear_right_wheel.brake, brake)
	
	rear_left_wheel.engine_force = engine_force
	rear_right_wheel.engine_force = engine_force
	
	front_left_wheel.brake = brake
	front_right_wheel.brake = brake
	rear_left_wheel.brake = brake
	rear_right_wheel.brake = brake
	
