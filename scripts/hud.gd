extends Node

var score: int = -2;
var max_score: int = -1;
var start_time: int = 0;


# ─── Events ───────────────────────────────────────────────────────────────────

func _process(_delta):
    _update_timer()
    _repaint()


# ─── Public ───────────────────────────────────────────────────────────────────

func set_score(new_score: int):
    score = new_score;

func set_max_score(new_max_score: int):
    max_score = new_max_score;

func reset_timer():
    start_time = Time.get_ticks_msec()


# ─── Private ──────────────────────────────────────────────────────────────────

func _repaint():
    var score_label = $Canvas/ScoreContainer/ScoreLabel;
    var color = Color(0, 1, 0) if max_score <= score else Color(1, 0, 0);
    score_label.add_theme_color_override("font_color", color);
    score_label.text = str(score) + "/" + str(max_score);

func _update_timer():
    var elapsed_time = Time.get_ticks_msec() - start_time
    var timer_label = $Canvas/TimerContainer/TimerLabel
    if not timer_label:
        print("Error: Timer label not found!")
        return

    var minutes = int(elapsed_time / 60000.0)
    var seconds = int(elapsed_time / 1000.0) % 60
    var milliseconds = int((elapsed_time % 1000) / 10.0)

    if minutes > 0:
        timer_label.text = "%02d:%02d" % [minutes, seconds]
    else:
        timer_label.text = "%02d:%02d" % [seconds, milliseconds]
