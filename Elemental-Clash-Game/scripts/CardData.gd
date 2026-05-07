class_name CardData
extends Resource

enum Element { FIRE, WATER, EARTH, LIGHTNING, SPECIAL }
enum SpecialType { NONE, MIRROR, SHIELD, STORM }

@export var card_name: String = ""
@export var element: Element = Element.FIRE
@export var attack: int = 0
@export var special_type: SpecialType = SpecialType.NONE
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var emoji: String = ""

static func create(p_name: String, p_element: Element, p_attack: int,
		p_special: SpecialType = SpecialType.NONE, p_desc: String = "") -> CardData:
	var d = CardData.new()
	d.card_name    = p_name
	d.element      = p_element
	d.attack       = p_attack
	d.special_type = p_special
	d.description  = p_desc
	match p_element:
		Element.FIRE:      d.color = Color("E8593C"); d.emoji = "FUEGO"
		Element.WATER:     d.color = Color("378ADD"); d.emoji = "AGUA"
		Element.EARTH:     d.color = Color("639922"); d.emoji = "TIERRA"
		Element.LIGHTNING: d.color = Color("BA7517"); d.emoji = "RAYO"
		Element.SPECIAL:   d.color = Color("7F77DD"); d.emoji = "ESPECIAL"
	return d

func element_name() -> String:
	return Element.keys()[element].capitalize()

func is_special() -> bool:
	return special_type != SpecialType.NONE

func to_dict() -> Dictionary:
	return {
		"name": card_name,
		"element": element_name(),
		"attack": attack,
		"special": SpecialType.keys()[special_type]
	}
