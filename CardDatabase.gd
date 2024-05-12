extends Node

var fields = Global.CARD_FIELDS
var types = Global.CARD_TYPES

var DATA = {
	"Chop":
		{
			fields.Name: "Chop",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: types.Harvesting,
			fields.Text: "Chop 2x2",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Chop",
			fields.MousePointer: load("res://Assets/Icons/Chop_mouse.png"),
		},
	"Mine":
		{
			fields.Name: "Mine",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: types.Harvesting,
			fields.Text: "Mine 2x2",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Mine_mouse.png"),
		},
	"Gather":
		{
			fields.Name: "Gather",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: types.Logistics,
			fields.Text: "Gather 2x2",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "Gather",
			fields.MousePointer: load("res://Assets/Icons/Gather_mouse.png"),
		},
	"Build":
		{
			fields.Name: "Build",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: types.Logistics,
			fields.Text: "Build 4",
			fields.Function: "Build",
			fields.MousePointer: load("res://Assets/Icons/Build_mouse.png"),
			fields.Arguments: {"Build": 4},
		},
	"Manufacture":
		{
			fields.Name: "Manufacture",
			fields.Rarity: "Starter",
			fields.EnergyCost: 1,
			fields.Type: types.Logistics,
			fields.Text: "Manufacture 4",
			fields.Function: "Manufacture",
			fields.MousePointer: load("res://Assets/Icons/cursor.png"),
			fields.Arguments: {"Manufacture": 4}
		},
	"Factory":
		{
			fields.Name: "Factory",
			fields.Rarity: "Starter",
			fields.EnergyCost: 2,
			fields.Type: types.Logistics,
			fields.Text: "Gather 2x2, then Manufacture 6",
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
			fields.Type: types.Harvesting,
			fields.Text: "Mine 3x2",
			fields.TargetArea: Vector2i(3,2),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Mine_mouse.png"),
		},
	"Gust":
		{
			fields.Name: "Gust",
			fields.Rarity: "Common",
			fields.EnergyCost: 1,
			fields.Type: types.Harvesting,
			fields.Text: "Chop 2x2, then draw a card.",
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
			fields.Type: types.Logistics,
			fields.Text: "Bridge 1",
			fields.TargetArea: Vector2i(1,1),
			fields.Function: "Bridge",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
			fields.Arguments: {"Bridge": 1}
		},
	"Bolster":
		{
			fields.Name: "Bolster",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: types.Logistics,
			fields.Text: "Increase all numbers on another card in your hand by 1 for this level.",
			fields.TargetArea: Vector2i(2,2),
			fields.Function: "NumbersUp",
			fields.MousePointer: load("res://Assets/Icons/Bolster_cursor.png"),
		},
	"Freeze":
		{
			fields.Name: "Freeze",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: types.Logistics,
			fields.Text: "Bridge 5x5",
			fields.TargetArea: Vector2i(5,5),
			fields.Function: "Bridge",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
		},
	"Dynamite":
		{
			fields.Name: "Dynamite",
			fields.Rarity: "Uncommon",
			fields.EnergyCost: 1,
			fields.Type: types.Harvesting,
			fields.Text: "Mine 4x4",
			fields.TargetArea: Vector2i(4,4),
			fields.Function: "Mine",
			fields.MousePointer: load("res://Assets/Icons/Bridge_mouse.png"),
		},
	"Levitate":
		{
			fields.Name: "Levitate",
			fields.Rarity: "Rare",
			fields.EnergyCost: 2,
			fields.Type: types.Logistics,
			fields.Text: "Build 6, even over Trees and Boulders.",
			fields.Function: "Build",
			fields.MousePointer: load("res://Assets/Icons/Bolster_cursor.png"),
			fields.Arguments: {"Manufacture": 4, "ManufactureCost": 1, "Build": 6, "BuildOver": [Global.tree, Global.rock]}
		},
	"Headlight":
		{
			fields.Name: "Headlight",
			fields.Rarity: "Rare",
			fields.EnergyCost: 1,
			fields.Type: types.Technology,
			fields.Text: "Reveal all.",
			fields.Function: "Reveal",
			fields.MousePointer: load("res://Assets/Icons/Reveal_mouse.png"),
			fields.Arguments: {"Reveal": "All"}
		},
	"AutoBuild":
		{
			fields.Name: "AutoBuild",
			fields.Rarity: "Rare",
			fields.EnergyCost: 3,
			fields.Type: types.Technology,
			fields.Text: "Whenever you reach the end of the track with speed remaining, place a rail in a straight line.",
			fields.Function: "AutoBuild",
			fields.MousePointer: load("res://Assets/Icons/Reveal_mouse.png"),
		},
}
