var cdt = load("res://CardDataTypes.gd").new()
var fields = cdt.CARD_FIELDS
var types = cdt.CARD_TYPES

var DATA = {
	"Chop":
		{
			fields.Name: "Chop",
			fields.Type: types.Harvesting,
			fields.TopText: "Chop 2x2",
			fields.BottomText: "Transport 5",
			fields.TargetArea: Vector2i(2,2)
		},
	"Mine":
		{
			fields.Name: "Mine",
			fields.Type: types.Harvesting,
			fields.TopText: "Mine 2x2",
			fields.BottomText: "Transport 5",
			fields.TargetArea: Vector2i(3,3)
		},
	"Transport":
		{
			fields.Name: "Transport",
			fields.Type: types.Logistics,
			fields.TopText: "Transport 10",
			fields.BottomText: "Transport 10",
			fields.TargetArea: Vector2i(4,1)
		},
	"Build":
		{
			fields.Name: "Build",
			fields.Type: types.Logistics,
			fields.TopText: "Build 2",
			fields.BottomText: "Transport 5",
			fields.TargetArea: Vector2i(2,5)
		}
}
