extends Node2D

var card_in_slot = false
var card_slot_type = "Slot"
var card_in_slot_type = "Action"

func _ready() -> void:
	self.scale = Vector2(Global.FIELD_CARD_SCALE, Global.FIELD_CARD_SCALE)
