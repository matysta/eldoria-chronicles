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
    var elapsed_time = float(Time.get_ticks_msec() - start_time)
    var timer_label = $Canvas/TimerContainer/TimerLabel
    if timer_label:
        if elapsed_time >= 60000:
            var minutes = int(elapsed_time / 60000)
            var seconds = int(float(int(elapsed_time) % 60000) / 1000.0)
            timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
        else:
            var seconds = int(elapsed_time / 1000)
            var milliseconds = int(float(int(elapsed_time) % 1000) / 10.0)
            timer_label.text = str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(2)
    else:
        print("Error: Timer label not found!")
