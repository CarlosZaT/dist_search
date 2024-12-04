extends Node2D

var is_root = false
var cell = Vector2.ZERO
var parent = null
var children = []
var visited = false

func _ready() -> void:
	pass # Replace with function body.
func get_id():
	return "%s" % cell
