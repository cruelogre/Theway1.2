-------------------------------------------------------------------------
-- Desc:    
-- Author:  diyal.yin
-- Date:    2016.08.13
-- Last:    
-- Content:  常见数据中心结构定义  不允许自己用，需要再DataCenter中获取实例
-- 20160809  新建
-- 20160809  添加大厅协议数据，并且将登录后收到的玩家信息存到用户数据中心
-- 20170217  恢复对局的时候重新拉取大厅个人数据
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local WhippedEggSceneProxy = class("WhippedEggSceneProxy",require("packages.mvc.Proxy"))
local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local GDPokerUtil = import(".GDPokerUtil","WhippedEgg.util.")

local GDPlayCardRequest = require("WhippedEgg.request.GDPlayCardRequest")
local GDTributeRequest = require("WhippedEgg.request.GDTributeRequest")
local GDSubstituteRequest = require("WhippedEgg.request.GDSubstituteRequest")
local GDUserInfoRequest = require("WhippedEgg.request.GDUserInfoRequest")

local ChooseRoomRequest = require("hall.request.ChooseRoomRequest")
local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")

local Toast = require("app.views.common.Toast")
require("WhippedEgg.ConstType")

function WhippedEggSceneProxy:init()
	self.gamezoneid = 0
	self.fortuneBase  = 0
	self.GamePlayID = 0
	self.InstMatchID = 0
	self.logTag = "WhippedEggSceneProxy.lua"
	wwlog(self.logTag, "WhippedEggSceneProxy.lua init")

	self.gdGameMsgModel = import(".GDGameModel", "WhippedEgg.Model."):create(self) --消息实体
	self._gdmatchModel = require("hall.model.GDMatchModel"):create(self) --比赛消息
	self._hallNetModel = require("hall.model.HallNetModel"):create(self)
	
	self:registerMsg()

end

function WhippedEggSceneProxy:registerMsg()
	
	--开局
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDGameStart_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
	--进贡
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDTribute_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_TRIBUTE)
	--交换牌
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDExchangerCard_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_EXCHANGECARD)
	--打牌
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDPlayCard_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD)
	--游戏结束
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDGameOver_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_GAMEOVER)
	--恢复对局
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDResumeGame_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
	
	--续局中玩家状态改变通知
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDTableUserState_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_TABLESTATE)
	
	--托管消息
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDTrusteeship_Ret,
	handler(self, self.response),WhippedEggCfg.InnerEvents.GD_EVENT_TABLESTATE)
	
	--打到结算分
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDHoldAward_Ret,
	handler(self,self.response),WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_HOLDAWARD)
	
	--玩家信息
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDGamePlayerInfo_Ret,
	handler(self,self.response),WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP)
	--比赛开局
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchGameStart_Ret,
	handler(self,self.response),WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
	--比赛结算
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchGameOver_Ret,
	handler(self,self.response),WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMEOVER)
	
	--比赛恢复对局
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchResumeGame_Ret,
	handler(self,self.response),WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
	
	--
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchNotifyUser_Ret,handler(self,self.response))
	
	
	
	--self:registerRootMsgId(self._hallNetModel.MSG_ID.Msg_GDHallAction_send,handler(self, self.normalResponse))
	self:registerRootMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDPlayCard_Send,handler(self, self.normalResponse))
	self:registerRootMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDTribute_Send,handler(self, self.normalResponse))
	self:registerRootMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDPlayCard_Ret,handler(self, self.normalResponse))
	
	self:registerRootMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDTrusteeship_Ret,handler(self, self.normalResponse))
	--self:registerRootMsgId
end

function WhippedEggSceneProxy:normalResponse(msgId,msgTable)
	print(msgTable)
	dump(msgTable)
	if msgTable.msgId and msgTable.kResult==1 then
		Toast:makeToast(tostring(msgTable.msgId),1.0):show()
	end
end

function WhippedEggSceneProxy:response(msgId, msgTable)
	local dispatchEventId = nil
	local dispatchData = nil

	--有消息过来就不用退出游戏 BUG #19745 【经典】即将进入结算界面时，按home键后台运行程序，进入结算界面后再启动程序，界面卡在了牌局界面
	if MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic then 
		MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic.canReturnBack = false
	end

	if msgId==self.gdGameMsgModel.MSG_ID.Msg_GDGameStart_Ret then --游戏开局
		wwlog(self.logTag,"经典对局开始委托消息处理")
		wwplyaCardLog("-------------------------对局开局--------------------")

		self.GamePlayID = msgTable.GamePlayID
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART
		dispatchData = self:handleGameStart(msgTable)
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDTribute_Ret then --进贡
		if not self:compareGamePlayId(msgTable.GamePlayID,"进贡") then
			return
		end
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_TRIBUTE
		dispatchData = self:handleTribute(msgTable)
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDExchangerCard_Ret then --交换牌
		if not self:compareGamePlayId(msgTable.GamePlayID,"交换牌") then
			return
		end
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_EXCHANGECARD
		dispatchData = self:handleExchangeCard(msgTable)
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDPlayCard_Ret then --打牌
		if not self:compareGamePlayId(msgTable.GamePlayID,"打牌") then
			return
		end
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_PLAYCARD
		dispatchData = self:handlePlayCard(msgTable)
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDGameOver_Ret then --经典游戏结束
		wwplyaCardLog("-------------------------结束对局--------------------")

		if not self:compareGamePlayId(msgTable.GamePlayID,"经典游戏结束") then
			return
		end
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_GAMEOVER
		dispatchData = self:handleGameOver(msgTable)
		WWFacade:dispatchCustomEvent(require("hall.mediator.cfg.RoomChatCfg").InnerEvents.RMCHAT_EVENT_CLOSEUI)
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDResumeGame_Ret then --恢复对局
		wwlog(self.logTag,"经典恢复对局委托消息处理")
		wwplyaCardLog("-------------------------恢复对局--------------------")

		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME
		dispatchData = self:handleResumeGame(msgTable)
		self.GamePlayID = msgTable.GamePlayID
		--恢复对局数据重新拉取  Modified By cruelogre 2017/2/17
		self:getHallProxy():getHallDatas()
		
	elseif msgId==self.gdGameMsgModel.MSG_ID.Msg_GDTableUserState_Ret then --续局状态改变
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_TABLESTATE
		dispatchData = self:handleTableState(msgTable)
	elseif msgId == self.gdGameMsgModel.MSG_ID.Msg_GDTrusteeship_Ret then --托管
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_SUBSTITUTE
		dispatchData = self:handleSubstitute(msgTable)
	elseif msgId == self.gdGameMsgModel.MSG_ID.Msg_GDHoldAward_Ret then --打到结算分
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_HOLDAWARD
		dispatchData = msgTable
		WWFacade:dispatchCustomEvent(require("hall.mediator.cfg.RoomChatCfg").InnerEvents.RMCHAT_EVENT_CLOSEUI)
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchGameStart_Ret then --比赛开局
		wwlog(self.logTag,"比赛对局开局%d %d",self.InstMatchID,msgTable.InstMatchID)
		wwplyaCardLog("-------------------------对局开局--------------------")

  		if self.InstMatchID == msgTable.InstMatchID then
			dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART
			dispatchData = self:handleMatchStartGame(msgTable)
			self.GamePlayID = msgTable.GamePlayID
		else
			wwlog("开局没有给你一样的InstMatchID啊 二湿兄！！！！")
		end
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchGameOver_Ret then  --比赛结束
		wwlog(self.logTag,"比赛对局结束%d %d",self.InstMatchID,msgTable.InstMatchID)

		wwplyaCardLog("-------------------------结束对局--------------------")
		
		if self.InstMatchID == msgTable.InstMatchID then
			dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMEOVER 
			dispatchData = self:handleMatchGameOver(msgTable)
		else
			wwlog("结束没有给你一样的InstMatchID啊 二湿兄！！！！")
		end
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchNotifyUser_Ret then --比赛通知
		--dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMEOVER
		--dispatchData = self:handleMatchGameOver(msgTable)
		wwlog(self.logTag,"比赛通知%d  %d",self.InstMatchID,msgTable.InstMatchID)
		dispatchEventId,dispatchData = self:handleMatchNotify(msgTable)

		if self.InstMatchID == 0 and msgTable.Type == 11 then --开赛
			self.InstMatchID = msgTable.InstMatchID
		end
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchResumeGame_Ret then --比赛恢复对局
		wwlog(self.logTag,"比赛恢复对局委托消息处理")
		wwplyaCardLog("-------------------------恢复对局--------------------")

		self.InstMatchID = msgTable.InstMatchID
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME
		dispatchData = self:handleMatchResumeGame(msgTable)
		self.GamePlayID = msgTable.GamePlayID

		--请求一次比赛详情
		ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH):requestMatchDetail(dispatchData.MatchID)
		--恢复对局数据重新拉取  Modified By cruelogre 2017/2/17
		self:getHallProxy():getHallDatas()
	elseif msgId == self.gdGameMsgModel.MSG_ID.Msg_GDGamePlayerInfo_Ret then --返回用户请求数据
		dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP
		dispatchData = self:handleUserinfo(dispatchEventId,msgTable)
	end
	--存入缓存中
	if dispatchEventId and dispatchData and type(dispatchData)=="table" then
		--DataCenter:clearData(dispatchEventId)
		local temp = {}
		copyTable(dispatchData,temp)
		DataCenter:cacheData(dispatchEventId,temp)
		
	end
	--恢复对局
	if FSRegistryManager.curFSMName ~= FSMConfig.FSM_WHIPPEDEGG then
		if msgId==self.gdGameMsgModel.MSG_ID.Msg_GDResumeGame_Ret then
			if dispatchData.GameZoneID == 0 then --私人房
				wwlog(self.logTag,"发送进入游戏事件 私人房恢复对局%s",msgId)
       	 		local sirenData = DataCenter:getData(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)

				local gameType = Game_Type.PersonalPromotion
				if sirenData.Playtype == Play_Type.PromotionGame then
					gameType = Game_Type.PersonalPromotion
				elseif sirenData.Playtype == Play_Type.RandomGame then
					gameType = Game_Type.PersonalRandom
				elseif sirenData.Playtype == Play_Type.RcircleGame then
					gameType = Game_Type.PersonalRcircle
				end
				WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,gameType,sirenData.RoomID,sirenData.DWinPoint,sirenData.MasterID,sirenData.MultipleData)
			else --经典房
				wwlog(self.logTag,"发送进入游戏事件 经典恢复对局%s",msgId)
				local gameType = Game_Type.ClassicalPromotion
				if dispatchData.PlayType == Play_Type.PromotionGame then
					gameType = Game_Type.ClassicalPromotion
				elseif dispatchData.PlayType == Play_Type.RandomGame then
					gameType = Game_Type.ClassicalRandomGame
				elseif dispatchData.PlayType == Play_Type.RcircleGame then
					gameType = Game_Type.ClassicalRcircleGame
				end
				WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,gameType,dispatchData.GameZoneID,dispatchData.FortuneBase)
			end
		elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchResumeGame_Ret then --比赛恢复对局
			local jumpType = nil
			if dispatchData.PlayType == Play_Type.RandomGame then
				local btype = tonumber(dispatchData.BeginType)
				if btype == 1 then --定人赛
					jumpType = Game_Type.MatchRamdomCount
				elseif btype == 2 then --定时赛
					jumpType = Game_Type.MatchRamdomTime
				end
			elseif dispatchData.PlayType == Play_Type.RcircleGame then
				local btype = tonumber(dispatchData.BeginType)
				if btype == 1 then --定人赛
					jumpType = Game_Type.MatchRcircleCount
				elseif btype == 2 then --定时赛
					jumpType = Game_Type.MatchRcircleTime
				end
			end

			if jumpType then
				WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,jumpType,dispatchData.MatchID,0)
				wwlog(self.logTag,"发送进入游戏事件 比赛恢复对局%s",msgId)
			end
		end
	end

	
	--发送消息
	if dispatchEventId and WhippedEggCfg.innerEventComponent then
		WhippedEggCfg.innerEventComponent:dispatchEvent({
					name = dispatchEventId;
					_userdata = dispatchData;
					
				})
	end
	
end

function WhippedEggSceneProxy:compareGamePlayId( id,str)
	-- body
	if id then
		if self.GamePlayID == id  then
			return true
		else
			wwlog("本次牌局id 和你消息中牌局id  不一样啊！！！！！！"..str)
			return false
		end
	else
		return true
	end
end

function WhippedEggSceneProxy:handleGameStart(msgTable)
	if not msgTable.playerArr then
		return nil
	end
  
	local gamestartData = {}
	gamestartData.GamePlayID = msgTable.GamePlayID --对局标志
	gamestartData.PlayType = msgTable.PlayType --游戏玩法
	gamestartData.ZoneWin = msgTable.ZoneWin --输赢财富类型
	gamestartData.FortuneBase = msgTable.FortuneBase --财富计算底数
	gamestartData.Trump = msgTable.Trump --本局主牌 
	gamestartData.ContinueFlag = msgTable.ContinueFlag --是否续局
	gamestartData.Upgrade = msgTable.Upgrade --续局的上升了多少级
	gamestartData.PlayTimeout = msgTable.PlayTimeout --出牌步时
	gamestartData.FHTimeout = msgTable.FHTimeout --首个出牌步时
	gamestartData.JGTimeout = msgTable.JGTimeout --进贡步时
	gamestartData.Jingong = msgTable.Jingong -- 进贡标识 是否进贡
	
	gamestartData.players = {}
	for _,playerdata in pairs(msgTable.playerArr) do
		local player = {}
		--直接copy过来
		copyTable(playerdata,player)
		if gamestartData.PlayType == Play_Type.RcircleGame or gamestartData.PlayType == Play_Type.RandomGame then
			player.PlayLevel = gamestartData.Trump
		end
		--底牌  这个数据是解析之后的新家的字段
	--	wwlog("gamestartData",playerdata.UserID)
		player.baseCards = GDPokerUtil.parseServerData(playerdata.card)
		table.insert(gamestartData.players,player)
	end
	gamestartData.NextPlayerID = msgTable.NextPlayerID -- 首个出牌的玩家
	gamestartData.TrumpCard = GDPokerUtil.parseServerData(string.char(msgTable.TrumpCard)) -- 团团转打几
	gamestartData.TCUserID1 = msgTable.TCUserID1 -- 第一个发主牌玩家
	gamestartData.TCUserID2 = msgTable.TCUserID2 -- 第二个发主牌玩家

	return gamestartData
end

function WhippedEggSceneProxy:handleTribute(msgTable)
	local tributeTable = {}
	tributeTable.GamePlayID = msgTable.GamePlayID --对局标识
	tributeTable.Type = msgTable.Type -- 1 进贡 2 返回牌给进贡方 3 抗贡
	tributeTable.UserID = msgTable.UserID -- 用户ID
	--tributeTable.card = msgTable.Card --进贡或者返回的牌
	tributeTable.pokerCard = GDPokerUtil.parseServerData(string.char(msgTable.Card))
	tributeTable.NextPlayerID = msgTable.NextPlayerID --首先出牌玩家ID

	
	return tributeTable
end
function WhippedEggSceneProxy:handleExchangeCard(msgTable)
	
	local exchangeCardTable = {}
	exchangeCardTable.GamePlayID = msgTable.GamePlayID --对局标识
	exchangeCardTable.exchangeArr = {}
	if msgTable.exchangeArr then
		for _,exchangedata in pairs(msgTable.exchangeArr) do
			local exchanged = {}
			exchanged.pokerCard = GDPokerUtil.parseServerData(string.char(exchangedata.card))
			copyTable(exchangedata,exchanged)
			
			table.insert(exchangeCardTable.exchangeArr,exchanged)
		end
	end
	
	exchangeCardTable.NextPlayerID = msgTable.NextPlayerID --首先出牌玩家ID
	
	return exchangeCardTable
end
function WhippedEggSceneProxy:handlePlayCard(msgTable)

	local playerCardTable = {}
	--dump(msgTable)
	playerCardTable.GamePlayID = msgTable.GamePlayID --对局标识
	playerCardTable.UserID = msgTable.UserID -- 用户ID
	--playerCardTable.card = msgTable.Card --进贡或者返回的牌
	--打出的实际牌
	playerCardTable.pokerCard = GDPokerUtil.parseServerData(tostring(msgTable.Card))
	--替换后的牌
	playerCardTable.replaceCard = GDPokerUtil.parseServerData(tostring(msgTable.ReplaceCard))
	
	playerCardTable.NextPlayUseID = msgTable.NextPlayUseID --下一个出牌玩家ID
	playerCardTable.Flag = msgTable.Flag  --接风标志
	playerCardTable.ParnerCard = GDPokerUtil.parseServerData(tostring(msgTable.ParnerCard))
	playerCardTable.PlayCardType = msgTable.PlayCardType
	playerCardTable.PlayCardValue = msgTable.PlayCardValue--GDPokerUtil.parseServerData(string.char(msgTable.PlayCardValue))
	
	return playerCardTable
	
end
function WhippedEggSceneProxy:handleGameOver(msgTable)
	local gameoverTable = {}
	
	gameoverTable.GamePlayID = msgTable.GamePlayID --对局标识
	gameoverTable.FortuneTax = msgTable.FortuneTax -- 桌子税收
	gameoverTable.Upgrade = msgTable.Upgrade -- 本局上升了多少级

	
	gameoverTable.players = {}
	if msgTable.players then
		for _,playerdata in pairs(msgTable.players) do
			local players = {}
			if playerdata.Card then
				playerdata.pokerCards = GDPokerUtil.parseServerData(playerdata.Card)
			else
				playerdata.pokerCards = {}
			end
			
			copyTable(playerdata,players)
			
			table.insert(gameoverTable.players,players)
		end
	end
	return gameoverTable
	
end
function WhippedEggSceneProxy:handleResumeGame(msgTable)
	local resumeGameTable = {}
	
	resumeGameTable.GameZoneID = msgTable.GameZoneID --区域Id
	resumeGameTable.GamePlayID = msgTable.GamePlayID --对局标识
    resumeGameTable.PlayType = msgTable.PlayType --游戏玩法
    resumeGameTable.ZoneWin =msgTable.ZoneWin --输赢财富类型
    resumeGameTable.FortuneBase =msgTable.FortuneBase --财富计算的底数
    resumeGameTable.Trump =msgTable.Trump --本局主牌
    resumeGameTable.ContinueFlag =msgTable.ContinueFlag -- 是否续局的对局 
    resumeGameTable.Upgrade =msgTable.Upgrade --续局的上局上升了多少级
    resumeGameTable.PlayTimeout =msgTable.PlayTimeout --出牌步时
    resumeGameTable.JGTimeout =msgTable.JGTimeout --进贡步时
    resumeGameTable.Jingong =msgTable.Jingong --是否进贡 1 进贡 0 无需进贡
    resumeGameTable.Status =msgTable.Status -- 牌局阶段 1 进贡 2 出牌
    resumeGameTable.NextPlayUseID =msgTable.NextPlayUseID --下一个出牌的玩家
    resumeGameTable.NextPlayTimeout = msgTable.NextPlayTimeout --下个出牌玩家倒计时时间
    resumeGameTable.LastPlayUserID =msgTable.LastPlayUserID --上个出牌玩家
    resumeGameTable.LastPlayCards = GDPokerUtil.parseServerData(msgTable.LastPlayCards)--上个玩家出的牌
    resumeGameTable.RecordCard = msgTable.RecordCard
    resumeGameTable.RemainCard = msgTable.RemainCard

	resumeGameTable.players = {}
	if msgTable.players then
		for _,playerdata in pairs(msgTable.players) do
			local players = {}
			--玩家手中的牌
			playerdata.pokerCards = GDPokerUtil.parseServerData(playerdata.Card)
			playerdata.JGCards = GDPokerUtil.parseServerData(string.char(playerdata.JGCard))
			playerdata.RecvCards = GDPokerUtil.parseServerData(string.char(playerdata.RecvCard))
			copyTable(playerdata,players)

			if resumeGameTable.PlayType == Play_Type.RcircleGame or resumeGameTable.PlayType == Play_Type.RandomGame then
				players.PlayLevel = resumeGameTable.Trump
			end
			
			table.insert(resumeGameTable.players,players)
		end
	end

	resumeGameTable.RoomMultiple = msgTable.RoomMultiple
	resumeGameTable.LastRank1User = msgTable.LastRank1User
	resumeGameTable.GameZoneName = msgTable.GameZoneName

	return resumeGameTable	
end

function WhippedEggSceneProxy:handleTableState(msgTable)
	local stateTable = {}
	
	stateTable.UserID = msgTable.UserID --玩家id
    stateTable.Type = msgTable.Type --类型 1 准备好 2 离开
	
	return stateTable	
end

function WhippedEggSceneProxy:handleSubstitute(msgTable)
	local stTable = {}
	
	copyTable(msgTable,stTable)
	
	return stTable	
end

--进贡请求
-- @param gameplayId 游戏对局标志
-- @param reqType 进贡标志 1 进贡 2 还贡 3 抗贡
-- @param card 本地牌table  { color = 1,val = 2 }
function WhippedEggSceneProxy:requestTribute(gameplayId,reqType,card)
	
	local tributeReq = GDTributeRequest:create()
	--gameplayId,reqType,userid,card
	local pokercard = GDPokerUtil.parseLocalData(card)
	
	tributeReq:formatRequest(gameplayId,reqType,tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")),string.byte(pokercard))
	tributeReq:send(self)
end
--打牌请求
-- @param gameplayId 游戏对局标志
-- @param pokerCard 本地牌table组  {{ color = 1,val = 2 },{ color = 1,val = 3 }}
-- @param replacedCard 本地替换后牌table组  {{ color = 1,val = 2 },{ color = 1,val = 3 }}
-- @param playCardType 牌类型 单牌，对子，三张，三带二 ...
-- @param playCardValue 牌值
function WhippedEggSceneProxy:requestPlayCard(gameplayId,pokerCard,replacedCard,playCardType,playCardValue)
	local playcardReq = GDPlayCardRequest:create()
	local cardStr = (pokerCard and GDPokerUtil.parseLocalData(pokerCard) or "") --string.char(48)
	local replacedStr = (replacedCard and GDPokerUtil.parseLocalData(replacedCard) or "") --string.char(48)

	--gameplayId,userid,pokerCard,replaceCard,playCardType,playCardValue
	playcardReq:formatRequest(gameplayId,tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")),cardStr,replacedStr,playCardType,playCardValue)
	playcardReq:send(self)
end

--换桌
function WhippedEggSceneProxy:changeDesk()
	self:leaveAway()

	wwlog("WhippedEggSceneProxy:changeDesk ",self.gamezoneid)
	local msgIds = self._hallNetModel.MSG_ID	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(2,self.gamezoneid)
	crquest:send(self)
end
--续桌请求
function WhippedEggSceneProxy:requestContinue()
	wwlog("WhippedEggSceneProxy:requestContinue ",self.gamezoneid)
	local msgIds = self._hallNetModel.MSG_ID	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(4,self.gamezoneid)
	crquest:send(self)
end
--离开
function WhippedEggSceneProxy:leaveAway()
	wwlog("WhippedEggSceneProxy:leaveAway ",self.gamezoneid)
	local msgIds = self._hallNetModel.MSG_ID	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(5,self.gamezoneid)
	crquest:send(self)
end

--获取当前开局消息（从数据中心）
function WhippedEggSceneProxy:getNowStartData(gameType)
	local startData = nil
	if gameType == Game_Type.ClassicalPromotion or 
		gameType == Game_Type.ClassicalRandomGame or 
		gameType == Game_Type.ClassicalRcircleGame or
		gameType == Game_Type.PersonalPromotion or 
		gameType == Game_Type.PersonalRandom or 
		gameType == Game_Type.PersonalRcircle then
		startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
		if not startData and not next(startData) then
			startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
		end
	elseif gameType == Game_Type.MatchRamdomCount or 
		gameType == Game_Type.MatchRamdomTime or 
		gameType == Game_Type.MatchRcircleCount or
		gameType == Game_Type.MatchRcircleTime then
		startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
		if not startData and not next(startData) then
			startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
		end
	end
	return startData
end

--获取玩法的房间数据（从数据中心）
function WhippedEggSceneProxy:getRoomData(zoneID)

end

--开局动画播放结束通知
function WhippedEggSceneProxy:sayStartActionOver2Server(gameType)
	wwlog(self.logTag,"开局动画结束，通知Server")

	local startData = self:getNowStartData(gameType) 
	if startData then
		local msgIds = self._hallNetModel.MSG_ID	
		local crquest = ChooseRoomRequest:create()
		crquest:formatRequest(7, startData.GamePlayID)
		crquest:send(self)
	end
end

--确定、取消进入比赛房间等待
--定时赛的时候，服务端通知比赛时间状况，弹出对话框，确认，取消
--8确认  9取消
function WhippedEggSceneProxy:sayMatchSureOCancle( Type )
	wwlog(self.logTag,"比赛近况通知 %d", Type)

	local startData = self:getNowStartData(gameType)
	if startData then
		local msgIds = self._hallNetModel.MSG_ID	
		local crquest = ChooseRoomRequest:create()
		crquest:formatRequest(Type, startData.GamePlayID)
		crquest:send(self)
	end
end

--托管请求
--@param stType  请求类型 0 托管 1 取消托管
--@param gameType  游戏类型 经典 比赛
function WhippedEggSceneProxy:requestSubstitute(stType,gameType)
	wwlog(self.logTag,"WhippedEggSceneProxy:requestSubstitute %d   %d  %d",self.gamezoneid,stType,gameType)
	local startData = nil
	if gameType == Game_Type.ClassicalPromotion or 
		gameType == Game_Type.ClassicalRandomGame or 
		gameType == Game_Type.ClassicalRcircleGame then
		startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
		if not startData or not next(startData) then
			startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
		end
	elseif gameType == Game_Type.MatchRamdomCount or 
		gameType == Game_Type.MatchRamdomTime or 
		gameType == Game_Type.MatchRcircleCount or
		gameType == Game_Type.MatchRcircleTime then
		startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
		if not startData or not next(startData) then
			startData = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
		end
	end

	if startData and startData.GamePlayID then
		local stquest = GDSubstituteRequest:create()
		wwlog(self.logTag,'gamezoneid:'..self.gamezoneid..',GamePlayID:'..startData.GamePlayID..',stType:'..stType)
		stquest:formatRequest(tonumber(self.gamezoneid),tonumber(startData.GamePlayID),stType)
		stquest:send(self)
	end
end

function WhippedEggSceneProxy:requestUserInfo(userid,clearAll)
	--先取缓存 这个数据最好一局释放一次
	
	local msgId = WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP
	
	if clearAll then --是否清空内存中的用户数据
		DataCenter:clearData(msgId)
	end
	
	local msgTable = DataCenter:getData(msgId)
	
	
	if msgTable and msgTable[userid] then
		--如果存在，直接发送消息
		wwlog(self.logTag,"数据已经有了，直接通知")
		if msgId and WhippedEggCfg.innerEventComponent then
			WhippedEggCfg.innerEventComponent:dispatchEvent({
					name = msgId;
					_userdata = userid;
					
				})
		end
		
	else
		--没有 请求
		local userReq = GDUserInfoRequest:create()
		userReq:formatRequest(1,userid)
		userReq:send(self)
	end
	
end


--处理比赛开局消息
function WhippedEggSceneProxy:handleMatchStartGame(msgTable)
	if not msgTable.playerList then
		return nil
	end
	--开局后清空一些消息的内存
	--清空淘汰信息
	DataCenter:clearData(MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED)
	
	local matchStartData = {}
	matchStartData.GamePlayID = msgTable.GamePlayID --对局标志
	matchStartData.InstMatchID = msgTable.InstMatchID --比赛实例ID
	matchStartData.PlayType = msgTable.PlayType --游戏玩法
	matchStartData.ZoneWin = msgTable.ZoneWin --输赢财富类型
	matchStartData.SetNo = msgTable.SetNo --本赛段第几轮
	matchStartData.PlayNo = msgTable.PlayNo --本轮第几局
	
	matchStartData.ScoreBase = msgTable.ScoreBase --本局积分的底数
	matchStartData.Trump = msgTable.Trump --本局主牌 

	matchStartData.PlayTimeout = msgTable.PlayTimeout --出牌步时
	matchStartData.FHTimeout = msgTable.FHTimeout --首出牌步时
	
	matchStartData.players = {}
	for _,playerdata in pairs(msgTable.playerList) do
		local player = {}
		--直接copy过来
		copyTable(playerdata,player)
		--底牌  这个数据是解析之后的新家的字段
		player.baseCards = GDPokerUtil.parseServerData(playerdata.card)

		table.insert(matchStartData.players,player)
	end
	matchStartData.NextPlayerID = msgTable.NextPlayerID -- 首个出牌的玩家
	matchStartData.TrumpCard = GDPokerUtil.parseServerData(string.char(msgTable.TrumpCard)) -- 团团转打几
	matchStartData.TCUserID1 = msgTable.TCUserID1 -- 第一个发主牌玩家
	matchStartData.TCUserID2 = msgTable.TCUserID2 -- 第二个发主牌玩家
	
	return matchStartData
end
--处理比赛结算消息
function WhippedEggSceneProxy:handleMatchGameOver(msgTable)
	
	local gameoverTable = {}
	
	gameoverTable.GamePlayID = msgTable.GamePlayID --对局标识
	gameoverTable.InstMatchID = msgTable.InstMatchID -- 比赛实例ID

	dump(msgTable)
	gameoverTable.players = {}
	if msgTable.playerList then
		for _,playerdata in pairs(msgTable.playerList) do
			local players = {}
			if playerdata.Card then
				playerdata.pokerCards = GDPokerUtil.parseServerData(playerdata.Card)
			else
				playerdata.pokerCards = {}
			end
			
			copyTable(playerdata,players)
			
			table.insert(gameoverTable.players,players)
		end
	end
	dump(gameoverTable)
	return gameoverTable
end

function WhippedEggSceneProxy:handleMatchResumeGame(msgTable)
	
	local resumeMatchGameTable = {}
	
	copyTable(msgTable,resumeMatchGameTable)
	
	resumeMatchGameTable.LastPlayCards = GDPokerUtil.parseServerData(msgTable.LastPlayCards)--上个玩家出的牌
	resumeMatchGameTable.players = {}
	if msgTable.playerList then
		for _,playerdata in pairs(msgTable.playerList) do
			local players = {}
			--玩家手中的牌
			playerdata.pokerCards = GDPokerUtil.parseServerData(playerdata.card)

			copyTable(playerdata,players)
			
			table.insert(resumeMatchGameTable.players,players)
		end
	end
	
	return resumeMatchGameTable	
	
end

function WhippedEggSceneProxy:handleUserinfo(msgId,msgTable)
	wwlog(self.logTag,"获取到了用户数据")
	dump(msgTable)
	local msgtables = DataCenter:getData(msgId)
	if not msgtables then --从来没请求过
		local tempTable = {}
		tempTable[msgTable.UserID] = {}
		copyTable(msgTable,tempTable[msgTable.UserID])
		DataCenter:cacheData(msgId,tempTable)
	else
		-- msgtables[msgTable.UserID]
		--直接更新
		local tempTable = {}
		copyTable(msgTable,tempTable)
		DataCenter:updateData(msgId,msgTable.UserID,tempTable)
	end
	return msgTable.UserID --返回请求的userid
end

function WhippedEggSceneProxy:handleMatchNotify(msgTable)
	local eventTag  = nil
	local eventData = nil
	local msgType = msgTable.Type  
	if msgType == 1 then --开赛预通知
	elseif msgType == 2 then  --退赛成功
	elseif msgType == 3 then  --退赛成功，比赛已开始，不返回门票
	elseif msgType == 4 then  --正在开赛中，不允许退赛
	elseif msgType == 5 then  --不在比赛中，不允许退赛
	elseif msgType == 6 then  --人数不足，比赛被取消
	elseif msgType == 7 then  --报名成功
		
	elseif msgType == 8 then  --报名失败
		
	elseif msgType == 9 then  --好友退赛
	elseif msgType == 11 then  --开赛
		
	elseif msgType == 12 then  --晋级下一轮
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_UPGRADE
		eventData = {}
		eventData.data =  msgTable.RespInfo --晋级人数
		copyTable(msgTable,eventData)
	elseif msgType == 13 then  --被淘汰
		
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED
		eventData = { MRanking = msgTable.Param1,matchid = msgTable.MatchID ,matchname = msgTable.MatchName }
	elseif msgType == 14 then  --比赛结束
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED
		eventData =  { MRanking = msgTable.Param1,matchid = msgTable.MatchID ,matchname = msgTable.MatchName }
	elseif msgType == 15 then  --等待其他桌完成对局
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS
		eventData = {}
		copyTable(msgTable,eventData)
		DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS_RANKDATA,eventData)
	elseif msgType == 16 then  --恢复现场
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE
		eventData = {}
		copyTable(msgTable,eventData)
	elseif msgType == 17 then  --玩家名次变化
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_RANK_CHANGE
		eventData = {}
		eventData.data =  msgTable.RespInfo --自己名次/比赛人数
	elseif msgType == 20 then  --玩家淘汰人数通知
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_ELIMINATE_CHANGE
		eventData = {}
		eventData.data =  msgTable.Param1 --Param1=淘汰的人数
	end
	if string.len(msgTable.RespInfo)>0 then
		--Toast:makeToast(tostring(msgTable.RespInfo),1.0):show()
	end

	return eventTag,eventData
end
function WhippedEggSceneProxy:getHallProxy()
	return ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
end
return WhippedEggSceneProxy