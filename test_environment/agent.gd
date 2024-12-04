extends CharacterBody2D


const SPEED = 2
var REF = Vector2.ZERO
@onready var raycast_list = [$ray_up,
							$ray_down,
							$ray_left,
							$ray_right]


#Search variables
var pending_cells = []
var visited_cells = []
var path = []


var moving = false
var current = Vector2.ZERO
func _ready() -> void:
	$animator.play("idle")
#func _physics_process(_delta: float) -> void:
##
	### Get the input direction and handle the movement/deceleration.
	### As good practice, you should replace UI actions with custom gameplay actions.
	#var movement = Vector2.ZERO
	#movement.x = Input.get_axis("ui_left", "ui_right")
	#movement.y = Input.get_axis("ui_up", "ui_down")
	#
	#velocity = movement.normalized() * 200
	#move_and_slide()
	#
	#pass

func _process(delta: float) -> void:
	if moving:
		if get_cell().x < current.x:
			$animator.play("right")
		if get_cell().x > current.x:
			$animator.play("left")
		if get_cell().y < current.y:
			$animator.play("down")
		if get_cell().y > current.y:
			$animator.play("up")
		moving = move()
		if not moving: $animator.stop()
		


func move():
	# true - keep moving
	# false - moving has finsihed
	var cell = get_cell()
	#print("Moving from: ", cell ," to: ", current)
	if cell.x != current.x:
		position.x = move_toward(position.x, current.x * 48 + REF.x, SPEED)
	elif cell.y != current.y:
		position.y = move_toward(position.y, current.y * 48 + REF.y, SPEED)
	else:
		return false
	return true
	
func is_on_goal():
	for ray in raycast_list:
		var collider = ray.get_collider()
		if collider:
			if collider.name == "goal":
				return true 
	return false

func get_available_cells():
	var cells = []
	for ray in raycast_list:
		var _cell = get_cell()
		var collider = ray.get_collider()
		if not collider:
			match ray.name:
				"ray_up":
					_cell.y -= 1
				"ray_down":
					_cell.y += 1
				"ray_left":
					_cell.x -= 1
				"ray_right":
					_cell.x += 1
			cells.append(_cell)
	return cells


#func get_destination(direction):
	#destination = get_cell()
	#match direction:
		#"up":
			#destination.y -= 1
		#"down":
			#destination.y += 1
		#"right":
			#destination.x += 1
		#"left":
			#destination.x -= 1
	#return destination

func get_cell()->Vector2:
	var x = (position.x - REF.x) / 48
	var y = (position.y - REF.y) / 48
	return Vector2(x, y)
	
	
	
	
