extends Node

const HAND_CARD_SCALE = 0.5
const FIELD_CARD_SCALE = 0.35
const CARD_DRAW_SPEED = 1
const CARD_MOVE_SPEED = 0.1

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
