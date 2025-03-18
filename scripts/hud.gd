extends Node

var score: int = -2;
var max_score: int = -1;

func set_score(new_score: int):
    score = new_score;
    repaint()

func set_max_score(new_max_score: int):
    max_score = new_max_score;
    repaint()

func repaint():
    var score_label = $Canvas/Container/ScoreLabel;
    var color = Color(0, 1, 0) if max_score <= score else Color(1, 0, 0);
    score_label.add_theme_color_override("font_color", color);
    score_label.text = str(score) + "/" + str(max_score);
