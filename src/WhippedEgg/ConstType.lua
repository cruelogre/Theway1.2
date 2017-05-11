-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋常亮定义
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
require("app.config.wwGoodsInfo")

--玩家位置
cc.exports.Player_Type = {
    SelfPlayer = 0,   			--我自己
    LeftPlayer = 1,				--左玩家
    UpPlayer = 2,				--上玩家
    RightPlayer = 3,			--右玩家
}

--自己
cc.exports.MY_FIX_UP = 50			--理成列 列中间隔
cc.exports.MY_FIX_UP_EXPAND = 75	--理成列 点击牌展开
cc.exports.MY_MAX_CARD_COUNT = 12	--最多整张容纳牌数
cc.exports.MY_FIX = 140				--牌间隔最大值
cc.exports.MY_FIX_WEIDTH = 160		--牌宽度
cc.exports.MY_FIX_HEIGHT = 205		--牌高度

cc.exports.screenSize = cc.Director:getInstance():getWinSize()  --适配屏幕
cc.exports.DISTRIBUTE_CARD_MAX_NUM = 108						--两副牌张数
cc.exports.DISTRIBUTE_CARD_MIN_NUM = 27							--每个玩家最多牌张数
cc.exports.DISTRIBUTE_CARD_PLAYER_NUM = 4						--玩家个数
cc.exports.CHANGECOLOR_CARD_PLAYER_NUM = 10						--牌变色张数
cc.exports.CardChooseBlenColor = cc.c3b(0x65,0x76,0xD8) 		--选中牌变色

cc.exports.SettlementClassicalSec = 15  --经典房结算倒计时
cc.exports.SettlementMatchSec = 3		--比赛房结算倒计时

--牌的选中状态
cc.exports.Card_State = {
	State_None = 0,				--初始状态
	State_CheckIng = 1,			--正在选中
	State_Checked = 2,			--已选择
	State_Discard = 3,			--不能点选
}

--牌节点触摸区域
cc.exports.Card_Check_Size = {
	halpUp = 0, 				--上边有遮盖
	up = 1,						--上边
	half = 2,					--一般
	all = 3,					--整个
}

cc.exports.PlayCardType = 
{
	NORMAL = 1, 	--出牌
	OVER_TIME = 2, 	--超时
	NO_CARD = 3,   	--不出
}

cc.exports.PlayerStateType = {
	None = 1,       
	Wait = 2,			--等待中
	Ready = 3,      	--已准备
	PayTribute = 4, 	--进贡
	RetTribute = 5, 	--退贡
	UnPayTribute = 6, 	--抗贡
	TributeEnd = 7, 	--结束贡
	NotPlay = 8,		--不出
	Solitaire = 9,		--接风
}

cc.exports.ToastState = {
	None = 1, 
	NoRule = 2,			--不符合规则
	FriendNeedHelp = 3, --队友需要你
	FriendCard = 4,		--朋友的牌
	NoColorBomb = 5,	--没有同花顺
	NoPass = 6,			--不能大过对方
	Trusteeship = 7,    --托管
	MustChooseOneCard = 8,    --请选择一张牌
}

cc.exports.GameStateType = {
	None = 1,  		--无
	Enter = 2,      --进入

	WaitPlayerInfo = 3,		--等待玩家
	Ready = 4,      --准备
	EnterBackground = 5,--切换到后台 直接跳过发牌 不会再去发牌
	DealCard = 6,  	--发牌
	PayTribute = 7,	--进贡
	RetTribute = 8, --退贡
	UnPayTribute = 9, --抗贡
	TributeEnd = 10, --结束贡
	Playing = 11,	--玩牌
	Settlement = 12,	--结算
	MathcWaitOther = 13,	--等待其他玩家


	WaitSettlement = 14,	--等待结算
}

cc.exports.FOLLOW_TYPE = {
	TYPE_B = 1,			-- 黑桃
	TYPE_M = 2,			-- 梅花
	TYPE_F = 3,			-- 方块
	TYPE_H = 4,			-- 红桃
	TYPE_L = 5,		    -- 癞子
}

cc.exports.CARD_VALUE = {
	R2 = 1,				-- 2
	R3 = 2,				-- 3
	R4 = 3,				-- 4
	R5 = 4,				-- 5
	R6 = 5,				-- 6
	R7 = 6,				-- 7
	R8 = 7,				-- 8
	R9 = 8,				-- 9
	R10 = 9,			-- 10
	RJ = 10,			-- J
	RQ = 11,			-- Q
	RK = 12,			-- K
	R1 = 13,			-- A
	R_WA = 14,			-- WA 小王
	R_WB = 15,			-- WB 大王
}

cc.exports.CARD_TYPE = { -- 牌的类型
	NONE = 1, 				--无效牌

	SINGLE = 2, 			--单个
	DOUBLE = 3, 			--对
	TRIPLE = 4, 			--三个
	TRIPLE_AND_DOUBLE = 5, 	--三带二
	COMMON_STRAIGHT = 6, 	--普通顺子
	PLATE = 7, 				--钢板
	LINK_DOUBLE = 8, 		--连对

	FOUR_BOMB = 9,          --四炸
	FIVE_BOMB = 10,         --五炸
	FLUSH_BOMB = 11,        --同花顺
	SIX_BOMB = 12,          --六炸
	SEVEN_BOMB = 13,        --七炸
	EIGHT_BOMB = 14,         --八炸
	NINE_BOMB = 15,          --九炸
	TEN_BOMB = 16,          --十炸
	KING_BOMB = 17,  		--王炸
} 

--房间类型
cc.exports.Room_Type = {
    ClassicalRoom = 1,   		--经典房
    MatchRoom = 2,				--比赛房
    PersonalRoom = 3,			--私人房
}
--玩法类型
cc.exports.Play_Type = {
    PromotionGame = 1,   		--升级玩法
    RandomGame = 2,				--逢人配玩法
    RcircleGame = 3,			--团团转玩法
}

--牌局类型
cc.exports.Game_Type = {
    ClassicalPromotion = 1,   	--经典房升级玩法
    ClassicalRandomGame = 2,   	--经典房逢人配玩法
    ClassicalRcircleGame = 3,   --经典房团团转玩法

    MatchRamdomCount = 4,		--比赛逢人配定人赛
    MatchRamdomTime = 5,		--比赛逢人配定时赛
    MatchRcircleCount = 6,		--比赛团团转定人赛
    MatchRcircleTime = 7,		--比赛团团转定时赛

    PersonalPromotion = 8,     	--私人房升级玩法
    PersonalRandom = 9,   		--私人房逢人配玩法
    PersonalRcircle = 10,	    --私人房团团转玩法
}

cc.exports.lightWiner = {
	winerLeft = 1, --己方
	winerRight = 2, --对方
	winerAll = 3, --双方
}

--牌局类型
cc.exports.Team_Type = {
    TEAM_SINGLE = 0,   			--单人
    TEAM_MUTIPLE = 1,			--组队
}

--用户游戏中的状态类型  1=真人，5=机器人，7=后台托管，17=玩家主动托管
cc.exports.User_Type = {
	REAL = 1, --真人
	ROBOT = 5, --机器人
	SUBSTITUTE_BACK = 7, --后台托管
	SUBSTITUTE_ACTIVE = 17, --玩家主动托管
}
--玩家位置
cc.exports.GenderType = {
    male = 1,   			--男
    female = 2,				--女
}

cc.exports.RegionType = {
    nanJing = 0,   			--南京
    normal = 1,				--普通
}

--从小到大
function cc.exports.cardTipsProSort( pro )
	-- body
	--先排序一次
	if next(pro) == nil then
		return
	end

	table.sort( pro, function (a,b)
		-- body
		return a[1].val < b[1].val 
	end )

	local nowCardVal = false
	for i=#pro,1,-1 do
		if pro[i][1].val == GameModel.nowCardVal then
			nowCardVal = table.remove(pro,i)
		end
	end

 	local find = false
	local idx = 0
	for m,n in pairs(pro) do
		if n[1].val >= tonumber(CARD_VALUE.R_WA) then
			find = true
			idx = m
			break
		end
	end

	if nowCardVal then
		if find then
			table.insert(pro,idx,nowCardVal)
		else
			table.insert(pro,nowCardVal)
		end
	end
end

--从大到小
function cc.exports.cardTributeSort( pro )
	-- body
	--先排序一次
	if next(pro) == nil then
		return
	end

	table.sort( pro, function (a,b)
		-- body
		return a[1].val > b[1].val 
	end )

	local nowCardVal = false
	for i=#pro,1,-1 do
		if pro[i][1].val == GameModel.nowCardVal then
			nowCardVal = table.remove(pro,i)
		end
	end

 	local find = false
	local idx = 0
	for m,n in pairs(pro) do
		if n[1].val < tonumber(CARD_VALUE.R_WA) then
			find = true
			idx = m
			break
		end
	end

	if nowCardVal then
		if find then
			table.insert(pro,idx,nowCardVal)
		else
			table.insert(pro,1,nowCardVal)
		end
	end
end

--从大到小
function cc.exports.cardDetectionBigToSmallSort( cardList )
	-- body
	--先排序一次
	if next(cardList) == nil then
		return
	end
	--从大到小
	table.sort( cardList, function (a,b)
		-- body
		if a.val > b.val then
			return true
		elseif a.val < b.val then
			return false
		else
			return a.color < b.color --黑梅方红
		end
	end )

	local nowCardVal = {}
	for i=#cardList,1,-1 do
		if cardList[i].val == GameModel.nowCardVal then
			table.insert(nowCardVal,table.remove(cardList,i))
		end
	end

	local find = false
	local idx = 0
	for m,n in pairs(cardList) do
		if n.val < tonumber(CARD_VALUE.R_WA) then
			find = true
			idx = m
			break
		end
	end

	if next(nowCardVal) then
		if find then
			for k,v in pairs(nowCardVal) do
				table.insert(cardList,idx,v)
			end
		else
			for k,v in pairs(nowCardVal) do
				table.insert(cardList,v)
			end
		end
	end 
end


function cc.exports.cardDetectionSmallToBigSort( cardList )
	table.sort( cardList, function ( a,b )
		-- body
		if a.val < b.val then
			return true
		elseif a.val > b.val then  --从小到大
			return false
		else
			if a.color < b.color then --黑梅方红
				return true
			elseif a.color > b.color then
				return false
			else
				return a.createIdx < b.createIdx
			end 
		end
	end )
	local nowCardVal = {}
	for i=#cardList,1,-1 do
		if cardList[i].val == GameModel.nowCardVal then
			table.insert(nowCardVal,table.remove(cardList,i))
		end
	end

 	local find = false
	local idx = 0
	for m,n in pairs(cardList) do
		if n.val >= tonumber(CARD_VALUE.R_WA) then
			find = true
			idx = m
			break
		end
	end

	if next(nowCardVal) then
		if find then
			for i=#nowCardVal,1,-1 do
				table.insert(cardList,idx,nowCardVal[i])
			end
		else
			for i=#nowCardVal,1,-1 do
				table.insert(cardList,nowCardVal[i])
			end
		end
	end
end

function cc.exports.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function cc.exports.insertItem(list, item)
	local find = false
    for k,v in pairs(list) do
    	if v == item then
    		find = true
    		break
    	end
    end

    if not find then
    	table.insert(list,item)
    end
end

function cc.exports.insertItemByDifVal(list, item)
	if not next(item) then
		return 
	end
	--外部可能由于服务器推送消息没同步 把牌释放了
	for k,v in pairs(item) do
		if tolua.isnull(v) then
			return
		end
	end
	--先排序
	local function ItemSort( item )
		-- body
		table.sort( item, function (a,b)
			-- body
			if a.val < b.val then
				return true
			elseif a.val > b.val then  --从小到大
				return false
			else
				return a.color < b.color --黑梅方红
			end
		end )
	end
	ItemSort(item)

	local find = false
    for k,v in pairs(list) do
    	ItemSort(v)
    	local equal = {}
    	if #v == #item then
    		for m,n in pairs(v) do
	    		for x,y in pairs(item) do
	    			if y == n then
	    				table.insert(equal,true)
	    				break
	    			end
	    		end
	    	end
	    end

	    --找到两组完全相同的
	    if #equal == #v and #equal == #item then
	    	find = true
	    	break
	    end
    end

    if next(list) == nil or not find then
    	table.insert(list,item)
    end
end

function cc.exports.findItem(list, item)
	local find = false
    for k,v in pairs(list) do
    	if v == item then
    		find = true
    		break
    	end
    end
    return find
end

function cc.exports.findItemByColorAndValue(list, color,val)
	local find = false
    for k,v in pairs(list) do
    	if v.color == color and v.val == val then
    		find = true
    		break
    	end
    end
    return find
end

function cc.exports.CloneTable(srcT, destT)
	for i=#destT,1,-1 do
		table.remove(destT,i)
	end

	for k,v in pairs(srcT) do
		table.insert(destT,v)
	end
end

function cc.exports.TableReplace(t,idx,node)
	if type(t) == "table" then
		table.remove(t,idx)
		table.insert(t,idx,node)
	end
end

function cc.exports.PlayCardSwitch( num )
	-- body
	if num <= 9 then
		return tostring(num+1)
	elseif num == 10 then
		return	"J"
	elseif num == 11 then
		return	"Q"
	elseif num == 12 then
		return	"K"
	elseif num == 13 then
		return	"A"
	elseif num == 14 then
		return	"小王"
	elseif num == 15 then
		return	"大王"
	end
end

function cc.exports.printCardLogType( typeCard,Cards,player)
	local cardstr = ""
	for k,v in pairs(Cards) do
		cardstr = cardstr..PlayCardSwitch(v.val)
	end
	-- body
	if typeCard == tonumber(CARD_TYPE.NONE) then
		wwplyaCardLog("%s%s%s",player,"  无效牌  "," 此轮我最先出牌 ")
	elseif typeCard == tonumber(CARD_TYPE.SINGLE) then
		wwplyaCardLog("%s%s%s",player,"  单个  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.DOUBLE) then
		wwplyaCardLog("%s%s%s",player,"  对子  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.TRIPLE) then
		wwplyaCardLog("%s%s%s",player,"  三个  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.TRIPLE_AND_DOUBLE) then
		wwplyaCardLog("%s%s%s",player,"  三带二  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.COMMON_STRAIGHT) then
		wwplyaCardLog("%s%s%s",player,"  普通顺子  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.PLATE) then
		wwplyaCardLog("%s%s%s",player,"  钢板  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.LINK_DOUBLE) then
		wwplyaCardLog("%s%s%s",player,"  连对  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.FOUR_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  四炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.FIVE_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  五炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.FLUSH_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  同花顺  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.SIX_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  六炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.SEVEN_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  七炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.EIGHT_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  八炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.NINE_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  九炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.TEN_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  十炸  ",cardstr)
	elseif typeCard == tonumber(CARD_TYPE.KING_BOMB) then
		wwplyaCardLog("%s%s%s",player,"  王炸  ",cardstr)
	end
end

function cc.exports.getSoundFileName( gender,file )
	-- body
	local genderStr = ""
	if gender == GenderType.male then
		genderStr = 'n'
	elseif gender == GenderType.female then
		genderStr = 'v'
	end

	local fileName = string.format("sound/%s/%s/%s%s_%s",GameModel.RegionType,genderStr,GameModel.RegionType,genderStr,file)
	wwlog("fileName",fileName)
	return fileName
end

function cc.exports.getValSoundFileName( gender,val )
	-- body
	local genderStr = ""
	if gender == GenderType.male then
		genderStr = 'n'
	elseif gender == GenderType.female then
		genderStr = 'v'
	end

	local file = ""
	if val == CARD_VALUE.R2 then
		file = 'er'
	elseif val == CARD_VALUE.R3 then
		file = 'san'
	elseif val == CARD_VALUE.R4 then
		file = 'si'
	elseif val == CARD_VALUE.R5 then
		file = 'wu'
	elseif val == CARD_VALUE.R6 then
		file = 'liu'
	elseif val == CARD_VALUE.R7 then
		file = 'qi'
	elseif val == CARD_VALUE.R8 then
		file = 'ba'
	elseif val == CARD_VALUE.R9 then
		file = 'jiu'
	elseif val == CARD_VALUE.R10 then
		file = 'shi'
	elseif val == CARD_VALUE.RJ then
		file = 'J'
	elseif val == CARD_VALUE.RQ then
		file = 'Q'
	elseif val == CARD_VALUE.RK then
		file = 'K'
	elseif val == CARD_VALUE.R1 then
		file = 'A'
	elseif val == CARD_VALUE.R_WA then
		file = 'xiaowang'
	elseif val == CARD_VALUE.R_WB then
		file = 'dawang'
	end

	local fileName = string.format("sound/%s/%s/%s%s_%s",GameModel.RegionType,genderStr,GameModel.RegionType,genderStr,file)
	return fileName
end

--打牌音效
function cc.exports.playCardSound( selfNode,gender,typeCard,val)
	-- body
	if typeCard == tonumber(CARD_TYPE.SINGLE) then
		playSoundEffect(getValSoundFileName(gender,val))
	elseif typeCard == tonumber(CARD_TYPE.DOUBLE) then
		-- if val >= CARD_VALUE.R_WA then
		-- 	if val == CARD_VALUE.R_WA then
		-- 		playSoundEffect(getSoundFileName(gender,'xiaowang'),false)
		-- 	elseif val == CARD_VALUE.R_WB then
		-- 		playSoundEffect(getSoundFileName(gender,'dawang'),false)
		-- 	end
		-- else
		-- 	selfNode:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- 		-- body
		-- 		playSoundEffect(getSoundFileName(gender,'yidui'),false)
		-- 	end),cc.DelayTime:create(0.15),cc.CallFunc:create(function ( ... )
		-- 		-- body
		-- 		playSoundEffect(getValSoundFileName(gender,val),false)
		-- 	end)))
		-- end

		playSoundEffect(getSoundFileName(gender,'yidui'))
	elseif typeCard == tonumber(CARD_TYPE.TRIPLE) then
		-- selfNode:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- 	-- body
		-- 	playSoundEffect(getSoundFileName(gender,'sanzhang'),false)
		-- end),cc.DelayTime:create(0.15),cc.CallFunc:create(function ( ... )
		-- 	-- body
		-- 	playSoundEffect(getValSoundFileName(gender,val),false)
		-- end)))

		playSoundEffect(getSoundFileName(gender,'sanzhang'))
	elseif typeCard == tonumber(CARD_TYPE.TRIPLE_AND_DOUBLE) then
		playSoundEffect(getSoundFileName(gender,'sandaier'))
	elseif typeCard == tonumber(CARD_TYPE.COMMON_STRAIGHT) then
		playSoundEffect(getSoundFileName(gender,'shunzi'))
	elseif typeCard == tonumber(CARD_TYPE.PLATE) then
		playSoundEffect(getSoundFileName(gender,'gangban'))
	elseif typeCard == tonumber(CARD_TYPE.LINK_DOUBLE) then
		playSoundEffect(getSoundFileName(gender,'liandui'))
	elseif typeCard == tonumber(CARD_TYPE.FOUR_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.FIVE_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.FLUSH_BOMB) then
		playSoundEffect(getSoundFileName(gender,'tonghuashun'))
	elseif typeCard == tonumber(CARD_TYPE.SIX_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.SEVEN_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.EIGHT_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.NINE_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.TEN_BOMB) then
		playSoundEffect(getSoundFileName(gender,'zhadan'))
	elseif typeCard == tonumber(CARD_TYPE.KING_BOMB) then
		playSoundEffect(getSoundFileName(gender,'wangzha'))
	end
end

--不出
function cc.exports.donotPlayCardSound( gender )
	-- body
	local fileName = ""
	local random = math.random(0,1)
	if gender == GenderType.male then
		if random == 0 then
			fileName = 'buyao'
		else
			fileName = 'guo'
		end
	elseif gender == GenderType.female then
		if random == 0 then
			fileName = 'yaobuqi'
		else
			fileName = 'buyao'
		end
	end
	playSoundEffect(getSoundFileName(gender,fileName))
end

--大牌
function cc.exports.passPlayCardSound( selfNode,gender,isFirst,typeCard,val )
	-- body
	local function randomPass( ... )
		-- body
		local fileName = ""
		local random = math.random(0,1)
		if gender == GenderType.male then
			if random == 0 then
				fileName = 'dani'
			else
				fileName = 'yani'
			end
		elseif gender == GenderType.female then
			if random == 0 then
				fileName = 'wolai'
			else
				fileName = 'chini'
			end
		end

		return fileName
	end
	--第一手牌
	if isFirst then
		playCardSound(selfNode,gender,typeCard,val)
	else
		local random = math.random(0,1)
		if random == 0 then
			playCardSound(selfNode,gender,typeCard,val)
		else
			local fileName = randomPass()
			playSoundEffect(getSoundFileName(gender,fileName))
		end
	end
end

--报警
function cc.exports.callThePoliceSound( gender )
	-- body
	local fileName = ""
	if gender == GenderType.male then
		fileName = 'xiaoxin'
	elseif gender == GenderType.female then
		fileName = 'wokuaidawanlo'
	end
	playSoundEffect(getSoundFileName(gender,fileName))
end

--进贡/退贡
function cc.exports.TributeSound(selfNode,gender,Tribute,val )
	-- body
	local fileName = ""
	local delayTime = 0
	if Tribute then --进贡
		if gender == GenderType.male then
			fileName = 'geini'
			delayTime = 0.5
		elseif gender == GenderType.female then
			fileName = 'wuwu'
			delayTime = 1
		end
	else
		if gender == GenderType.male then
			fileName = 'huannizhang'
			delayTime = 1
		elseif gender == GenderType.female then
			fileName = 'geiniyizhang'
			delayTime = 1
		end
	end

	-- selfNode:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
	-- 	-- body
	-- 	playSoundEffect(getSoundFileName(gender,fileName),false)
	-- end),cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
	-- 	-- body
	-- 	playSoundEffect(getValSoundFileName(gender,val),false)
	-- end)))

	playSoundEffect(getSoundFileName(gender,fileName))
end


function cc.exports.findLoopIdx( lastPositionType,nextPositionType )
	local idx = {}
	if nextPositionType == Player_Type.SelfPlayer then
		if lastPositionType == Player_Type.UpPlayer then
			table.insert(idx,Player_Type.LeftPlayer)
		elseif lastPositionType == Player_Type.RightPlayer then
			table.insert(idx,Player_Type.LeftPlayer)
			table.insert(idx,Player_Type.UpPlayer)
		end
	elseif nextPositionType == Player_Type.LeftPlayer then
		if lastPositionType == Player_Type.RightPlayer then
			table.insert(idx,Player_Type.UpPlayer)
		elseif lastPositionType == Player_Type.SelfPlayer then
			table.insert(idx,Player_Type.UpPlayer)
			table.insert(idx,Player_Type.RightPlayer)
		end
	elseif nextPositionType == Player_Type.UpPlayer then
		if lastPositionType == Player_Type.SelfPlayer then
			table.insert(idx,Player_Type.RightPlayer)
		elseif lastPositionType == Player_Type.LeftPlayer then
			table.insert(idx,Player_Type.RightPlayer)
			table.insert(idx,Player_Type.SelfPlayer)
		end
	elseif nextPositionType == Player_Type.RightPlayer then
		if lastPositionType == Player_Type.LeftPlayer then
			table.insert(idx,Player_Type.SelfPlayer)
		elseif lastPositionType == Player_Type.UpPlayer then
			table.insert(idx,Player_Type.SelfPlayer)
			table.insert(idx,Player_Type.LeftPlayer)
		end
	end

	return idx
end

function cc.exports.createClippingNode( fileName,child,pos )
	-- body
	local clippingNode = cc.ClippingNode:create();
	local maskNode = cc.Sprite:createWithSpriteFrameName(fileName)
	clippingNode:setAlphaThreshold(0)
	clippingNode:setStencil(maskNode)
	clippingNode:addChild(child)
	clippingNode:setPosition(pos)

	return clippingNode
end

--判断是否队友
function cc.exports.isTeammate( playerA,playerB )
	-- body
	if playerA == Player_Type.SelfPlayer and playerB == Player_Type.UpPlayer or
		playerB == Player_Type.SelfPlayer and playerA == Player_Type.UpPlayer or
		playerA == Player_Type.LeftPlayer and playerB == Player_Type.RightPlayer or 
		playerB == Player_Type.LeftPlayer and playerA == Player_Type.RightPlayer then
		return true
	end

	return false
end

--判断哪两个交换
function cc.exports.switchPlayers( playerA,playerB)
	-- body
	if playerA == Player_Type.SelfPlayer and playerB == Player_Type.LeftPlayer then
		return Player_Type.LeftPlayer,Player_Type.UpPlayer
	elseif playerA == Player_Type.SelfPlayer and playerB == Player_Type.RightPlayer then
		return Player_Type.RightPlayer,Player_Type.UpPlayer
	elseif playerA == Player_Type.RightPlayer and playerB == Player_Type.SelfPlayer then
		return Player_Type.SelfPlayer,Player_Type.LeftPlayer
	elseif playerA == Player_Type.RightPlayer and playerB == Player_Type.UpPlayer then
		return Player_Type.UpPlayer,Player_Type.LeftPlayer
	elseif playerA == Player_Type.UpPlayer and playerB == Player_Type.RightPlayer then
		return Player_Type.RightPlayer,Player_Type.SelfPlayer
	elseif playerA == Player_Type.UpPlayer and playerB == Player_Type.LeftPlayer then
		return Player_Type.LeftPlayer,Player_Type.SelfPlayer
	elseif playerA == Player_Type.LeftPlayer and playerB == Player_Type.UpPlayer then
		return Player_Type.UpPlayer,Player_Type.RightPlayer
	elseif playerA == Player_Type.LeftPlayer and playerB == Player_Type.SelfPlayer then
		return Player_Type.SelfPlayer,Player_Type.RightPlayer
	end
end

--截取前5个汉字 或者9个字符
function cc.exports.subNickName( context )
	-- body
	local length = string.len(context)
	local hanzi = 0
	local yinwen = 0
	if length > 9 then
		local str = ""
		local ibyte = 1
		for i=1,length do
			local cValue = string.byte(context,ibyte)
			if cValue > 0 and cValue < 127 then
				str = str..string.sub(context,ibyte,ibyte)
				yinwen = yinwen + 1
				ibyte = ibyte + 1
			else --utf8中文占3个字符
				str = str..string.sub(context,ibyte,ibyte+2)
				hanzi = hanzi + 1
				ibyte = ibyte + 3
			end

			if ibyte > length then
				if hanzi >= 3 or yinwen >= 9 or hanzi*3+yinwen >= 9 then
					return str.."..."
				else
					return str
				end
			else
				if hanzi >= 3 or yinwen >= 9 or hanzi*3+yinwen >= 9 then
					return str.."..."
				end
			end
		end
	else
		return context
	end
end
