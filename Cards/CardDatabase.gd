extends Node

var fields = Global.CARD_FIELDS

func typeToString(type:Global.CARD_TYPES):
	match type:
		Global.CARD_TYPES.Harvesting:
			return "Harvesting"
		Global.CARD_TYPES.Logistics:
			return "Logistics"
		Global.CARD_TYPES.Technology:
			return "Technology"
		Global.CARD_TYPES.Weapons:
			return "Weapons"

var DATA = {
	"Harvest":
		{
			fields.Name: "Harvest",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Harvest TARGETAREA",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Harvest",
			fields.MousePointer: load("res://Assets/Icons/Chop_mouse.png"),
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
	"Blast":
		{
			fields.Name: "Blast",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Weapons,
			fields.Text: "Blast TARGETAREA orthogonal to any train car for ARGBlast damage.",
			fields.TargetArea: Vector2i(3,3),
			fields.Function: "Blast",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Blast": 1},
		},
	"Factory":
		{
			fields.Name: "Factory",
			fields.Rarity: "Common",
			fields.EnergyCost: 2,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gather TARGETAREA, then Build ARGBuild",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Factory",
			fields.MousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.Arguments: {"Build": 3}
		},
	"Drill":
		{
			fields.Name: "Drill",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Harvest TARGETAREA",
			fields.TargetArea: Vector2i(3,2),
			fields.Function: "Harvest",
			fields.MousePointer: load("res://Assets/Icons/Chop_mouse.png"),
		},
	"Gust":
		{
			fields.Name: "Gust",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: Global.CARD_TYPES.Harvesting,
			fields.Text: "Harvest TARGETAREA, then draw ARGDraw card.",
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
			fields.Text: "Harvest TARGETAREA",
			fields.TargetArea: Vector2i(4,4),
			fields.Function: "Harvest",
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
			fields.Text: "Whenever you Harvest, Clear all squares around the highlighted area.",
			fields.Function: "Swarm",
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
			fields.Text: "Remove all wood and stone, then gain energy equal to the number of wood and stone removed.",
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
	"Assemble":
		{
			fields.Name: "Assemble",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 0,
			fields.Exhaust: true,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Manufacture ARGManufacture.\nExhaust",
			fields.Function: "Manufacture",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Manufacture": 6},
		},
	"Reforest":
		{
			fields.Name: "Reforest",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 0,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Replace all empty spaces in a TARGETAREA area with trees. Draw ARGDraw.",
			fields.Function: "Reforest",
			fields.TargetArea: Vector2i(2,3),
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Draw": 1},
		},
	"Scoop":
		{
			fields.Name: "Scoop",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 0,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gather TARGETAREA. Draw ARGDraw.",
			fields.Function: "Scoop",
			fields.TargetArea: Vector2i(2,1),
			fields.MousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.Arguments: {"Draw": 1},
		},
	"Energize":
		{
			fields.Name: "Energize",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Exhaust: true,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gain ARGEnergy energy.\nExhaust.",
			fields.Function: "Energize",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Energy": 2},
		},
	"Vacuum":
		{
			fields.Name: "Vacuum",
			fields.Rarity: "Rare",
			fields.EnergyCost: 2,
			fields.Exhaust: true,
			fields.Type: Global.CARD_TYPES.Logistics,
			fields.Text: "Gather ALL resources on the map.\nExhaust.",
			fields.Function: "Vacuum",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
	"Collateral Damage":
		{
			fields.Name: "Collateral Damage",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 2,
			fields.Type: Global.CARD_TYPES.Technology,
			fields.Text: "Whenever you Harvest, also deal 1 damage to all enemies within the harvested area.",
			fields.Function: "Collateral",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
		},
}
