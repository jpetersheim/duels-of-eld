extends Node2D

@onready var action_log = $"../ActionLogBox/ActionLog"

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var screen_size
var card_being_dragged
var is_hovering_on_card

var player_hand_reference
var stats_manager_ref
var player_deck_ref

var player_cards_on_field = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	player_hand_reference = $"../PlayerHand"
	player_deck_ref = $"../PlayerDeck"
	stats_manager_ref = $"../StatsManager"
		
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),clamp(mouse_pos.y, 0, screen_size.y))


func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)


func finish_drag():
	card_being_dragged.scale = Vector2(Global.HAND_CARD_SCALE + 0.05, Global.HAND_CARD_SCALE + 0.05)
	var card_slot_found = raycast_check_for_card_slot()
	
	#Play card in normal card slots
	if card_slot_found and not card_slot_found.card_in_slot and card_slot_found.card_slot_type == "Slot":
		if card_being_dragged.card_type == card_slot_found.card_in_slot_type:
			card_being_dragged.scale = Vector2(Global.FIELD_CARD_SCALE, Global.FIELD_CARD_SCALE)
			card_being_dragged.z_index = -1
			card_being_dragged.card_slot_card_is_in = card_slot_found
			
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			player_cards_on_field.append(card_being_dragged)
			
			var log_msg = "[color=cyan]%s[/color] played [color=green]%s[/color] card [color=yellow]%s[/color]." % ["Player", card_being_dragged.card_type, card_being_dragged.card_name]
			action_log.add_log(log_msg)
			
			# card dropped in empty slot
			card_being_dragged.position = card_slot_found.position
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_slot_found.card_in_slot = true
			card_being_dragged = null
			
			stats_manager_ref.update_stats("Player", player_cards_on_field)
			
			return
	
	#Play card in Discard slot
	if card_slot_found and card_slot_found.card_slot_type == "Discard":
		if card_being_dragged.card_type == card_slot_found.card_in_slot_type:
			card_being_dragged.scale = Vector2(Global.FIELD_CARD_SCALE, Global.FIELD_CARD_SCALE)
			card_being_dragged.z_index = -1
			card_being_dragged.card_slot_card_is_in = card_slot_found
			
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			if card_being_dragged.card_type == "Gear":
				player_deck_ref.player_gear_discard.append(card_being_dragged)
			elif card_being_dragged.card_type == "Action":
				player_deck_ref.player_action_discard.append(card_being_dragged)
				
			var log_msg = "[color=cyan]%s[/color] discarded [color=green]%s[/color] card [color=yellow]%s[/color]." % ["Player", card_being_dragged.card_type, card_being_dragged.card_name]
			action_log.add_log(log_msg)
			
			# card dropped in empty slot
			card_being_dragged.position = card_slot_found.position
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_slot_found.card_in_slot = true
			card_being_dragged = null
			
			stats_manager_ref.update_stats("Player", player_cards_on_field)
			
			return
	
	player_hand_reference.add_card_to_hand(card_being_dragged, Global.CARD_MOVE_SPEED)
	card_being_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_left_click_released():
	if card_being_dragged:
		finish_drag()	


func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	#Check if the card is in a card slot and not being dragged
	if !card.card_slot_card_is_in && !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false


func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(Global.HAND_CARD_SCALE + 0.05, Global.HAND_CARD_SCALE + 0.05)
		card.z_index = 2
	else:
		card.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)
		card.z_index = 1


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card =  cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
				highest_z_card = current_card
				highest_z_index = current_card.z_index
	return highest_z_card
