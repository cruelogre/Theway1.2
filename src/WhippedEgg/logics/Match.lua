-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  
-- Date:    2016.09.18
-- Last: 
-- Content:  比赛玩法逻辑处理  这里不做任何UI或数据相关处理，单纯的业务逻辑处理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Match = class("Match",require("WhippedEgg.logics.RoomBase"))

local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local CardDetection = require("WhippedEgg.CardDetection")

local GDPokerUtil = import(".GDPokerUtil","WhippedEgg.util.")

function Match:ctor()
	self.netHandlers = {}
	Match.super.ctor(self)
end

function Match:init()
	self.logTag = "Match.lua"

	--这里要判断一下信息是否已经进来了 最后一个人进来的时候 数据最先过来
	local matchstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
	if matchstart and next(matchstart) then
		local event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART }
		wwlog(self.logTag, "进来前就收到比赛开局消息")
		self:commondEventHandle(event)
		-- DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
	else
	 	matchstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
	 	if matchstart and next(matchstart) then
	 		local event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME }
			wwlog(self.logTag, "进来前就收到比赛恢复对局消息")
			self:commondEventHandle(event)
			-- DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
	 	end
	end

	
	local _,handler1 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD,handler(self,self.commondEventHandle))
	local _,handler2 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_SUBSTITUTE,handler(self,self.commondEventHandle))
	local _,handler3 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART,handler(self,self.commondEventHandle))
	local _,handler4 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMEOVER,handler(self,self.commondEventHandle))
	local _,handler5 = WhippedEggCfg.innerEventComponent:addEventListener(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME,handler(self,self.commondEventHandle))
	
	
	local _,handler6 = WhippedEggCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED,handler(self,self.commondEventHandle))
	local _,handler7 = WhippedEggCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS,handler(self,self.commondEventHandle))
	local _,handler8 = WhippedEggCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_UPGRADE,handler(self,self.commondEventHandle))
	local _,handler9 = WhippedEggCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_RANK_CHANGE,handler(self,self.commondEventHandle))
	local _,handler10 = WhippedEggCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_ELIMINATE_CHANGE,handler(self,self.commondEventHandle))
	
	local _,handler11 = NetWorkCfg.innerEventComponent:addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL,handler(self,self.commondEventHandle))
	
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

	table.insert(self.netHandlers,handler11)
end

--重新滞空
function Match:recycle()
	if NetWorkCfg.innerEventComponent then
		if self.netHandlers then
			for _,handlerX in pairs(self.netHandlers) do
				NetWorkCfg.innerEventComponent:removeEventListener(handlerX)
			end
		end
	end

	Match.super.recycle(self)

	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)

	WhippedEggSceneProxy.InstMatchID = 0
end

function Match:createCardRecorder( ... )
	
end

function Match:commondEventHandle(event)
	wwlog(self.logTag, "掼蛋玩法消息回调处理"..event.name)
	if event.name == WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART then --开局
		wwlog(self.logTag,"比赛 开局")

		self:handleStartGame(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD then --打牌
		wwlog(self.logTag,"比赛 打牌")

		self:handlePlayCard(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMEOVER then --结束
		self:handleGameOver(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_SUBSTITUTE then --托管
		self:handleSubstitute(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED then --淘汰
		self:handleObsoleted(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS then --等待其他玩家
		self:waitOthers(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_UPGRADE then --晋级下一轮拉
		self:updrade(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_RANK_CHANGE then --玩家名次变化
		self:rankChange(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_ELIMINATE_CHANGE then --玩家淘汰人数变化
		self:eliminateChange(event.name)
	elseif event.name == WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME then --比赛恢复对局
		wwlog(self.logTag,"比赛 恢复对局")

		self:handleResumeMatch(event.name)
	elseif event.name == MatchCfg.InnerEvents.MATCH_EVENT_DETAIL then --刷新比赛详情
		self:handleMatchDetail(event.name,event._userdata)
	end
end

function Match:handleMatchDetail(eventid,msgTable)
	--WhippedEggSceneProxy.gamezoneid
	if msgTable.MatchID == WhippedEggSceneProxy.gamezoneid then
		wwlog(self.logTag,"游戏里边收到比赛详情更新 组队消息%d",msgTable.TeamWork)
		local ismutiple = (msgTable.TeamWork == 1)
		GameManageFactory:getCurGameManage().teamType = ismutiple and Team_Type.TEAM_MUTIPLE or Team_Type.TEAM_SINGLE

		if GameManageFactory:getCurGameManage().MyPlayer then
			GameManageFactory:getCurGameManage().MyPlayer:teamTypeChange()
		end

		if GameManageFactory:getCurGameManage().gameState == GameStateType.MathcWaitOther then
			GameManageFactory:getCurGameManage():getMatchWaitLayer():teamTypeChange()
		end
	end
end

--[[
比赛开局消息收到后的处理,我方进退恭逻辑处理
--]]
function Match:handleStartGame(eventid)
	wwlog(self.logTag, "比赛开局处理")

	if GameManageFactory:getCurGameManage():getSettlementLayer():isHaveSettmentLayer() then
		wwlog(self.logTag, "缓存比赛开局处理")
		GameManageFactory:getCurGameManage().newStartGame = true
		return
	end

	if self.StartGame then
		return
	end
	self.StartGame = true -- 已经收到开局信息
	self.showAll1 = {false,false}
	self.showAll2 = {false,false}
	
	removeAll(self.currentRanks)
	self.currentRanks = {}
	GameManageFactory:getCurGameManage():SettlementReset()
	-- 根据玩家信息排桌
	self.startData = DataCenter:getData(eventid)
	--存储开赛信息
	DataCenter:cacheData(COMMON_EVENTS.C_EVENT_GAMEDATA,{GamePlayID = self.startData.GamePlayID,InstMatchID = self.startData.InstMatchID })
	
	wwlog(self.logTag, "设置头像桌面玩家信息")
	self.seatInfos = GameManageFactory:getCurGameManage():getSeatsInfo(self.startData.players)  --几个玩家分边后的数据
	--将排座信息存入 GameManage  (一个游戏回合需要修改)
	GameManageFactory:getCurGameManage():setCruGameSeatInfo(self.seatInfos)

	local trump = self.startData.Trump
	GameManageFactory:getCurGameManage():setPlayCardInfo(trump, trump)
	GameManageFactory:getCurGameManage():setGetRcircleCardPeople(self.startData.TCUserID1, self.startData.TCUserID2)
	if self.startData.TrumpCard and next(self.startData.TrumpCard) ~= nil then
		GameManageFactory:getCurGameManage():setPlayCardColor(self.startData.TrumpCard[1].color)
	end

	if self.startData.PlayType == Play_Type.RandomGame then
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

	local data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_START_DATA)
	if not data then
	 	data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE)
	end
	local number = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_UPGRADE) --晋级人数
	local matchall = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL) --比赛详情
	local tNumber = number == nil and 0 or tonumber(number.RespInfo)
	
	if tNumber == 0 then --没有晋级消息  从比赛详情
		--WhippedEggSceneProxy
		--WhippedEggSceneProxy.gamezoneid --存放的是matchid
		local matchdata = matchall[WhippedEggSceneProxy.gamezoneid]
		if matchdata then
			if tonumber(matchdata.BeginType)==1 then
				tNumber = tonumber(matchdata.Requirement)
			else
				tNumber = tonumber(matchdata.EnterCount)
			end
			
		else
			wwlog(self.logTag,"出异常拉",WhippedEggSceneProxy.gamezoneid)
		end
		if not tNumber then
			wwlog(self.logTag,"出异常拉111",matchdata.EnterCount)
			
		end
		
	end
	local setplays = string.split(data.RespInfo,"/") --轮次/局数/每轮晋级人数
	--setplays[3] 每轮晋级人数
	local jinjiarr = string.split(setplays[3],",")
	--data.data
	local info = {
		SetNo = self.startData.SetNo, --本赛段第几轮
		PlayNo = self.startData.PlayNo, --本轮第几局
		MRanking = self.seatInfos.side1[1].MRanking, --我的排名
		TotalNumber = tonumber(data.Param1), --当前有多少人  这里设置的是第一轮第一局的
		TotalSet = setplays[1] and tonumber(setplays[1]) or 0, --一共多少轮
		TotalPlay = setplays[2] and tonumber(setplays[2]) or 0, --一共多少局
		everyUpInfo = setplays[3] and tonumber(setplays[3]) or 0, --每轮晋级人数
		upgradeInfo = tonumber(jinjiarr[self.startData.SetNo]), --晋级条件
	}
	if tonumber(self.startData.SetNo)>1 and tonumber(jinjiarr[self.startData.SetNo-1]) >0 then
		info.TotalNumber = tonumber(jinjiarr[self.startData.SetNo-1])
	end
	GameManageFactory:getCurGameManage():setMySelfMatchInfo(info)

	--开局默认设置头像
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.SelfPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.LeftPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.RightPlayer,false)
	GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.UpPlayer,false)
	GameManageFactory:getCurGameManage():readyDealCard(self.seatInfos.side1[1].baseCards, handler(self, self.handleFirstStep))

	local ScoreBase = self.startData.ScoreBase or 0 --设置底分（从开局消息中，取出打几的信息）
	GameManageFactory:getCurGameManage():setRoomPoint(ScoreBase)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.SelfPlayer,self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.UpPlayer,self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.LeftPlayer,self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayerInfo(Player_Type.RightPlayer,self.seatInfos)
    Match.super.baseStartGame(self,self.startData)
end

--结算
function Match:handleGameOver(eventid)
	if not self.StartGame then
		return
	end
	self.StartGame = false
	
	Match.super.handleGameOver(self,eventid)
end	

function Match:handleResumeMatch(eventid)
	--恢复对局	
	Match.super.resumeGameSet(self)
	
	wwlog(self.logTag, "比赛恢复对局处理1")
	if GameManageFactory:getCurGameManage():getSettlementLayer():isHaveSettmentLayer() then
		GameManageFactory:getCurGameManage().newStartGame = true
		return
	end
	wwlog(self.logTag, "比赛恢复对局处理2")

	self.StartGame = true
	self.showAll1 = {false,false}
	self.showAll2 = {false,false}
	--恢复对局的时候请求一下比赛详情
	-- 根据玩家信息排桌
	self.startData = DataCenter:getData(eventid)
	MatchProxy:requestMatchDetail(self.startData.MatchID)

	--没有玩家数据 在等待界面
	if not next(self.startData.players) then
		wwlog(self.logTag,"恢复对局的时候，本轮打完了，等待其他玩家")
		MatchProxy.restoreMatchId = self.startData.MatchID
		GameManageFactory:getCurGameManage().newResumeGame = true
		local data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE)
		local setplays = string.split(data.RespInfo,"/") --轮数信息
			--data.data
		local info = {
			SetNo = self.startData.SetNo, --本赛段第几轮
			PlayNo = self.startData.PlayNo, --本轮第几局
			MRanking = self.startData.MRanking or 0, --我的排名
			TotalNumber = self.startData.PlayerCount, --当前有多少人
			TotalSet = setplays[1] and tonumber(setplays[1]) or 0, --一共多少轮
			TotalPlay =  setplays[2] and tonumber(setplays[2]) or 0, --一共多少局
			upgradeInfo = self.startData.WinCount, --晋级条件
		}
		GameManageFactory:getCurGameManage():setMySelfMatchInfo(info)
		return
	end
	wwlog(self.logTag, "设置头像桌面玩家信息")
	self.seatInfos = GameManageFactory:getCurGameManage():getSeatsInfo(self.startData.players)  --几个玩家分边后的数据
	
	--将排座信息存入 GameManage  (一个游戏回合需要修改)
	GameManageFactory:getCurGameManage():setCruGameSeatInfo(self.seatInfos)
	GameManageFactory:getCurGameManage():setPlayCardTime(self.startData.PlayTimeout)
	GameManageFactory:getCurGameManage():setResumeGameTime(self.startData.NextPlayTimeout)
	GameManageFactory:getCurGameManage():setRoomName(self.startData.MatchName)
	
	wwlog(self.logTag, "设置底分")
	local scoreBase = self.startData.ScoreBase or 0 --设置底分（从开局消息中，取出打几的信息）
	local mySidePokermNow = self.startData.Trump or 0  --排座后自己打几
	local otherSidePokermNow = self.startData.Trump or 0   --排座后对方打几

	local isPlayerBankerType = lightWiner.winerAll
	if self.startData.PlayType == Play_Type.RandomGame then
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
	GameManageFactory:getCurGameManage():recoverysetCurGamePlayNum( scoreBase,mySidePokermNow,otherSidePokermNow,isPlayerBankerType ) --房间底分，我们打几，对方打几，本局是不是打我们的数字
	
	local data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE)
	local setplays = string.split(data.RespInfo,"/") --轮数信息
		--data.data
	local info = {
		SetNo = self.startData.SetNo, --本赛段第几轮
		PlayNo = self.startData.PlayNo, --本轮第几局
		MRanking = self.seatInfos.side1[1].MRanking, --我的排名
		TotalNumber = self.startData.PlayerCount, --当前有多少人
		TotalSet = setplays[1] and tonumber(setplays[1]) or 0, --一共多少轮
		TotalPlay =  setplays[2] and tonumber(setplays[2]) or 0, --一共多少局
		upgradeInfo = self.startData.WinCount, --晋级条件
	}
	
	wwdump(info,"恢复对局座位信息")
	GameManageFactory:getCurGameManage():setMySelfMatchInfo(info)
	
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
    Match.super.baseResumeGameGame(self,self.startData)
	nextStep()
end

function Match:setPlayerState(playerType,userType)
	wwlog(self.logTag, "设置玩家是否托管"..playerType..","..userType)
	GameManageFactory:getCurGameManage():playerTrShipState(playerType,userType == User_Type.SUBSTITUTE_BACK or userType == User_Type.SUBSTITUTE_ACTIVE)
end

function Match:handleObsoleted(eventid)
	wwlog(self.logTag,"我尼玛被淘汰了1")
	WhippedEggSceneProxy.InstMatchID = 0
	wwlog(self.logTag,"我尼玛被淘汰了2")
	self.StartGame = false
	GameManageFactory:getCurGameManage().newStartGame = false
	GameManageFactory:getCurGameManage().newResumeGame = false
	local data = DataCenter:getData(eventid)
	local magics = self:getMatchAward(data.matchid,data.MRanking)
	local info  = {MRanking = data.MRanking,name = data.matchname }
	if not info.name or string.len(info.name)==0 then
		local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
		local tempmatchData =allMtchData[data.matchid]
		info.name = tempmatchData.Name
	end
	info.awardlist = magics
	
	GameManageFactory:getCurGameManage():matchOver(info)
end

function Match:waitOthers(eventid)
	--如果有被淘汰的消息
	local obsoletedData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED)
	if obsoletedData and next(obsoletedData) then
		wwlog(self.logTag,"我已经被淘汰了，不用等了")
		return
	end
	local otherdata = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS_RANKDATA)
	wwdump(otherdata,"本轮打完了，等待其他玩家"..eventid)
	local data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_START_DATA)
	if not data then
	 	data = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE)
	end
	wwdump(data,"本轮打完了，等待其他玩家 MATCH_EVENT_RESTORE_SCENE")
	local setplays = string.split(data.RespInfo,"/") --轮次/局数/每轮晋级人数
	--setplays[3] 每轮晋级人数
	local jinjiarr = string.split(setplays[3],",")
	local info = {}
	--要放总人数
	table.insert(info,tonumber(data.Param1))
	
	for _,v in pairs(jinjiarr) do
		table.insert(info,tonumber(v))
	end
	GameManageFactory:getCurGameManage():setRoomName(data.MatchName)
	GameManageFactory:getCurGameManage():waitOtherPlayer(info)
	if otherdata then
		wwlog(self.logTag,"本轮打完了,还有桌"..tonumber(otherdata.Param1))
		GameManageFactory:getCurGameManage():setLetfDesk(tonumber(otherdata.Param1))

		local matchRank = string.split(otherdata.RespInfo,"/") 
		GameManageFactory:getCurGameManage():setMatchRank({MRanking = matchRank[1],TotalNumber = matchRank[2] })
	else
		wwlog("比赛等待界面能把我想要的信息给我不？？？？？？？？ ")
	end
end

function Match:updrade(eventid)
	wwlog(self.logTag,"我靠，我晋级了")
end

function Match:rankChange(eventid)
	wwlog(self.logTag,"名次变化通知")
	if not self.StartGame then
		return
	end
	local rankTable = DataCenter:getData(eventid)
	local ranks = string.split(rankTable.data,"/")
	local info  ={
		MRanking = ranks[1] and tonumber(ranks[1]) or 0, --一共多少轮, --我的排名
		TotalNumber = ranks[2] and tonumber(ranks[2]) or 0, --一共多少轮, --当前有多少人
	}
	GameManageFactory:getCurGameManage():setMatchRank(info)
end

function Match:eliminateChange(eventid)
	if not self.StartGame then
		return
	end
	local eliminateCount = DataCenter:getData(eventid).data
	wwlog(self.logTag,"淘汰人数变化通知 %d", eliminateCount)
	GameManageFactory:getCurGameManage():setMatcheliminateCount(eliminateCount)
end

--获取比赛奖励 物品ID
--@param mid 比赛ID 
--@param rankNo 我的排名
function Match:getMatchAward(mid,rankNo)
	local awardlist = {}
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	if tempmatchData and tempmatchData.awardList then
		for _,awardata in pairs(tempmatchData.awardList) do
			if rankNo>=awardata.BeginRankNo and rankNo<=awardata.EndRankNo then
				if awardata.magicList and type(awardata.magicList)=="table" then
					for _,v in ipairs(awardata.magicList) do
						if v.FID~=0 then
							table.insert(awardlist,v)
						end
					end
					break
				end
				break
			end
			
		end
	end
	
	return awardlist
end

return Match