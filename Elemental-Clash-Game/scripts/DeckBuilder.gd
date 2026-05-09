class_name DeckBuilder
extends RefCounted

static func build_deck() -> Array[CardData]:
	var deck: Array[CardData] = []
	# Fire (5)
	deck.append(CardData.create("Llamarada",  CardData.Element.FIRE, 6, CardData.SpecialType.NONE, "Ataque de fuego basico"))
	deck.append(CardData.create("Inferno",    CardData.Element.FIRE, 7, CardData.SpecialType.NONE, "Fuego intenso"))
	deck.append(CardData.create("Volcan",     CardData.Element.FIRE, 8, CardData.SpecialType.NONE, "Erupcion poderosa"))
	deck.append(CardData.create("Brasas",     CardData.Element.FIRE, 5, CardData.SpecialType.NONE, "Fuego lento pero constante"))
	deck.append(CardData.create("Fenix",      CardData.Element.FIRE, 9, CardData.SpecialType.NONE, "Ave inmortal de fuego"))
	# Water (5)
	deck.append(CardData.create("Ola",        CardData.Element.WATER, 6, CardData.SpecialType.NONE, "Ola poderosa"))
	deck.append(CardData.create("Tsunami",    CardData.Element.WATER, 8, CardData.SpecialType.NONE, "Ola gigante e imparable"))
	deck.append(CardData.create("Corriente",  CardData.Element.WATER, 5, CardData.SpecialType.NONE, "Flujo constante"))
	deck.append(CardData.create("Maelstrom",  CardData.Element.WATER, 7, CardData.SpecialType.NONE, "Remolino devastador"))
	deck.append(CardData.create("Hielo",      CardData.Element.WATER, 6, CardData.SpecialType.NONE, "Congela al rival"))
	# Earth (4)
	deck.append(CardData.create("Roca",       CardData.Element.EARTH, 7, CardData.SpecialType.NONE, "Defensa solida"))
	deck.append(CardData.create("Terremoto",  CardData.Element.EARTH, 9, CardData.SpecialType.NONE, "Sacude el suelo"))
	deck.append(CardData.create("Enredadera", CardData.Element.EARTH, 6, CardData.SpecialType.NONE, "Atrapa al rival"))
	deck.append(CardData.create("Golem",      CardData.Element.EARTH, 8, CardData.SpecialType.NONE, "Criatura de piedra"))
	# Lightning (3)
	deck.append(CardData.create("Chispa",     CardData.Element.LIGHTNING, 7, CardData.SpecialType.NONE, "Descarga electrica"))
	deck.append(CardData.create("Rayo",       CardData.Element.LIGHTNING, 9, CardData.SpecialType.NONE, "Golpe fulminante"))
	deck.append(CardData.create("Tormenta",   CardData.Element.LIGHTNING, 8, CardData.SpecialType.NONE, "Tempestad electrica"))
	# Special (3)
	deck.append(CardData.create("Espejo",     CardData.Element.SPECIAL, 0, CardData.SpecialType.MIRROR, "Copia el elemento rival"))
	deck.append(CardData.create("Escudo",     CardData.Element.SPECIAL, 0, CardData.SpecialType.SHIELD, "Bloquea todo el danio"))
	deck.append(CardData.create("Caos",       CardData.Element.SPECIAL, 10, CardData.SpecialType.STORM,  "Inflige 10 de danio fijo"))
	deck.shuffle()
	return deck
