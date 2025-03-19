extends Node2D

@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var anim_sprite = $AnimatedSprite2D

var minSpeed = 30
var maxSpeed = 70
var speed = randi() % (maxSpeed - minSpeed + 1) + minSpeed

var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    setDirection()
    position.x += _delta * speed * direction

func setDirection():
    # Go right if left colliding
    if ray_cast_left.is_colliding():
        direction = 1
        anim_sprite.flip_h = false

    # Go left if right colliding
    elif ray_cast_right.is_colliding():
        direction = -1
        anim_sprite.flip_h = true
