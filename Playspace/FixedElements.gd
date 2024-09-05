extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	#mouse_filter = Control.MOUSE_FILTER_PASS
	#size = Global.VIEWPORT_SIZE
	
	$DiscardPile.scale *= 0.45
	$DiscardPile.position = Global.DISCARD_PILE_POSITION
	$DiscardPileParticles.position = Global.DISCARD_PILE_POSITION + $DiscardPile.size*$DiscardPile.scale / 2 + Vector2(0.0, $DiscardPile.size.y * $DiscardPile.scale.y / 3)
	
	$DrawPile.scale *= 0.45
	$DrawPile.position = Global.DRAW_PILE_POSITION
	$DrawPileParticles.position = Global.DRAW_PILE_POSITION + $DrawPile.size*$DrawPile.scale / 2 + Vector2(0.0, $DrawPile.size.y * $DrawPile.scale.y / 3)


