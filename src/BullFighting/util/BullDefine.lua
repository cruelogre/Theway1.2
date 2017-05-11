-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋常亮定义
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

--玩家位置
cc.exports.BullSeverPlayerType = {
    SelfPlayerSeat = 5,   			--我自己
    RightPlayerSeat = 4,			--右玩家
    RightUpPlayerSeat = 3,			--右上玩家
    LeftUpPlayerSeat = 2,			--左上玩家
    LeftPlayerSeat = 1,				--左玩家
}

cc.exports.BullPlayerType = {
    SelfPlayerSeat = 5,   			--我自己
    RightPlayerSeat = 4,			--右玩家
    RightUpPlayerSeat = 3,			--右上玩家
    LeftUpPlayerSeat = 2,			--左上玩家
    LeftPlayerSeat = 1,				--左玩家
}

--自己
cc.exports.BULL_FIX_UP = 20			--理成列 列中间隔

cc.exports.screenSize = cc.Director:getInstance():getWinSize()  --适配屏幕
cc.exports.BULL_DISTRIBUTE_CARD_MIN_NUM = 5							--每个玩家最多牌张数
cc.exports.BULL_DISTRIBUTE_CARD_PLAYER_NUM = 5						--玩家个数
cc.exports.BULL_CARD_NUM = 3										--算牛的牌数
cc.exports.BullCardChooseBlenColor = cc.c3b(0x65,0x76,0xD8) 		--选中牌变色
cc.exports.BullCaculateCardTime = 10 								--算牛CD时间
cc.exports.BullCardScale = 0.5 								    --牌缩放
cc.exports.BullRadomArea = 50 								    --牌缩放
cc.exports.BullGoldToImg = 50 								    	--多少分代表一个金币


--牌的选中状态
cc.exports.BullCardState = {
	State_None = 0,				--初始状态
	State_CheckIng = 1,			--正在选中
	State_Checked = 2,			--已选择
	State_Discard = 3,			--不能点选
}

cc.exports.BullGameStateType = {
	waitBegin = 0,  --等待开局
	Begin = 1,      --开局
	Cathectic = 2,  --投注
	ShowCard = 3,   --亮牌
	Settlement = 4,	--结算
}

--花色大->小 （黑莓方红）
cc.exports.BullFollowType = {
	TYPE_F = 1,			-- 方块
	TYPE_M = 2,			-- 梅花
	TYPE_H = 3,			-- 红桃
	TYPE_B = 4,			-- 黑桃
}

--牌值(用于渲染)
cc.exports.BullCardValue = {
	R1 = 1,				-- 1
	R2 = 2,				-- 2
	R3 = 3,				-- 3
	R4 = 4,				-- 4
	R5 = 5,				-- 5
	R6 = 6,				-- 6
	R7 = 7,				-- 7
	R8 = 8,				-- 8
	R9 = 9,				-- 9
	R10 = 10,			-- 10
	RJ = 11,			-- J
	RQ = 12,			-- Q
	RK = 13,			-- K
}

cc.exports.BullType = { -- 牛的类型
	None = 0, 				--无效牌
	BullOne = 1, 			--牛一
	BullTwo = 2, 			--牛二
	BullThree = 3, 			--牛三
	BullFour = 4, 			--牛四
	BullFive = 5, 			--牛五
	BullSix = 6, 			--牛六
	BullSeven = 7, 			--牛七
	BullEight = 8,         	--牛八
	BullNine = 9,         	--牛九
	BullBull = 10,        	--牛牛
	BullFourBomb = 11,      --四炸
	BullFiveFlower = 12,    --五花牛
	BullSmall = 13,         --五小牛
} 

cc.exports.BullCards = { -- 牛的类型
	{ color = 1,val = 2},
	{ color = 3,val = 2},
	{ color = 4,val = 11},
	{ color = 2,val = 2},
	{ color = 1,val = 13},
}

cc.exports.BullWaitState = {
	BullWaitBegin = 1,
	BullWaitChoose = 2,
	BullWaitOtherChoose = 3,
	BullWaitCaculate = 4,
	BullSettlment = 5,
}

--判断有炸弹
function cc.exports.detectionBullBomb(cardList)
	--保存数据
	local cardClone = {}
	CloneTable(cardList,cardClone)
	
	--拆分
	local cardTable = {} 
	local lastCard = false
	for k,v in pairs(cardClone) do
		if not lastCard or lastCard.val ~= v.val then 
			cardTable[#cardTable + 1] = {}
		end
		lastCard = v
		table.insert(cardTable[#cardTable],lastCard)
	end

	if #cardTable == 2 then--只有两种数
	 	if #cardTable[1] == 4 or #cardTable[2] == 4 then
	 		return true
		end
	end

	return false
end

--判断五小牛
function cc.exports.detectionBullFiveLit(cardList)
	--保存数据
	local cardClone = {}
	CloneTable(cardList,cardClone)
	
	local valAll = 0
	for k,v in pairs(cardClone) do
		if v.val > 5 then
			return false
		end

		valAll = valAll + v.val
	end

	if valAll > 10 then
		return false
	end

	return true
end

function cc.exports.playNiuValSoundFileName( gender,val )
	-- body
	local genderStr = "niu_nan"
	if gender == GenderType.male then
		genderStr = 'niu_nan'
	elseif gender == GenderType.female then
		genderStr = 'niu_nv'
	end

	local file = "cow_"..val
	
	local fileName = string.format("sound/%s/%s",genderStr,file)
	playSoundEffect(fileName)
end