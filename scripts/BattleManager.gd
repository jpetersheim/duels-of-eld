extends Node

var action_log
var stats_manager_ref
var card_to_play
var turn_counter

var opponent_empty_gear_slots = []
var opponent_empty_action_slots = []
var opponent_hand_card_types = []
var opponent_cards_on_field = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_log = $"../ActionLogBox/ActionLog"
	stats_manager_ref = $"../StatsManager"
	
	turn_counter = 1
	$"../TurnCounter".text = "Turn " + str(turn_counter) + ": Player"
	var log_msg = "[color=black]Turn %s:[/color] [color=cyan]%s[/color][color=black].[/color]" % [turn_counter, "Player"]
	action_log.add_log(log_msg)
	
	if turn_counter == 1:
		stats_manager_ref.player_attacks_this_turn = 0
		$"../AttackButton".visible = false
		$"../AttackButton".disabled = true
	else:
		stats_manager_ref.player_attacks_this_turn = stats_manager_ref.opponent_default_attacks
	
	opponent_empty_gear_slots.append($"../OpponentSlotsGear/OpponentSlotGear1")
	opponent_empty_gear_slots.append($"../OpponentSlotsGear/OpponentSlotGear2")
	opponent_empty_gear_slots.append($"../OpponentSlotsGear/OpponentSlotGear3")
	opponent_empty_gear_slots.append($"../OpponentSlotsGear/OpponentSlotGear4")
	
	opponent_empty_action_slots.append($"../OpponentSlotsActions/OpponentSlotAction1")
	opponent_empty_action_slots.append($"../OpponentSlotsActions/OpponentSlotAction2")
	opponent_empty_action_slots.append($"../OpponentSlotsActions/OpponentSlotAction3")
	opponent_empty_action_slots.append($"../OpponentSlotsActions/OpponentSlotAction4")
	

func _on_end_turn_button_pressed() -> void:
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	$"../AttackButton".visible = false
	$"../AttackButton".disabled = true
	
	turn_counter += 1
	$"../PlayerDeck".draw_at_end_turn()
	
	$"../TurnCounter".text = "Turn " + str(turn_counter) + ": Opponent"
	var log_msg = "[color=black]Turn %s:[/color] [color=red]%s[/color][color=black].[/color]" % [turn_counter, "Opponent"]
	action_log.add_log(log_msg)
	
	stats_manager_ref.player_attacks_this_turn = stats_manager_ref.player_default_attacks
	
	opponent_turn()


func _on_attack_button_pressed() -> void:
	direct_attack("Player", stats_manager_ref.player_attack, stats_manager_ref.opponent_block)


func opponent_turn():
	var opponent_hand = $"../OpponentHand".opponent_hand
	for card in opponent_hand:
		opponent_hand_card_types.append(card.card_type)
	
	#Wait 1s before making any moves
	await Global.wait(1.0)
	
	#Opponents Turn
	if $"../OpponentDeck".opponent_gear_deck.size() != 0:
		#Wait 1s before making any moves
		await Global.wait(1.0)
	
	# Check if free action slots, if no end turn
	if (opponent_empty_action_slots.size() != 0 or "Action" in opponent_hand_card_types) and (opponent_empty_gear_slots.size() != 0 or "Gear" in opponent_hand_card_types):
		play_card_with_highest_attack()
	
	#update stats
	stats_manager_ref.update_stats("Opponent", opponent_cards_on_field)
	
	await Global.wait(1.0)
	
	#opponent attacks
	if turn_counter == 1:
		stats_manager_ref.opponent_attacks_this_turn = 0
	else:
		stats_manager_ref.opponent_attacks_this_turn = stats_manager_ref.opponent_default_attacks
	
	while stats_manager_ref.opponent_attacks_this_turn > 0:
		direct_attack("Opponent", stats_manager_ref.opponent_attack, stats_manager_ref.player_block)
		
	end_opponent_turn()

func play_card_with_highest_attack():
	var opponent_hand = $"../OpponentHand".opponent_hand
	# Play the card in hand with highest attack
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
			
	if opponent_empty_gear_slots.size() != 0:
		var random_empty_gear_card_slot = opponent_empty_gear_slots[randi_range(0,opponent_empty_gear_slots.size()-1)]
		opponent_empty_gear_slots.erase(random_empty_gear_card_slot)
	
		card_to_play = opponent_hand[0]
		for card in opponent_hand:
			if card.card_attack > card_to_play.card_attack:
				card_to_play = card

		#Animate cards position and scale
		var tween = get_tree().create_tween()
		tween.tween_property(card_to_play, "position", random_empty_gear_card_slot.position, Global.CARD_MOVE_SPEED)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(card_to_play, "scale", Vector2(Global.FIELD_CARD_SCALE,Global.FIELD_CARD_SCALE), Global.CARD_MOVE_SPEED)
		card_to_play.get_node("AnimationPlayer").play("card_flip")
		
		$"../OpponentHand".remove_card_from_hand(card_to_play)
		opponent_cards_on_field.append(card_to_play)
	
	#Wait 1s before making any moves
	await Global.wait(1)


func direct_attack(attacker, attacker_dmg, defender_block):
	if attacker == "Player":
		stats_manager_ref.player_attacks_this_turn -= 1
		if stats_manager_ref.player_attacks_this_turn == 0:
			$"../AttackButton".visible = false
			$"../AttackButton".disabled = true
			
		var log_msg = "[color=cyan]%s[/color] attacked for [color=orange]%s[/color] damage. [color=red]%s[/color] blocked for [color=gray]%s[/color] damage." % ["Player", attacker_dmg, "Opponent", defender_block]
		action_log.add_log(log_msg)
	
	if attacker == "Opponent":
		stats_manager_ref.opponent_attacks_this_turn -= 1
		
		var log_msg = "[color=red]%s[/color] attacked for [color=orange]%s[/color] damage. [color=cyan]%s[/color] blocked for [color=gray]%s[/color] damage." % ["Opponent", attacker_dmg, "Player", defender_block]
		action_log.add_log(log_msg)
	
	stats_manager_ref.update_health(attacker, attacker_dmg, defender_block)


func end_opponent_turn():
	$"../OpponentDeck".draw_at_end_turn()
	stats_manager_ref.opponent_attacks_this_turn = stats_manager_ref.opponent_default_attacks
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
	turn_counter += 1
	$"../TurnCounter".text = "Turn " + str(turn_counter) + ": Player"
	var log_msg = "[color=black]Turn %s:[/color] [color=cyan]%s[/color][color=black].[/color]" % [turn_counter, "Player"]
	action_log.add_log(log_msg)
	
	player_turn()


func player_turn():
		if stats_manager_ref.player_attacks_this_turn > 0:
			$"../AttackButton".visible = true
			$"../AttackButton".disabled = false
