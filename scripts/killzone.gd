extends Area2D

@onready var timer = $Timer;
@onready var game_manager = %GameManager

func _ready():
    assert(timer != null, "Timer node is missing!")
    call_deferred("_check_game_manager")

func _check_game_manager():
    if game_manager == null:
        push_error("GameManager is not assigned!")

func _on_body_entered(_body: Node2D):
    print("You died");
    Engine.time_scale = 0.5
    _body.get_node("CollisionShape2D").queue_free();
    timer.start();


func _on_timer_timeout():
    game_manager.on_level_restart();
    Engine.time_scale = 1;
