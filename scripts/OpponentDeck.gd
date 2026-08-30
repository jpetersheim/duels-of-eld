extends Node2D

const CARD_SCENE_PATH = "res://scenes/OpponentCard.tscn"

var opponent_deck = ["Knight", "Archer", "Demon", "Knight", "Knight", "Knight", "Knight", "Knight", "Archer", "Archer", "Archer"]
var card_database_reference
var hand_card_limit = 6
var can_draw_card = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)
	opponent_deck.shuffle()
	$NumInDeck.text = str(opponent_deck.size())
	card_database_reference = preload("res://scripts/CardDatabase.gd")
	
	for i in range(hand_card_limit):
		draw_card()


func draw_card():
	#if $"../OpponentHand".opponent_hand.size() >= hand_card_limit:
		#can_draw_card = false
			#
	#if !can_draw_card:
		#return
	
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	#if player draws last card, dis
	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
		$NumInDeck.visible = false
	
	$NumInDeck.text = str(opponent_deck.size())
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	#var card_image_path = str("res://Assets/" + card_drawn_name + ".png")
	#new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	new_card.card_attack = card_database_reference.CARDS[card_drawn_name][0]
	new_card.get_node("CardDetails").get_node("Name").text = card_database_reference.CARDS.find_key(card_database_reference.CARDS[card_drawn_name])
	new_card.get_node("CardDetails").get_node("Attack").text = str(new_card.card_attack)
	new_card.get_node("CardDetails").get_node("Health").text = str(card_database_reference.CARDS[card_drawn_name][1])
	new_card.get_node("CardDetails").get_node("Type").text = str(new_card.card_type)
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	new_card.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)
	new_card.position = Vector2(self.position.x,self.position.y)
	$"../OpponentHand".add_card_to_hand(new_card, Global.CARD_DRAW_SPEED)
	#new_card.get_node("AnimationPlayer").play("card_flip")

func draw_at_end_turn():
	while $"../OpponentHand".opponent_hand.size() < hand_card_limit:
		draw_card()
