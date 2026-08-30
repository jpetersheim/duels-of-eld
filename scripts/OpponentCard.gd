extends Node2D

var hand_position
var card_id
var card_type
var card_attack
var card_name
var card_block

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be child of CardManager or this will error
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
