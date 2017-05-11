local PokerServerDef = {}

PokerServerDef.TYPE = {
	DIAMONDS = 1, --方块
	CLUBS = 2, --梅花
	HEARTS = 3, --红桃
	SPADES = 4, --黑桃
	JOKERS = 5, --王牌
}
--牌值（普通牌）
PokerServerDef.VALUE = {
	R_3 = 1,
	R_4 = 2,
	R_5 = 3,
	R_6 = 4,
	R_7 = 5,
	R_8 = 6,
	R_9 = 7,
	R_10 = 8,
	R_J = 9,
	R_Q = 10,
	R_K = 11,
	R_A = 12,
	R_2 = 13,
}
--牌值（大小王）
PokerServerDef.JOKER = {
	SMALL_JOKER = 1, --小王
	BIG_JOKER = 2 --大王
}

return PokerServerDef