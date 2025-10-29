extends Control

@onready var colorRect = $"../ColorRect"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	colorRect.visible = true
	colorRect.get_node("AnimationPlayer").play("fade_in")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/SampleScene.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
