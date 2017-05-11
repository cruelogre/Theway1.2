-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋牌型提示
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GameModel = require("WhippedEgg.Model.GameModel")
local CardDetection = require("WhippedEgg.CardDetection")
local CardTips = {}

--是否是可变牌
function CardTips.detectionIsChangeCard(node)
	-- body
	if node.val == GameModel.nowCardVal and node.color == tonumber(FOLLOW_TYPE.TYPE_H)  then
		return true
	end

	return false
end

--可变牌数量
function CardTips.detectionChangeCardCount(cardList)
	-- body
	local count = 0
	for k,v in pairs(cardList) do
		if CardTips.detectionIsChangeCard(v) then
			count = count + 1
		end
	end
	return count
end

--提示单个 A
function CardTips.tipSignle(effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	--安全判断 一般不会出现
	local Project = {}
	if #effectiveCards ~= #viewCard then
		return Project
	end

	--先从已有牌有效无效列中找满足条件的牌
	local ViewCardPro = CardTips.tipSignleViewCard( effectiveCards,viewCard,val )
	for k,v in pairs(ViewCardPro) do
		table.insert(Project,v)
	end
	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)
	if next(Project) == nil then 
		local allCardPro = CardTips.tipSignleAllCard( allCard,val )
		for k,v in pairs(allCardPro) do
			insertItemByDifVal(Project,v)
		end
	end

	return Project
end

--从显示表查找单个 A
function CardTips.tipSignleViewCard( effectiveCards,viewCard,val )
	-- body
	--先从已有牌有效无效列中找满足条件的牌
	local Project = {}
	for i=1,#viewCard do
		if effectiveCards[i] == tonumber(CARD_TYPE.SINGLE) then --单个
			if val then --存在具体值 
				if val == tonumber(CARD_VALUE.R_WB) then --大王 没得选
					break
				elseif val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
					if viewCard[i][1].val >= tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,viewCard[i])
					end
				else
					if viewCard[i][1].val > tonumber(val) then
						table.insert(Project,viewCard[i])
					elseif viewCard[i][1].val == GameModel.nowCardVal and
						val < tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,viewCard[i])
					end
				end
			else       --不存在具体值 我先发单
				table.insert(Project,viewCard[i])
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.NONE) then --无效 
			if val and val == tonumber(CARD_VALUE.R_WB) then --大王 没得选
				break
			end	
			--拆分
			local cardTable = {} 
			local lastCard = false
			for k,v in pairs(viewCard[i]) do
				if not lastCard or lastCard.val ~= v.val then 
					cardTable[#cardTable + 1] = {}
				end
				lastCard = v
				table.insert(cardTable[#cardTable],lastCard)
			end

			for k,v in pairs(cardTable) do
				if #v == 1 then 
					if val then --存在具体值 
						if val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
							if v[1].val >= tonumber(CARD_VALUE.R_WA) then
								table.insert(Project,v)
							end
						else
							if v[1].val > tonumber(val) then
								table.insert(Project,v)
							elseif v[1].val == GameModel.nowCardVal and
								val < tonumber(CARD_VALUE.R_WA) then
								table.insert(Project,v)
							end
						end
					else       --不存在具体值 我先发单
						table.insert(Project,v)
					end
				end
			end
		end
	end

	cardTipsProSort(Project)
	return Project
end

--从牌号库查找单个 A
function CardTips.tipSignleAllCard( allCard,val )
	-- body
	--牌号库及花色库中遍历等于该类型的级牌
	local Project = {}
	for k,v in pairs(allCard) do
		if #v > 0 then
			if val then --存在具体值 
				if val == tonumber(CARD_VALUE.R_WB) then --大王 没得选
					break
				elseif val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
					if v[1].val >= tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,{v[1]})
					end
				else
					if v[1].val > tonumber(val) then
						table.insert(Project,{v[1]})
					elseif v[1].val == GameModel.nowCardVal and
						val < tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,{v[1]})
					end
				end
			else       --不存在具体值 我先发单
				table.insert(Project,{v[1]})
			end
		end
	end

	cardTipsProSort(Project)
	return Project
end

--提示对子 22
function CardTips.tipDouble(effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	--安全判断 一般不会出现
	local Project = {}
	if #effectiveCards ~= #viewCard then
		return Project
	end

	--先从已有牌有效无效列中找满足条件的牌
	local ViewCardPro = CardTips.tipDoubleViewCard( effectiveCards,viewCard,val )
	for k,v in pairs(ViewCardPro) do
		table.insert(Project,v)
	end

	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	if next(Project) == nil then 
		--不用变牌 拿对子或者拆对子
		local allCardPro = CardTips.tipDoubleAllCard( allCard,val )
		for k,v in pairs(allCardPro) do
			insertItemByDifVal(Project,v)
		end

		--用一个可变牌
		--牌号库及花色库中遍历等于该类型的级牌
		local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
		if #changeCards >= 1 then
			local allCardProOneChange = CardTips.tipDoubleAllCardOneChange( allCard,val )
			for k,v in pairs(allCardProOneChange) do
				table.insert(Project,v)
			end
		end
	end

	return Project
end

--从显示表查找对子 22
function CardTips.tipDoubleViewCard( effectiveCards,viewCard,val )
	-- body
	local Project = {}
	if val and val == tonumber(CARD_VALUE.R_WB) then --大王 没得选
		return Project
	end

	for i=#viewCard,1,-1 do
		if effectiveCards[i] == tonumber(CARD_TYPE.DOUBLE) then --有效
			if val then --存在具体值 
				if val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
					if  viewCard[i][1].val >= tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,viewCard[i])
					end
				else
					if viewCard[i][1].val > tonumber(val) then
						table.insert(Project,viewCard[i])
					elseif viewCard[i][1].val == GameModel.nowCardVal and
						val < tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,viewCard[i])
					end
				end
			else       --不存在具体值 我先发对
				table.insert(Project,viewCard[i])
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.NONE) then --无效
			--拆分
			local cardTable = {} 
			local lastCard = false
			for k,v in pairs(viewCard[i]) do
				if not lastCard or lastCard.val ~= v.val then 
					cardTable[#cardTable + 1] = {}
				end
				lastCard = v
				table.insert(cardTable[#cardTable],lastCard)
			end

			for k,v in pairs(cardTable) do
				if #v == 2 then 
					if val then --存在具体值 
						if val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
							if v[1].val >= tonumber(CARD_VALUE.R_WA) then
								table.insert(Project,v)
							end
						else
							if v[1].val > tonumber(val) then
								table.insert(Project,v)
							elseif v[1].val == GameModel.nowCardVal and
								val < tonumber(CARD_VALUE.R_WA) then
								table.insert(Project,v)
							end
						end
					else       --不存在具体值 我先发单
						table.insert(Project,v)
					end
				end
			end
		end
	end

	cardTipsProSort(Project)
	return Project
end

--从牌号库查找对子 22
function CardTips.tipDoubleAllCard( allCard,val )
	-- body
	local Project = {}
	if val and val == tonumber(CARD_VALUE.R_WB) then --大王 没得选
		return Project
	end

	for k,v in pairs(allCard) do
		if #v > 1 then
			if val then --存在具体值 
				if val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
					if v[1].val >= tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,{v[1],v[2]})
					end
				else
					if v[1].val > tonumber(val) then
						table.insert(Project,{v[1],v[2]})
					elseif v[1].val == GameModel.nowCardVal and
						val < tonumber(CARD_VALUE.R_WA) then
						table.insert(Project,{v[1],v[2]})
					end
				end
			else       --不存在具体值 我先发单
				table.insert(Project,{v[1],v[2]})
			end
		end
	end

	cardTipsProSort(Project)
	return Project
end

--从牌号库查找的对子用一个可变牌 2X
function CardTips.tipDoubleAllCardOneChange( allCard,val )
	-- body
	local Project = {}
	if val and (val >= tonumber(CARD_VALUE.R_WA) or val == GameModel.nowCardVal) then --大王 没得选
		return Project
	end

	local cardClone = clone(allCard)
	local changeNode = {}
	for i=#cardClone[GameModel.nowCardVal],1,-1 do
		if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
			table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
		end
	end
	for k,v in pairs(cardClone) do
		if #v == 1 then
			if val then --存在具体值 
				if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then
					table.insert(Project,{v[1],changeNode[1]})
				elseif v[1].val == GameModel.nowCardVal then
					table.insert(Project,{v[1],changeNode[1]})
				end
			else       --不存在具体值
				if v[1].val < tonumber(CARD_VALUE.R_WA) then --不能变王 
					table.insert(Project,{v[1],changeNode[1]})
				end
			end
		end
	end
	cardTipsProSort(Project)

	return Project
end

--提示三张 222
function CardTips.tipTriple(effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	--安全判断 一般不会出现2211
	local Project = {}
	if #effectiveCards ~= #viewCard then
		return Project
	end

	--先从已有牌有效无效列中找满足条件的牌
	local viewCardPro = CardTips.tipTripleViewCard( effectiveCards,viewCard,val )
	for k,v in pairs(viewCardPro) do
		table.insert(Project,v)
	end

	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	if next(Project) == nil then 
		
		--不用变牌 拿三个子或者拆四个
		local allCardPro = CardTips.tipTripleAllCard( allCard,val )
		for k,v in pairs(allCardPro) do
			insertItemByDifVal(Project,v)
		end

		--牌号库及花色库中遍历等于该类型的级牌
		local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
		--用一个可变牌
		if #changeCards == 1 then
			local allCardProOneChange = CardTips.tipTripleAllCardOneChange( allCard,val )
			for k,v in pairs(allCardProOneChange) do
				table.insert(Project,v)
			end
		elseif #changeCards == 2 then
			local allCardProOneChange = CardTips.tipTripleAllCardOneChange( allCard,val )
			for k,v in pairs(allCardProOneChange) do
				table.insert(Project,v)
			end

			local allCardProTwoChange = CardTips.tipTripleAllCardTwoChange( allCard,val )
			for k,v in pairs(allCardProTwoChange) do
				table.insert(Project,v)
			end
		end
	end

	return Project
end

--显示表查找三个 222
function CardTips.tipTripleViewCard( effectiveCards,viewCard,val )
	-- body
	local Project = {}
	if val and val == GameModel.nowCardVal then --三个中当前打的牌最大
		return Project
	end

	for i=#viewCard,1,-1 do
		if effectiveCards[i] == tonumber(CARD_TYPE.TRIPLE) then --有效
			if val then --存在具体值 
				if viewCard[i][1].val > tonumber(val) or viewCard[i][1].val == GameModel.nowCardVal then
					table.insert(Project,viewCard[i])
				end
			else       --不存在具体值 我先发单
				table.insert(Project,viewCard[i])
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.NONE) then --无效 
			--拆分
			local cardTable = {} 
			local lastCard = false
			for k,v in pairs(viewCard[i]) do
				if not lastCard or lastCard.val ~= v.val then 
					cardTable[#cardTable + 1] = {}
				end
				lastCard = v
				table.insert(cardTable[#cardTable],lastCard)
			end

			for k,v in pairs(cardTable) do
				if val then --存在具体值 
					if #v == 3 then
						if v[1].val > tonumber(val) or v[1].val == GameModel.nowCardVal then
							table.insert(Project,v)
						end
					end
				else       --不存在具体值 我先发单
					if #v == 3 then
						table.insert(Project,v)
					end
				end
			end
		end
	end

	cardTipsProSort(Project)
	return Project
end

--从牌号库查找三个 222 可拆牌
function CardTips.tipTripleAllCard( allCard,val )
	-- body
	local Project = {}
	if val and val == GameModel.nowCardVal then --三个中当前打的牌最大
		return Project
	end

	for k,v in pairs(allCard) do
		if #v > 2 then
			if val then --存在具体值 
				if v[1].val > tonumber(val) or v[1].val == GameModel.nowCardVal then
					table.insert(Project,{v[1],v[2],v[3]})
				end
			else       --不存在具体值 我先发单
				table.insert(Project,{v[1],v[2],v[3]})
			end
		end
	end
	cardTipsProSort(Project)
	return Project
end

--从牌号库查找三个带个可变牌 22X
function CardTips.tipTripleAllCardOneChange( allCard,val )
	-- body
	local  Project = {}
	if val and val == GameModel.nowCardVal then --三个中当前打的牌最大
		return Project
	end

	local cardClone = clone(allCard)
	local changeNode = {}
	for i=#cardClone[GameModel.nowCardVal],1,-1 do
		if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
			table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
		end
	end

	for k,v in pairs(cardClone) do
		if #v == 2 then
			if val then --存在具体值 
				if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then
					table.insert(Project,{v[1],v[2],changeNode[1]})
				elseif v[1].val == GameModel.nowCardVal then
					table.insert(Project,{v[1],v[2],changeNode[1]})
				end
			else       --不存在具体值 
				if v[1].val < tonumber(CARD_VALUE.R_WA) then
					table.insert(Project,{v[1],v[2],changeNode[1]})
				end
			end
		end
	end
	cardTipsProSort(Project)
	return Project
end

--从牌号库查找三个带个可变牌 2XX
function CardTips.tipTripleAllCardTwoChange( allCard,val )
	-- body
	local  Project = {}
	if val and val == GameModel.nowCardVal then --三个中当前打的牌最大
		return Project
	end
	
	local cardClone = clone(allCard)
	local changeNode = {}
	for i=#cardClone[GameModel.nowCardVal],1,-1 do
		if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
			table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
		end
	end

	for k,v in pairs(cardClone) do
		if #v == 1 then
			if val then --存在具体值 
				if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then
					table.insert(Project,{v[1],changeNode[1],changeNode[2]})
				elseif v[1].val == GameModel.nowCardVal then
					table.insert(Project,{v[1],changeNode[1],changeNode[2]})
				end
			else       --不存在具体值 
				if v[1].val < tonumber(CARD_VALUE.R_WA) then
					table.insert(Project,{v[1],changeNode[1],changeNode[2]})
				end
			end
		end
	end
	cardTipsProSort(Project)

	return Project
end

--提示三带二
function CardTips.tipThreeAndTwo(effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	--安全判断 一般不会出现
	local Project = {}
	if #effectiveCards ~= #viewCard then
		return Project
	end

	--先从已有牌有效无效列中找满足条件的牌22233
	local viewCardPro = CardTips.tipThreeAndTwoViewCard( effectiveCards,viewCard,val )
	for k,v in pairs(viewCardPro) do
		table.insert(Project,v)
	end

	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	if next(Project) == nil then --前面都没找到
		--不用变牌 找三个或者拆
		local function ThreeAndTwoNoChangeCard( Project,allCard,val )
			-- body
			local cardClone = clone(allCard)
			local TripleAllCardPro = CardTips.tipTripleAllCard( cardClone,val )
			if #TripleAllCardPro > 0 then -- 找到三个才继续找对
				--在除了找到的三个值之外找两个
				for k,v in pairs(TripleAllCardPro) do
					cardClone[v[1].val] = {}
				end
				local DoubleAllCardPro = CardTips.tipDoubleAllCard( cardClone )
				if #TripleAllCardPro == 1 then
					if #DoubleAllCardPro > 0 then
						local cards = {}
						for k,v in pairs(TripleAllCardPro[1]) do --先放三个
							table.insert(cards,v)
						end
						for k,v in pairs(DoubleAllCardPro[1]) do --再放一对
							table.insert(cards,v)
						end

						insertItemByDifVal(Project,cards)
					end
				elseif #TripleAllCardPro > 1 then
					if #DoubleAllCardPro > 0 then
						for k,v in pairs(TripleAllCardPro) do --先放三个
							local cards = {}
							for m,n in pairs(v) do
								table.insert(cards,n)
							end
							for m,n in pairs(DoubleAllCardPro[1]) do --再放一对
								table.insert(cards,n)
							end
							insertItemByDifVal(Project,cards)
						end
					else
						for i=2,#TripleAllCardPro do --用三个中最小的凑对
							local cards = {}
							for m,n in pairs(TripleAllCardPro[i]) do
								table.insert(cards,n)
							end
							table.insert(cards,TripleAllCardPro[1][1])
							table.insert(cards,TripleAllCardPro[1][2])
							insertItemByDifVal(Project,cards)
						end
					end 
				end
			end
		end

		local function ThreeAndTwoOneChangeCard( Project,allCard,allColorCard,val ) --3332 3322
			-- body
			--3332
			local cardClone1 = clone(allCard)
			local changeNode = {}
			for i=#cardClone1[GameModel.nowCardVal],1,-1 do
				if CardTips.detectionIsChangeCard(cardClone1[GameModel.nowCardVal][i]) then
					table.insert(changeNode,table.remove(cardClone1[GameModel.nowCardVal],i))
				end
			end

			local TripleAllCardPro = CardTips.tipTripleAllCard( cardClone1,val )
			if #TripleAllCardPro > 0 then -- 找到三个才继续找对
				--在除了找到的三个值之外找两个
				for k,v in pairs(TripleAllCardPro) do
					cardClone1[v[1].val] = {}
				end
				local singelAllCardPro = {} --选择一个单个就行
				for k,v in pairs(cardClone1) do
					if #v == 1 and v[1].val < tonumber(CARD_VALUE.R_WA) then
						table.insert(singelAllCardPro,v[1])
						break
					end
				end

				if #singelAllCardPro > 0 then
					for k,v in pairs(TripleAllCardPro) do --先放三个
						local cards = {}
						for m,n in pairs(v) do
							table.insert(cards,n)
						end
						table.insert(cards,singelAllCardPro[1])
						table.insert(cards,changeNode[1])
						table.insert(Project,cards)
					end
				end 
			end

			--3322
			local cardClone2 = clone(allCard)
			local changeNode = {}
			for i=#cardClone2[GameModel.nowCardVal],1,-1 do
				if CardTips.detectionIsChangeCard(cardClone2[GameModel.nowCardVal][i]) then
					table.insert(changeNode,table.remove(cardClone2[GameModel.nowCardVal],i))
				end
			end

			local doubleAllCardPro = {}
			for k,v in pairs(cardClone2) do
				if #v == 2 then
					if val then --存在具体值 
						if val >= tonumber(CARD_VALUE.R_WA) then --大王 没得选
							break
						elseif val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
							break
						else
							if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then
								table.insert(doubleAllCardPro,v)
							end
						end
					else       --不存在具体值 我先发单
						if v[1].val < tonumber(CARD_VALUE.R_WA) then
							table.insert(doubleAllCardPro,v)
						end
					end
				end

				cardTipsProSort(doubleAllCardPro)
			end
			if #doubleAllCardPro > 0 then -- 找到三个才继续找对
				--在除了找到的三个值之外找两个
				for k,v in pairs(doubleAllCardPro) do
					cardClone2[v[1].val] = {}
				end
				local doubleAllCardPro2 = {} --选择一个2个就行
				for k,v in pairs(cardClone2) do
					if #v == 2 then
						table.insert(doubleAllCardPro2,v)
						break
					end
				end

				if #doubleAllCardPro2 > 0 then
					for k,v in pairs(doubleAllCardPro) do --先放三个
						local cards = {}
						for m,n in pairs(v) do
							table.insert(cards,n)
						end
						table.insert(cards,changeNode[1])

						for m,n in pairs(doubleAllCardPro2) do
							table.insert(cards,n[1])
							table.insert(cards,n[2])
						end
						table.insert(Project,cards)
					end
				else
					for i=2,#doubleAllCardPro do --用三个中最小的凑对
						local cards = {}
						for m,n in pairs(doubleAllCardPro[i]) do
							table.insert(cards,n)
						end
						table.insert(cards,changeNode[1])
						table.insert(cards,doubleAllCardPro[1][1])
						table.insert(cards,doubleAllCardPro[1][2])
						table.insert(Project,cards)
					end
				end 
			end
		end

		local function ThreeAndTwoTwoChangeCard( Project,allCard,allColorCard,val ) --322 332
			-- body
			--322
			local cardClone1 = clone(allCard)
			local changeNode = {}
			for i=#cardClone1[GameModel.nowCardVal],1,-1 do
				if CardTips.detectionIsChangeCard(cardClone1[GameModel.nowCardVal][i]) then
					table.insert(changeNode,table.remove(cardClone1[GameModel.nowCardVal],i))
				end
			end

			local singelAllCardPro = {} --选择一个单个就行
			for k,v in pairs(cardClone1) do
				if #v == 1 then
					if val then --存在具体值 
						if val >= tonumber(CARD_VALUE.R_WA) then --大王 没得选
							break
						elseif val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
							break
						else
							if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then --不能变王
								table.insert(singelAllCardPro,v)
							end
						end
					else       --不存在具体值 我先发单
						if v[1].val < tonumber(CARD_VALUE.R_WA) then 
							table.insert(singelAllCardPro,v)
						end
					end
				end

				cardTipsProSort(singelAllCardPro)
			end

			if #singelAllCardPro > 0 then -- 找到yi个才继续找对
				--在除了找到的三个值之外找两个
				for k,v in pairs(singelAllCardPro) do
					cardClone1[v[1].val] = {}
				end

				local doubleAllCardPro = {} --选择一个2个就行
				for k,v in pairs(cardClone1) do
					if #v == 2 then
						table.insert(doubleAllCardPro,v)
						break
					end
				end

				if #doubleAllCardPro > 0 then
					for k,v in pairs(singelAllCardPro) do --先放三个
						local cards = {}
						
						table.insert(cards,v[1])
						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])

						table.insert(cards,doubleAllCardPro[1][1])
						table.insert(cards,doubleAllCardPro[1][2])

						table.insert(Project,cards)
					end
				end
			end

			--332
			local cardClone2 = clone(allCard)
			local changeNode = {}
			for i=#cardClone2[GameModel.nowCardVal],1,-1 do
				if CardTips.detectionIsChangeCard(cardClone2[GameModel.nowCardVal][i]) then
					table.insert(changeNode,table.remove(cardClone2[GameModel.nowCardVal],i))
				end
			end
			local doubleAllCardPro = {}
			for k,v in pairs(cardClone2) do
				if #v == 2 then
					if val then --存在具体值 
						if val >= tonumber(CARD_VALUE.R_WA) then --大王 没得选
							break
						elseif val == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
							break
						else
							if v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then
								table.insert(doubleAllCardPro,v)
							end
						end
					else       --不存在具体值 我先发单
						if v[1].val < tonumber(CARD_VALUE.R_WA) then 
							table.insert(doubleAllCardPro,v)
						end
					end
				end
			end
			if #doubleAllCardPro > 0 then -- 找到三个才继续找对
				--在除了找到的三个值之外找两个
				for k,v in pairs(doubleAllCardPro) do
					cardClone2[v[1].val] = {}
				end
				local singelAllCardPro = {} --选择一个2个就行
				for k,v in pairs(cardClone1) do
					if #v == 1 and v[1].val < tonumber(CARD_VALUE.R_WA) then
						table.insert(singelAllCardPro,v)
						break
					end
				end

				if #singelAllCardPro > 0 then
					for k,v in pairs(doubleAllCardPro) do --先放三个
						local cards = {}
						for m,n in pairs(v) do
							table.insert(cards,n)
						end
						table.insert(cards,changeNode[1])

						table.insert(cards,singelAllCardPro[1][1])
						table.insert(cards,changeNode[2])
						
						table.insert(Project,cards)
					end
				end 
			end
		end
		

		--牌号库及花色库中遍历等于该类型的级牌
		local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
		if changeCards == 0 then
			ThreeAndTwoNoChangeCard(Project,allCard,val)
		elseif #changeCards == 1 then --3332 3322
			ThreeAndTwoNoChangeCard(Project,allCard,val)
			ThreeAndTwoOneChangeCard(Project,allCard,allColorCard,val)
		elseif #changeCards == 2 then
			ThreeAndTwoNoChangeCard(Project,allCard,val)
			ThreeAndTwoOneChangeCard(Project,allCard,allColorCard,val)
			ThreeAndTwoTwoChangeCard(Project,allCard,allColorCard,val)
		end
	end

	return Project
end

--显示表中找33322不拆不变
function CardTips.tipThreeAndTwoViewCard( effectiveCards,viewCard,val )
	-- body
	local Project = {}
	if val and val == GameModel.nowCardVal then --三个中当前打的牌最大
		return Project
	end

	--直接列中满足要求
	local TripleViewCardPro = {} --三个
	local DoubleViewCardPro = {}
	for i=#viewCard,1,-1 do
		if effectiveCards[i] == tonumber(CARD_TYPE.TRIPLE_AND_DOUBLE) then --有效
			if val then --存在具体值 
				if viewCard[i][1].val > tonumber(val) or viewCard[i][1].val == GameModel.nowCardVal then
					table.insert(Project,viewCard[i])
				end
			else       --不存在具体值 我先发单
				table.insert(Project,viewCard[i])
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.NONE) then --无效 
			--拆分
			local cardTable = {} 
			local lastCard = false
			for k,v in pairs(viewCard[i]) do
				if not lastCard or lastCard.val ~= v.val then 
					cardTable[#cardTable + 1] = {}
				end
				lastCard = v
				table.insert(cardTable[#cardTable],lastCard)
			end

			for k,v in pairs(cardTable) do
				if val then --存在具体值 
					if #v == 3 then
						if v[1].val > tonumber(val) or v[1].val == GameModel.nowCardVal then
							table.insert(TripleViewCardPro,v)
						end
					end

					if #v == 2 then
						table.insert(DoubleViewCardPro,v)
					end
				else       --不存在具体值 我随便发
					if #v == 3 then
						table.insert(TripleViewCardPro,v)
					end

					if #v == 2 then
						table.insert(DoubleViewCardPro,v)
					end
				end
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.TRIPLE) then --三个
			if val then --存在具体值 
				if viewCard[i][1].val > tonumber(val) or viewCard[i][1].val == GameModel.nowCardVal then
					table.insert(TripleViewCardPro,viewCard[i])
				end
			else       --不存在具体值 我随便发
				table.insert(TripleViewCardPro,viewCard[i])
			end
		elseif effectiveCards[i] == tonumber(CARD_TYPE.DOUBLE) then --两个
			table.insert(DoubleViewCardPro,viewCard[i])
		end
	end

	if #TripleViewCardPro > 0 and #DoubleViewCardPro > 0 then -- 找到三个才继续找对
		for k,v in pairs(TripleViewCardPro) do --先放三个
			local cards = {}
			for m,n in pairs(v) do
				table.insert(cards,n)
			end
			for m,n in pairs(DoubleViewCardPro[1]) do --再放一对
				table.insert(cards,n)
			end
			table.insert(Project,cards)
		end
	end

	cardTipsProSort(Project)
	return Project
end

--提示钢板 333444
function CardTips.tipPlate(  effectiveCards,viewCard,allCard,allColorCard,val  )
	-- body
	--安全判断 一般不会出现
	local Project = {}
	if #effectiveCards ~= #viewCard then
		return Project
	end

	--无可变牌
	local function findPlateNoChangeCard( effectiveCards,viewCard,allCard,val )
		-- body
		local Project = {}

		--直接列中满足要求
		for i=#viewCard,1,-1 do
			if effectiveCards[i] == tonumber(CARD_TYPE.PLATE) then --有效
				if val then --存在具体值 
					if viewCard[i][1].val > tonumber(val) then
						table.insert(Project,viewCard[i])
					end
				else       --不存在具体值 我先发单
					table.insert(Project,viewCard[i])
				end
			end
		end

		if val then --有值 222333-KKKAAA
			if val < tonumber(CARD_VALUE.RK) then
				for i=val+1,tonumber(CARD_VALUE.RK) do --val-K
					local card1 = allCard[i]
					local card2 = allCard[i+1]

					if #card1 >= 3 and #card2 >= 3 then
						local cards = {}
						for i=1,3 do
							table.insert(cards,card1[i])
						end
						
						for i=1,3 do
							table.insert(cards,card2[i])
						end

						insertItemByDifVal(Project,cards)
					end
				end
			end
		else--没值 提示 AAA222 - KKKAAA
			local card1 = allCard[tonumber(CARD_VALUE.R1)]
			local card2 = allCard[tonumber(CARD_VALUE.R2)]

			if #card1 >= 3 and #card2 >= 3 then
				local cards = {}
				for i=1,3 do
					table.insert(cards,card1[i])
				end
				
				for i=1,3 do
					table.insert(cards,card2[i])
				end

				insertItemByDifVal(Project,cards)
			end 

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RK) do --val-k
				local card1 = allCard[i]
				local card2 = allCard[i+1]

				if #card1 >= 3 and #card2 >= 3 then
					local cards = {}
					for i=1,3 do
						table.insert(cards,card1[i])
					end
					
					for i=1,3 do
						table.insert(cards,card2[i])
					end

					insertItemByDifVal(Project,cards)
				end
			end
		end

		return Project
	end

	--一张可变牌
	local function findPlateOneChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			local cards = cardClone[GameModel.nowCardVal]
			if CardTips.detectionIsChangeCard(cards[i]) then
				table.insert(changeNode,table.remove(cards,i))
			end
		end

		if val then --有值 222333 - KKKAAA
			if val < CARD_VALUE.RK then
				for i=val+1,tonumber(CARD_VALUE.RK) do --val-K
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]

					if #card1 == 2 and #card2 >= 3 then
						local cards = {}
						for k,v in pairs(card1) do
							table.insert(cards,v)
						end
						table.insert(cards,changeNode[1])

						for i=1,3 do
							table.insert(cards,card2[i])
						end

						table.insert(pro,cards)
					elseif #card1 >= 3 and #card2 == 2 then
						local cards = {}
						for i=1,3 do
							table.insert(cards,card1[i])
						end

						for k,v in pairs(card2) do
							table.insert(cards,v)
						end
						table.insert(cards,changeNode[1])

						table.insert(pro,cards)
					end
				end
			end
		else--没值 提示 AAA222 - KKKAAA
			local card1 = cardClone[tonumber(CARD_VALUE.R1)]
			local card2 = cardClone[tonumber(CARD_VALUE.R2)]

			if #card1 == 2 and #card2 >= 3 then
				local cards = {}
				for k,v in pairs(card1) do
					table.insert(cards,v)
				end
				table.insert(cards,changeNode[1])

				for i=1,3 do
					table.insert(cards,card2[i])
				end

				table.insert(pro,cards)
			elseif #card1 >= 3 and #card2 == 2 then
				local cards = {}
				for i=1,3 do
					table.insert(cards,card1[i])
				end

				for k,v in pairs(card2) do
					table.insert(cards,v)
				end
				table.insert(cards,changeNode[1])

				table.insert(pro,cards)
			end 

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RK) do --2-K
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]

				if #card1 == 2 and #card2 >= 3 then
					local cards = {}
					for k,v in pairs(card1) do
						table.insert(cards,v)
					end
					table.insert(cards,changeNode[1])

					for i=1,3 do
						table.insert(cards,card2[i])
					end

					table.insert(pro,cards)
				elseif #card1 >= 3 and #card2 == 2 then
					local cards = {}
					for i=1,3 do
						table.insert(cards,card1[i])
					end

					for k,v in pairs(card2) do
						table.insert(cards,v)
					end
					table.insert(cards,changeNode[1])

					table.insert(pro,cards)
				end 
			end
		end

		return pro
	end

	--两张可变牌
	local function findPlateTwoChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		if val then --有值 222333-KKKAAA
			if val < CARD_VALUE.RK then
				for i=val+1,tonumber(CARD_VALUE.RK) do --val-K
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]

					if #card1 == 1 and #card2 >= 3 then
						local cards = {}
						table.insert(cards,card1[1])
						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])
						for i=1,3 do
							table.insert(cards,card2[i])
						end
						
						table.insert(pro,cards)
					elseif #card1 >= 3 and #card2 == 1 then
						local cards = {}
						for i=1,3 do
							table.insert(cards,card1[i])
						end
						table.insert(cards,card2[1])
						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])
						
						table.insert(pro,cards)
					elseif #card1 == 2 and #card2 == 2 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end
						table.insert(cards,changeNode[1])
						for i=1,2 do
							table.insert(cards,card2[i])
						end
						table.insert(cards,changeNode[2])

						table.insert(pro,cards)
					end
				end
			end
		else--没值 提示 AAA222
			local card1 = cardClone[tonumber(CARD_VALUE.R1)]
			local card2 = cardClone[tonumber(CARD_VALUE.R2)]

			if #card1 == 1 and #card2 >= 3 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				for i=1,3 do
					table.insert(cards,card2[i])
				end
				
				table.insert(pro,cards)
			elseif #card1 >= 3 and #card2 == 1 then
				local cards = {}
				for i=1,3 do
					table.insert(cards,card1[i])
				end
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				
				table.insert(pro,cards)
			elseif #card1 == 2 and #card2 == 2 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				table.insert(cards,changeNode[1])
				for i=1,2 do
					table.insert(cards,card2[i])
				end
				table.insert(cards,changeNode[2])

				table.insert(pro,cards)
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RK) do --222333-KKKAAA
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]

				if #card1 == 1 and #card2 >= 3 then
					local cards = {}
					table.insert(cards,card1[1])
					table.insert(cards,changeNode[1])
					table.insert(cards,changeNode[2])
					for i=1,3 do
						table.insert(cards,card2[i])
					end
					
					table.insert(pro,cards)
				elseif #card1 >= 3 and #card2 == 1 then
					local cards = {}
					for i=1,3 do
						table.insert(cards,card1[i])
					end
					table.insert(cards,card2[1])
					table.insert(cards,changeNode[1])
					table.insert(cards,changeNode[2])
					
					table.insert(pro,cards)
				elseif #card1 == 2 and #card2 == 2 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					table.insert(cards,changeNode[1])
					for i=1,2 do
						table.insert(cards,card2[i])
					end
					table.insert(cards,changeNode[2])

					table.insert(pro,cards)
				end
			end
		end

		return pro
	end

	local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
	if #changeCards == 0 then
		local NoChangeCard = findPlateNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 1 then
		local NoChangeCard = findPlateNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end

		local OneChangeCard = findPlateOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 2 then
		local NoChangeCard = findPlateNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end

		local OneChangeCard = findPlateOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end

		local TwoChangeCard = findPlateTwoChangeCard(allCard,val)
		for k,v in pairs(TwoChangeCard) do
			table.insert(Project,v)
		end
	end

	--牌号库及花色库中遍历大于该类型的级牌(炸弹)
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--不变不拆有钢板
function CardTips.findPlateViewCard( effectiveCards,viewCard,allCard,val )
	-- body
	local Project = {}

	--直接列中满足要求
	for i=#viewCard,1,-1 do
		if effectiveCards[i] == tonumber(CARD_TYPE.PLATE) then --有效
			if val then --存在具体值 
				if viewCard[i][1].val > tonumber(val) then
					table.insert(Project,viewCard[i])
				end
			else       --不存在具体值 我先发单
				table.insert(Project,viewCard[i])
			end
		end
	end

	if val then --有值 222333-KKKAAA
		if val < tonumber(CARD_VALUE.RK) then
			for i=val+1,tonumber(CARD_VALUE.RK) do --val-K
				local card1 = allCard[i]
				local card2 = allCard[i+1]

				if #card1 == 3 and #card2 == 3 then
					local cards = {}
					for i=1,3 do
						table.insert(cards,card1[i])
					end
					
					for i=1,3 do
						table.insert(cards,card2[i])
					end

					insertItemByDifVal(Project,cards)
				end
			end
		end
	else--没值 提示 AAA222 - KKKAAA
		local card1 = allCard[tonumber(CARD_VALUE.R1)]
		local card2 = allCard[tonumber(CARD_VALUE.R2)]

		if #card1 == 3 and #card2 == 3 then
			local cards = {}
			for i=1,3 do
				table.insert(cards,card1[i])
			end
			
			for i=1,3 do
				table.insert(cards,card2[i])
			end

			insertItemByDifVal(Project,cards)
		end 

		for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RK) do --val-k
			local card1 = allCard[i]
			local card2 = allCard[i+1]

			if #card1 == 3 and #card2 == 3 then
				local cards = {}
				for i=1,3 do
					table.insert(cards,card1[i])
				end
				
				for i=1,3 do
					table.insert(cards,card2[i])
				end

				insertItemByDifVal(Project,cards)
			end
		end
	end

	return Project
end

--提示连对
function CardTips.tipLinkDouble( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local  Project = {}

	--不需要可变牌
	local function findLinkDoubleNoChangeCard( effectiveCards,viewCard,allCard,val )
		-- body
		local Project = {}

		--直接列中满足要求
		for i=#viewCard,1,-1 do
			if effectiveCards[i] == tonumber(CARD_TYPE.LINK_DOUBLE) then --有效
				if val then --存在具体值 
					if viewCard[i][1].val > tonumber(val) then
						table.insert(Project,viewCard[i])
					end
				else       --不存在具体值 我先发单
					table.insert(Project,viewCard[i])
				end
			end
		end

		if val then --有值 223344-QQKKAA
			if val < tonumber(CARD_VALUE.RQ) then
				for i=val+1,tonumber(CARD_VALUE.RQ) do --val-Q
					local card1 = allCard[i]
					local card2 = allCard[i+1]
					local card3 = allCard[i+2]

					if #card1 >= 2 and #card2 >= 2 and #card3 >= 2 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end
						
						for i=1,2 do
							table.insert(cards,card2[i])
						end

						for i=1,2 do
							table.insert(cards,card3[i])
						end

						insertItemByDifVal(Project,cards)
					end
				end
			end
		else--没值 提示 AA22233 - QQKKAA
			local card1 = allCard[tonumber(CARD_VALUE.R1)]
			local card2 = allCard[tonumber(CARD_VALUE.R2)]
			local card3 = allCard[tonumber(CARD_VALUE.R3)]

			if #card1 >= 2 and #card2 >= 2 and #card3 >= 2 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				
				for i=1,2 do
					table.insert(cards,card2[i])
				end

				for i=1,2 do
					table.insert(cards,card3[i])
				end

				insertItemByDifVal(Project,cards)
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RQ) do --val-k
				local card1 = allCard[i]
				local card2 = allCard[i+1]
				local card3 = allCard[i+2]

				if #card1 >= 2 and #card2 >= 2 and #card3 >= 2 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					
					for i=1,2 do
						table.insert(cards,card2[i])
					end

					for i=1,2 do
						table.insert(cards,card3[i])
					end

					insertItemByDifVal(Project,cards)
				end
			end
		end

		return Project
	end

	--一张可变牌
	local function findLinkDoubleOneChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			local cards = cardClone[GameModel.nowCardVal]
			if CardTips.detectionIsChangeCard(cards[i]) then
				table.insert(changeNode,table.remove(cards,i))
			end
		end

		if val then --有值 Val - QQKKAA
			if val < CARD_VALUE.RQ then
				for i=val+1,tonumber(CARD_VALUE.RQ) do --val-Q
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]
					local card3 = cardClone[i+2]

					if #card1 == 1 and #card2 >= 2 and #card3 >= 2 then
						local cards = {}
						
						table.insert(cards,card1[1])
						table.insert(cards,changeNode[1])

						for i=1,2 do
							table.insert(cards,card2[i])
						end
						for i=1,2 do
							table.insert(cards,card3[i])
						end

						table.insert(pro,cards)
					elseif #card1 >= 2 and #card2 == 1 and #card3 >= 2 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end

						table.insert(cards,card2[1])
						table.insert(cards,changeNode[1])

						for i=1,2 do
							table.insert(cards,card3[i])
						end

						table.insert(pro,cards)
					elseif #card1 >= 2 and #card2 >= 2 and #card3 == 1 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end
						for i=1,2 do
							table.insert(cards,card2[i])
						end
						table.insert(cards,card3[1])
						table.insert(cards,changeNode[1])

						table.insert(pro,cards)
					end
				end
			end
		else--没值 提示 AA2233 - QQKKAA
			local card1 = cardClone[tonumber(CARD_VALUE.R1)]
			local card2 = cardClone[tonumber(CARD_VALUE.R2)]
			local card3 = cardClone[tonumber(CARD_VALUE.R3)]

			if #card1 == 1 and #card2 >= 2 and #card3 >= 2 then
				local cards = {}
				
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])

				for i=1,2 do
					table.insert(cards,card2[i])
				end
				for i=1,2 do
					table.insert(cards,card3[i])
				end

				table.insert(pro,cards)
			elseif #card1 >= 2 and #card2 == 1 and #card3 >= 2 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end

				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])

				for i=1,2 do
					table.insert(cards,card3[i])
				end

				table.insert(pro,cards)
			elseif #card1 >= 2 and #card2 >= 2 and #card3 == 1 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				for i=1,2 do
					table.insert(cards,card2[i])
				end
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[1])

				table.insert(pro,cards)
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RQ) do --2-Q
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]
				local card3 = cardClone[i+2]

				if #card1 == 1 and #card2 >= 2 and #card3 >= 2 then
					local cards = {}
					
					table.insert(cards,card1[1])
					table.insert(cards,changeNode[1])

					for i=1,2 do
						table.insert(cards,card2[i])
					end
					for i=1,2 do
						table.insert(cards,card3[i])
					end

					table.insert(pro,cards)
				elseif #card1 >= 2 and #card2 == 1 and #card3 >= 2 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end

					table.insert(cards,card2[1])
					table.insert(cards,changeNode[1])

					for i=1,2 do
						table.insert(cards,card3[i])
					end

					table.insert(pro,cards)
				elseif #card1 >= 2 and #card2 >= 2 and #card3 == 1 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					for i=1,2 do
						table.insert(cards,card2[i])
					end
					table.insert(cards,card3[1])
					table.insert(cards,changeNode[1])

					table.insert(pro,cards)
				end
			end
		end

		return pro
	end

	--两张可变牌
	local function findLinkDoubleTwoChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		if val then --有值 222333-QQKKAA
			if val < CARD_VALUE.RQ then
				for i=val+1,tonumber(CARD_VALUE.RQ) do --val-Q
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]
					local card3 = cardClone[i+2]

					if #card2 == 0 and #card2 >= 2 and #card3 >= 2 then
						local cards = {}
						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])
						for i=1,2 do
							table.insert(cards,card2[i])
						end
						for i=1,2 do
							table.insert(cards,card3[i])
						end
						
						table.insert(pro,cards)
					elseif #card1 >= 2 and #card2 == 0 and #card3 >= 2 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end
						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])

						for i=1,2 do
							table.insert(cards,card3[i])
						end
						
						table.insert(pro,cards)
					elseif #card1 >= 2 and #card2 >= 2 and #card3 == 0 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end

						for i=1,2 do
							table.insert(cards,card2[i])
						end

						table.insert(cards,changeNode[1])
						table.insert(cards,changeNode[2])

						table.insert(pro,cards)
					elseif #card1 == 1 and #card2 == 1 and #card3 >= 2 then
						local cards = {}
						table.insert(cards,card1[1])
						table.insert(cards,changeNode[1])
						table.insert(cards,card2[1])
						table.insert(cards,changeNode[2])

						for i=1,2 do
							table.insert(cards,card3[i])
						end
						table.insert(pro,cards)
					elseif #card1 == 1 and #card2 >= 2 and #card3 == 1 then
						local cards = {}
						table.insert(cards,card1[1])
						table.insert(cards,changeNode[1])
						for i=1,2 do
							table.insert(cards,card2[i])
						end
						table.insert(cards,card3[1])
						table.insert(cards,changeNode[2])
						table.insert(pro,cards)
					elseif #card1 >= 2 and #card2 == 1 and #card3 == 1 then
						local cards = {}
						for i=1,2 do
							table.insert(cards,card1[i])
						end
						table.insert(cards,card2[1])
						table.insert(cards,changeNode[1])
						
						table.insert(cards,card3[1])
						table.insert(cards,changeNode[2])
						
						table.insert(pro,cards)
					end
				end
			end
		else--没值 提示 AAA222
			local card1 = cardClone[tonumber(CARD_VALUE.R1)]
			local card2 = cardClone[tonumber(CARD_VALUE.R2)]
			local card3 = cardClone[tonumber(CARD_VALUE.R3)]

			if #card2 == 0 and #card2 >= 2 and #card3 >= 2 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				for i=1,2 do
					table.insert(cards,card2[i])
				end
				for i=1,2 do
					table.insert(cards,card3[i])
				end
				
				table.insert(pro,cards)
			elseif #card1 >= 2 and #card2 == 0 and #card3 >= 2 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])

				for i=1,2 do
					table.insert(cards,card3[i])
				end
				
				table.insert(pro,cards)
			elseif #card1 >= 2 and #card2 >= 2 and #card3 == 0 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end

				for i=1,2 do
					table.insert(cards,card2[i])
				end

				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])

				table.insert(pro,cards)
			elseif #card1 == 1 and #card2 == 1 and #card3 >= 2 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[2])

				for i=1,2 do
					table.insert(cards,card3[i])
				end
				table.insert(pro,cards)
			elseif #card1 == 1 and #card2 >= 2 and #card3 == 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				for i=1,2 do
					table.insert(cards,card2[i])
				end
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])

				table.insert(pro,cards)
			elseif #card1 >= 2 and #card2 == 1 and #card3 == 1 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])
				
				table.insert(pro,cards)
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RQ) do --223344-QQKKAA
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]
				local card3 = cardClone[i+2]

				if #card2 == 0 and #card2 >= 2 and #card3 >= 2 then
					local cards = {}
					table.insert(cards,changeNode[1])
					table.insert(cards,changeNode[2])
					for i=1,2 do
						table.insert(cards,card2[i])
					end
					for i=1,2 do
						table.insert(cards,card3[i])
					end
					
					table.insert(pro,cards)
				elseif #card1 >= 2 and #card2 == 0 and #card3 >= 2 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					table.insert(cards,changeNode[1])
					table.insert(cards,changeNode[2])

					for i=1,2 do
						table.insert(cards,card3[i])
					end
					
					table.insert(pro,cards)
				elseif #card1 >= 2 and #card2 >= 2 and #card3 == 0 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end

					for i=1,2 do
						table.insert(cards,card2[i])
					end

					table.insert(cards,changeNode[1])
					table.insert(cards,changeNode[2])

					table.insert(pro,cards)
				elseif #card1 == 1 and #card2 == 1 and #card3 >= 2 then
					local cards = {}
					table.insert(cards,card1[1])
					table.insert(cards,changeNode[1])
					table.insert(cards,card2[1])
					table.insert(cards,changeNode[2])

					for i=1,2 do
						table.insert(cards,card3[i])
					end
					table.insert(pro,cards)
				elseif #card1 == 1 and #card2 >= 2 and #card3 == 1 then
					local cards = {}
					table.insert(cards,card1[1])
					table.insert(cards,changeNode[1])
					for i=1,2 do
						table.insert(cards,card2[i])
					end
					table.insert(cards,card3[1])
					table.insert(cards,changeNode[2])

					table.insert(pro,cards)
				elseif #card1 >= 2 and #card2 == 1 and #card3 == 1 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					table.insert(cards,card2[1])
					table.insert(cards,changeNode[1])
					
					table.insert(cards,card3[1])
					table.insert(cards,changeNode[2])
					
					table.insert(pro,cards)
				end
			end
		end

		return pro
	end

	local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
	if #changeCards == 0 then
		local NoChangeCard = findLinkDoubleNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 1 then
		local NoChangeCard = findLinkDoubleNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end

		local OneChangeCard = findLinkDoubleOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 2 then
		local NoChangeCard = findLinkDoubleNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end

		local OneChangeCard = findLinkDoubleOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end

		local TwoChangeCard = findLinkDoubleTwoChangeCard(allCard,val)
		for k,v in pairs(TwoChangeCard) do
			table.insert(Project,v)
		end
	end

	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--不拆不变有连对
function CardTips.findLinkDoubleViewCard( effectiveCards,viewCard,allCard,val )
	-- body
	local Project = {}

	--直接列中满足要求
	for i=#viewCard,1,-1 do
		if effectiveCards[i] == tonumber(CARD_TYPE.LINK_DOUBLE) then --有效
			if val then --存在具体值 
				if viewCard[i][1].val > tonumber(val) then
					table.insert(Project,viewCard[i])
				end
			else       --不存在具体值 我先发单
				table.insert(Project,viewCard[i])
			end
		end
	end

	if val then --有值 223344-QQKKAA
		if val < tonumber(CARD_VALUE.RQ) then
			for i=val+1,tonumber(CARD_VALUE.RQ) do --val-Q
				local card1 = allCard[i]
				local card2 = allCard[i+1]
				local card3 = allCard[i+2]

				if #card1 == 2 and #card2 == 2 and #card3 == 2 then
					local cards = {}
					for i=1,2 do
						table.insert(cards,card1[i])
					end
					
					for i=1,2 do
						table.insert(cards,card2[i])
					end

					for i=1,2 do
						table.insert(cards,card3[i])
					end

					insertItemByDifVal(Project,cards)
				end
			end
		end
	else--没值 提示 AA22233 - QQKKAA
		local card1 = allCard[tonumber(CARD_VALUE.R1)]
		local card2 = allCard[tonumber(CARD_VALUE.R2)]
		local card3 = allCard[tonumber(CARD_VALUE.R3)]

		if #card1 == 2 and #card2 == 2 and #card3 == 2 then
			local cards = {}
			for i=1,2 do
				table.insert(cards,card1[i])
			end
			
			for i=1,2 do
				table.insert(cards,card2[i])
			end

			for i=1,2 do
				table.insert(cards,card3[i])
			end

			insertItemByDifVal(Project,cards)
		end

		for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.RQ) do --val-k
			local card1 = allCard[i]
			local card2 = allCard[i+1]
			local card3 = allCard[i+2]

			if #card1 == 2 and #card2 == 2 and #card3 == 2 then
				local cards = {}
				for i=1,2 do
					table.insert(cards,card1[i])
				end
				
				for i=1,2 do
					table.insert(cards,card2[i])
				end

				for i=1,2 do
					table.insert(cards,card3[i])
				end

				insertItemByDifVal(Project,cards)
			end
		end
	end

	return Project
end

--提示四炸
function CardTips.tip4Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local fourBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,4,val)
	for k,v in pairs(fourBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanTwoLevel( Project,effectiveCards,viewCard,allCard, allColorCard)

	return Project
end

--提示五炸
function CardTips.tip5Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local fiveBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,5,val)
	for k,v in pairs(fiveBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanThreeLevel( Project,effectiveCards,viewCard,allCard, allColorCard)

	return Project
end

--提示六炸
function CardTips.tip6Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local sixBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,6,val)
	for k,v in pairs(sixBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanFiveLevel( Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--提示七炸
function CardTips.tip7Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanSixLevel( Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--提示八炸
function CardTips.tip8Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanSevenLevel( Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--提示九炸
function CardTips.tip9Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanEightLevel( Project,effectiveCards,viewCard,allCard,allColorCard )

	return Project
end

--提示十炸
function CardTips.tip10Bomb( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local Project = {}
	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	CardTips.greaterThanNineLevel( Project,allCard)

	return Project
end

--大于一级
function CardTips.greaterThanOneLevel( Project,effectiveCards,viewCard,allCard, allColorCard,val)
	-- body
	local fourBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,4,val)
	for k,v in pairs(fourBomb) do
		table.insert(Project,v)
	end
	local fiveBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,5,val)
	for k,v in pairs(fiveBomb) do
		table.insert(Project,v)
	end

	local colorBomb = CardTips.tipColorBomb(effectiveCards,viewCard,allCard,allColorCard,val,true)
	for k,v in pairs(colorBomb) do
		table.insert(Project,v)
	end

	local sixBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,6,val)
	for k,v in pairs(sixBomb) do
		table.insert(Project,v)
	end

	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于二级
function CardTips.greaterThanTwoLevel( Project,effectiveCards,viewCard,allCard, allColorCard,val)
	-- body
	local fiveBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,5,val)
	for k,v in pairs(fiveBomb) do
		table.insert(Project,v)
	end

	local colorBomb = CardTips.tipColorBomb(effectiveCards,viewCard,allCard,allColorCard,val,true)
	for k,v in pairs(colorBomb) do
		table.insert(Project,v)
	end

	local sixBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,6,val)
	for k,v in pairs(sixBomb) do
		table.insert(Project,v)
	end

	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于三级
function CardTips.greaterThanThreeLevel( Project,effectiveCards,viewCard,allCard, allColorCard,val)
	-- body
	local colorBomb = CardTips.tipColorBomb(effectiveCards,viewCard,allCard,allColorCard,val,true)
	for k,v in pairs(colorBomb) do
		table.insert(Project,v)
	end

	local sixBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,6,val)
	for k,v in pairs(sixBomb) do
		table.insert(Project,v)
	end

	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于四级
function CardTips.greaterThanFourLevel( Project,effectiveCards,viewCard,allCard,allColorCard,val)
	-- body
	local sixBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,6,val)
	for k,v in pairs(sixBomb) do
		table.insert(Project,v)
	end

	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于五级
function CardTips.greaterThanFiveLevel( Project,effectiveCards,viewCard,allCard, allColorCard,val)
	-- body
	local sevenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,7,val)
	for k,v in pairs(sevenBomb) do
		table.insert(Project,v)
	end

	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于六级
function CardTips.greaterThanSixLevel( Project,effectiveCards,viewCard,allCard,allColorCard,val)
	-- body
	local eightBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,8,val)
	for k,v in pairs(eightBomb) do
		table.insert(Project,v)
	end

	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于七级
function CardTips.greaterThanSevenLevel(Project,effectiveCards,viewCard,allCard,allColorCard,val)
	-- body
	local nineBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,9,val)
	for k,v in pairs(nineBomb) do
		table.insert(Project,v)
	end

	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于八级
function CardTips.greaterThanEightLevel( Project,effectiveCards,viewCard,allCard,allColorCard,val)
	-- body
	local tenBomb = CardTips.tipNBomb(effectiveCards,viewCard,allCard,allColorCard,10,val)
	for k,v in pairs(tenBomb) do
		table.insert(Project,v)
	end

	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--大于九级
function CardTips.greaterThanNineLevel( Project,allCard)
	-- body
	local kingBomb = CardTips.tipKingBomb(allCard)
	for k,v in pairs(kingBomb) do
		table.insert(Project,v)
	end
end

--N炸
function CardTips.tipNBomb( effectiveCards,viewCard,allCard,allColorCard,n,val )
	-- body
	local Project = {}
	local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]

	--先不要可变牌
	local function tipNBombNoChangeCard( Project,effectiveCards,viewCard,allCard,n,val )
		-- body
		--直接列中满足要求
		local typeBomb = CARD_TYPE.NONE
		if n == 4 then
			typeBomb = CARD_TYPE.FOUR_BOMB
		elseif n == 5 then
			typeBomb = CARD_TYPE.FIVE_BOMB
		elseif n == 6 then
			typeBomb = CARD_TYPE.SIX_BOMB
		elseif n == 7 then
			typeBomb = CARD_TYPE.SEVEN_BOMB
		elseif n == 8 then
			typeBomb = CARD_TYPE.EIGHT_BOMB
		elseif n == 9 then
			typeBomb = CARD_TYPE.NINE_BOMB
		elseif n == 10 then
			typeBomb = CARD_TYPE.TEN_BOMB
		end

		for i=#viewCard,1,-1 do
			if effectiveCards[i] == tonumber(typeBomb) then --有效
				if val then --存在具体值 
					if val == GameModel.nowCardVal then --本次打的牌
						break
					elseif viewCard[i][1].val > val then
						table.insert(Project,viewCard[i])
					elseif viewCard[i][1].val == GameModel.nowCardVal then
						table.insert(Project,viewCard[i])
					end
				else       --不存在具体值 我先发单
					table.insert(Project,viewCard[i])
				end
			end
		end

		for k,v in pairs(allCard) do
			if #v == n then
				if val then --存在具体值 
					if val == GameModel.nowCardVal then --本次打的牌
						break
					elseif v[1].val > tonumber(val) then
						insertItemByDifVal(Project,v)
					elseif v[1].val == GameModel.nowCardVal then
						insertItemByDifVal(Project,v)
					end
				else       --不存在具体值 我先发
					insertItemByDifVal(Project,v)
				end
			end
		end

		cardTipsProSort(Project)
	end
	
	--有一张可变牌
	local function tipNBombOneChangeCard( Project,allCard,n,val )
		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		for k,v in pairs(cardClone) do
			if #v == n-1 then
				if val then --存在具体值 
					if val == GameModel.nowCardVal then --本次打的牌
						break
					elseif v[1].val > tonumber(val) then
						local cards = {}
						for x,y in pairs(v) do
							table.insert(cards,y)
						end
						table.insert(cards,changeCards[1])
						table.insert(Project,cards)
					end
				else       --不存在具体值 我先发
					if v[1].val ~= GameModel.nowCardVal then 
						local cards = {}
						for x,y in pairs(v) do
							table.insert(cards,y)
						end
						table.insert(cards,changeCards[1])
						table.insert(Project,cards)
					end
				end
			end
		end
	end

	--有两张可变牌
	local function tipNBombTwoChangeCard( Project,allCard,n,val )
		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		for k,v in pairs(cardClone) do
			if #v == n-2 then
				if val then --存在具体值 
					if val == GameModel.nowCardVal then --本次打的牌
						break
					elseif v[1].val > tonumber(val) and v[1].val < tonumber(CARD_VALUE.R_WA) then --不能变王
						local cards = {}
						for x,y in pairs(v) do
							table.insert(cards,y)
						end
						table.insert(cards,changeCards[1])
						table.insert(cards,changeCards[2])
						table.insert(Project,cards)
					end
				else       --不存在具体值 我先发单
					if #v == 2 then
						if v[1].val < tonumber(CARD_VALUE.R_WA) and 
							v[1].val ~= GameModel.nowCardVal then --不能变王 
							local cards = {}
							for x,y in pairs(v) do
								table.insert(cards,y)
							end
							table.insert(cards,changeCards[1])
							table.insert(cards,changeCards[2])
							table.insert(Project,cards)
						end
					elseif v[1].val ~= GameModel.nowCardVal then
						local cards = {}
						for x,y in pairs(v) do
							table.insert(cards,y)
						end
						table.insert(cards,changeCards[1])
						table.insert(cards,changeCards[2])
						table.insert(Project,cards)
					end
				end
			end
		end
	end

	if #changeCards == 0 then
		tipNBombNoChangeCard( Project,effectiveCards,viewCard,allCard,n,val )
	elseif #changeCards == 1 then
		tipNBombNoChangeCard( Project,effectiveCards,viewCard,allCard,n,val )
		tipNBombOneChangeCard( Project,allCard,n,val )
	elseif #changeCards == 2 then
		tipNBombNoChangeCard( Project,effectiveCards,viewCard,allCard,n,val )
		tipNBombOneChangeCard( Project,allCard,n,val )
		tipNBombTwoChangeCard( Project,allCard,n,val )

	end
	return Project
end

--同花顺
function CardTips.tipColorBomb( effectiveCards,viewCard,allCard,allColorCard,val,bTips )
	-- body
	local  Project = {}
	--不需要可变牌
	local function findColorBombNoChangeCard( effectiveCards,viewCard,allColorCard,val )
		-- body
		local pro = {}
		--直接列中满足要求
		for i = #viewCard,1,-1 do
			if effectiveCards[i] == tonumber(CARD_TYPE.FLUSH_BOMB) then --有效
				if val then --存在具体值 
					if viewCard[i][1].val > tonumber(val) then
						table.insert(pro,viewCard[i])
					end
				else       --不存在具体值 我先发单
					table.insert(pro,viewCard[i])
				end
			end
		end

		local function NoChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 >= 1 and #card2 >= 1 and #card3 >= 1 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			end
		end
		if not val or val == 0  then --没值 提示 A2345 - 10JQKA
			for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
				local card1 = allColorCard[tonumber(CARD_VALUE.R1)][k]
				local card2 = allColorCard[tonumber(CARD_VALUE.R2)][k]
				local card3 = allColorCard[tonumber(CARD_VALUE.R3)][k]
				local card4 = allColorCard[tonumber(CARD_VALUE.R4)][k]
				local card5 = allColorCard[tonumber(CARD_VALUE.R5)][k]

				NoChangeCard(card1,card2,card3,card4,card5)
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
					local card1 = allColorCard[i][k]
					local card2 = allColorCard[i+1][k]
					local card3 = allColorCard[i+2][k]
					local card4 = allColorCard[i+3][k]
					local card5 = allColorCard[i+4][k]

					NoChangeCard(card1,card2,card3,card4,card5)
				end
			end
		else --有值 23456-10JQKA
			if val < tonumber(CARD_VALUE.R10) then
				for i=val+1,tonumber(CARD_VALUE.R10) do --val-10
					for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
						local card1 = allColorCard[i][k]
						local card2 = allColorCard[i+1][k]
						local card3 = allColorCard[i+2][k]
						local card4 = allColorCard[i+3][k]
						local card5 = allColorCard[i+4][k]

						NoChangeCard(card1,card2,card3,card4,card5)
					end
				end
			end
		end

		return pro
	end

	--一张可变牌
	local function findColorBombOneChangeCard( allColorCard,val )
		-- body
		local pro = {}
		local cardClone = clone(allColorCard)
		local changeNode = {}
		table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]))

		local function OneChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 == 0 and #card2 >= 1 and #card3 >= 1 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 == 0 and #card3 >= 1 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 == 0 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 >= 1 and #card4 == 0 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 >= 1 and #card4 >= 1 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[1])

				insertItemByDifVal(pro,cards)
			end
		end

		if not val or val == 0 then --没值 提示 A2345 - 10JQKA
			for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
				local card1 = cardClone[tonumber(CARD_VALUE.R1)][k]
				local card2 = cardClone[tonumber(CARD_VALUE.R2)][k]
				local card3 = cardClone[tonumber(CARD_VALUE.R3)][k]
				local card4 = cardClone[tonumber(CARD_VALUE.R4)][k]
				local card5 = cardClone[tonumber(CARD_VALUE.R5)][k]

				OneChangeCard( card1,card2,card3,card4,card5 )
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
					local card1 = cardClone[i][k]
					local card2 = cardClone[i+1][k]
					local card3 = cardClone[i+2][k]
					local card4 = cardClone[i+3][k]
					local card5 = cardClone[i+4][k]

					OneChangeCard( card1,card2,card3,card4,card5 )
				end
			end
		else --有值 23456-10JQKA
			if val < tonumber(CARD_VALUE.R10) then
				for i = val+1,tonumber(CARD_VALUE.R10) do --val-10
					for k = tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
						local card1 = cardClone[i][k]
						local card2 = cardClone[i+1][k]
						local card3 = cardClone[i+2][k]
						local card4 = cardClone[i+3][k]
						local card5 = cardClone[i+4][k]

						OneChangeCard( card1,card2,card3,card4,card5 )
					end
				end
			end
		end

		return pro
	end

	--两张可变牌
	local function findColorBombTwoChangeCard( allColorCard,val )
		-- body
		local pro = {}
		local cardClone = clone(allColorCard)
		local changeNode = {}
		table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]))
		table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]))

		local function TwoChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 == 0 and #card2 == 0 and #card3 >= 1 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 >= 1 and #card3 == 0 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 >= 1 and #card3 >= 1 and #card4 == 0 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 >= 1 and #card3 >= 1 and #card4 >= 1 and #card5 == 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 == 0 and #card3 == 0 and #card4 >= 1 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 == 0 and #card3 >= 1 and #card4 == 0 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 == 0 and #card3 >= 1 and #card4 >= 1 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 == 0 and #card4 == 0 and #card5 >= 1 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 == 0 and #card4 >= 1 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			elseif #card1 >= 1 and #card2 >= 1 and #card3 >= 1 and #card4 == 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			end
		end

		if not val or val == 0 then --没值 提示 A2345 - 10JQKA
			for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
				local card1 = cardClone[tonumber(CARD_VALUE.R1)][k]
				local card2 = cardClone[tonumber(CARD_VALUE.R2)][k]
				local card3 = cardClone[tonumber(CARD_VALUE.R3)][k]
				local card4 = cardClone[tonumber(CARD_VALUE.R4)][k]
				local card5 = cardClone[tonumber(CARD_VALUE.R5)][k]

				TwoChangeCard( card1,card2,card3,card4,card5 )
			end

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
					local card1 = cardClone[i][k]
					local card2 = cardClone[i+1][k]
					local card3 = cardClone[i+2][k]
					local card4 = cardClone[i+3][k]
					local card5 = cardClone[i+4][k]

					TwoChangeCard( card1,card2,card3,card4,card5 )
				end
			end
		else --有值 23456-10JQKA
			if val < tonumber(CARD_VALUE.R10) then
				for i=val+1,tonumber(CARD_VALUE.R10) do --val-10
					for k=tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do --黑梅方红
						local card1 = cardClone[i][k]
						local card2 = cardClone[i+1][k]
						local card3 = cardClone[i+2][k]
						local card4 = cardClone[i+3][k]
						local card5 = cardClone[i+4][k]

						TwoChangeCard( card1,card2,card3,card4,card5 )
					end
				end
			end
		end

		return pro
	end


	local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
	if #changeCards == 0 then
		local NoChangeCardPro = findColorBombNoChangeCard(effectiveCards,viewCard,allColorCard,val)
		for k,v in pairs(NoChangeCardPro) do
			table.insert(Project,v)
		end
	elseif #changeCards == 1 then
		local NoChangeCardPro = findColorBombNoChangeCard(effectiveCards,viewCard,allColorCard,val)
		for k,v in pairs(NoChangeCardPro) do
			table.insert(Project,v)
		end

		local OneChangeCardPro = findColorBombOneChangeCard(allColorCard,val)
		for k,v in pairs(OneChangeCardPro) do
			table.insert(Project,v)
		end
	elseif #changeCards == 2 then
		local NoChangeCardPro = findColorBombNoChangeCard(effectiveCards,viewCard,allColorCard,val)
		for k,v in pairs(NoChangeCardPro) do
			table.insert(Project,v)
		end

		local OneChangeCardPro = findColorBombOneChangeCard(allColorCard,val)
		for k,v in pairs(OneChangeCardPro) do
			table.insert(Project,v)
		end

		local TwoChangeCardPro = findColorBombTwoChangeCard(allColorCard,val)
		for k,v in pairs(TwoChangeCardPro) do
			table.insert(Project,v)
		end
	end

	if not bTips then
		--牌号库及花色库中遍历大于该类型的级牌（炸弹）
		CardTips.greaterThanFourLevel(Project,effectiveCards,viewCard,allCard,allColorCard)
	end

	return Project
end

--普通顺子
function CardTips.tipCommonStraight( effectiveCards,viewCard,allCard,allColorCard,val )
	-- body
	local  Project = {}
	--不需要可变牌
	local function findCommonStraightNoChangeCard( effectiveCards,viewCard,allCard,val )
		-- body
		local pro = {}
		--直接列中满足要求
		for i=#viewCard,1,-1 do
			if effectiveCards[i] == tonumber(CARD_TYPE.COMMON_STRAIGHT) then --有效
				if val then --存在具体值 
					if viewCard[i][1].val > tonumber(val) then
						table.insert(pro,viewCard[i])
					end
				else       --不存在具体值 我先发单
					table.insert(pro,viewCard[i])
				end
			end
		end

		local function NoChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 > 0 and #card2 > 0 and #card3 > 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			end
		end

		if val then --有值 23456-10JQKA
			if val < CARD_VALUE.R10 then
				for i=val+1,tonumber(CARD_VALUE.R10) do --val-10
					local card1 = allCard[i]
					local card2 = allCard[i+1]
					local card3 = allCard[i+2]
					local card4 = allCard[i+3]
					local card5 = allCard[i+4]

					NoChangeCard( card1,card2,card3,card4,card5 )
				end
			end
		else--没值 提示 A2345 - 10JQKA
			local card1 = allCard[tonumber(CARD_VALUE.R2)]
			local card2 = allCard[tonumber(CARD_VALUE.R3)]
			local card3 = allCard[tonumber(CARD_VALUE.R4)]
			local card4 = allCard[tonumber(CARD_VALUE.R5)]
			local card5 = allCard[tonumber(CARD_VALUE.R1)]

			NoChangeCard( card1,card2,card3,card4,card5 )

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				local card1 = allCard[i]
				local card2 = allCard[i+1]
				local card3 = allCard[i+2]
				local card4 = allCard[i+3]
				local card5 = allCard[i+4]
				
				NoChangeCard( card1,card2,card3,card4,card5 )
			end
		end

		return pro
	end

	--一张可变牌
	local function findCommonStraightOneChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		local function OneChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 == 0 and #card2 > 0 and #card3 > 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 == 0 and #card3 > 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 == 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 > 0 and #card4 == 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 > 0 and #card4 > 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[1])

				insertItemByDifVal(pro,cards)
			end
		end

		if val then --有值 23456-10JQKA
			if val < CARD_VALUE.R10 then
				for i=val+1,tonumber(CARD_VALUE.R10) do --val-10
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]
					local card3 = cardClone[i+2]
					local card4 = cardClone[i+3]
					local card5 = cardClone[i+4]

					OneChangeCard( card1,card2,card3,card4,card5 )
				end
			end
		else--没值 提示 A2345 - 10JQKA
			local card1 = cardClone[tonumber(CARD_VALUE.R2)]
			local card2 = cardClone[tonumber(CARD_VALUE.R3)]
			local card3 = cardClone[tonumber(CARD_VALUE.R4)]
			local card4 = cardClone[tonumber(CARD_VALUE.R5)]
			local card5 = cardClone[tonumber(CARD_VALUE.R1)]

			OneChangeCard( card1,card2,card3,card4,card5 )

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]
				local card3 = cardClone[i+2]
				local card4 = cardClone[i+3]
				local card5 = cardClone[i+4]

				OneChangeCard( card1,card2,card3,card4,card5 )
			end
		end

		return pro
	end

	--两张可变牌
	local function findCommonStraightTwoChangeCard( allCard,val )
		-- body
		local pro = {}

		local cardClone = clone(allCard)
		local changeNode = {}
		for i=#cardClone[GameModel.nowCardVal],1,-1 do
			if CardTips.detectionIsChangeCard(cardClone[GameModel.nowCardVal][i]) then
				table.insert(changeNode,table.remove(cardClone[GameModel.nowCardVal],i))
			end
		end

		local function TwoChangeCard( card1,card2,card3,card4,card5 )
			-- body
			if #card1 == 0 and #card2 == 0 and #card3 > 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 > 0 and #card3 == 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[3])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])
				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 > 0 and #card3 > 0 and #card4 == 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 == 0 and #card2 > 0 and #card3 > 0 and #card4 > 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,changeNode[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[5])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 == 0 and #card3 == 0 and #card4 > 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card4[1])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 == 0 and #card3 > 0 and #card4 == 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 == 0 and #card3 > 0 and #card4 > 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card3[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 == 0 and #card4 == 0 and #card5 > 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])
				table.insert(cards,card5[1])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 == 0 and #card4 > 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,card4[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			elseif #card1 > 0 and #card2 > 0 and #card3 > 0 and #card4 == 0 and #card5 == 0 then
				local cards = {}
				table.insert(cards,card1[1])
				table.insert(cards,card2[1])
				table.insert(cards,card3[1])
				table.insert(cards,changeNode[1])
				table.insert(cards,changeNode[2])

				insertItemByDifVal(pro,cards)
			end
		end

		if val then --有值 23456-10JQKA
			if val < CARD_VALUE.R10 then
				for i=val+1,tonumber(CARD_VALUE.R10) do --val-10
					local card1 = cardClone[i]
					local card2 = cardClone[i+1]
					local card3 = cardClone[i+2]
					local card4 = cardClone[i+3]
					local card5 = cardClone[i+4]

					TwoChangeCard( card1,card2,card3,card4,card5 )
				end
			end
		else--没值 提示 A2345 - 10JQKA
			local card1 = cardClone[tonumber(CARD_VALUE.R2)]
			local card2 = cardClone[tonumber(CARD_VALUE.R3)]
			local card3 = cardClone[tonumber(CARD_VALUE.R4)]
			local card4 = cardClone[tonumber(CARD_VALUE.R5)]
			local card5 = cardClone[tonumber(CARD_VALUE.R1)]

			TwoChangeCard( card1,card2,card3,card4,card5 )

			for i=tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R10) do --val-10
				local card1 = cardClone[i]
				local card2 = cardClone[i+1]
				local card3 = cardClone[i+2]
				local card4 = cardClone[i+3]
				local card5 = cardClone[i+4]

				TwoChangeCard( card1,card2,card3,card4,card5 )
			end
		end

		return pro
	end

	local changeCards = allColorCard[GameModel.nowCardVal][tonumber(FOLLOW_TYPE.TYPE_H)]
	if #changeCards == 0 then
		local NoChangeCard = findCommonStraightNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 1 then
		local NoChangeCard = findCommonStraightNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end

		local OneChangeCard = findCommonStraightOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end
	elseif #changeCards == 2 then
		local NoChangeCard = findCommonStraightNoChangeCard(effectiveCards,viewCard,allCard,val)
		for k,v in pairs(NoChangeCard) do
			table.insert(Project,v)
		end
		local OneChangeCard = findCommonStraightOneChangeCard(allCard,val)
		for k,v in pairs(OneChangeCard) do
			table.insert(Project,v)
		end
		local TwoChangeCard = findCommonStraightTwoChangeCard(allCard,val)
		for k,v in pairs(TwoChangeCard) do
			table.insert(Project,v)
		end
	end

	--牌号库及花色库中遍历大于该类型的级牌（炸弹）
	CardTips.greaterThanOneLevel(Project,effectiveCards,viewCard,allCard,allColorCard)

	return Project
end

--王炸
function CardTips.tipKingBomb( allCard )
	-- body
	local Project = {}
	if #allCard[tonumber(CARD_VALUE.R_WA)] == 2 and #allCard[tonumber(CARD_VALUE.R_WB)] == 2 then
		local cards = {}
		for k,v in pairs(allCard[tonumber(CARD_VALUE.R_WB)]) do
			table.insert(cards,v)
		end

		for k,v in pairs(allCard[tonumber(CARD_VALUE.R_WA)]) do
			table.insert(cards,v)
		end

		table.insert(Project,cards)
	end
	
	return Project
end

--需要大牌（首轮我出）
function CardTips.tipBigCard( effectiveCards,viewCard,allCard,allColorCard )
	-- body
	local Project = {}
	--最后一波是否能全部打出 
	local cardlist = {}
	for k,v in pairs(viewCard) do
		for m,n in pairs(v) do
			table.insert(cardlist,n)
		end
	end
	if CardDetection.detectionType(cardlist) ~= CARD_TYPE.NONE then
		table.insert(Project,cardlist)
		return Project
	end

	--单牌
	local ViewCardProSignle = CardTips.tipSignleViewCard( effectiveCards,viewCard )
	for k,v in pairs(ViewCardProSignle) do
		table.insert(Project,v)
	end

	--对子牌
	local ViewCardProDouble = CardTips.tipDoubleViewCard( effectiveCards,viewCard )
	for k,v in pairs(ViewCardProDouble) do
		table.insert(Project,v)
	end

	--三个牌
	local viewCardProTriple = CardTips.tipTripleViewCard( effectiveCards,viewCard )
	for k,v in pairs(viewCardProTriple) do
		table.insert(Project,v)
	end

	--三带二牌
	local viewCardProThreeAndTwo = CardTips.tipThreeAndTwoViewCard( effectiveCards,viewCard )
	for k,v in pairs(viewCardProThreeAndTwo) do
		table.insert(Project,v)
	end

	--钢板牌
	local PlateNoChangeCard = CardTips.findPlateViewCard(effectiveCards,viewCard,allCard)
	for k,v in pairs(PlateNoChangeCard) do
		table.insert(Project,v)
	end

	--连对
	local LinkDoubleNoChangeCard = CardTips.findLinkDoubleViewCard(effectiveCards,viewCard,allCard)
	for k,v in pairs(LinkDoubleNoChangeCard) do
		table.insert(Project,v)
	end

	--剩余整列
	local allColCanPlay = CardTips.allColCanPlay(effectiveCards,viewCard)
	for k,v in pairs(allColCanPlay) do
		insertItemByDifVal(Project,v)
	end

	return Project
end

--剩余整列可打的牌
function CardTips.allColCanPlay( effectiveCards,viewCard )
	-- body
	local Project = {}
	for i=#viewCard,1,-1 do
		if effectiveCards[i] > tonumber(CARD_TYPE.NONE) then --有效
			table.insert(Project,viewCard[i])
		end
	end

	return Project
end

return CardTips