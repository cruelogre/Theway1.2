-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋牌型检测
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local CardDetection = {}
local GameModel = require("WhippedEgg.Model.GameModel")

--牌型检测 传入牌数据 返回牌类型 根据张数判断
function CardDetection.detectionType(cardList,bChange,firstPlate) --牌数据 是否修改成癞子 ,优先选钢板
	--body
	--牌数大于0
	local cardCount = #cardList
	if cardCount <= 0 then
		return CARD_TYPE.NONE
	end

	--先排序一次
	cardDetectionBigToSmallSort(cardList)

	--可变牌数
	local changeCardCount = CardDetection.detectionChangeCardCount(cardList)

	--按牌的张数判断牌型
	if cardCount == 1 then
		return CARD_TYPE.SINGLE,cardList[1].val  --单张 值
	elseif cardCount == 2 then
		if changeCardCount <= 0 then
			if cardList[1].val == cardList[2].val then
				return CARD_TYPE.DOUBLE,cardList[1].val  --一对 值
			end
		else
			return CardDetection.changeCardDouble(cardList,changeCardCount,bChange)
		end
	elseif cardCount == 3 then
		if changeCardCount <= 0 then
			if cardList[1].val == cardList[2].val and 
				cardList[2].val == cardList[3].val then
				return CARD_TYPE.TRIPLE,cardList[1].val  --三个 222 值
			end
		else
			return CardDetection.changeCardTriple(cardList,changeCardCount,bChange)
		end
	elseif cardCount == 4 then
		if CardDetection.detectionKingBomb(cardList) then
			return CARD_TYPE.KING_BOMB,0 --王炸
		else
			return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
		end
	elseif cardCount == 5 then
		local ThreeAndTwo,ThreeAndTwoVal = CardDetection.detectionThreeAndTwo(cardList,changeCardCount,bChange) --三带二
		
		if ThreeAndTwo then
			return CARD_TYPE.TRIPLE_AND_DOUBLE,ThreeAndTwoVal --三带二
		else
			local Straight,StraightType,StraightVal,StraightColor = CardDetection.detectionStraight(cardList,changeCardCount,bChange) --顺子
			if Straight then --顺子
				return StraightType,StraightVal,StraightColor
			else
				return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
			end
		end
	elseif cardCount == 6 then
		if firstPlate then
			local plate,Pval = CardDetection.detectionPlate(cardList,changeCardCount,bChange) --判断钢板
			if plate then
				return CARD_TYPE.PLATE,Pval
			else
				local linkDouble,Lval = CardDetection.detectionLinkDouble(cardList,changeCardCount,bChange) --判断连对
				if linkDouble then
					return CARD_TYPE.LINK_DOUBLE,Lval
				else
					return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
				end
			end
		else
			local linkDouble,Lval = CardDetection.detectionLinkDouble(cardList,changeCardCount,bChange) --判断连对
			if linkDouble then
				return CARD_TYPE.LINK_DOUBLE,Lval
			else
				local plate,Pval = CardDetection.detectionPlate(cardList,changeCardCount,bChange) --判断钢板
				if plate then
					return CARD_TYPE.PLATE,Pval
				else
					return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
				end
			end
		end
	elseif cardCount == 7 then
		return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
	elseif cardCount == 8 then
		return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
	elseif cardCount == 9 then
		return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
	elseif cardCount == 10 then
		return CardDetection.detectionBomb(cardList,cardCount,changeCardCount,bChange)
	else --最多能出10张 
		return CARD_TYPE.NONE
	end

	return CARD_TYPE.NONE
end

--可变牌数量
function CardDetection.detectionChangeCardCount(cardList)
	-- body
	local count = 0
	for k,v in pairs(cardList) do
		if CardDetection.detectionIsChangeCard(v) then
			count = count + 1
		end
	end
	return count
end

--是否是可变牌
function CardDetection.detectionIsChangeCard(node)
	-- body
	if node.val == GameModel.nowCardVal and node.color == tonumber(FOLLOW_TYPE.TYPE_H)  then
		return true
	end

	return false
end

--检测王炸
function CardDetection.detectionKingBomb(cardList)
	-- body
	if #cardList == 4 then
		if cardList[1].val >= tonumber(CARD_VALUE.R_WA) and
			cardList[2].val >= tonumber(CARD_VALUE.R_WA) and
			cardList[3].val >= tonumber(CARD_VALUE.R_WA) and
			cardList[4].val >= tonumber(CARD_VALUE.R_WA) then
			return true
		end
	end
	return false
end

--判断是否是三带俩 33322 22333
function CardDetection.detectionThreeAndTwo(cardList,changeCardCount,bChange)
	--保存数据
	local cardClone = {}
	CloneTable(cardList,cardClone)

	if changeCardCount == 0 then
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
		 	if #cardTable[1] == 2 and #cardTable[2] == 3 then --33222型
		 		for k,v in pairs(cardTable[1]) do
		 			table.remove(cardClone,1)
		 			table.insert(cardClone,v)
		 		end
		 		CloneTable(cardClone,cardList)
		 		return true,cardTable[2][1].val
		 	elseif #cardTable[1] == 3 and #cardTable[2] == 2 then  --33322型
		 		return true,cardTable[1][1].val
			end
		end
	else
		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end

		if changeCardCount == 1 then --3322   3222 3332
			if #cardTable == 2 then
				if #cardTable[1] == 2 and #cardTable[2] == 2 then  --3322
					if not CardDetection.detectionKingBomb(cardClone) then
						if cardTable[1][1].val >= tonumber(CARD_VALUE.R_WA) then --王王22
							if bChange then
								node[1].isLaizi = cardTable[2][1].val
							end
							for k,v in pairs(cardTable[1]) do
								table.remove(cardClone,1)
								table.insert(cardClone,v)
							end
							table.insert(cardClone,3,node[1])
							CloneTable(cardClone,cardList)

							return true,cardTable[2][1].val
						else
					 		if bChange then
								node[1].isLaizi = cardTable[1][1].val
							end
					 		table.insert(cardClone,3,node[1])
							CloneTable(cardClone,cardList)
							return true,cardTable[1][1].val
						end
					end
				elseif #cardTable[1] == 1 and #cardTable[2] == 3 then  --3222
					if cardTable[1][1].val >= tonumber(CARD_VALUE.R_WA) then --变牌不能变王
						return false
					else
						table.remove(cardClone,1)
						table.insert(cardClone,cardTable[1][1])
						table.insert(cardClone,node[1])
						if bChange then
							node[1].isLaizi = cardTable[1][1].val
						end
						CloneTable(cardClone,cardList)
						return true,cardTable[2][1].val
					end
				elseif #cardTable[1] == 3 and #cardTable[2] == 1 then  --3332
					if cardTable[2][1].val >= tonumber(CARD_VALUE.R_WA) then --变牌不能变王
						return false
					else
						table.insert(cardClone,node[1])
						if bChange then
							node[1].isLaizi = cardTable[2][1].val
						end
						CloneTable(cardClone,cardList)
						return true,cardTable[1][1].val
					end
				end
			end
		elseif changeCardCount == 2 then --322  332
			if #cardTable == 2 then
				if #cardTable[1] == 1 and #cardTable[2] == 2 then  --322
					if cardTable[1][1].val >= tonumber(CARD_VALUE.R_WA) or
					 	cardTable[2][1].val >= tonumber(CARD_VALUE.R_WA) then --小王小王大王 kk小王
						return false
					else
						table.insert(cardClone,2,node[1])
						table.insert(cardClone,2,node[2])
						if bChange then
							node[1].isLaizi = cardTable[1][1].val
							node[2].isLaizi = cardTable[1][1].val
						end

						CloneTable(cardClone,cardList)
						return true,cardTable[1][1].val
					end
				elseif #cardTable[1] == 2 and #cardTable[2] == 1 then  --332
					if cardTable[1][1].val >= tonumber(CARD_VALUE.R_WA) then --王王2
				 		table.insert(cardClone,node[1])
				 		table.insert(cardClone,node[2])
				 		if bChange then
							node[1].isLaizi = cardTable[2][1].val
							node[2].isLaizi = cardTable[2][1].val
						end

						for k,v in pairs(cardTable[1]) do
							table.remove(cardClone,1)
							table.insert(cardClone,v)
						end

						CloneTable(cardClone,cardList)
						return true,cardTable[2][1].val
					else --332
						table.insert(cardClone,3,node[1])
						table.insert(cardClone,node[2])
						if bChange then
							node[1].isLaizi = cardTable[1][1].val
							node[2].isLaizi = cardTable[2][1].val
						end
						CloneTable(cardClone,cardList)
						return true,cardTable[1][1].val
					end
				end
			end
		end
	end

	return false
end

--判断是否是顺子 A2345 < 23456 < 10JQKA
function CardDetection.detectionStraight(cardList,changeCardCount,bChange)
	--body
	for k,v in pairs(cardList) do --顺子里面不能有王
		if v.val >= tonumber(CARD_VALUE.R_WA) then
			return false
		end
	end

	--判断是否同花
	local function sameColor( cards )
		-- body
		if next(cards) ~= nil then
			local color = cards[1].color
			for k,v in pairs(cards) do
			 	if color ~= v.color then --不同花色
			 		return false
			 	end
			end 
			return true
		else
			return false
		end
	end

	--判断是否是顺子
	local function detectionStraight( cardList )
		-- body
		table.sort( cardList, function (a,b)
			-- body
			return a.val > b.val 
		end )
		local cardClone = {}
		CloneTable(cardList,cardClone)
		
		if cardClone[1].val == tonumber(CARD_VALUE.R1) and  --A5432 -> 5432A
			cardClone[2].val == tonumber(CARD_VALUE.R5) and 
			cardClone[3].val == tonumber(CARD_VALUE.R4) and 
			cardClone[4].val == tonumber(CARD_VALUE.R3) and 
			cardClone[5].val == tonumber(CARD_VALUE.R2) then
			table.insert(cardClone,cardClone[1])
			table.remove(cardClone,1)
			CloneTable(cardClone,cardList)
			return true,0
		elseif cardClone[1].val - cardClone[5].val == 4 and cardClone[1].val < CARD_VALUE.R_WA then--65432 ---- AKQJ10
			return true,cardList[5].val
		end
		return false
	end

	if changeCardCount == 0 then
		--筛牌种 每个互不相等
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardList) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 5 then --剩下牌一定要相互不一样 排除重叠情况
			return false
		end

		local Straight,StraightVal = detectionStraight(cardList)
		if Straight then 
			if sameColor(cardList) then
				return true,CARD_TYPE.FLUSH_BOMB,StraightVal,cardList[1].color
			else
				return true,CARD_TYPE.COMMON_STRAIGHT,StraightVal
			end
		else
			return false
		end
	elseif changeCardCount == 1 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 4 then --剩下牌一定要相互不一样 排除重叠情况
			return false
		end

		local project = {}
		for val = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R1) do
			if val ~= cardClone[1].val and 
				val ~= cardClone[2].val and
				val ~= cardClone[3].val and
				val ~= cardClone[4].val then --不能重叠
				local Straight,StraightVal 
				local temp = {}
				CloneTable(cardClone,temp)
				local xNode = false
				if node[1].clone then
					xNode = node[1]:clone()
				else
					xNode = {}
					xNode.color = node[1].color
				end
				xNode.val = val
				xNode.replace = true
				table.insert(temp,xNode)
				Straight,StraightVal = detectionStraight(temp)
				if Straight then
					table.insert(project,{temp,StraightVal})
				end

				if #project >= 2 then --最多有两种解决方案
					break
				end
			end
		end

		--解决方案
		if next(project) then
			table.sort(project,function ( a,b )
				-- body
				return a[2] > b[2] 
			end)
			CloneTable(project[1][1],cardList)
			for k,v in pairs(cardList) do
				if v.replace then --替换值
					if bChange then
						node[1].isLaizi = v.val
					end
					TableReplace(cardList,k,node[1])
					break
				end
			end
			if sameColor(cardClone) then --同花顺
				return true,CARD_TYPE.FLUSH_BOMB,project[1][2],cardClone[1].color
			else
				return true,CARD_TYPE.COMMON_STRAIGHT,project[1][2]
			end
		else
			return false
		end
	elseif changeCardCount == 2 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 3 then --剩下牌一定要相互不一样 排除重叠情况
			return false
		end

		local project = {}
		for val1 = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R1) do
			for val2 = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R1) do
				if val1 ~= cardClone[1].val and 
					val1 ~= cardClone[2].val and
					val1 ~= cardClone[3].val and
					val2 ~= cardClone[1].val and
					val2 ~= cardClone[2].val and
					val2 ~= cardClone[3].val and
					val1 ~= val2 then --不能重叠
					local Straight,StraightVal 
					local temp = {}
					CloneTable(cardClone,temp)
					local xNode1 = false
					if node[1].clone then
						xNode1 = node[1]:clone()
					else
						xNode1 = {}
						xNode1.color = node[1].color
					end
					local xNode2 = false
					if node[2].clone then
						xNode2 = node[2]:clone()
					else
						xNode2 = {}
						xNode2.color = node[2].color
					end
					xNode1.val = val1
					xNode1.replace1 = true
					xNode2.val = val2
					xNode2.replace2 = true
					table.insert(temp,xNode1)
					table.insert(temp,xNode2)
					Straight,StraightVal = detectionStraight(temp)
					if Straight then
						table.insert(project,{temp,StraightVal})
					end

					if #project >=6 then --最多有六种解决方案
						break
					end
				end
			end
		end

		--解决方案
		if next(project) then
			table.sort(project,function ( a,b )
				-- body
				return a[2] > b[2] 
			end)
			CloneTable(project[1][1],cardList)
			for k,v in pairs(cardList) do
				if v.replace1 then 
					if bChange then
						node[1].isLaizi = v.val
					end
					TableReplace(cardList,k,node[1])
				elseif v.replace2 then --替换值
					if bChange then
						node[2].isLaizi = v.val
					end
					TableReplace(cardList,k,node[2])
				end
			end

			if sameColor(cardClone) then --同花顺
				return true,CARD_TYPE.FLUSH_BOMB,project[1][2],cardClone[1].color
			else
				return true,CARD_TYPE.COMMON_STRAIGHT,project[1][2]
			end
		else
			return false
		end
	end

	return false
end

--判断是否是钢板 AAA222 333444
function CardDetection.detectionPlate( cardList,changeCardCount,bChange)
	-- body
	local function detectionPlate( cardList )
		-- body
		table.sort( cardList, function (a,b)
			-- body
			if a.val > b.val then  --从大到小
				return true
			elseif a.val < b.val then  
				return false
			else
				return a.color < b.color --黑梅方红
			end
		end )

		local cardClone = {}
		CloneTable(cardList,cardClone)

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
		 	if #cardTable[1] == 3 and #cardTable[2] == 3 then 
		 		if cardTable[1][1].val == tonumber(CARD_VALUE.R1) and 
		 			cardTable[2][1].val == tonumber(CARD_VALUE.R2) then  --AAA222
		 			local allCardTable = {}
		 			for k,v in pairs(cardTable[2]) do
		 				table.insert(allCardTable,v)
		 			end

		 			for k,v in pairs(cardTable[1]) do
		 				table.insert(allCardTable,v)
		 			end
		 			CloneTable(allCardTable,cardList)
		 			return true,0
		 		elseif cardTable[1][1].val - cardTable[2][1].val == 1 then --333222
			 		return true,cardTable[2][1].val
		 		end
			end
		end

		return false
	end

	if changeCardCount == 0 then
		return detectionPlate(cardList)
	elseif changeCardCount == 1 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 2 then --剩下牌只能有两种
			return false
		end

		for k,v in pairs(cardTable) do
			local plate,plateVal 
			local temp = {}
			CloneTable(cardClone,temp)
			local xNode = false
			if node[1].clone then
				xNode = node[1]:clone()
			else
				xNode = {}
				xNode.color = node[1].color
			end
			xNode.val = v[1].val
			xNode.replace = true
			table.insert(temp,xNode)
			plate,plateVal = detectionPlate(temp)
			if plate then
				CloneTable(temp,cardList)
				for m,n in pairs(cardList) do
					if n.replace then --替换值
						if bChange then
							node[1].isLaizi = n.val
						end
						TableReplace(cardList,m,node[1])
						break
					end
				end

				return plate,plateVal
			end
		end
		return false
	elseif changeCardCount == 2 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 2 then --剩下牌只能有两种
			return false
		end

		local project = {}
		for k,v in pairs(cardTable) do
			for m,n in pairs(cardTable) do
				local plate,plateVal 
				local temp = {}
				CloneTable(cardClone,temp)
				local xNode1 = false
				if node[1].clone then
					xNode1 = node[1]:clone()
				else
					xNode1 = {}
					xNode1.color = node[1].color
				end
				local xNode2 = false
				if node[2].clone then
					xNode2 = node[2]:clone()
				else
					xNode2 = {}
					xNode2.color = node[2].color
				end
				xNode1.val = v[1].val
				xNode1.replace1 = true
				xNode2.val = n[1].val
				xNode2.replace2 = true
				table.insert(temp,xNode1)
				table.insert(temp,xNode2)
				plate,plateVal = detectionPlate(temp)
				if plate then
					CloneTable(temp,cardList)
					for x,y in pairs(cardList) do
						if y.replace1 then --替换值
							if bChange then
								node[1].isLaizi = y.val
							end
							TableReplace(cardList,x,node[1])
						elseif y.replace2 then
							if bChange then
								node[2].isLaizi = y.val
							end
							TableReplace(cardList,x,node[2])
						end
					end

					return plate,plateVal
				end
			end
		end
		return false
	end
end

--判断是否是连对 AA2233 223344
function CardDetection.detectionLinkDouble( cardList,changeCardCount,bChange )
	-- body
	local function detectionLinkDouble( cardList )
		-- body
		table.sort( cardList, function (a,b)
			-- body
			if a.val > b.val then
				return true
			elseif a.val < b.val then  --从大到小
				return false
			else
				return a.color < b.color --黑梅方红
			end
		end )

		local cardClone = {}
		CloneTable(cardList,cardClone)

		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end

		if #cardTable == 3 then--只有三种数
		 	if #cardTable[1] == 2 and #cardTable[2] == 2 and #cardTable[3] == 2 then 
		 		if cardTable[1][1].val == tonumber(CARD_VALUE.R1) and 
		 			cardTable[2][1].val == tonumber(CARD_VALUE.R3) and
		 			 cardTable[3][1].val == tonumber(CARD_VALUE.R2) then  --AA3322
		 			
			 		for k,v in pairs(cardTable[3]) do
			 			table.insert(cardClone,3,table.remove(cardClone))
			 		end
					CloneTable(cardClone,cardList)
			 		return true,0
		 		elseif cardTable[1][1].val - cardTable[2][1].val == 1 and
		 			cardTable[2][1].val - cardTable[3][1].val == 1 and cardTable[1][1].val < CARD_VALUE.R_WA then --443322 
			 		return true,cardTable[3][1].val
		 		end
			end
		end

		return false
	end

	if changeCardCount == 0 then
		return detectionLinkDouble(cardList)
	elseif changeCardCount == 1 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end
		if #cardTable ~= 3 then --剩下牌只能有三种
			return false
		end

		for k,v in pairs(cardTable) do
			local LinkDouble,LinkDoubleVal 
			local temp = {}
			CloneTable(cardClone,temp)
			local xNode = false
			if node[1].clone then
				xNode = node[1]:clone()
			else
				xNode = {}
				xNode.color = node[1].color
			end
			xNode.val = v[1].val
			xNode.replace = true
			table.insert(temp,xNode)
			LinkDouble,LinkDoubleVal = detectionLinkDouble(temp)
			if LinkDouble then
				CloneTable(temp,cardList)
				for m,n in pairs(cardList) do
					if n.replace then --替换值
						if bChange then
							node[1].isLaizi = n.val
						end
						TableReplace(cardList,m,node[1])
						break
					end
				end
				return LinkDouble,LinkDoubleVal
			end
		end
		return false
	elseif changeCardCount == 2 then
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end
		--再筛牌种
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end

		if #cardTable == 2 then
			local project = {}
			for val1 = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R1) do
				for val2 = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R1) do
					if val1 ~= cardClone[1].val and 
						val1 ~= cardClone[2].val and
						val2 ~= cardClone[1].val and
						val2 ~= cardClone[2].val and
						val1 == val2 then --必须重叠
						local LinkDouble,LinkDoubleVal 
						local temp = {}
						CloneTable(cardClone,temp)
						local xNode1 = false
						if node[1].clone then
							xNode1 = node[1]:clone()
						else
							xNode1 = {}
							xNode1.color = node[1].color
						end
						local xNode2 = false
						if node[2].clone then
							xNode2 = node[2]:clone()
						else
							xNode2 = {}
							xNode2.color = node[2].color
						end
						xNode1.val = val1
						xNode1.replace1 = true
						xNode2.val = val2
						xNode2.replace2 = true
						table.insert(temp,xNode1)
						table.insert(temp,xNode2)
						LinkDouble,LinkDoubleVal = detectionLinkDouble(temp)
						if LinkDouble then
							table.insert(project,{temp,LinkDoubleVal})
						end

						if #project >=2 then --最多有2种解决方案
							break
						end
					end
				end
			end

			--解决方案
			if next(project) then
				table.sort(project,function ( a,b )
					-- body
					return a[2] > b[2] 
				end)
				CloneTable(project[1][1],cardList)
				for k,v in pairs(cardList) do
					if v.replace1 then
						if bChange then
							node[1].isLaizi = v.val
						end
						TableReplace(cardList,k,node[1])
					elseif v.replace2 then
						if bChange then
							node[2].isLaizi = v.val
						end
						TableReplace(cardList,k,node[2])
					end
				end

				return true,project[1][2]
			else
				return false
			end
		elseif #cardTable == 3 then --2234
			local project = {}
			for k,v in pairs(cardTable) do
				for m,n in pairs(cardTable) do
					if v[1].val ~= n[1].val then
						local LinkDouble,LinkDoubleVal 
						local temp = {}
						CloneTable(cardClone,temp)
						local xNode1 = false
						if node[1].clone then
							xNode1 = node[1]:clone()
						else
							xNode1 = {}
							xNode1.color = node[1].color
						end
						local xNode2 = false
						if node[2].clone then
							xNode2 = node[2]:clone()
						else
							xNode2 = {}
							xNode2.color = node[2].color
						end
						xNode1.val = v[1].val
						xNode1.replace1 = true
						xNode2.val = n[1].val
						xNode2.replace2 = true
						table.insert(temp,xNode1)
						table.insert(temp,xNode2)
						LinkDouble,LinkDoubleVal = detectionLinkDouble(temp)
						if LinkDouble then
							CloneTable(temp,cardList)
							for x,y in pairs(cardList) do
								if y.replace1 then
									if bChange then
										node[1].isLaizi = y.val
									end
									TableReplace(cardList,x,node[1])
								elseif y.replace2 then
									if bChange then
										node[2].isLaizi = y.val
									end
									TableReplace(cardList,x,node[2])
								end
							end

							return LinkDouble,LinkDoubleVal
						end
					end
				end
			end
		end
		return false
	end
end

--判断是否是几炸
function CardDetection.detectionBomb( cardList,cardCount,changeCardCount,bChange)
	if changeCardCount == 0 then --没有可变牌
		local val = cardList[1].val
		local equal = true
		for k,v in pairs(cardList) do
			if val ~= v.val then
				equal = false
				break
			end
		end

		if equal then -- 全部相等 炸弹
			if cardCount == 4 then
				return CARD_TYPE.FOUR_BOMB,val
			elseif cardCount == 5 then
				return CARD_TYPE.FIVE_BOMB,val
			elseif cardCount == 6 then
				return CARD_TYPE.SIX_BOMB,val
			elseif cardCount == 7 then
				return CARD_TYPE.SEVEN_BOMB,val
			elseif cardCount == 8 then
				return CARD_TYPE.EIGHT_BOMB,val
			end
		end
	elseif changeCardCount == 1 then --有一张可变 排序后可变牌在最后 333332
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end

		--拆分N数据块
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end

		if #cardTable == 1 then
			if bChange then
				node[1].isLaizi = cardTable[1][1].val
			end

			table.insert(cardClone,node[1])
			CloneTable(cardClone,cardList)

			if cardCount == 4 then
				return CARD_TYPE.FOUR_BOMB,cardTable[1][1].val
			elseif cardCount == 5 then
				return CARD_TYPE.FIVE_BOMB,cardTable[1][1].val
			elseif cardCount == 6 then
				return CARD_TYPE.SIX_BOMB,cardTable[1][1].val
			elseif cardCount == 7 then
				return CARD_TYPE.SEVEN_BOMB,cardTable[1][1].val
			elseif cardCount == 8 then
				return CARD_TYPE.EIGHT_BOMB,cardTable[1][1].val
			elseif cardCount == 9 then
				return CARD_TYPE.NINE_BOMB,cardTable[1][1].val
			end
		end
	elseif changeCardCount == 2 then --有两张可变
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end

		--拆分N数据块
		local cardTable = {}
		local lastCard = false
		for k,v in pairs(cardClone) do
			if not lastCard or lastCard.val ~= v.val then 
				cardTable[#cardTable + 1] = {}
			end
			lastCard = v
			table.insert(cardTable[#cardTable],lastCard)
		end


		if #cardTable == 1 then 
			if cardTable[1][1].val >= tonumber(CARD_VALUE.R_WA) then --不能双王
		  		return CARD_TYPE.NONE
		  	else

			if bChange then
				node[1].isLaizi = cardTable[1][1].val
				node[2].isLaizi = cardTable[1][1].val
			end

			table.insert(cardClone,node[1])
			table.insert(cardClone,node[2])
			CloneTable(cardClone,cardList)

			if cardCount == 4 then
				return CARD_TYPE.FOUR_BOMB,cardTable[1][1].val
				elseif cardCount == 5 then
					return CARD_TYPE.FIVE_BOMB,cardTable[1][1].val
				elseif cardCount == 6 then
					return CARD_TYPE.SIX_BOMB,cardTable[1][1].val
				elseif cardCount == 7 then
					return CARD_TYPE.SEVEN_BOMB,cardTable[1][1].val
				elseif cardCount == 8 then
					return CARD_TYPE.EIGHT_BOMB,cardTable[1][1].val
				elseif cardCount == 9 then
					return CARD_TYPE.NINE_BOMB,cardTable[1][1].val
				elseif cardCount == 10 then
					return CARD_TYPE.TEN_BOMB,cardTable[1][1].val
				end
		  	end
		end
	end

	return CARD_TYPE.NONE
end

--带可变牌的对
function CardDetection.changeCardDouble( cardList,changeCardCount,bChange )
	-- body
	if changeCardCount == 1 then --有一张可变牌  X2
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end

		if cardClone[1].val ~= tonumber(CARD_VALUE.R_WA) and 
			cardClone[1].val ~= tonumber(CARD_VALUE.R_WB) then -- 可变牌不能变大小王

			if bChange then
				node[1].isLaizi = cardClone[1].val
			end
			table.insert(cardClone,node[1])
			CloneTable(cardClone,cardList)
			return CARD_TYPE.DOUBLE,cardClone[1].val 
		end
	else
		return CARD_TYPE.DOUBLE,cardList[1].val 
	end

	return CARD_TYPE.NONE
end

--带可变牌的三个
function CardDetection.changeCardTriple( cardList,changeCardCount,bChange )
	-- body
	if changeCardCount == 1 then --有一张可变牌  22X
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end

		if cardClone[1].val == cardClone[2].val and
			cardClone[1].val ~= tonumber(CARD_VALUE.R_WA) and
			cardClone[1].val ~= tonumber(CARD_VALUE.R_WB) and
			cardClone[2].val ~= tonumber(CARD_VALUE.R_WA) and
			cardClone[2].val ~= tonumber(CARD_VALUE.R_WB) then --不能三个王

			if bChange then
				node[1].isLaizi = cardClone[1].val
			end

			table.insert(cardClone,node[1])
			CloneTable(cardClone,cardList)
			return CARD_TYPE.TRIPLE,cardClone[1].val
		else
			return CARD_TYPE.NONE
		end
	elseif changeCardCount == 2 then --有两张可变牌  XX2
		local cardClone = {}
		CloneTable(cardList,cardClone)

		local node = {}
		for i = #cardClone,1,-1 do --先删除可变牌
			if CardDetection.detectionIsChangeCard(cardClone[i]) then
				local changeNode = table.remove(cardClone,i)
				table.insert(node,changeNode)
			end
		end

		if #cardClone == 1 and 
			cardClone[1].val ~= tonumber(CARD_VALUE.R_WA) and
			cardClone[1].val ~= tonumber(CARD_VALUE.R_WB) then -- 可变牌不能变大小王
			if bChange then
				node[1].isLaizi = cardClone[1].val
				node[2].isLaizi = cardClone[1].val
			end

			table.insert(cardClone,node[1])
			table.insert(cardClone,node[2])
			CloneTable(cardClone,cardList)
			return CARD_TYPE.TRIPLE,cardClone[1].val 
		else
			return CARD_TYPE.NONE
		end
	end
	return CARD_TYPE.NONE
end

return CardDetection
