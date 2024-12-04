extends Sprite2D


# Called when the node enters the scene tree for the first time.
var WIDTH = 1280
var HEIGHT = 720
var size = 128
func _ready() -> void:
	scale.x = int(HEIGHT/size)
	scale.y = int(HEIGHT/size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
