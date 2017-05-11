-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  
-- Date:    2016.08.29
-- Last: 
-- Content:  经典玩法逻辑处理  这里不做任何UI或数据相关处理，单纯的业务逻辑处理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Classical = class("Classical",require("WhippedEgg.logics.RoomBase"))

local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")

local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local CardDetection = require("WhippedEgg.CardDetection")

local GDPokerUtil = import(".GDPokerUtil","WhippedEgg.util.")

local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")

function Classical:ctor()
	Classical.super.ctor(self)
end

function Classical:init()
	self.logTag = "Classical.lua"

	--这里要判断一下信息是否已经进来了 最后一个人进来的时候 数据最先过来
	local Classicstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
	if Classicstart and next(Classicstart) then
		local event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART }
		wwlog(self.logTag, "进来前就收到经典开局消息")
		self:commondEventHandle(event)
	else
	 	Classicstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
	 	if Classicstart and next(Classicstart) then
	 		local event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME }
			wwlog(self.logTag, "进来前就收到经典恢复对局消息")
			self:commondEventHandle(event)
	 	end
	end

	local _,handler1 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART,handler(self,self.commondEventHandle))
	local _,handler2 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_TRIBUTE,handler(self,self.commondEventHandle))
	local _,handler3 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_EXCHANGECARD,handler(self,self.commondEventHandle))
	local _,handler4 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD,handler(self,self.commondEventHandle))
	local _,handler5 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_GAMEOVER,handler(self,self.commondEventHandle))
	local _,handler6 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME,handler(self,self.commondEventHandle))
	local _,handler7 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_TABLESTATE,handler(self,self.commondEventHandle))
	local _,handler8 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_SUBSTITUTE,handler(self,self.commondEventHandle))
	local _,handler9 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_HOLDAWARD,handler(self,self.commondEventHandle))
	local _,handler10 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP,handler(self,self.commondEventHandle))
	
	table.insert(self.handlers,handler1)
	table.insert(self.handlers,handler2)
	table.insert(self.handlers,handler3)
	table.insert(self.handlers,handler4)
	table.insert(self.handlers,handler5)
	table.insert(self.handlers,handler6)
	table.insert(self.handlers,handler7)
	table.insert(self.handlers,handler8)
	table.insert(self.handlers,handler9)
	table.insert(self.handlers,handler10)
end

--重新滞空
function Classical:recycle()
	Classical.super.recycle(self)

	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
end

function Classical:createCardRecorder( ... )
	Classical.super.createCardRecorder(self)

	 --这里要判断一下信息是否已经进来了 最后一个人进来的时候 数据最先过来
    local Classicstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
    if Classicstart and next(Classicstart) then
        self.cardRecorder:onGameResume(Classicstart)
    end    
end
	
function Classical:commondEventHandle(event)
	wwlog(self.logTag, "掼蛋玩法消息回调处理")
	if event.name == WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART then --开局
		wwlog(self.logTag, "经典 开局")
		self:handleStartGame(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_TRIBUTE then --进贡
		self:handleTribute(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_EXCHANGECARD then --换牌
		self:handleExchangeCard(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD then --打牌
		wwlog(self.logTag, "经典 打牌")
		self:handlePlayCard(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_GAMEOVER then --结束
		self:handleGameOver(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME then --恢复对局
		wwlog(self.logTag, "经典 恢复对局")
		self:handleResumeGame(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_TABLESTATE then --状态改变
		self:handleTableState(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_SUBSTITUTE then --托管
		wwlog(self.logTag, "经典 托管")
		self:handleSubstitute(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_HOLDAWARD then --打到结算分
		self:handleHoldAward(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP then --对局中玩家数据
		self:handleUserInfo(event.name,event._userdata)
	end
end

--[[
开局消息收到后的处理,我方进退恭逻辑处理
--]]
function Classical:handleStartGame(eventid)
	wwlog(self.logTag, "经典开局处理")
	if self.StartGame then
		return
	end

	self.StartGame = true
	self.showAll1 = {false,false}
	self.showAll2 = {false,false}
	
	removeAll(self.currentRanks)
	self.currentRanks = {}
	GameManageFactory:getCurGameManage():SettlementReset()
	
	-- 根据玩家信息排桌
	self.startData = DataCenter:getData(eventid)
	--存储开赛信息
	DataCenter:cacheData(COMMON_EVENTS.C_EVENT_GAMEDATA,{GamePlayID = self.startData.GamePlayID,InstMatchID =self.startData.InstMatchID })
	
	--将排座信息存入 GameManage  (一个游戏回合需要修改)
	self.seatInfos = GameManageFactory:getCurGameManage():getSeatsInfo(self.startData.players)  --几个玩家分边后的数据
	GameManageFactory:getCurGameManage():setCruGameSeatInfo(self.seatInfos)

	wwlog(self.logTag, "设置本次打几")
	local mySidePokermNow = self.seatInfos.side1[1].PlayLevel  --排座后自己打几
	local otherSidePokermNow = self.seatInfos.side2[1].PlayLevel  --排座后对方打几
	GameManageFactory:getCurGameManage():setPlayCardInfo(mySidePokermNow, otherSidePokermNow)
	GameManageFactory:getCurGameManage():setGetRcircleCardPeople(self.startData.TCUserID1, self.startData.TCUserID2)
	if self.startData.TrumpCard and next(self.startData.TrumpCard) ~= nil then
		GameManageFactory:getCurGameManage():setPlayCardColor(self.startData.TrumpCard[1].color)
	end

	--重置托管消息  开局后默认不托管
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.SelfPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.LeftPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.RightPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.UpPlayer,false)

	--发牌逻辑处理
	--这里判断如果是续局	
	if self.startData.ContinueFlag == 1 then
		if self.startData.PlayType == Play_Type.PromotionGame then
			--判断上一局我们是输了还是赢了
			local weWin = false
			for i,vv in ipairs(self.seatInfos.side1) do
				if vv.Ranking == 1 then
					weWin = true
					break
				end
			end
			--续局中  我们赢了
			if weWin then
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerLeft)
			else
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerRight)
			end
		elseif self.startData.PlayType == Play_Type.RandomGame then
			GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerAll)
		elseif self.startData.PlayType == Play_Type.RcircleGame then
			local playPosition1 = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, self.startData.TCUserID1)
			local playPosition2 = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, self.startData.TCUserID2)
			if playPosition1 == Player_Type.SelfPlayer or playPosition2 == Player_Type.SelfPlayer then
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerLeft)
			else
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerRight)
			end
		end
		
		--续局落
		GameManageFactory:getCurGameManage():readyDealCard(self.seatInfos.side1[1].baseCards, handler(self, self.HandleContinueStep))
	else --不是续局 直接开始
		if self.startData.PlayType == Play_Type.PromotionGame then
			--第一局 随便打 默认使我们这边点亮和设置成我们这边的主牌
			GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerLeft)
		elseif self.startData.PlayType == Play_Type.RandomGame then
			GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerAll)
		elseif self.startData.PlayType == Play_Type.RcircleGame then
			local playPosition1 = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, self.startData.TCUserID1)
			local playPosition2 = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, self.startData.TCUserID2)
			if playPosition1 == Player_Type.SelfPlayer or playPosition2 == Player_Type.SelfPlayer then
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerLeft)
			else
				GameManageFactory:getCurGameManage():setCurGamePlayNum(lightWiner.winerRight)
			end
		end
		GameManageFactory:getCurGameManage():readyDealCard(self.seatInfos.side1[1].baseCards, handler(self, self.handleFirstStep))
	end

	wwlog(self.logTag, "设置头像桌面玩家信息")
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.UpPlayer,self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.LeftPlayer,self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.RightPlayer,self.seatInfos)
    Classical.super.baseStartGame(self,self.startData)
end

--续局回调
function Classical:HandleContinueStep()
	if self.startData.Jingong == 0 then --抗贡
		--d动画  TODO 消息通知服务端
		GameManageFactory:getCurGameManage():UnPayTribute(handler(self, self.handleFirstStep))
		--回调  handleFirstStep
		
	else --进贡流程
		local doubleWin = false --是否存在双贡
		if self.seatInfos.side1[1].Ranking <=2 and
		self.seatInfos.side1[2].Ranking <=2 then
		--两个都在前两名
			doubleWin = true
		elseif self.seatInfos.side1[1].Ranking > 2 and
		self.seatInfos.side1[2].Ranking > 2 then
			--两个都在后两名
			doubleWin = true
		end
		
		for _,v in pairs(self.startData.players) do
			if v.UserID ~= self.seatInfos.side1[1].UserID then
				if v.Ranking == 4 then --进贡
					GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.PayTribute)
				elseif v.Ranking>0 and v.Ranking <=2 then --退贡
					if doubleWin then --双贡条件下两个都需要换贡
						GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.RetTribute)
					elseif v.Ranking == 1 then
						GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.RetTribute)
					end
				end
			end
		end
		
		if self.seatInfos.side1[1].Ranking == 4 then
			
			--判断是否第四名 需要进贡选牌
			local jgCallBack = function( choosePoker )
				wwlog(self.logTag, "发送进贡消息")
				self:handleTributeChoose(choosePoker, 1)
			end
			GameManageFactory:getCurGameManage():PayTribute(jgCallBack,self.startData.JGTimeout)
		elseif (self.seatInfos.side1[1].Ranking == 1) 
			or ( doubleWin and (self.seatInfos.side1[1].Ranking == 2)) then
			--第一名 或者  双贡的第二名要退贡
			local hgCallBack = function( choosePoker )
				wwlog(self.logTag, "发送还贡消息")
				self:handleTributeChoose(choosePoker, 2)
			end
			GameManageFactory:getCurGameManage():RetTribute(hgCallBack,self.startData.JGTimeout)
		end

	end
end

--玩家进贡选牌回调
function Classical:handleTributeChoose( choosePoker, type )
	wwlog(self.logTag, "进贡选牌后回调")
	local gameplayid = self.startData.GamePlayID
	WhippedEggSceneProxy:requestTribute(gameplayid, type,choosePoker)
end

--收到进贡回调消息了哦
function Classical:handleTribute(eventid)
	if not self.StartGame then
		return
	end
	wwlog(self.logTag, "收到进贡回调消息了哦")
	local tributeData = DataCenter:getData(eventid)
	local playidPosition = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, tributeData.UserID)

	if tributeData.Type == 1 then --进贡返回
		GameManageFactory:getCurGameManage():OtherPlayerTributeCard(playidPosition,tributeData.pokerCard)
		
	elseif tributeData.Type == 2 then --返回牌给进贡方
		GameManageFactory:getCurGameManage():OtherPlayerTributeCard(playidPosition,tributeData.pokerCard)
	end
end

--收到交换牌消息了哦
function Classical:handleExchangeCard(eventid)
	if not self.StartGame then
		return
	end
	wwlog(self.logTag, "收到交换牌消息了哦")
	local exchangeCardData = DataCenter:getData(eventid)
	-- wwdump(exchangeCardData,"服务器的交换牌消息")
	local sCount = 0
	local exchangeCallBack = function( )
		-- 交换牌结束，开始打牌
		wwlog(self.logTag, "交换牌结束，开始打牌")
		sCount = sCount + 1
		wwlog(self.logTag,"current exchange count:%d,limit count:%d",sCount,(#exchangeCardData.exchangeArr)/2)
		if sCount == (#exchangeCardData.exchangeArr)/2 then
			self:handleFirstStep(exchangeCardData.NextPlayerID)
		end
	end
	local fromUserId = nil
	for i,v in ipairs(exchangeCardData.exchangeArr) do
		local pokerCard = v.pokerCard
		local sFromUserID = v.FromUserID
		local stoUserID = v.toUserID

		local fromPosition = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, sFromUserID)
		local toPosition = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, stoUserID)
		
		if tonumber(stoUserID) == tonumber(self.seatInfos.side1[1].UserID) then
			GameManageFactory:getCurGameManage():exChangeTributeCard(fromPosition, toPosition, exchangeCallBack, pokerCard)
		elseif tonumber(sFromUserID) ~= tonumber(self.seatInfos.side1[1].UserID) then
			if fromUserId ~= nil and fromUserId ==stoUserID then
				GameManageFactory:getCurGameManage():exChangeTributeCard(fromPosition, toPosition, exchangeCallBack, pokerCard)
			end
			fromUserId = sFromUserID
		end
	end
end

--结算
function Classical:handleGameOver(eventid)
	if not self.StartGame then
		return
	end
	self.StartGame = false
	Classical.super.handleGameOver(self,eventid)
end	

function Classical:handleResumeGame(eventid)
	--恢复对局	
	wwlog(self.logTag, "经典恢复对局处理")
	Classical.super.resumeGameSet(self)
	
	self.StartGame = true
	self.showAll1 = {false,false}
	self.showAll2 = {false,false}
	
	removeAll(self.currentRanks)
	self.currentRanks = {}
	-- 根据玩家信息排桌
	self.startData = DataCenter:getData(eventid)
	DataCenter:cacheData(COMMON_EVENTS.C_EVENT_GAMEDATA,{GamePlayID = self.startData.GamePlayID,InstMatchID = self.startData.InstMatchID })
	wwlog(self.logTag, "设置头像桌面玩家信息")
	self.seatInfos = GameManageFactory:getCurGameManage():getSeatsInfo(self.startData.players)  --几个玩家分边后的数据
	
	--将排座信息存入 GameManage  (一个游戏回合需要修改)
	GameManageFactory:getCurGameManage():setCruGameSeatInfo(self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayCardTime(self.startData.PlayTimeout)
	GameManageFactory:getCurGameManage():setRoomName(self.startData.GameZoneName)

	wwlog(self.logTag, "设置底分")
	local fortuneBase = self.startData.FortuneBase or 0 --设置底分（从开局消息中，取出打几的信息）
	local mySidePokermNow = self.seatInfos.side1[1].PlayLevel  --排座后自己打几
	local otherSidePokermNow = self.seatInfos.side2[1].PlayLevel  --排座后对方打几

	local isPlayerBankerType = lightWiner.winerAll
	if self.startData.PlayType == Play_Type.PromotionGame then
		--判断上一局我们是输了还是赢了
		local weWin = true
		if self.startData.LastRank1User == 0 then
			weWin = true
		else
			local LastRank1User = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,self.startData.LastRank1User)
			if LastRank1User ~= Player_Type.SelfPlayer and LastRank1User ~= Player_Type.UpPlayer then
				weWin = false
			end
		end
		if weWin then
			isPlayerBankerType = lightWiner.winerLeft
		else
			isPlayerBankerType = lightWiner.winerRight
		end
	elseif self.startData.PlayType == Play_Type.RandomGame then
		isPlayerBankerType = lightWiner.winerAll
	elseif self.startData.PlayType == Play_Type.RcircleGame then
		local weWin = true
		local LastRank1User = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,self.startData.LastRank1User)
		if LastRank1User ~= Player_Type.SelfPlayer then
			weWin = false
		end
		if weWin then
			isPlayerBankerType = lightWiner.winerLeft
		else
			isPlayerBankerType = lightWiner.winerRight
		end
	end
	
	GameManageFactory:getCurGameManage():recoverysetCurGamePlayNum( fortuneBase,mySidePokermNow,otherSidePokermNow,isPlayerBankerType ) --房间底分，我们打几，对方打几，本局是不是打我们的数字
	GameManageFactory:getCurGameManage():recoveryPlayerInfo( Player_Type.UpPlayer, self.seatInfos ) 
	GameManageFactory:getCurGameManage():recoveryPlayerInfo( Player_Type.LeftPlayer, self.seatInfos ) 
	GameManageFactory:getCurGameManage():recoveryPlayerInfo( Player_Type.RightPlayer, self.seatInfos ) 
	GameManageFactory:getCurGameManage():recoveryPlayerInfo( Player_Type.SelfPlayer, self.seatInfos ) 
	
	--设置头像是否托管
	self:setPlayerState(Player_Type.SelfPlayer,self.seatInfos.side1[1].UserType)
	self:setPlayerState(Player_Type.UpPlayer,self.seatInfos.side1[2].UserType)
	self:setPlayerState(Player_Type.LeftPlayer,self.seatInfos.side2[1].UserType)
	self:setPlayerState(Player_Type.RightPlayer,self.seatInfos.side2[2].UserType)
	
	wwlog(self.logTag,"上一个非pass玩家出牌id %d",self.startData.LastPlayUserID)
	wwlog(self.logTag,"我的id %d",self.seatInfos.side1[1].UserID)
	if self.startData.LastPlayUserID == self.seatInfos.side1[1].UserID then
		local typeCard,val = CardDetection.detectionType(self.startData.LastPlayCards)
		self.myPlayCardType = typeCard
		self.myPlayCardValue = val
	end
	local function nextStep( ... )
		-- body
		if self.startData.LastPlayUserID <= 0 then
			wwlog(self.logTag,"上个玩家ID为零 第一轮")
			local nextPositionType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,self.startData.NextPlayUseID)

    		if nextPositionType == Player_Type.SelfPlayer then
				GameManageFactory:getCurGameManage():showClockToPlay(Player_Type.SelfPlayer,1,0,handler(self, self.requestPlayCard))
			else 
				GameManageFactory:getCurGameManage():showClockToPlay(nextPositionType)
			end
		else
	    	local lastPositionType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,self.startData.LastPlayUserID)
	    	local nextPositionType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,self.startData.NextPlayUseID)

	    	if lastPositionType == nextPositionType then
				wwlog(self.logTag,"上个玩家ID和本次玩家ID相等 ")
				wwlog(self.logTag,"lastPositionType = %d,nextPositionType = %d",lastPositionType,nextPositionType)

	    		if nextPositionType == Player_Type.SelfPlayer then
	    			wwlog(self.logTag,"我出")
					GameManageFactory:getCurGameManage():showClockToPlay(nextPositionType,1,0,handler(self, self.requestPlayCard))
				else 
					GameManageFactory:getCurGameManage():showClockToPlay(nextPositionType)
				end 
				--其他有牌显示不出
				for k,v in pairs(Player_Type) do
					if v ~= nextPositionType then
						if #GameManageFactory:getCurGameManage():getCardByPosition(self.seatInfos,v) > 0 then 
							wwlog(self.logTag,"其他人有牌显示不出%d",v)
							GameManageFactory:getCurGameManage():playCard( v,{} )
						end
					end
				end
	    	else
				wwlog(self.logTag,"上个玩家ID和本次玩家ID不相等")
				wwlog(self.logTag,"lastPositionType = %d,nextPositionType = %d",lastPositionType,nextPositionType)

	    		--上家打的牌
	    		if lastPositionType == Player_Type.UpPlayer then
		    		GameManageFactory:getCurGameManage():setPlayCardsCount( Player_Type.UpPlayer, 
		    			#self.seatInfos.side1[2].pokerCards + #self.startData.LastPlayCards ) 
	    		elseif lastPositionType == Player_Type.LeftPlayer then
					GameManageFactory:getCurGameManage():setPlayCardsCount( Player_Type.LeftPlayer, 
						#self.seatInfos.side2[1].pokerCards + #self.startData.LastPlayCards ) 
	    		elseif lastPositionType == Player_Type.RightPlayer then
					GameManageFactory:getCurGameManage():setPlayCardsCount( Player_Type.RightPlayer, 
						#self.seatInfos.side2[2].pokerCards + #self.startData.LastPlayCards ) 
				end 
	    		GameManageFactory:getCurGameManage():playCard(lastPositionType,self.startData.LastPlayCards,self.startData.LastPlayCards)
	    
	    		local idx = findLoopIdx(lastPositionType,nextPositionType)
	    		--中间的有牌就不出
	    		for k,v in pairs(Player_Type) do
	    			for m,n in pairs(idx) do
	    				if v == n then
							if #GameManageFactory:getCurGameManage():getCardByPosition(self.seatInfos,v) > 0 then 
	    						wwlog(self.logTag,"显示不出玩家%d",n)
								GameManageFactory:getCurGameManage():playCard( v,{} )
							end
						end
	    			end
				end

	    		--轮到下家
				local typeCard,val = CardDetection.detectionType(self.startData.LastPlayCards)
				self.maxPlayCardType = typeCard
				self.maxPlayCardValue = val
				self.maxPlayCardUserId = self.startData.LastPlayUserID
	    		if nextPositionType == Player_Type.SelfPlayer then
					GameManageFactory:getCurGameManage():showClockToPlay(nextPositionType,self.maxPlayCardType,self.maxPlayCardValue,handler(self, self.requestPlayCard))
				else 
					GameManageFactory:getCurGameManage():showClockToPlay(nextPositionType)
				end 
	    	end
		end

		--队友有牌 我没牌 查看队友牌
		if #self.seatInfos.side1[2].pokerCards > 0 and #self.seatInfos.side1[1].pokerCards <= 0 then
			wwlog(self.logTag,"查看队友的牌")
			GameManageFactory:getCurGameManage():seeFriendPlayerCard(self.seatInfos.side1[2].pokerCards)
		end
	end

	if self.startData.Status == 1 then
		if self.startData.Jingong == 0 then --抗贡
			--d动画  TODO 消息通知服务端
			GameManageFactory:getCurGameManage():UnPayTribute(nextStep)
			--回调  handleFirstStep
		else --进贡流程			
			local doubleWin = false --是否存在双贡
			if self.seatInfos.side1[1].Ranking <=2 and
			self.seatInfos.side1[2].Ranking <=2 then
			--两个都在前两名
				doubleWin = true
			elseif self.seatInfos.side1[1].Ranking > 2 and
			self.seatInfos.side1[2].Ranking > 2 then
				--两个都在后两名
				doubleWin = true
			end
			
			for _,v in pairs(self.startData.players) do
				if v.UserID ~= self.seatInfos.side1[1].UserID then
					if doubleWin then --双贡
						if v.Ranking == 4 then --进贡
							if v.JGCards and next(v.JGCards) then
								GameManageFactory:getCurGameManage():OtherPlayerTributeCard(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID),v.JGCards)
							else
								GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.PayTribute)
							end
						else
							if v.JGCards and next(v.JGCards) then
								GameManageFactory:getCurGameManage():OtherPlayerTributeCard(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID),v.JGCards)
							else
								GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.RetTribute)
							end
						end
					else
						if v.Ranking == 4 then --进贡
							if v.JGCards and next(v.JGCards) then
								GameManageFactory:getCurGameManage():OtherPlayerTributeCard(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID),v.JGCards)
							else
								GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.PayTribute)
							end
						elseif v.Ranking == 1 then --退贡
							if v.JGCards and next(v.JGCards) then
								GameManageFactory:getCurGameManage():OtherPlayerTributeCard(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID),v.JGCards)
							else
								GameManageFactory:getCurGameManage():OtherPlayerTribute(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,v.UserID), PlayerStateType.RetTribute)
							end
						end
					end
				end
			end
			
			if self.seatInfos.side1[1].Ranking == 4 then
				--判断是否第四名 需要进贡选牌
				if self.seatInfos.side1[1].JGCards and next(self.seatInfos.side1[1].JGCards) then
					GameManageFactory:getCurGameManage():OtherPlayerTributeCard(Player_Type.SelfPlayer,self.seatInfos.side1[1].JGCards)
				else
					local jgCallBack = function( choosePoker )
						wwlog(self.logTag, "发送进贡消息")
						self:handleTributeChoose(choosePoker, 1)
					end
					GameManageFactory:getCurGameManage():PayTribute(jgCallBack,self.startData.NextPlayTimeout)
				end
			elseif (self.seatInfos.side1[1].Ranking == 1) 
				or ( doubleWin and (self.seatInfos.side1[1].Ranking == 2)) then
				--第一名 或者  双贡的第二名要退贡
				if self.seatInfos.side1[1].JGCards and next(self.seatInfos.side1[1].JGCards) then
					GameManageFactory:getCurGameManage():OtherPlayerTributeCard(Player_Type.SelfPlayer,self.seatInfos.side1[1].JGCards)
				else
					local hgCallBack = function( choosePoker )
						wwlog(self.logTag, "发送还贡消息")
						self:handleTributeChoose(choosePoker, 2)
					end
					GameManageFactory:getCurGameManage():RetTribute(hgCallBack,self.startData.NextPlayTimeout)
				end
			end
		end
	else
		GameManageFactory:getCurGameManage():setResumeGameTime(self.startData.NextPlayTimeout) --打牌剩余时间
		nextStep()
	end
    Classical.super.baseResumeGameGame(self,self.startData)
end

function Classical:setPlayerState(playerType,userType)
	wwlog(self.logTag, "设置玩家是否托管"..playerType..","..userType)
	GameManageFactory:getCurGameManage():playerTrShipState(playerType,userType == User_Type.SUBSTITUTE_BACK or userType == User_Type.SUBSTITUTE_ACTIVE )
end

--桌子状态改变
function Classical:handleTableState(eventid)
	local stateTable = DataCenter:getData(eventid)
	wwlog(self.logTag,"状态改变通知收到了")
	if not stateTable or stateTable.Type == nil or stateTable.UserID==nil then
		return
	end
	wwlog(self.logTag,"%s 状态改变拉 %d",stateTable.UserID,stateTable.Type)
	if stateTable.Type==2 then
		GameManageFactory:getCurGameManage():playerLeave(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,stateTable.UserID))
		GameManageFactory:getCurGameManage():setRank(Player_Type.LeftPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.RightPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.SelfPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.UpPlayer,0)
	elseif stateTable.Type==1 then
		--这个地方需要考虑进来的是之前的人还是后边匹配的人
		GameManageFactory:getCurGameManage():playerReady(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,stateTable.UserID))
	end
end

function Classical:handleHoldAward(eventid)
	local holdtable = DataCenter:getData(eventid)
	if not holdtable then
		return
	end
	--通过游戏区域 找name
	local hallist = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	if hallist and hallist[2] then
		local gamezones= hallist[2].looptab1
		if gamezones then
			for _,v in ipairs(gamezones) do
				if v.GameZoneID==holdtable.GameZoneID then
					holdtable.Name = v.Name
					break
				end
			end
		end
	end
	
	holdtable.Name = holdtable.Name or ""
	GameManageFactory:getCurGameManage():levelUpSettlement(holdtable)
end

function Classical:handleUserInfo(eventid,reqUserid)
	if not self.StartGame then
		return
	end
	wwlog(self.logTag, "显示玩家头像信息"..tostring(eventid)..","..tostring(reqUserid))
	local userinfoTables = DataCenter:getData(eventid)
	if not userinfoTables or not userinfoTables[reqUserid] then
		return
	end
	if GameManageFactory:getCurGameManage().reqUserId ~=nil and 
		userinfoTables[GameManageFactory:getCurGameManage().reqUserId] then
		local playerType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos,GameManageFactory:getCurGameManage().reqUserId)
		userinfoTables[GameManageFactory:getCurGameManage().reqUserId].fileName = "guandan/head_boy.png"
		GameManageFactory:getCurGameManage():checkPlayInfo(playerType,userinfoTables[GameManageFactory:getCurGameManage().reqUserId])
	end
end

return Classical