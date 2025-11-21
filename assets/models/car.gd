extends VehicleBody3D
@export_group("Wheel")
@export var front_left_wheel:VehicleWheel3D
@export var front_right_wheel:VehicleWheel3D
@export var rear_left_wheel:VehicleWheel3D
@export var rear_right_wheel:VehicleWheel3D

@export_group("Suspension Setting")
@export var wheel_friction: float = 10.5	
@export var suspension_stiff_value: float = 0.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for wheel in [front_left_wheel,front_right_wheel, rear_left_wheel,rear_right_wheel]:
		wheel.wheel_friction_slip = wheel_friction
		wheel.suspension_stiffness = suspension_stiff_value
