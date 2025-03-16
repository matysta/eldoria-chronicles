extends Node

var current_score = 0;

func _ready():
    Hud.set_score(current_score);
    Hud.set_max_score(get_max_score());

func add_score_point():
    current_score += 1;
    print("Current score: " + str(current_score));
    Hud.set_score(current_score)

func on_level_restart():
    current_score = 0
    print("Level restarted. Score reset to: " + str(current_score))
    Hud.set_score(current_score)

func get_max_score() -> int:
    var root = get_tree().root
    return count_coins(root)

func count_coins(node) -> int:
    var coin_count = 0
    if node is Coin:
        coin_count += 1
    for child in node.get_children():
        coin_count += count_coins(child) # Accumulate count from children
    return coin_count
