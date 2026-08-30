extends Control

@onready var card_front: Control = $CardFront
@onready var card_back: Control = $CardBack

var is_showing_front: bool = true
var is_flipping: bool = false

func _ready() -> void:
	# Recalculate pivot whenever the Control node resizes
	resized.connect(_on_resized)
	_update_pivot()
	
	# Initial visibility setup
	card_front.visible = is_showing_front
	card_back.visible = !is_showing_front
	
	print("ready to flip card")
	print("front showing: " && is_showing_front)
	print("is flipping: " && is_flipping)

func _on_resized() -> void:
	_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size / 2.0

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("clicked to flip, check is_flipping")
		if not is_flipping:
			print("trying to flip")
			flip_card()

func flip_card(duration: float = 0.5) -> void:
	is_flipping = true
	var tween = create_tween()
	
	# Phase 1: Compress Y-scale down to 0.0 (edge-on view)
	tween.tween_property(self, "scale:y", 0.0, duration / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
	# Midpoint: Swap node visibilities right when scale is 0
	tween.tween_callback(self._swap_active_node)
	
	# Phase 2: Expand Y-scale back to 1.0
	tween.tween_property(self, "scale:y", 1.0, duration / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Unlock flipping flag when finished
	tween.tween_callback(func(): is_flipping = false)

func _swap_active_node() -> void:
	is_showing_front = !is_showing_front
	
	# Toggle visibility between the two nodes
	card_front.visible = is_showing_front
	card_back.visible = !is_showing_front
