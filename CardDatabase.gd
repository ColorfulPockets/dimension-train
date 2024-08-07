extends Node

var fields = Global.CARD_FIELDS

var DATA = {
	"Chop":
		{
			fields.Name: "Chop",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Chop TARGETAREA",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Chop",
			fields.MousePointer: load("res://Assets/Icons/Chop_mouse.png"),
		},
	"Mine":
		{
			fields.Name: "Mine",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Mine TARGETAREA",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Mine_mouse.png"),
		},
	"Gather":
		{
			fields.Name: "Gather",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gather TARGETAREA",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Gather",
			fields.MousePointer: load("res://Assets/Icons/Gather_mouse.png"),
		},
	"Build":
		{
			fields.Name: "Build",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Build ARGBuild",
			fields.Function: "Build",
			fields.MousePointer: load("res://Assets/Icons/Build_mouse.png"),
			fields.Arguments: {"Build": 100 if Global.devmode else 4},
		},
	"Manufacture":
		{
			fields.Name: "Manufacture",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Manufacture ARGManufacture",
			fields.Function: "Manufacture",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Manufacture": 4}
		},
	"Factory":
		{
			fields.Name: "Factory",
			fields.Rarity: "Starter",
			fields.EnergyCost: 2,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gather TARGETAREA, then Manufacture ARGManufacture",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Factory",
			fields.MousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.Arguments: {"Manufacture": 6}
		},
	"Drill":
		{
			fields.Name: "Drill",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Mine TARGETAREA",
			fields.TargetArea: Vector2i(3,2),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Mine_mouse.png"),
		},
	"Gust":
		{
			fields.Name: "Gust",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Chop TARGETAREA, then draw ARGDraw card.",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Gust",
			fields.MousePointer: load("res://Assets/Icons/Chop_mouse.png"),
			fields.Arguments: {"Draw": 1}
		},
	"Bridge":
		{
			fields.Name: "Bridge",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Bridge TARGETAREA",
			fields.TargetArea: Vector2i(1,1),
			fields.Function: "Bridge",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
		},
	"Bolster":
		{
			fields.Name: "Bolster",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Increase the target area on another card in your hand by +1/+1 for this level.",
			fields.Function: "Bolster",
			fields.MousePointer: load("res://Assets/Icons/Bolster_cursor.png"),
		},
	"Freeze":
		{
			fields.Name: "Freeze",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Bridge TARGETAREA",
			fields.TargetArea: Vector2i(5,5),
			fields.Function: "Bridge",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
		},
	"Dynamite":
		{
			fields.Name: "Dynamite",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Mine TARGETAREA",
			fields.TargetArea: Vector2i(4,4),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
		},
	"Levitate":
		{
			fields.Name: "Levitate",
			fields.Rarity: "Rare",
			fields.EnergyCost: 2,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Build ARGBuild, even over Trees and Boulders. (Can't build over resources; clears underneath rail)",
			fields.Function: "Build",
			fields.MousePointer: load("res://Assets/Icons/Bolster_cursor.png"),
			fields.Arguments: {"Build": 6, "BuildOver": Global.trees + Global.rocks}
		},
	"AutoBuild":
		{
			fields.Name: "AutoBuild",
			fields.Rarity: "Rare",
			fields.EnergyCost: 3,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Whenever you reach the end of the track with speed remaining, place a rail in a straight line.",
			fields.Function: "AutoBuild",
			fields.MousePointer: load("res://Assets/Icons/Reveal_mouse.png"),
		},
	"Magnet":
		{
			fields.Name: "Magnet",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Increases pickup range by 1",
			fields.Function: "Magnet",
			fields.MousePointer: load("res://Assets/Icons/Reveal_mouse.png"),
		},
	"Brake":
		{
			fields.Name: "Brake",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Reduce speed this turn by ARGBrake",
			fields.Function: "Brake",
			fields.MousePointer: load("res://Assets/Icons/Reveal_mouse.png"),
			fields.Arguments: {"Brake": 3}
		},
	"Recycle":
		{
			fields.Name: "Recycle",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Each time you destroy an enemy, +2 ER",
			fields.Function: "Recycle",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"Swarm":
		{
			fields.Name: "Swarm",
			fields.Rarity: "Rare",
			fields.EnergyCost: 3,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Whenever you Chop or Mine, Clear all squares around the highlighted area.",
			fields.Function: "Swarm",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"Blast":
		{
			fields.Name: "Blast",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Chop and Mine TARGETAREA.",
			fields.Function: "Blast",
			fields.TargetArea: Vector2i(2,2),
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"AutoManufacture":
		{
			fields.Name: "AutoManufacture",
			fields.Rarity: "Rare",
			fields.EnergyCost: 3,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Each time you play a card, Manufacture 2.",
			fields.Function: "AutoManufacture",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"Turbo":
		{
			fields.Name: "Turbo",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Remove all rails, then gain energy equal to the number of rails removed.",
			fields.Function: "Turbo",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"Skim":
		{
			fields.Name: "Skim",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Draw ARGDraw cards.",
			fields.Function: "Draw",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Draw": 3}
		},
	"Transmute":
		{
			fields.Name: "Transmute",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Select two TARGETAREA areas and swap all non-rail cells",
			fields.Function: "Transmute",
			fields.TargetArea: Vector2i(2,2),
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
		# TODO cards that rearrange stuff on the board
}
