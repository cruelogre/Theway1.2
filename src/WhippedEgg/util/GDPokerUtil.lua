local GDPokerUtil = {}
require("WhippedEgg.ConstType")
local PokerServerDef = import(".PokerServerDef","WhippedEgg.util.")
--解析服务器的返回的牌数据，解析成惯蛋中的牌表
function GDPokerUtil.parseServerData(str)
	local cardsTable = {}
	if not str or str == "\0" then
		return cardsTable
	end
	local len = string.len(str)
	for i=1,len do
		local b = string.byte(str,i)
		
		local pokerNum = bit.band(b,0x0F)
		local color = bit.rshift(b,4)
		
		local localColor = GDPokerUtil.serverToLocalColor(color)
		local pokerTable = {}
		pokerTable.color = localColor
		if localColor == FOLLOW_TYPE.TYPE_W then
			--大小王
			pokerTable.color = FOLLOW_TYPE.TYPE_F --随便给一个color
			pokerTable.val = GDPokerUtil.serverTolocalJoker(pokerNum)
		else
			--普通牌
			pokerTable.val = GDPokerUtil.serverToLocalNumber(pokerNum)
		end
		table.insert(cardsTable,pokerTable)
	end
	
	return cardsTable
end
--服务器花色转换成本地花色
function GDPokerUtil.serverToLocalColor(color)
	local localColor = FOLLOW_TYPE.TYPE_B
	if color == PokerServerDef.TYPE.DIAMONDS then --方块
		localColor = FOLLOW_TYPE.TYPE_F
	elseif color == PokerServerDef.TYPE.CLUBS then --梅花
		localColor = FOLLOW_TYPE.TYPE_M
	elseif color == PokerServerDef.TYPE.HEARTS then --红桃
		localColor = FOLLOW_TYPE.TYPE_H
	elseif color == PokerServerDef.TYPE.SPADES then --黑桃
		localColor = FOLLOW_TYPE.TYPE_B
	elseif color == PokerServerDef.TYPE.JOKERS then --王牌
		localColor = FOLLOW_TYPE.TYPE_W
	end
	return localColor
end
--服务器牌值转换成本地牌值
function GDPokerUtil.serverToLocalNumber(pokerNum)
	local localPokerNum = CARD_VALUE.R3
	if pokerNum == PokerServerDef.VALUE.R_2 then
		localPokerNum = CARD_VALUE.R2
	else
		localPokerNum = pokerNum +1
	end
	return localPokerNum
end
--服务器大小王转换成本地大小王
function GDPokerUtil.serverTolocalJoker(pokerNum)
	local localPokerNum = math.min(pokerNum,2)
	localPokerNum = math.max(localPokerNum,1)
	return CARD_VALUE.R_WA+localPokerNum-1
end
--
function GDPokerUtil.localToServerColor(color)
	local serColor = PokerServerDef.TYPE.DIAMONDS
	if color == FOLLOW_TYPE.TYPE_B then --黑桃
		serColor = PokerServerDef.TYPE.SPADES
	elseif color == FOLLOW_TYPE.TYPE_F then --方块
		serColor = PokerServerDef.TYPE.DIAMONDS
	elseif color == FOLLOW_TYPE.TYPE_M then --梅花
		serColor = PokerServerDef.TYPE.CLUBS
	elseif color == FOLLOW_TYPE.TYPE_H then --红桃
		serColor = PokerServerDef.TYPE.HEARTS
	end
	return serColor
end
function GDPokerUtil.localToServerNumber(pokerNum)
	local serPokerNum = PokerServerDef.VALUE.R_2
	if pokerNum >= CARD_VALUE.R_WA then
		serPokerNum = GDPokerUtil.localToServerJoker(pokerNum)
		
	elseif pokerNum ~= CARD_VALUE.R2 then
		
		serPokerNum = PokerServerDef.VALUE.R_3 + pokerNum - 1  - 1
	end
	
	return serPokerNum
end

function GDPokerUtil.localToServerJoker(pokerNum)
	return pokerNum - CARD_VALUE.R_WA + 1
end
--转换牌至服务器的约定
-- @param pokerData 本地牌数据  格式为 {color = 1,val = 2 }
function GDPokerUtil.parseLocalData(pokerData)
	local serverStr = ""
	
	if pokerData then
	
	if pokerData.color and pokerData.val then --单个表的形式
		local serPokerNum = 1
		local serColor = 1
		if pokerData.val < CARD_VALUE.R_WA then --普通牌
			serColor = GDPokerUtil.localToServerColor(pokerData.color)
		else -- 大小王
			serColor = PokerServerDef.TYPE.JOKERS
		end
		serPokerNum = GDPokerUtil.localToServerNumber(pokerData.val)
		
		serverStr = string.char(bit.bor(bit.lshift(serColor,4),serPokerNum))
	else --表数组
		
		for _,pd in pairs(pokerData) do
			if pd.color and pd.val then
				local serPokerNum2 = 1
				local serColor2 = 1
				if pd.val < CARD_VALUE.R_WA then --普通牌
					serColor2 = GDPokerUtil.localToServerColor(pd.color)
				else -- 大小王
					serColor2 = PokerServerDef.TYPE.JOKERS
				end
				serPokerNum2 = GDPokerUtil.localToServerNumber(pd.val)
				serverStr = serverStr..string.char(bit.bor(bit.lshift(serColor2,4),serPokerNum2))
			end
		end
		
	end
		
	end
	
	
	return serverStr
end
--是否是出的一手牌
--@param playerCardSignMap 出牌的表 1 出牌 0 不出
--@param personCount 还有多少人
function GDPokerUtil.isFirstHandle(playerCardSignMap,personCount)
	if playerCardSignMap and #playerCardSignMap>1 then
		if playerCardSignMap[#playerCardSignMap] == 0 then
			return false
		end
		local isfirst = true
		personCount = personCount or 4
		personCount = personCount - 1
		personCount = math.max(personCount,1)
		for x = #playerCardSignMap-1,#playerCardSignMap-personCount,-1 do
			if playerCardSignMap[x]~=0 then --前面三个都是不出
				isfirst = false
			end
		end
		
		return isfirst
	end
	return true
end

return GDPokerUtil