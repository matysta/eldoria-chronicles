extends Area2D

@onready var player = %Player


func _on_body_entered(_body:Node2D):
    player.set_jump_velocity_boost()

func _on_body_exited(_body:Node2D):
    player.reset_jump_velocity()
