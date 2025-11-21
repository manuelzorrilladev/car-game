extends Label3D

# Referencia al nodo del vehículo (el padre del Label3D)
var vehicle: VehicleBody3D


func _ready():
	# Intenta obtener el padre del Label3D
	var parent_node = get_parent()
	
	# ✅ Paso clave: Verificamos si el padre existe y es un VehicleBody3D
	if parent_node is VehicleBody3D:
		vehicle = parent_node
		text = " 0.0 km/h"
	else:
		# En caso de error de jerarquía de nodos
		print("Error: El padre del Label3D no es un VehicleBody3D. Asegúrate de que el Label3D sea un hijo directo del vehículo.")
		text = "ERROR"
		

func _process(delta):
	if vehicle:
		# 1. Obtener la velocidad lineal (vector de velocidad)
		var speed_meters_per_second = vehicle.linear_velocity.length()
		
		# 2. Convertir m/s a km/h
		var speed_kmh = speed_meters_per_second * 3.6
		
		# 3. Mostrar la velocidad formateada con un decimal
		text = " %.1f km/h" % speed_kmh
