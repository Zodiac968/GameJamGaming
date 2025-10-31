extends Area3D

var start_timer = false
var seconds = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_timer:
		seconds -= delta
		if seconds < 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene_to_file("res://Scenes/Levels/start.tscn")


func _on_body_entered(body: Node3D) -> void:
	for i in get_children():
		if i.get_child(0):
			i.get_child(0).emitting = true
	start_timer = true
			
