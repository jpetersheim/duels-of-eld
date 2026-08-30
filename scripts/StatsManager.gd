extends Node

const STARTING_HEALTH = 30

var player_default_attacks = 1
var player_attacks_this_turn = 1
var opponent_default_attacks = 1
var opponent_attacks_this_turn = 1

var player_health
var opponent_health

var player_attack = 0
var opponent_attack = 0

func _ready() -> void:
	player_health = STARTING_HEALTH
	opponent_health = STARTING_HEALTH
	update_health("Start",0)

func update_health(attacker, attacker_dmg):
	if attacker == "Opponent":
		player_health -= attacker_dmg
	elif attacker == "Player":
		opponent_health -= attacker_dmg
	
	if opponent_health < 0:
		opponent_health = 0
	
	if player_health < 0:
		player_health = 0
	
	$"../OpponentStats/Health".text = str(opponent_health) + "/" + str(STARTING_HEALTH)
	$"../PlayerStats/Health".text = str(player_health) + "/" + str(STARTING_HEALTH)
	
func update_stats(entity, cards_on_field_array):
	#attack
	if entity == "Opponent":
		opponent_attack = 0
		for card in cards_on_field_array:
			opponent_attack += card.card_attack
	elif entity == "Player":
		player_attack = 0
		for card in cards_on_field_array:
			player_attack += card.card_attack
	
	$"../OpponentStats/Attack".text = str(opponent_attack)
	$"../PlayerStats/Attack".text = str(player_attack)
	
