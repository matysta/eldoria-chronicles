extends Area2D

@onready var timer = $Timer;

func _on_body_entered(_body: Node2D):
    print("You died");
    Engine.time_scale = 0.5
    _body.get_node("CollisionShape2D").queue_free();
    timer.start();


func _on_timer_timeout():
    %GameManager.on_level_restart();
    get_tree().reload_current_scene();
    Engine.time_scale = 1;
