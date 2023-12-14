extends Node

enum DIFFICULTY {EASY, HARD, ELITE, BOSS}

var STAGES = {
	"Plains": {
		DIFFICULTY.EASY:
			[
				"CORRIDOR"
			],
		DIFFICULTY.HARD:
			[],
		DIFFICULTY.ELITE:
			[],
		DIFFICULTY.BOSS:
			[],
		}
}

enum MAP_INFO {LAYOUT, TILES}

var MAPS = {
	"CORRIDOR": {
		MAP_INFO.LAYOUT: Vector2i(1,3),
		MAP_INFO.TILES:
	}
}

var TILES = {
	
}
