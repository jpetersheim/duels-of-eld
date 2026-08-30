extends Node2D

var card_slot_type = "Opponent"
var card_in_slot_type = "Opponent"

func _ready() -> void:
	self.scale = Vector2(Global.FIELD_CARD_SCALE, Global.FIELD_CARD_SCALE)
