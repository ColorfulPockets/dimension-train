extends Node

var fields = Global.CARD_FIELDS
var types = Global.CARD_TYPES

var DATA = {
	"Chop":
		{
			fields.Name: "Chop",
			fields.Type: types.Harvesting,
			fields.TopText: "Chop 2x2",
			fields.BottomText: "Gather 1x1",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(1,1),
			fields.TopFunction: "Chop",
			fields.BottomFunction: "Gather",
			fields.TopMousePointer: load("res://Assets/Icons/Chop_mouse.png"),
			fields.BottomMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
		},
	"Mine":
		{
			fields.Name: "Mine",
			fields.Type: types.Harvesting,
			fields.TopText: "Mine 2x2",
			fields.BottomText: "Gather 1x1",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(1,1),
			fields.TopFunction: "Mine",
			fields.BottomFunction: "Gather",
			fields.TopMousePointer: load("res://Assets/Icons/Mine_mouse.png"),
			fields.BottomMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
		},
	"Gather":
		{
			fields.Name: "Gather",
			fields.Type: types.Logistics,
			fields.TopText: "Gather 2x2",
			fields.BottomText: "Gather 2x2",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(2,2),
			fields.TopFunction: "Gather",
			fields.BottomFunction: "Gather",
			fields.TopMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.BottomMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
		},
	"Build":
		{
			fields.Name: "Build",
			fields.Type: types.Logistics,
			fields.TopText: "Build 2",
			fields.BottomText: "Gather 1x2",
			fields.BottomTargetArea: Vector2i(1,2),
			fields.TopFunction: "Build",
			fields.BottomFunction: "Gather",
			fields.TopMousePointer: load("res://Assets/Icons/Build_mouse.png"),
			fields.BottomMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.Arguments: [2],
		},
	"Manufacture":
		{
			fields.Name: "Manufacture",
			fields.Type: types.Logistics,
			fields.TopText: "Manufacture 2",
			fields.BottomText: "Gather 2x1",
			fields.BottomTargetArea: Vector2i(2,1),
			fields.TopFunction: "Manufacture",
			fields.BottomFunction: "Gather",
			fields.TopMousePointer: load("res://Assets/Icons/cursor.png"),
			fields.BottomMousePointer: load("res://Assets/Icons/Gather_mouse.png"),
			fields.Arguments: [2],
		},
}
