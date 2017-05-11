-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  团团转玩法
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RcirclesGameManage = class("RcirclesGameManage",require("WhippedEgg.GameManageRoot.GameManageBase"))
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)

--初始化界面
--@param gameType 游戏类型
--@param ismutiple 组队还是单人
function RcirclesGameManage:createGame(gameType,ismutiple )
	self.pOneLuci = 0
	self.pTwoLuci = 0
	self.pOnePos = -1
	self.pTwoPos = -1

	return RcirclesGameManage.super.createGame(self,gameType,ismutiple)
end

----------------------------------------------------------------------------------------------------
--发牌相关
----------------------------------------------------------------------------------------------------
--本次打几
function RcirclesGameManage:setCurGamePlayNum(isBankerOurs) --打谁的牌 到底是对方还是我们
	-- body
	wwlog(self.logTag,"设置本次打几")
	GameModel.isPlayerBankerType = isBankerOurs
	GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存

	wwplyaCardLog("-------------------------本局主牌打"..PlayCardSwitch(GameModel.nowCardVal).."-----------------")
end

--主牌花色
function RcirclesGameManage:setPlayCardColor( color )
	-- body
	if color then
		GameModel.nowCardColor = color
	else
		GameModel.nowCardColor = FOLLOW_TYPE.TYPE_H
	end
end

function RcirclesGameManage:setGetRcircleCardPeople( pOneId,pTwoId )
	-- body
	if pOneId ~= 0 and pTwoId ~= 0 then
		self.pOnePos = self:getPositionbyId(self.pSeatsInfos,pOneId)--第一张主牌位置
		self.pTwoPos = self:getPositionbyId(self.pSeatsInfos,pTwoId)--第二张主牌位置
	end
end

function RcirclesGameManage:getDealRcircleCardLuci( ... )
	-- body
	wwlog(self.logTag,"查看哪两个摸到团团转牌%d%d",self.pOnePos,self.pTwoPos)
	if self.pOnePos == -1 or self.pTwoPos == -1 then
		return
	end
	if self.pOnePos == Player_Type.SelfPlayer then
		self.pOneLuci = self.MyPlayer:findRcicleCardIdx()
	else
		self.pOneLuci = CHANGECOLOR_CARD_PLAYER_NUM
	end
	
	if self.pTwoPos == Player_Type.SelfPlayer then
		self.pTwoLuci = self.MyPlayer:findRcicleCardIdx()
	else
		self.pTwoLuci = CHANGECOLOR_CARD_PLAYER_NUM + 1
	end

	if self.pOneLuci > self.pTwoLuci then
		if self.pOnePos == Player_Type.SelfPlayer then
			self.pTwoLuci = math.min(self.pOneLuci + 1,DISTRIBUTE_CARD_MIN_NUM) 
		end

		if self.pTwoPos == Player_Type.SelfPlayer then
			self.pOneLuci = math.max(self.pTwoLuci - 1,1)
		end
	end
end

function RcirclesGameManage:RcircleCard( idx )
	-- body
	if self.pOnePos == -1 and self.pTwoPos == -1 then
		return
	end

	if idx == self.pOneLuci then 
		if self.pOnePos == Player_Type.SelfPlayer then
			self.MyPlayer:showRcircleCard()
		elseif self.pOnePos == Player_Type.RightPlayer then
			self:getRightPlayer():showRcircleCard()
		elseif self.pOnePos == Player_Type.UpPlayer then
			self:getUpPlayer():showRcircleCard()
		elseif self.pOnePos == Player_Type.LeftPlayer then
			self:getLeftPlayer():showRcircleCard()
		end
	end

	if idx == self.pTwoLuci then 
		if self.pTwoPos == Player_Type.SelfPlayer then
			self.MyPlayer:showRcircleCard()
		elseif self.pTwoPos == Player_Type.RightPlayer then
			self:getRightPlayer():showRcircleCard()
		elseif self.pTwoPos == Player_Type.UpPlayer then
			self:getUpPlayer():showRcircleCard()
		elseif self.pTwoPos == Player_Type.LeftPlayer then
			self:getLeftPlayer():showRcircleCard()
		end
	end
end

function RcirclesGameManage:setPlayerInfo( playerType, players )
	-- body
	--发牌准备
	local function functionCardReady( ... )
		-- body
		self.gameState = GameStateType.Ready
		
		local function beginMatchAniEnd( ... )
			-- body
			self:getTipsAniLayer():playEggPain(function ( num )
				-- body
				self:getTipsAniLayer():setCurGamePlayNum(num,handler(self,self.DealCard),self.matchData)
			end)
		end
		wwlog(self.logTag,"先播放开始动画团团转")
		self:getTipsAniLayer():beginMatchAni( beginMatchAniEnd,self.matchData )

		self:setDealCardReady()
		self:matchContinue()
	end

	self.gameState = GameStateType.WaitPlayerInfo
	if playerType == Player_Type.UpPlayer then
		self.UpPlayerReady = true
		if self.UpPlayerID and self.UpPlayerID ~= players.side1[2].UserID then
			self.newPlayer = true
		end
		self.UpPlayerID = players.side1[2].UserID
	elseif playerType == Player_Type.LeftPlayer then
		self.LeftPlayerReady = true
		if self.LeftPlayerID and self.LeftPlayerID ~= players.side2[1].UserID then
			self.newPlayer = true
		end
		self.LeftPlayerID = players.side2[1].UserID
	elseif playerType == Player_Type.RightPlayer then
		self.RightPlayerReady = true
		if self.RightPlayerID and self.RightPlayerID ~= players.side2[2].UserID then
			self.newPlayer = true
		end
		self.RightPlayerID = players.side2[2].UserID
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayerReady = true
	end

	--最后一个设置完
	if playerType == Player_Type.RightPlayer then
		wwlog(self.logTag,"最后一个设置完")
		if self.newPlayer then
			self:setRank(Player_Type.LeftPlayer,0)
	  		self:setRank(Player_Type.RightPlayer,0)
	  		self:setRank(Player_Type.SelfPlayer,0)
	  		self:setRank(Player_Type.UpPlayer,0)
		end
		self:getUpPlayer():setHeadInfo(players.side1[2])
		self:getLeftPlayer():setHeadInfo(players.side2[1])
		self:getRightPlayer():setHeadInfo(players.side2[2])
		self.MyPlayer:setHeadInfo(players.side1[1])

		functionCardReady()
	end	
end

--正式发牌
function RcirclesGameManage:DealCard()
	-- body
	if self.gameState == GameStateType.EnterBackground then
		return
	end

	wwlog("发牌时间调试 开始",os.date("[%Y-%m-%d %H:%M:%S] ", os.time()))
	if not self.dealCardAlready then --要等发完牌才能再次发 防止报错
		self.gameState = GameStateType.DealCard
		self:delOtherPlayerCards()
		
		--准备牌
		self.DealCardLayer:createCards() 
		self.MyPlayer:releaseCards()
		self.MyPlayer:createCards(self.cardTable)
		self:getDealRcircleCardLuci()

		self.dealCardIndex = DISTRIBUTE_CARD_MAX_NUM --每次发牌id从最后面一张发起(也就是叠在最上面的牌)
		if not self.dealCardScriptFuncId then
			self.dealCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.dealCard), 0.05, false)
		end
		playSoundEffect("sound/effect/fapai",true)
	end
end

--每0.5秒发次牌
function RcirclesGameManage:dealCard( dt )
	-- body
	--按顺序发牌
	local order = self.dealCardIndex%DISTRIBUTE_CARD_PLAYER_NUM
	local playerCardIndex = math.ceil((DISTRIBUTE_CARD_MAX_NUM - self.dealCardIndex + 1)/4) -- 玩家牌索引
	local cardNode = self.DealCardLayer:getCardByIdx(self.dealCardIndex) --获取最上层一张牌
	if cardNode then
		if order == Player_Type.SelfPlayer then
			self.MyPlayer:dealCard(cardNode,playerCardIndex)
			self:RcircleCard(playerCardIndex)
		elseif order == Player_Type.RightPlayer then
			self:getRightPlayer():dealCard(cardNode,playerCardIndex)
		elseif order == Player_Type.UpPlayer then
			self:getUpPlayer():dealCard(cardNode,playerCardIndex)
		elseif order == Player_Type.LeftPlayer then
			self:getLeftPlayer():dealCard(cardNode,playerCardIndex)
		end

		--发牌层当前节点删除
		cardNode:removeFromParent()
		--自减
		self.dealCardIndex = self.dealCardIndex - 1
		--发完了
		if self.dealCardIndex <= 0 then 
			wwlog("发牌时间调试 结束",os.date("[%Y-%m-%d %H:%M:%S] ", os.time()))

			stopSoundEffect("sound/effect/fapai")
			self.DealCardLayer:releaseCards()
			self.dealCardAlready = true

			if self.dealCardScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
				self.dealCardScriptFuncId = false
			end

			if self.pOnePos == -1 and self.pTwoPos == -1 then
				if self.callBcak then
					self.callBcak()
				end
				self:playCardBeforeDealCardFunc()

				--发牌前先告诉服务器动画播放结束，矫正计时
				WhippedEggSceneProxy:sayStartActionOver2Server(self.gameType)
			else
				if not self.deleteRcircleCardScriptFuncId then
					self.deleteRcircleCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.deleteRcircleCardHandle), 2.5, false)
				end
			end
			self.FoldMenuLayer:addChatBtn()
		end
	else
		if self.dealCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
			self.dealCardScriptFuncId = false
		end
		
		self.DealCardLayer:releaseCards()
	end
end

function RcirclesGameManage:deleteRcircleCardHandle( ... )
	-- body
	if self.deleteRcircleCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.deleteRcircleCardScriptFuncId)
		self.deleteRcircleCardScriptFuncId = false
	end

	self.MyPlayer:deleteRcircleCard()
	self:getRightPlayer():deleteRcircleCard()
	self:getUpPlayer():deleteRcircleCard()
	self:getLeftPlayer():deleteRcircleCard()

	if self.pOnePos == self.pTwoPos or isTeammate(self.pOnePos,self.pTwoPos) then
		-- body
		if self.callBcak then
			self.callBcak()
		end
		self:playCardBeforeDealCardFunc()

		--发牌前先告诉服务器动画播放结束，矫正计时
		WhippedEggSceneProxy:sayStartActionOver2Server(self.gameType)
	else
		--发完牌换位置
		local p1,p2 = switchPlayers(self.pOnePos,self.pTwoPos)
		local retSeatInfo = self:getChangeSeats(self.pSeatsInfos,p1,p2)
		self:changeGameSeatInfo(retSeatInfo)

		self:getUpPlayer():runMoveAction(function ( ... )
			-- body
			self:getUpPlayer():setHeadInfo(self.pSeatsInfos.side1[2])
		end)
		self:getLeftPlayer():runMoveAction(function ( ... )
			-- body
			self:getLeftPlayer():setHeadInfo(self.pSeatsInfos.side2[1])
		end)
		self:getRightPlayer():runMoveAction(function ( ... )
			-- body
			self:getRightPlayer():setHeadInfo(self.pSeatsInfos.side2[2])
			self.MyPlayer:setHeadInfo(self.pSeatsInfos.side1[1])
			if self.callBcak then
				self.callBcak()
			end
			self:playCardBeforeDealCardFunc()

			--发牌前先告诉服务器动画播放结束，矫正计时
			WhippedEggSceneProxy:sayStartActionOver2Server(self.gameType)
		end)
	end
end

cc.exports.RcirclesGameManage = cc.exports.RcirclesGameManage or RcirclesGameManage:create()
return cc.exports.RcirclesGameManage
