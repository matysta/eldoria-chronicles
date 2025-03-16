extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D

var speed = 130.0
var jump_velocity = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
    apply_gravity(delta)
    handle_jump()
    handle_movement()
    apply_velocity()


# ─── Movement ──────────────────────────────────────────────────────────────────

func apply_gravity(delta):
    if not is_on_floor():
        velocity.y += gravity * delta

func handle_jump():
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

func handle_movement():
    var direction = Input.get_axis("move_left", "move_right")
    flip_sprite(direction)
    play_animation(direction)
    update_velocity(direction)

func update_velocity(direction):
    if direction:
        velocity.x = direction * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)

func apply_velocity():
    move_and_slide()

func set_jump_velocity_boost():
    jump_velocity = -600

func reset_jump_velocity():
    jump_velocity = -300


# ─── Sprite ────────────────────────────────────────────────────────────────────

func flip_sprite(direction):
    if direction > 0:
        anim_sprite.flip_h = false
    elif direction < 0:
        anim_sprite.flip_h = true

func play_animation(direction):
    if is_on_floor():
        if direction == 0:
            anim_sprite.play("Idle")
        else:
            anim_sprite.play("Run")
    else:
        anim_sprite.play("Jump")
