extends Label

# Cambia el nombre del nodo si tu VehicleBody3D se llama diferente
@onready var vehicle_body = $"../../ToyotaAE86"

# Referencias para la verificación de entradas (solo por claridad)
# Estos valores se obtendrán directamente del Input, no del VehicleBody3D
var steer_input: float = 0.0
var accel_input: float = 0.0
var engine_power: float = 0.0
var brake_pressed: bool = false
var drift_pressed: bool = false

# El tiempo de actualización (para no recargar la pantalla en cada frame)
const UPDATE_INTERVAL = 0.05 # Actualizar cada 0.05 segundos (20 veces por segundo)
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	
	# 1. Capturar las entradas del usuario (Godot las maneja en _process)
	steer_input = Input.get_axis("turn_right", "turn_left")
	accel_input = Input.get_axis("run_backwards", "run_foward")
	brake_pressed = Input.is_action_pressed("brake")
	drift_pressed = Input.is_action_pressed("drift")
	
	if timer >= UPDATE_INTERVAL:
		update_hud_display()
		timer = 0.0

func update_hud_display():
	if not is_instance_valid(vehicle_body):
		text = "ERROR: VehicleBody3D no encontrado."
		return

	# --- 2. Recopilar datos del vehículo ---
	
	# a) Determinar el estado de Drift (basado en la lógica de tu VehicleBody3D)
	# Si la fricción trasera es el valor DRIFT_SLIP, significa que estás en modo drift.
	var is_drifting = vehicle_body.rear_left_wheel.wheel_friction_slip == vehicle_body.DRIFT_SLIP
	
	var drift_status: String = ""
	if is_drifting:
		drift_status = "[ Drift Activo! 💨 ]"
	else:
		drift_status = "Modo Normal"

	# b) Determinar si las entradas de movimiento están activas
	var moving_input_status: String = ""
	if accel_input > 0.0:
		moving_input_status = "ADELANTE 🟢"
	elif accel_input < 0.0:
		moving_input_status = "ATRÁS 🔴"
	elif brake_pressed:
		moving_input_status = "FRENANDO 🛑"
	else:
		moving_input_status = "Sin Movimiento"
		
	# c) Obtener el valor de Steering (giro actual)
	# Lo obtenemos del VehicleBody3D (variable 'steering')
	var steering_value = vehicle_body.steering
	engine_power = vehicle_body.engine_force_value
	# --- 3. Construir el texto del Label ---
	
	var hud_text = ""
	hud_text += "--- Estado del Vehículo ---\n"
	
	# Muestra el estado del drift
	hud_text += "Estado: " + drift_status + "\n"
	
	# Muestra si el motor está recibiendo entrada
	hud_text += "Entrada Mov.: " + moving_input_status + "\n"
	
	# Muestra si el drift está presionado
	hud_text += "Drift Pres.: " + ("SI" if drift_pressed else "NO") + "\n"
	
	# Muestra el valor de Steering (formateado a 2 decimales)
	hud_text += "Steering: " + "%.2f" % steering_value  + "\n"
	
		# Muestra el valor de Steering (formateado a 2 decimales)
	hud_text += "Poder del motor: " + "%.2f" % engine_power
	
	# Asignar el texto final al Label
	text = hud_text
