extends Node

var score: int = -1;
var max_score: int = -1;

func set_score(new_score: int):
    score = new_score;
    repaint()

func set_max_score(new_max_score: int):
    max_score = new_max_score;
    repaint()

func repaint():
    $Canvas/ScoreLabel.text = "Score: " + str(score) + "/" + str(max_score);
