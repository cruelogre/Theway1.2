local BullfightPokerUtil = {}
require("BullFighting.util.BullDefine")
local BullPokerServerDef = import(".BullPokerServerDef","BullFighting.util.")
--解析服务器的返回的牌数据，解析成惯蛋中的牌表
local math = math
function BullfightPokerUtil.parseServerData(str)
	local cardsTable = {}
	if not str or str == "\0" then
		return cardsTable
	end
	local len = string.len(str)
	for i=1,len do
		local b = string.byte(str,i)
		
		local pokerNum =  (b-1)%13+1
		local color = math.floor((b-1)/13)+1
		
		local localColor = BullfightPokerUtil.serverToLocalColor(color)
		local pokerTable = {}
		pokerTable.color = localColor
		if localColor == BullFollowType.TYPE_W then
			--大小王
			pokerTable.color = BullFollowType.TYPE_F --随便给一个color
			pokerTable.val = BullfightPokerUtil.serverTolocalJoker(pokerNum)
		else
			--普通牌
			pokerTable.val = BullfightPokerUtil.serverToLocalNumber(pokerNum)
		end
		table.insert(cardsTable,pokerTable)
	end
	
	return cardsTable
end
--解析下注倍数
function BullfightPokerUtil.parseBetScore(str)
	local cardsTable = {}
	if not str or str == "\0" then
		return cardsTable
	end
	local len = string.len(str)
	for i=1,len do
		local b = string.byte(str,i)
		table.insert(cardsTable,b)
	end
	
	return cardsTable
end
--服务器花色转换成本地花色
function BullfightPokerUtil.serverToLocalColor(color)
	local localColor = BullFollowType.TYPE_B
	if color == BullPokerServerDef.TYPE.DIAMONDS then --方块
		localColor = BullFollowType.TYPE_F
	elseif color == BullPokerServerDef.TYPE.CLUBS then --梅花
		localColor = BullFollowType.TYPE_M
	elseif color == BullPokerServerDef.TYPE.HEARTS then --红桃
		localColor = BullFollowType.TYPE_H
	elseif color == BullPokerServerDef.TYPE.SPADES then --黑桃
		localColor = BullFollowType.TYPE_B
	elseif color == BullPokerServerDef.TYPE.JOKERS then --王牌
		localColor = BullFollowType.TYPE_W
	end
	return localColor
end

--服务器牌值转换成本地牌值
function BullfightPokerUtil.serverToLocalNumber(pokerNum)
	return pokerNum
end

--服务器大小王转换成本地大小王
function BullfightPokerUtil.serverTolocalJoker(pokerNum)

	return pokerNum
end
--
function BullfightPokerUtil.localToServerColor(color)
	local serColor = BullPokerServerDef.TYPE.DIAMONDS
	if color == BullFollowType.TYPE_B then --黑桃
		serColor = BullPokerServerDef.TYPE.SPADES
	elseif color == BullFollowType.TYPE_F then --方块
		serColor = BullPokerServerDef.TYPE.DIAMONDS
	elseif color == BullFollowType.TYPE_M then --梅花
		serColor = BullPokerServerDef.TYPE.CLUBS
	elseif color == BullFollowType.TYPE_H then --红桃
		serColor = BullPokerServerDef.TYPE.HEARTS
	end
	return serColor
end

function BullfightPokerUtil.localToServerNumber(pokerNum)
	return pokerNum
end

function BullfightPokerUtil.localToServerJoker(pokerNum)
	return pokerNum
end

--转换牌至服务器的约定
-- @param pokerData 本地牌数据  格式为 {color = 1,val = 2 }
function BullfightPokerUtil.parseLocalData(pokerData)
	local serverStr = ""
	
	if pokerData then
	
	if pokerData.color and pokerData.val then --单个表的形式
		local serPokerNum = BullPokerServerDef.VALUE.R_A
		local serColor = BullPokerServerDef.TYPE.SPADES
		serColor = BullfightPokerUtil.localToServerColor(pokerData.color)
		serPokerNum = BullfightPokerUtil.localToServerNumber(pokerData.val)
		
		serverStr = string.char((serColor-1)*13+serPokerNum)
	else --表数组
		
		for _,pd in pairs(pokerData) do
			if pd.color and pd.val then
				local serPokerNum2 = 1
				local serColor2 = 1
				if pd.val < CARD_VALUE.R_WA then --普通牌
					serColor2 = BullfightPokerUtil.localToServerColor(pd.color)
				else -- 大小王
					serColor2 = BullPokerServerDef.TYPE.JOKERS
				end
				serPokerNum2 = BullfightPokerUtil.localToServerNumber(pd.val)
				serverStr = serverStr..string.char((serColor2-1)*13+serPokerNum2)
			end
		end
		
	end
		
	end
	
	return serverStr
end

return BullfightPokerUtil