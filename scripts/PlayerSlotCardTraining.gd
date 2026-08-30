extends Node2D

var card_in_slot = false
var card_slot_type = "Discard"
var card_in_slot_type = "Gear"

func _ready() -> void:
	self.scale = Vector2(Global.FIELD_CARD_SCALE, Global.FIELD_CARD_SCALE)
