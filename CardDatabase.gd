extends Node

var fields = Global.CARD_FIELDS
var types = Global.CARD_TYPES

var DATA = {
	"Chop":
		{
			fields.Name: "Chop",
			fields.Type: types.Harvesting,
			fields.TopText: "Chop 2x2",
			fields.BottomText: "Transport 1x1",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(1,1),
			fields.TopFunction: "Chop",
			fields.BottomFunction: "Transport",
		},
	"Mine":
		{
			fields.Name: "Mine",
			fields.Type: types.Harvesting,
			fields.TopText: "Mine 2x2",
			fields.BottomText: "Transport 1x1",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(1,1),
			fields.TopFunction: "Mine",
			fields.BottomFunction: "Transport",
		},
	"Transport":
		{
			fields.Name: "Transport",
			fields.Type: types.Logistics,
			fields.TopText: "Transport 2x2",
			fields.BottomText: "Transport 2x2",
			fields.TopTargetArea: Vector2i(2,2),
			fields.BottomTargetArea: Vector2i(2,2),
			fields.TopFunction: "Transport",
			fields.BottomFunction: "Transport",
		},
	"Build":
		{
			fields.Name: "Build",
			fields.Type: types.Logistics,
			fields.TopText: "Build 2",
			fields.BottomText: "Transport 1x2",
			fields.TopTargetArea: Vector2i(1,1),
			fields.BottomTargetArea: Vector2i(1,2),
			fields.TopFunction: "Build",
			fields.BottomFunction: "Transport",
			
		}
}
