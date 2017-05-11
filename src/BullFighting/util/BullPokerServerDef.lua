local BullPokerServerDef = {}

BullPokerServerDef.TYPE = {
	DIAMONDS = 4, --方块
	CLUBS = 3, --梅花
	HEARTS = 2, --红桃
	SPADES = 1, --黑桃
	JOKERS = 5, --王牌
}
--牌值（普通牌）
BullPokerServerDef.VALUE = {
	R_3 = 3,
	R_4 = 4,
	R_5 = 5,
	R_6 = 6,
	R_7 = 7,
	R_8 = 8,
	R_9 = 9,
	R_10 = 10,
	R_J = 11,
	R_Q = 12,
	R_K = 13,
	R_A = 1,
	R_2 = 2,
}
--牌值（大小王）
BullPokerServerDef.JOKER = {
	SMALL_JOKER = 1, --小王
	BIG_JOKER = 2 --大王
}

return BullPokerServerDef