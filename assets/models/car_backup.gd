extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 2000
const CAMERA_ROTATION_SPEED = 1.5

@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D

var look_at
var camera_manual_rotation_y = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_at = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("turn_right","turn_left") * MAX_STEER, delta* 2.5)
	engine_force = Input.get_axis("run_backwards","run_foward") * ENGINE_POWER
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 40.0)
	var target_rotation_y = transform.basis.get_euler().y
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, target_rotation_y, delta * 1.0)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(look_at)


#func _physics_process(delta):
	#steering = move_toward(steering, Input.get_axis("turn_right","turn_left") * MAX_STEER, delta* 2.5)
	#engine_force = Input.get_axis("run_backwards","run_foward") * ENGINE_POWER
	#
	#camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 40.0)
	#
	## --- Control de Rotación de la Cámara con Teclado ---
	#
	## 1. Obtener la entrada del teclado para rotar la cámara
	#var camera_input = Input.get_axis("camera_right", "camera_left")
	#
	## 2. Aplicar la rotación manual
	#camera_manual_rotation_y += camera_input * delta * CAMERA_ROTATION_SPEED
	#
	## 3. Determinar la rotación objetivo
	#var target_rotation_y
	#
	#if abs(camera_input) > 0.05:
		## Si hay entrada de teclado de cámara, usa la rotación manual
		#target_rotation_y = camera_manual_rotation_y
	#else:
		## Si no hay entrada de teclado de cámara, interpolar de vuelta a la rotación del vehículo 
		## y actualizar la rotación manual para que coincida con la del vehículo
		#var vehicle_rotation_y = transform.basis.get_euler().y
		#target_rotation_y = vehicle_rotation_y
		#camera_manual_rotation_y = lerp_angle(camera_manual_rotation_y, vehicle_rotation_y, delta * 1.0)
		#
	## 4. Aplicar la rotación final al pivote de la cámara
	#camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, target_rotation_y, delta * 5.0) # Aumenté el factor de interpolación a 5.0 para una respuesta más rápida
	#
	## --- Apuntar la Cámara (Sin cambios) ---
	#look_at = look_at.lerp(global_position + linear_velocity, delta * 5.0)
	#camera_3d.look_at(look_at)
