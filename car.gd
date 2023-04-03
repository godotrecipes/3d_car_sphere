extends Node3D

var sphere_offset = Vector3.DOWN
var acceleration = 30.0
var steering = 18.0
var turn_speed = 4.0
var turn_stop_limit = 0.75
var body_tilt = 35

var speed_input = 0
var turn_input = 0

@onready var ball = $Ball
@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/suv2
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/suv2/wheel_frontRight
@onready var left_wheel = $CarMesh/suv2/wheel_frontLeft

func _ready():
	ground_ray.add_exception(ball)
	
func _physics_process(delta):
	car_mesh.position = ball.position + sphere_offset
	ball.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
	
func _process(delta):
	if not ground_ray.is_colliding():
		return
	speed_input = Input.get_axis("brake", "accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input

	
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * ball.linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 10.0 * delta)
