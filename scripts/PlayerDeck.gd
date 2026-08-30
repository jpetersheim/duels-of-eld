extends Node2D

const CARD_SCENE_PATH = "res://scenes/PlayerCard.tscn"

var player_gear_deck = [1,2,3,4,5,1,2,3,4,5]
var player_action_deck = [6,6,6,6,6,6,6,6,6]
var card_database_reference
var hand_card_limit = 6
var can_draw_card = true

var player_gear_discard = []
var player_action_discard = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)
	player_gear_deck.shuffle()
	$NumInDeck.text = str(player_gear_deck.size())
	card_database_reference = preload("res://scripts/CardDatabase.gd")
	
	for i in range(hand_card_limit):
		draw_card()


func draw_card():
	
	#Shuffle if deck runs out cards
	if player_gear_deck.size() == 0:
		shuffle_deck(player_gear_discard, player_gear_deck)
		#$Area2D/CollisionShape2D.disabled = true
		#$Sprite2D.visible = false
		#$NumInDeck.visible = false
		print("shuffled")
	
	var card_drawn_key = player_gear_deck[0]
	player_gear_deck.erase(card_drawn_key)
	
	$NumInDeck.text = str(player_gear_deck.size())
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	#var card_image_path = str("res://Assets/" + card_drawn_name + ".png")
	#new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.card_id = card_database_reference.CARDS.find_key(card_database_reference.CARDS[card_drawn_key])
	card_database_reference.CARDS.find_key(card_drawn_key)
	new_card.card_name = card_database_reference.CARDS[card_drawn_key][0]
	new_card.card_attack = card_database_reference.CARDS[card_drawn_key][1]
	new_card.card_block = card_database_reference.CARDS[card_drawn_key][2]
	new_card.card_type = card_database_reference.CARDS[card_drawn_key][3]
	new_card.get_node("CardDetails").get_node("Name").text = new_card.card_name
	new_card.get_node("CardDetails").get_node("Attack").text = str(new_card.card_attack)
	new_card.get_node("CardDetails").get_node("Block").text = str(new_card.card_block)
	new_card.get_node("CardDetails").get_node("Type").text = str(new_card.card_type)
	$"../CardInteractManager".add_child(new_card)
	new_card.name = "Card"
	new_card.scale = Vector2(Global.HAND_CARD_SCALE, Global.HAND_CARD_SCALE)
	new_card.position = Vector2(self.position.x,self.position.y)
	$"../PlayerHand".add_card_to_hand(new_card, Global.CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip_to_front")


func draw_at_end_turn():
	while $"../PlayerHand".player_hand.size() < hand_card_limit:
		draw_card()
		await Global.wait(0.5)


func shuffle_deck(discard_pile_array, deck_array):
	for card in discard_pile_array:
		$"../PlayerHand".animate_card_to_position(card, self.position, Global.CARD_DRAW_SPEED)
		card.get_node("AnimationPlayer").play_backwards("card_flip_to_front")
		deck_array.append(card.card_id)
		await Global.wait(0.1)
	deck_array.shuffle()
	await Global.wait(2.0)
