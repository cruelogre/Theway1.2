-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  过A玩法
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local PromotionGameManage = class("PromotionGameManage",require("WhippedEgg.GameManageRoot.GameManageBase"))
--初始化界面
--@param gameType 游戏类型
--@param ismutiple 组队还是单人
function PromotionGameManage:createGame(gameType,ismutiple )
	return PromotionGameManage.super.createGame(self,gameType,ismutiple)
end

----------------------------------------------------------------------------------------------------
--发牌相关
----------------------------------------------------------------------------------------------------
--本次打几
function PromotionGameManage:setCurGamePlayNum( isBankerOurs ) --打谁的牌 到底是对方还是我们
	-- body
	wwlog(self.logTag,"设置本次打几")
	self.DealCardLayer:recoveryOn()
	GameModel.isPlayerBankerType = isBankerOurs
  	if isBankerOurs == lightWiner.winerLeft then --己方
		GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存
		self:getTipsAniLayer():setCurGamePlayNum(GameModel.myNumber,handler(self,self.DealCard))
	elseif isBankerOurs == lightWiner.winerRight then --对方
		GameModel.nowCardVal = GameModel.opppsiteNumber-1 --本次打几保存
		self:getTipsAniLayer():setCurGamePlayNum(GameModel.opppsiteNumber,handler(self,self.DealCard))
	elseif isBankerOurs == lightWiner.winerAll then --双方
		GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存
		self:getTipsAniLayer():setCurGamePlayNum(GameModel.myNumber,handler(self,self.DealCard))
	end

	wwplyaCardLog("-------------------------本局主牌打"..PlayCardSwitch(GameModel.nowCardVal).."-----------------")
end
--主牌花色
function PromotionGameManage:setPlayCardColor( color )
	-- body
	GameModel.nowCardColor = FOLLOW_TYPE.TYPE_H
end
function PromotionGameManage:setPlayerInfo( playerType, players )
	-- body
	wwlog(self.logTag,"设置个人头像信息 发牌相关")
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
		wwlog(self.logTag,"所有玩家都准备好 准备牌")
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

		self.gameState = GameStateType.Ready
		self:setDealCardReady()
	end	
end

----------------------------------------------------------------------------------------------------
--设置我的结算名次信息
----------------------------------------------------------------------------------------------------
--旗帜结算
function PromotionGameManage:levelUpSettlement( info )
	-- body
	wwlog("收到锦旗消息")
	self.MyPlayer.allTimeVisible = false
	self.MyPlayer:ToastTips(ToastState.None)

	self.gameState = GameStateType.Settlement

	self.haveLevelUpSettlement = true
	self.levelUpSettlementInfo = info
	--修改个人信息
	self.MyPlayer:setHeadInfo()
end
function PromotionGameManage:levelUpSettlementCallBack( ... )
	-- body
	--结算层
	if self.haveLevelUpSettlement then
		self.haveLevelUpSettlement = false
		--self:getSettlementLayer():Banner(self.levelUpSettlementInfo)
		FSRegistryManager:currentFSM():trigger("banner",
		{   parentNode = display.getRunningScene(), 
			zorder = zorderLayer.SettlementLayer,
			info = self.levelUpSettlementInfo,
			})
	end
end

----------------------------------------------------------------------------------------------------
--进贡相关
----------------------------------------------------------------------------------------------------
--进贡
function PromotionGameManage:PayTribute(callBcak,sec)
	-- body
	wwlog(self.logTag,"收到我要进贡消息")
	if callBcak then
		self.gameState = GameStateType.PayTribute
		self.MyPlayer:PayTribute(callBcak)
	end
	if 	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
	else
		self:getTipsAniLayer():setTributeBegin(sec)
	end
end

--退贡
function PromotionGameManage:RetTribute(callBcak,sec)
	-- body
	wwlog(self.logTag,"收到我要退贡消息")
	self.gameState = GameStateType.RetTribute
	self.MyPlayer:RetTribute(callBcak)
	if 	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
	else
		self:getTipsAniLayer():setTributeBegin(sec)
	end
end

--抗贡
function PromotionGameManage:UnPayTribute( callBcak )
	-- body
	wwlog(self.logTag,"收到我要抗贡消息")
	self.gameState = GameStateType.UnPayTribute
	--播放动画 完毕回调
	self:getTipsAniLayer():Notribute(callBcak)
end
--近/抗贡完成
function PromotionGameManage:setTributeEnd( ... )
	-- body
	wwlog(self.logTag,"收到进/抗贡完成消息")
	self.gameState = GameStateType.TributeEnd
	self:getTipsAniLayer():setTributeEnd()
end
--其他玩家进/退贡状态
function PromotionGameManage:OtherPlayerTribute( playerType,state )
	-- body
	self.gameState = GameStateType.PayTribute
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():setStateType(state)
		wwlog(self.logTag,"收到 上玩家 进/退 贡消息",state)
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():setStateType(state)
		wwlog(self.logTag,"收到 左玩家 进/退 贡消息",state)
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():setStateType(state)
		wwlog(self.logTag,"收到 右玩家 进/退 贡消息",state)
	end
end
--其他玩家进退贡的牌
function PromotionGameManage:OtherPlayerTributeCard( playerType,card )
	-- body
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():TributeCard(card[1])
		wwlog(self.logTag,"收到 上玩家 退贡 牌 消息")
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():TributeCard(card[1])
		wwlog(self.logTag,"收到 左玩家 退贡 牌 消息")
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():TributeCard(card[1])
		wwlog(self.logTag,"收到 右玩家 退贡 牌 消息")
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayer:TributeCard(card[1])
		wwlog(self.logTag,"收到 我自己 退贡 牌 消息")
	end
end
--交换贡牌
function PromotionGameManage:exChangeTributeCard( playerA,playerB,callBcak,card ) --双方，回调 牌
	wwlog(self.logTag,"收到%d%d%s",playerA,playerB,"交换进贡牌消息")
	-- body
	self:getTipsAniLayer():setTributeEnd()
	if playerA == Player_Type.UpPlayer then
		if playerB == Player_Type.LeftPlayer then
			self:getUpPlayer():ExchangTributeCard(self:getLeftPlayer(),callBcak)
			self:getLeftPlayer():ExchangTributeCard(self:getUpPlayer())
		elseif playerB == Player_Type.RightPlayer then
			self:getUpPlayer():ExchangTributeCard(self:getRightPlayer(),callBcak)
			self:getRightPlayer():ExchangTributeCard(self:getUpPlayer())
		elseif playerB == Player_Type.SelfPlayer then
			self:getUpPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
			self.MyPlayer:ExchangTributeCard(self:getUpPlayer())
		end
	elseif playerA == Player_Type.LeftPlayer then
		if playerB == Player_Type.UpPlayer then
			self:getLeftPlayer():ExchangTributeCard(self:getUpPlayer(),callBcak)
			self:getUpPlayer():ExchangTributeCard(self:getLeftPlayer())
		elseif playerB == Player_Type.RightPlayer then
			self:getLeftPlayer():ExchangTributeCard(self:getRightPlayer(),callBcak)
			self:getRightPlayer():ExchangTributeCard(self:getLeftPlayer())
		elseif playerB == Player_Type.SelfPlayer then
			self:getLeftPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
			self.MyPlayer:ExchangTributeCard(self:getLeftPlayer())
		end
	elseif playerA == Player_Type.RightPlayer then
		if playerB == Player_Type.UpPlayer then
			self:getRightPlayer():ExchangTributeCard(self:getUpPlayer(),callBcak)
			self:getUpPlayer():ExchangTributeCard(self:getRightPlayer())
		elseif playerB == Player_Type.LeftPlayer then
			self:getRightPlayer():ExchangTributeCard(self:getLeftPlayer(),callBcak)
			self:getLeftPlayer():ExchangTributeCard(self:getRightPlayer())
		elseif playerB == Player_Type.SelfPlayer then
			self:getRightPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
			self.MyPlayer:ExchangTributeCard(self:getRightPlayer())
		end
	elseif playerA == Player_Type.SelfPlayer then
		if playerB == Player_Type.UpPlayer then
			self.MyPlayer:ExchangTributeCard(self:getUpPlayer())
			self:getUpPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
		elseif playerB == Player_Type.LeftPlayer then
			self.MyPlayer:ExchangTributeCard(self:getLeftPlayer())
			self:getLeftPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
		elseif playerB == Player_Type.RightPlayer then
			self.MyPlayer:ExchangTributeCard(self:getRightPlayer())
			self:getRightPlayer():ExchangTributeCard(self.MyPlayer,callBcak,card[1])
		end
	end
end

cc.exports.PromotionGameManage = cc.exports.PromotionGameManage or PromotionGameManage:create()
return cc.exports.PromotionGameManage
