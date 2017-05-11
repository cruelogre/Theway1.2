------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋总管理器基类
-- Modify: 2016/12/29 跳转时 添加gameid标志
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GameManageBase = class("GameManageBase")

local BackGrand = require("WhippedEgg.View.BackGrand")
local OtherPlayer = require("WhippedEgg.View.OtherPlayer")
local MyPlayer = require("WhippedEgg.View.MyPlayer")
local DealCard = require("WhippedEgg.View.DealCard")
local FoldMenuLayer = require("WhippedEgg.View.FoldMenuLayer")
local TipsAniLayer = require("WhippedEgg.View.TipsAniLayer")
local SettlementLayer = require("WhippedEgg.View.SettlementLayer")
local CancelTSpLayer = require("WhippedEgg.View.CancelTSpLayer")
local MatchWaitLayer = require("WhippedEgg.View.MatchWait")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local Toast = require("app.views.common.Toast")
local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)

local WhippedEggScene = require("WhippedEgg.GameManageRoot.WhippedEggScene")
local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")

local GDAnimator = require("WhippedEgg.util.GDAnimator")
local JumpFilter = require("packages.statebase.filter.JumpFilter")
cc.exports.zorderLayer = {
	BackGrand = 0,
	DealCardLayer = 1,
	FlashAniLayer = 2,
	UpPlayer = 3,
	LeftPlayer = 4,
	RightPlayer = 5,
	MyPlayer = 6,
	TipsAniLayer = 7,
	CancelTSpLayer = 8,
	FoldMenuLayer = 9,
	SettlementLayer = 10,
	MatchWaitLayer = 11,

	CustomLayer = 12,
	BankruptLayer = 13,
}

--初始化界面
--@param gameType 游戏类型
--@param ismutiple 组队还是单人
function GameManageBase:createGame(gameType,ismutiple )
	self.logTag = "GameManageBase.lua"
	wwlog(self.logTag,"创建游戏场景")
	--游戏玩法 目前支持经典 比赛
	self.gameType = gameType or Game_Type.ClassicalPromotion
	self.teamType = ismutiple and Team_Type.TEAM_MUTIPLE or Team_Type.TEAM_SINGLE

	self:setGameInfo(self.gameType,self.teamType)
	
	--创建游戏场景
	self.gameScene = WhippedEggScene:create(function ( ... )
		-- body
		if self.FoldMenuLayer then
			self.FoldMenuLayer:exitGame()
		end
	end)
	--游戏背景层
	self.BackGrand = BackGrand:create()
    self.gameScene:addChild(self.BackGrand,zorderLayer.BackGrand)

    --菜单层
	self.FoldMenuLayer = FoldMenuLayer:create()
	self.gameScene:addChild(self.FoldMenuLayer,zorderLayer.FoldMenuLayer)

    --发牌层
	self.DealCardLayer = DealCard:create()
	self.gameScene:addChild(self.DealCardLayer,zorderLayer.DealCardLayer)

	--自己
	self.MyPlayer = MyPlayer:create()
	self.gameScene:addChild(self.MyPlayer,zorderLayer.MyPlayer)

	self.CancelTSpLayer = false
	self.canCancelTSp = true

	--第一次默认能发牌
	self.dealCardAlready = false

	--是否每个玩家都已经匹配到
	self.UpPlayerReady = false
	self.LeftPlayerReady = false
	self.RightPlayerReady = false
	self.MyPlayerReady = true

	--保存玩家信息 方便查看是否发生改变
	self.UpPlayerID = false
	self.LeftPlayerID = false
	self.RightPlayerID = false

	--状态
	self.gameState = GameStateType.Enter

	--打牌时间
	self.playCardTime = 0

	--比赛我的数据
	self.matchData = false
	self.newPlayer = false
	self.newStartGame = false
	self.newResumeGame = false

	self.haveGetWaitOther = false --收到显示等待其他玩家指令
	self.matchWaitInfo = false
	self.haveGetMatchOver = false --收到显示奖状其他玩家指令
	self.matchOverInfo = false

	self.canSendStitute = true --允许请求托管操作
	
	self.othersReady = {}
	self.emailFlyTable = {}

	self.playCardBeforeDealCard = {}
	self.playCardBeforeDealCardTurnClockInfo = {}
	self.beginPlayFirstCard = false -- 可以开始打
	return self.gameScene
end

function GameManageBase:onExit( ... )
	-- body
	wwlog(self.logTag,"清理所有游戏房间对象")
	--关闭打牌逻辑开关
	local WhippedEggSceneMediator = MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE)
	if WhippedEggSceneMediator then
		WhippedEggSceneMediator:setGameStartEnd()
	end
	self.gameType = nil
	--房间信息
	self.roomInfos = nil
	-- self.roomName = nil

	--创建游戏场景
	self.gameScene = nil
	--游戏背景层
	self.BackGrand = nil
	
	--发牌层
	self.DealCardLayer = nil
	--动画层
	self.FlashAniLayer = nil
	--玩家上 （查看对方牌 要盖住我最后一手牌）
	self.UpPlayer = nil
	--玩家左
	self.LeftPlayer = nil
	--玩家右
	self.RightPlayer = nil
	--自己
	self.MyPlayer = nil
	--设置层
	self.FoldMenuLayer = nil
	--比赛开启动画
	self.TipsAniLayer = nil
	--比赛等待层
	self.SettlementLayer = nil
	self.MatchWaitLayer = nil
	self.CancelTSpLayer = nil
	self.canCancelTSp = nil
	--第一次默认能发牌
	self.dealCardAlready = nil
	--是否每个玩家都已经匹配到
	self.UpPlayerReady = nil
	self.LeftPlayerReady = nil
	self.RightPlayerReady = nil
	self.MyPlayerReady = nil

	self.UpPlayerID = nil
	self.LeftPlayerID = nil
	self.RightPlayerID = nil
	--状态
	self.gameState = nil
	--打牌时间
	self.playCardTime = nil
	--比赛我的数据
	self.matchData = nil
	self.newPlayer = nil
	self.newStartGame = nil
	self.newResumeGame = nil

	self.haveGetWaitOther = nil --收到显示等待其他玩家指令
	self.matchWaitInfo = nil
	self.haveGetMatchOver = nil --收到显示奖状其他玩家指令
	self.matchOverInfo = nil

	self.playCardBeforeDealCard = nil
	self.playCardBeforeDealCardTurnClockInfo = nil
	self.beginPlayFirstCard = nil

	if self.SendStituteScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.SendStituteScriptFuncId)
		self.SendStituteScriptFuncId = false
	end

	if self.dealCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
		self.dealCardScriptFuncId = false
	end

	if self.deleteRcircleCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.deleteRcircleCardScriptFuncId)
		self.deleteRcircleCardScriptFuncId = false
	end

	if self.playCardBeforeDealCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playCardBeforeDealCardScriptFuncId)
		self.playCardBeforeDealCardScriptFuncId = false
	end
end

----------------------------------------------------------------------------------------------------
--创建游戏层
----------------------------------------------------------------------------------------------------
function GameManageBase:getUpPlayer( ... )
	-- body
	if not self.UpPlayer or not isLuaNodeValid(self.UpPlayer) then
		self.UpPlayer = OtherPlayer:create(Player_Type.UpPlayer)
		self.gameScene:addChild(self.UpPlayer,zorderLayer.UpPlayer)
	end
	return self.UpPlayer
end

function GameManageBase:getLeftPlayer( ... )
	-- body
	if not self.LeftPlayer or not isLuaNodeValid(self.LeftPlayer) then
		--玩家左
		self.LeftPlayer = OtherPlayer:create(Player_Type.LeftPlayer)
		self.gameScene:addChild(self.LeftPlayer,zorderLayer.LeftPlayer)
	end
	return self.LeftPlayer
end

function GameManageBase:getRightPlayer( ... )
	-- body
	if not self.RightPlayer or not isLuaNodeValid(self.RightPlayer) then
		--玩家右
		self.RightPlayer = OtherPlayer:create(Player_Type.RightPlayer)
		self.gameScene:addChild(self.RightPlayer,zorderLayer.RightPlayer)
	end
	return self.RightPlayer
end

function GameManageBase:getTipsAniLayer( ... )
	-- body
	if not self.TipsAniLayer or not isLuaNodeValid(self.TipsAniLayer) then
		--设置层
		self.TipsAniLayer = TipsAniLayer:create()
		self.gameScene:addChild(self.TipsAniLayer,zorderLayer.TipsAniLayer)
	end

	return self.TipsAniLayer
end

function GameManageBase:getMatchWaitLayer( ... )
	-- body
	if not self.MatchWaitLayer or not isLuaNodeValid(self.MatchWaitLayer) then
		--比赛等待层
		self.MatchWaitLayer = MatchWaitLayer:create()
		self.gameScene:addChild(self.MatchWaitLayer,zorderLayer.MatchWaitLayer)
	end

	return self.MatchWaitLayer
end

function GameManageBase:getSettlementLayer( ... )
	-- body
	--结算层
	if not self.SettlementLayer then
		self.SettlementLayer = SettlementLayer:create()
		self.gameScene:addChild(self.SettlementLayer,zorderLayer.SettlementLayer)
	end

	return self.SettlementLayer
end
--当前是否有结算界面
function GameManageBase:isHaveSettmentLayer()
	local curStateName = FSRegistryManager:currentFSM():currentState().mStateName
	
	return curStateName == "UIGDGameoverWinState" or 
		curStateName == "UIGDGameoverLoseState" or 
		curStateName == "UIGDPersonalSettleState"
end
----------------------------------------------------------------------------------------------------
--房间名称
----------------------------------------------------------------------------------------------------
function GameManageBase:setRoomInfoByGameZoneID(gameType, zoneID)
	wwlog(self.logTag,"设置房间信息 包括名称一大堆")
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then
		--通过游戏区域 找name
		local hallist = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
		if hallist and hallist[2] then
			local gamezones= hallist[2].looptab1
			if gamezones then
				for _,v in ipairs(gamezones) do
					if v.GameZoneID == zoneID then
						self.roomInfos = v
						self.roomInfos.Name = v.Name or ""
						self:setRoomName(v.Name)
						break
					end
				end
			end
		end
	elseif self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then
		local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
		if allMtchData then
			self:setRoomName(allMtchData[zoneID].Name)
		end
	elseif self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
		--房间号
	end	
end

function GameManageBase:setRoomName( name )
	-- body
	wwlog(self.logTag,"设置房间名称%s",name)
	self.roomName = name
end

function GameManageBase:getRoomName( ... )
	-- body
	return self.roomName
end

----------------------------------------------------------------------------------------------------
--发牌相关
----------------------------------------------------------------------------------------------------
--设置房间底分
function GameManageBase:setRoomPoint( point ) --底分
	-- body
	wwlog(self.logTag,"设置底分%d",point)
	if 	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
		self.FoldMenuLayer:setRoomPoint(1)
	else
		self.FoldMenuLayer:setRoomPoint(point)
	end
end

--设置我方 对方打几
function GameManageBase:setPlayCardInfo(selfNum,otherNum ) --底分,己方打几,对方打几 
	-- body
	wwlog(self.logTag,"己方打几%d,对方打几%d",selfNum,otherNum)
	GameModel.myNumber = selfNum
  	GameModel.opppsiteNumber = otherNum
end

--主牌花色
function GameManageBase:setPlayCardColor( color )
	-- body
end

function GameManageBase:setGetRcircleCardPeople( pOneId,pTwoId )
end

--准备发牌
function GameManageBase:readyDealCard( cardTable,callBcak )
	-- body
	self.cardTable = cardTable --保存牌
	self.callBcak = callBcak -- 发完牌回调
end

--发牌层准备发牌
function GameManageBase:setDealCardReady()
	-- body
	self:getUpPlayer():setStateType(PlayerStateType.None)
	self:getLeftPlayer():setStateType(PlayerStateType.None)
	self:getRightPlayer():setStateType(PlayerStateType.None)
	self.MyPlayer:setStateType(PlayerStateType.None)

	self:delOtherPlayerCards()
	self.DealCardLayer:recoveryOn()
end

--重新开始删除其他玩家已有的牌
function GameManageBase:delOtherPlayerCards( ... )
	-- body
	self:getUpPlayer():releaseCards()
	self:getLeftPlayer():releaseCards()
	self:getRightPlayer():releaseCards()
	
	if self.dealCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
		self.dealCardScriptFuncId = false
	end
end

function GameManageBase:stopDealCard( ... )
	-- body
	if not self.dealCardAlready then
		wwlog(self.logTag,"没发完牌就切换到后台")
		self.gameState = GameStateType.EnterBackground
		self.dealCardAlready = true
		self.DealCardLayer:releaseCards()
		stopSoundEffect("sound/effect/fapai")

		if self.dealCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
			self.dealCardScriptFuncId = false
		end

		self.MyPlayer.cardLayer:removeAllChildren()
		self:getTipsAniLayer():stopAllAni()
	end

	--隐藏闹钟
	self:getUpPlayer():hideClock()
	self:getLeftPlayer():hideClock()
	self:getRightPlayer():hideClock()
	self.MyPlayer:hideClock()
	
	self.FoldMenuLayer:resetMenuMainPos()
end

--正式发牌
function GameManageBase:DealCard()
	GDAnimator:loadAnimationRes()
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

		self.dealCardIndex = DISTRIBUTE_CARD_MAX_NUM --每次发牌id从最后面一张发起(也就是叠在最上面的牌)
		if not self.dealCardScriptFuncId then
			self.dealCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.dealCard), 0.05, false)
		end
		playSoundEffect("sound/effect/fapai",true)
	end
end

--每0.5秒发次牌
function GameManageBase:dealCard( dt )
	-- body
	--按顺序发牌
	local order = self.dealCardIndex%DISTRIBUTE_CARD_PLAYER_NUM
	local playerCardIndex = math.ceil((DISTRIBUTE_CARD_MAX_NUM - self.dealCardIndex + 1)/4) -- 玩家牌索引
	local cardNode = self.DealCardLayer:getCardByIdx(self.dealCardIndex) --获取最上层一张牌
	if cardNode then
		if order == Player_Type.SelfPlayer then
			self.MyPlayer:dealCard(cardNode,playerCardIndex)
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

			--发牌前先告诉服务器动画播放结束，矫正计时
			WhippedEggSceneProxy:sayStartActionOver2Server(self.gameType)
			stopSoundEffect("sound/effect/fapai")

			if self.dealCardScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
				self.dealCardScriptFuncId = false
			end
			
			self.DealCardLayer:releaseCards()
			self.dealCardAlready = true

			--发完牌回调
			if self.callBcak then
				self.callBcak()
			end
			self:playCardBeforeDealCardFunc()
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

function GameManageBase:playCardBeforeDealCardFunc( ... )
	-- body
	local function playCardBeDealCard( ... )
		wwlog(self.logTag,"快速打 快速打")
		-- body
		if next(self.playCardBeforeDealCard) ~= nil then
			local playCardData = self.playCardBeforeDealCard[1]
			if playCardData.trueCards then
				if playCardData.playerType == Player_Type.UpPlayer then
					self:getUpPlayer():playCard(playCardData.trueCards,playCardData.replaceCards,true,playCardData.isFirst)
					self:getUpPlayer():setStateType(PlayerStateType.None)
				elseif playCardData.playerType == Player_Type.LeftPlayer then
					self:getLeftPlayer():playCard(playCardData.trueCards,playCardData.replaceCards,false,playCardData.isFirst)
					self:getLeftPlayer():setStateType(PlayerStateType.None)
				elseif playCardData.playerType == Player_Type.RightPlayer then
					self:getRightPlayer():playCard(playCardData.trueCards,playCardData.replaceCards,false,playCardData.isFirst)
					self:getRightPlayer():setStateType(PlayerStateType.None)
				elseif playCardData.playerType == Player_Type.SelfPlayer then
					self.MyPlayer:playCard(playCardData.trueCards,playCardData.replaceCards)
					self.MyPlayer:setStateType(PlayerStateType.None)
					self.MyPlayer:PlayCardSound(isFirst)
				end
			else
				if playCardData.playerType == Player_Type.UpPlayer then
					self:getUpPlayer():hideCard()
					self:getUpPlayer():setStateType(PlayerStateType.NotPlay)
				elseif playCardData.playerType == Player_Type.LeftPlayer then
					self:getLeftPlayer():hideCard()
					self:getLeftPlayer():setStateType(PlayerStateType.NotPlay)
				elseif playCardData.playerType == Player_Type.RightPlayer then
					self:getRightPlayer():hideCard()
					self:getRightPlayer():setStateType(PlayerStateType.NotPlay)
				elseif playCardData.playerType == Player_Type.SelfPlayer then
					self.MyPlayer:hideCard()
					self.MyPlayer:setStateType(PlayerStateType.NotPlay)
					donotPlayCardSound(self.MyPlayer.Gender)
				end
			end
			table.remove(self.playCardBeforeDealCard,1)
		end

		if next(self.playCardBeforeDealCard) == nil then
			self.beginPlayFirstCard = true
			if self.playCardBeforeDealCardTurnClockInfo.playerType then
				self:showPlayerClock(self.playCardBeforeDealCardTurnClockInfo.playerType,self.playCardBeforeDealCardTurnClockInfo.typeCard,
				self.playCardBeforeDealCardTurnClockInfo.CardVal,self.playCardBeforeDealCardTurnClockInfo.callBcak)
			end
			wwlog(self.logTag,"快速打完了")
			if self.playCardBeforeDealCardScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playCardBeforeDealCardScriptFuncId)
				self.playCardBeforeDealCardScriptFuncId = false
			end
		end
	end

	if next(self.playCardBeforeDealCard) ~= nil then
		if 	self.gameType == Game_Type.PersonalPromotion or 
			self.gameType == Game_Type.PersonalRandom or 
			self.gameType == Game_Type.PersonalRcircle then    --私人房
		else
			self:substitute(0)
			self.MyPlayer:setTrusteeShip(true)
		end
		
		if not self.playCardBeforeDealCardScriptFuncId then
			self.playCardBeforeDealCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(playCardBeDealCard, 0.1, false)
		end
	else
		self.beginPlayFirstCard = true
		if self.playCardBeforeDealCardTurnClockInfo.playerType then
			self:showPlayerClock(self.playCardBeforeDealCardTurnClockInfo.playerType,self.playCardBeforeDealCardTurnClockInfo.typeCard,
			self.playCardBeforeDealCardTurnClockInfo.CardVal,self.playCardBeforeDealCardTurnClockInfo.callBcak)
		end
		wwlog(self.logTag,"快速打完了")
	end
end

----------------------------------------------------------------------------------------------------
--设置我的比赛信息
----------------------------------------------------------------------------------------------------
function GameManageBase:setMySelfMatchInfo( info )
	-- body
	if info then
		wwdump(info,"设置我的比赛信息")
		self.matchData = info
		self.MyPlayer:setMatchInfo(info)
	end
end
--设置我的名次
function GameManageBase:setMatchRank( info )
	-- body
	if info then
		wwdump(info,"设置我的比赛名次")
		self.matchRankInfo = info
		if self.gameState == GameStateType.MathcWaitOther then
			self:getMatchWaitLayer():setMatchRank(self.matchRankInfo)
		end
		self.MyPlayer:setMatchRank(self.matchRankInfo)
	end
end
--设置多少人被我淘汰
function GameManageBase:setMatcheliminateCount( count )
	-- body
	wwlog(self.logTag,"设置多少人被我淘汰")
	self.matcheliminateCount = count or 0
	if self.gameState == GameStateType.MathcWaitOther then
		self:getMatchWaitLayer():setMatcheliminateCount(self.matcheliminateCount)
	end
end
--设置还有几桌
function GameManageBase:setLetfDesk( num )
	-- body
	wwlog(self.logTag,"设置还有几桌")
	self.deskNum = num or 0
	self:getMatchWaitLayer():setDeskCount(self.deskNum)
end

--比赛等待其他玩家
function GameManageBase:waitOtherPlayer( info )
	-- body
	wwlog(self.logTag,"等待其他玩家")
	self.haveGetWaitOther = true --收到显示等待其他玩家指令
	self.matchWaitInfo = info

	if self.newResumeGame then --恢复对局有等待比赛玩家情况
		self.newResumeGame = false
		self:settmentOverCallback()
	end
end
--比赛完
function GameManageBase:matchOver( info )
	-- body
	wwlog(self.logTag,"发奖状结算")
	self.haveGetMatchOver = true --收到显示奖状其他玩家指令
	self.matchOverInfo = info
	if self.gameState == GameStateType.WaitSettlement or self.gameState == GameStateType.MathcWaitOther then --等待时候被淘汰
		wwlog(self.logTag,"发奖状")
		self.gameState = GameStateType.WaitSettlement
		FSRegistryManager:currentFSM():trigger("match",
		{   parentNode = self.gameScene, 
			zorder = zorderLayer.MatchWaitLayer,
			info = self.matchOverInfo,
			})
		--self:getMatchWaitLayer():settment(self.matchOverInfo)
	end
end

function GameManageBase:settmentOverCallback( ... )
	-- body
	wwlog(self.logTag,"回调到等待界面去了")
	self:clearDesk()

	if self.haveGetWaitOther then
		self.gameState = GameStateType.MathcWaitOther
		self.haveGetWaitOther = false
		if self:isHaveSettmentLayer() then
			FSRegistryManager:currentFSM():trigger("back")
		end
		self:getMatchWaitLayer():waitOther(self.matchWaitInfo,self.matchData)
		self:setMatchRank(self.matchRankInfo)
		self:setMatcheliminateCount(self.matcheliminateCount or 0)
		self:setLetfDesk(self.deskNum or 0)
	end
	
	if self.haveGetMatchOver then
		self.gameState = GameStateType.WaitSettlement
		self.haveGetMatchOver = false
		FSRegistryManager:currentFSM():trigger("match",
		{   parentNode = self.gameScene, 
			zorder = zorderLayer.MatchWaitLayer,
			info = self.matchOverInfo,
			})
		--self:getMatchWaitLayer():settment(self.matchOverInfo)
	end

	if self.newStartGame then
		--发送消息
		wwlog(self.logTag,"发现有缓存 发送事件 驱动发牌")
		self.newStartGame = false
		local event = false
		local dispatchEventId = false
		local matchstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
		if matchstart and (table.nums(matchstart) ~= 0) then
			event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART }
			dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART
		else
		 	matchstart = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
		 	if matchstart and (table.nums(matchstart) ~= 0) then
		 		event  = {name = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME }
				dispatchEventId = WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME
		 	end
		end

		if dispatchEventId and WhippedEggCfg.innerEventComponent then
			WhippedEggCfg.innerEventComponent:dispatchEvent(event)
		end
	end
end
--比赛继续
function GameManageBase:matchContinue( ... )
	-- body
	wwlog(self.logTag,"等待玩家界面隐藏,比赛继续")
	self:getMatchWaitLayer():matchContinue()
end



----------------------------------------------------------------------------------------------------
--设置我的结算名次信息
----------------------------------------------------------------------------------------------------
--设置名次
function GameManageBase:setRank( playerType,rank,gameOver)
	-- body
	wwlog(self.logTag,"设置名次%d %d",playerType,rank)
	if self.beginPlayFirstCard or rank == 0 then
		if playerType == Player_Type.UpPlayer then
			self:getUpPlayer():setRank(rank,gameOver)
		elseif playerType == Player_Type.LeftPlayer then
			self:getLeftPlayer():setRank(rank,gameOver)
		elseif playerType == Player_Type.RightPlayer then
			self:getRightPlayer():setRank(rank,gameOver)
		elseif playerType == Player_Type.SelfPlayer then
			self.MyPlayer:setRank(rank,gameOver)
		end
	end
end
--普通结算
function GameManageBase:Settlement( win,info, gameOverUsersSeats )
	-- body
	GDAnimator:unloadAnimationRes()
	wwlog(self.logTag,"普通结算")
	self:clearDesk()
	self.gameState = GameStateType.Settlement
	wwlog(self.logTag, "当前游戏Type -"..self.gameType)
	self.MyPlayer:setTrusteeShip(false)
	if DataCenter:getUserdataInstance():getValueByKey("bankrupt") then
		HallSceneProxy:requestIsBankrupt()
	end
	if win then
		FSRegistryManager:currentFSM():trigger("win",
		{   parentNode = self.gameScene, 
			zorder = zorderLayer.SettlementLayer,
			info = info,
			gameOverUsersSeats = gameOverUsersSeats,
			levelUpSettlementCallBack = handler(self,self.levelUpSettlementCallBack),
			PersonalEndCallBack = handler(self,self.PersonalEndCallBack),
			})
		--self:getSettlementLayer():Win(info, gameOverUsersSeats,handler(self,self.levelUpSettlementCallBack),handler(self,self.PersonalEndCallBack))
		
	else
		FSRegistryManager:currentFSM():trigger("lose",
		{   parentNode = self.gameScene, 
			zorder = zorderLayer.SettlementLayer,
			info = info,
			gameOverUsersSeats = gameOverUsersSeats,
			levelUpSettlementCallBack = handler(self,self.levelUpSettlementCallBack),
			PersonalEndCallBack = handler(self,self.PersonalEndCallBack),
			})
		--self:getSettlementLayer():Lost(info, gameOverUsersSeats,handler(self,self.levelUpSettlementCallBack),handler(self,self.PersonalEndCallBack))
	end

	--修改个人信息
	self.MyPlayer:setHeadInfo(gameOverUsersSeats.side1[1])
	self:clearGameData()
	self.MyPlayer:ToastTips(ToastState.None)
	self:closePlayerInfo()
	self.MyPlayer.allTimeVisible = false

	self:SettlementReset()
	self.FoldMenuLayer:inVisibleChatBtn()
end

--私人房打完
function GameManageBase:PersonalEnd( info )
	-- body
	self.MyPlayer.allTimeVisible = false
	self.MyPlayer:ToastTips(ToastState.None)

	self.gameState = GameStateType.Settlement

	self.havePersonalEndSettlement = true
	self.PersonalEndSettlementInfo = info
	--修改个人信息
	if self.pSeatsInfos then
		for k,v in pairs(info) do
			local playPosition = self:getPositionbyId(self.pSeatsInfos,v.UserID)
			if playPosition == Player_Type.UpPlayer then
				self:getUpPlayer():setHeadInfo(v)
			elseif playPosition == Player_Type.LeftPlayer then
				self:getLeftPlayer():setHeadInfo(v)
			elseif playPosition == Player_Type.RightPlayer then
				self:getRightPlayer():setHeadInfo(v)
			elseif playPosition == Player_Type.SelfPlayer then
				self.MyPlayer:setHeadInfo(v)
			end
		end
	end
end

function GameManageBase:PersonalEndCallBack( ... )
	-- body
	--结算层
	if self.havePersonalEndSettlement then
		self.havePersonalEndSettlement = false
		--self:getSettlementLayer():personalEnd(self.PersonalEndSettlementInfo)
		FSRegistryManager:currentFSM():trigger("personal",
		{   parentNode = display.getRunningScene(), 
			zorder = zorderLayer.SettlementLayer,
			info = self.PersonalEndSettlementInfo,
			})
	else
		FSRegistryManager:currentFSM():trigger("back")
	end
end

function GameManageBase:SettlementReset( ... )
	-- body
	removeAll(self.othersReady)
	self.newPlayer = false
	self.dealCardAlready = false
	self.playCardBeforeDealCard = {}
	self.playCardBeforeDealCardTurnClockInfo = {}

	self.beginPlayFirstCard = false
	if self.BackGrand then
		self.BackGrand:resetDouble(1)
	end
	self.havePersonalEndSettlement = false
end

function GameManageBase:levelUpSettlementCallBack( ... )
	-- body
	
end
----------------------------------------------------------------------------------------------------
--打牌相关
----------------------------------------------------------------------------------------------------
--设置打牌时间
function GameManageBase:setPlayCardTime( time )
	-- body
	wwlog(self.logTag,"设置打牌时间%d",time)
	self.playCardTime = time
end
function GameManageBase:setResumeGameTime( time )
	-- body
	wwlog(self.logTag,"设置续局打牌时间%d",time)
	self.resumeTime = time
end
--轮到谁打牌
function GameManageBase:showClockToPlay( playerType,typeCard,CardVal,callBcak ) -- 轮到哪个玩家,玩家发的牌类型,值
	-- body
	if not self.beginPlayFirstCard then
		wwlog(self.logTag,"没发完牌 就有轮到谁出"..playerType)
		self.playCardBeforeDealCardTurnClockInfo = {playerType = playerType,typeCard = typeCard,CardVal = CardVal,callBcak = callBcak}
	else
		self:showPlayerClock(playerType,typeCard,CardVal,callBcak)
	end
end

function GameManageBase:showPlayerClock( playerType,typeCard,CardVal,callBcak )
	-- body
	wwlog(self.logTag,"轮到谁出"..playerType)

	--先关闭闹钟
	if self.lastShowPlayerType and typeCard ~= true then
		if self.lastShowPlayerType == Player_Type.UpPlayer then
			self:getUpPlayer():hideClock(true)
		elseif self.lastShowPlayerType == Player_Type.LeftPlayer then
			self:getLeftPlayer():hideClock(true)
		elseif self.lastShowPlayerType == Player_Type.RightPlayer then
			self:getRightPlayer():hideClock(true)
		elseif self.lastShowPlayerType == Player_Type.SelfPlayer then
			self.MyPlayer:hideClock(true)
		end
	end
	self.lastShowPlayerType = playerType

	self.gameState = GameStateType.Playing
	local playCardTime = 0
	if self.resumeTime then
		playCardTime = self.resumeTime
		self.resumeTime = nil
	else
		playCardTime = self.playCardTime
	end

	if playerType == Player_Type.UpPlayer then
		wwplyaCardLog("轮到   上家   出")
		self:getUpPlayer():turnToPlay(typeCard,playCardTime)
	elseif playerType == Player_Type.LeftPlayer then
		wwplyaCardLog("轮到   左家   出")
		self:getLeftPlayer():turnToPlay(typeCard,playCardTime)
	elseif playerType == Player_Type.RightPlayer then
		wwplyaCardLog("轮到   右家  出")
		self:getRightPlayer():turnToPlay(typeCard,playCardTime)
	elseif playerType == Player_Type.SelfPlayer then
		printCardLogType(tonumber(typeCard),{},"******轮到  我出 上家牌是")
		self.MyPlayer:turnToPlay(typeCard,CardVal,callBcak,playCardTime)
	end
end

--谁打牌
function GameManageBase:playCard( playerType,trueCards,replaceCards,isFirst ) -- 轮到哪个玩家，原始牌，替换牌
	-- body
	--没发完牌 这时有牌推过来
	if not self.beginPlayFirstCard then
		wwlog(self.logTag,"没发完牌 这时有牌推过来")
		if next(trueCards) then
			table.insert(self.playCardBeforeDealCard,{playerType = playerType,trueCards = trueCards,replaceCards = replaceCards,isFirst = isFirst})
		else
			table.insert(self.playCardBeforeDealCard,{playerType = playerType,trueCards = false})
		end
	else
		wwlog(self.logTag,"打牌步骤")
		if playerType == Player_Type.UpPlayer then
			if next(trueCards) then
				self:getUpPlayer():playCard(trueCards,replaceCards,true,isFirst)
				--对家出完牌
				if self:getPlayCardsCount(Player_Type.UpPlayer) <= 0 then
					self.MyPlayer:ToastTips(ToastState.None)
				end
			else
				wwplyaCardLog("上家  不出")
				self:getUpPlayer():setStateType(PlayerStateType.NotPlay)
			end
		elseif playerType == Player_Type.LeftPlayer then
			if next(trueCards) then
				self:getLeftPlayer():playCard(trueCards,replaceCards,false,isFirst)
			else
				wwplyaCardLog("左家  不出")
				self:getLeftPlayer():setStateType(PlayerStateType.NotPlay)
			end
		elseif playerType == Player_Type.RightPlayer then
			if next(trueCards) then
				self:getRightPlayer():playCard(trueCards,replaceCards,false,isFirst)
			else
				wwplyaCardLog("右家  不出")
				self:getRightPlayer():setStateType(PlayerStateType.NotPlay)
			end
		elseif playerType == Player_Type.SelfPlayer then
			self:setCancleTrShipLayerEffective(true) --开发限制
			if next(trueCards) then
				self.MyPlayer:playCard(trueCards,replaceCards)
				self.MyPlayer:PlayCardSound(isFirst)
			else
				wwplyaCardLog("我  不出")
				self.MyPlayer:setStateType(PlayerStateType.NotPlay)
				donotPlayCardSound(self.MyPlayer.Gender)
			end
		end
	end
end
--接风
function GameManageBase:solitairePlay( playerType )
	-- body
	wwlog(self.logTag,"显示接风 %d",playerType)
	wwplyaCardLog("显示接风 %d",playerType)

	self.FoldMenuLayer:solitaireAni(playerType)

	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():setStateType(PlayerStateType.Solitaire)
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():setStateType(PlayerStateType.Solitaire)
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():setStateType(PlayerStateType.Solitaire)
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayer:setStateType(PlayerStateType.Solitaire)
	end
end
--查看队友的牌
function GameManageBase:seeFriendPlayerCard( Cards ) -- 查看队友的牌
	-- body
	wwlog(self.logTag,"查看队友的牌")
	self:getUpPlayer():seeFriendPlayerCard(Cards)
	self.MyPlayer:setDisableButtonState(true)
	if self:IsSeeFriendPlayerCard() then
		self.MyPlayer:ToastTips(ToastState.FriendCard,true)
	end
end
--检测显示对家牌
function GameManageBase:IsSeeFriendPlayerCard( ... )
	-- body
	if not isLuaNodeValid(self.MyPlayer) then --结算完 马上回大厅界面
		return false
	end

	if self:getPlayCardsCount(Player_Type.SelfPlayer) <= 0 and 
		self:getPlayCardsCount(Player_Type.UpPlayer) > 0 then
		return true
	end

	return false
end
--获得玩家牌数
function GameManageBase:getPlayCardsCount( playerType ) --哪个玩家
	-- body
	if playerType == Player_Type.UpPlayer then
		return self:getUpPlayer():getCardCount()
	elseif playerType == Player_Type.LeftPlayer then
		return self:getLeftPlayer():getCardCount()
	elseif playerType == Player_Type.RightPlayer then
		return self:getRightPlayer():getCardCount()
	elseif playerType == Player_Type.SelfPlayer then
		return self.MyPlayer:getCardCount()
	end
	return 0
end
--设置玩家牌数
function GameManageBase:setPlayCardsCount( playerType,count ) --哪个玩家
	-- body
	if playerType == Player_Type.UpPlayer then
		return self:getUpPlayer():setCardsCount(count)
	elseif playerType == Player_Type.LeftPlayer then
		return self:getLeftPlayer():setCardsCount(count)
	elseif playerType == Player_Type.RightPlayer then
		return self:getRightPlayer():setCardsCount(count)
	end
end



--保存本次的开局座位信息（开局座位）
function GameManageBase:setCruGameSeatInfo( seatsInfos )
	self.pSeatsInfos = seatsInfos
end
--获取本次的开局座位信息（开局座位）
function GameManageBase:getCruGameSeatInfo()
	return self.pSeatsInfos
end

function GameManageBase:getCardByPosition( seatsInfos,positon )
	-- body
	if positon == Player_Type.SelfPlayer then
		return seatsInfos.side1[1].pokerCards
	elseif positon == Player_Type.LeftPlayer then
		return seatsInfos.side2[1].pokerCards
	elseif positon == Player_Type.UpPlayer then
		return seatsInfos.side1[2].pokerCards
	elseif positon == Player_Type.RightPlayer then
		return seatsInfos.side2[2].pokerCards
	end
end
--根据UserID获取座位信息
function GameManageBase:getCruSeatInfoByUserID( userid )

	local seatInfo = {}

	if self.pSeatsInfos.side1[1].UserID == userid then
		seatInfo = self.pSeatsInfos.side1[1]
	elseif self.pSeatsInfos.side1[2].UserID == userid then
		seatInfo = self.pSeatsInfos.side1[2]
	elseif self.pSeatsInfos.side2[1].UserID == userid then
		seatInfo = self.pSeatsInfos.side2[1]
	elseif self.pSeatsInfos.side2[2].UserID == userid then
		seatInfo = self.pSeatsInfos.side2[2]
	end

	return seatInfo
end
--[[
-- 分边逻辑，排座
-- 数据列表中的 1 3为一伙 2 4为一伙
--]]
function GameManageBase:getSeatsInfo( players )
	if not players then
		return
	end
	-- {
	-- 	side1 = {},  --自己 （1 是自己  2是屏幕上方玩家）
	-- 	side2 = {} --对手玩家数据 （1是左边玩家，2是右边玩家）
	-- }
	local tmpSeatsInfo = {}
	local retSeatsInfo = {}
	tmpSeatsInfo.side1 = {}
	tmpSeatsInfo.side2 = {}
	retSeatsInfo.side1 = {}
	retSeatsInfo.side2 = {}
	
	--1 3 和 2 4分边
	local findIndex = { 1, 3, 2, 4 }
	for i,v in ipairs(findIndex) do
		if i > 2 then
			table.insert(tmpSeatsInfo.side1, players[v])
		else
			table.insert(tmpSeatsInfo.side2, players[v])
		end
	end

	local myUserId = DataCenter:getUserdataInstance():getValueByKey("userid")

	local isIInTmpSide1 = false

	for i,v in ipairs(tmpSeatsInfo.side1) do
		
		if v.UserID == myUserId then
			isIInTmpSide1 = true
		end
	end
	
	retSeatsInfo.side1 = isIInTmpSide1 and tmpSeatsInfo.side1 or tmpSeatsInfo.side2
	retSeatsInfo.side2 = isIInTmpSide1 and tmpSeatsInfo.side2 or tmpSeatsInfo.side1
	
   if retSeatsInfo.side1[1].UserID ~= myUserId then
	    local tmp1 = retSeatsInfo.side1[1]
		retSeatsInfo.side1[1] = retSeatsInfo.side1[2]
		retSeatsInfo.side1[2] = tmp1
		if isIInTmpSide1 then --如果我一开始就是在2，4里边 这个时候 3是我的上家
			local tmp2 = retSeatsInfo.side2[1]
			retSeatsInfo.side2[1] = retSeatsInfo.side2[2]
			retSeatsInfo.side2[2] = tmp2
		end
	elseif not isIInTmpSide1 then --我在1，3里边的时候才会2，4，位置调换
		local tmp2 = retSeatsInfo.side2[1]
		retSeatsInfo.side2[1] = retSeatsInfo.side2[2]
		retSeatsInfo.side2[2] = tmp2
	end	
	
	return retSeatsInfo
end

--[[
获得玩家的座位信息
@param sertsInfo 排序后的玩家座位信息
@param userid    玩家ID
--]]
function GameManageBase:getPositionbyId( sertsInfo, userid )
	local positionType = -1
	if sertsInfo.side1[1].UserID == userid then --自家
		positionType = Player_Type.SelfPlayer
	elseif sertsInfo.side1[2].UserID == userid then  --屏幕上方玩家
		positionType = Player_Type.UpPlayer
	elseif sertsInfo.side2[1].UserID == userid then  --屏幕左边玩家
		positionType = Player_Type.LeftPlayer
	elseif sertsInfo.side2[2].UserID == userid then  --屏幕右边玩家
		positionType = Player_Type.RightPlayer
	end
	return positionType
end

--[[
-- 获得团团转换桌后的座位欣喜
--]]
function GameManageBase:getChangeSeats(oldSeats, switchA, switchB)
	
	local retSeatInfo = {}
	local userid = ww.WWGameData:getInstance():getIntegerForKey("userid")

	local function getSeatByUserID(seatTable, userIDIndex)
		local seatRow
		local nIndex
		if userIDIndex == Player_Type.SelfPlayer then
			seatRow = seatTable.side1[1]
			nIndex = 1
		elseif userIDIndex == Player_Type.UpPlayer then
			seatRow = seatTable.side1[2]
			nIndex = 2
		elseif userIDIndex == Player_Type.LeftPlayer then
			seatRow = seatTable.side2[1]
			nIndex = 3
		elseif userIDIndex == Player_Type.RightPlayer then
			seatRow = seatTable.side2[2]
			nIndex = 4
		end
		return seatRow, nIndex
	end

	local function switchSeatInfo(retSeatInfo, nIndex, newSeatInfoRow )
		if nIndex == 1 then
			-- retSeatInfo.side1[1] = seatBOld
		elseif nIndex == 2 then
			retSeatInfo.side1[2] = newSeatInfoRow
		elseif nIndex == 3 then
			retSeatInfo.side2[1] = newSeatInfoRow
		elseif nIndex == 4 then
			retSeatInfo.side2[2] = newSeatInfoRow
		end
	end  

	if (Player_Type.SelfPlayer == switchA) or (Player_Type.SelfPlayer == switchB) then
		--有自己
		local otherUserSeatIndex 
		if (Player_Type.SelfPlayer == switchA) then
			otherUserSeatIndex = switchB
		else
			otherUserSeatIndex = switchA
		end

		retSeatInfo = clone(oldSeats)
		local seatAOld, aIndex = getSeatByUserID(retSeatInfo, otherUserSeatIndex)
		if aIndex == 2 then
			-- 1243
			retSeatInfo.side1[1] = oldSeats.side1[1]
			retSeatInfo.side1[2] = oldSeats.side1[2]
			retSeatInfo.side2[1] = oldSeats.side2[2]
			retSeatInfo.side2[2] = oldSeats.side2[1]
		elseif aIndex == 3 then
			--1423
			retSeatInfo.side1[1] = oldSeats.side1[1]
			retSeatInfo.side1[2] = oldSeats.side2[2]
			retSeatInfo.side2[1] = oldSeats.side1[2]
			retSeatInfo.side2[2] = oldSeats.side2[1]
		elseif aIndex == 4 then
			--1342
			retSeatInfo.side1[1] = oldSeats.side1[1]
			retSeatInfo.side1[2] = oldSeats.side2[1]
			retSeatInfo.side2[1] = oldSeats.side2[2]
			retSeatInfo.side2[2] = oldSeats.side1[2]
		end
		
	else
		--没有自己,则只是简单的替换两个玩家
		retSeatInfo = clone(oldSeats)
		local seatAOld, aIndex = getSeatByUserID(retSeatInfo, switchA)
		local seatBOld, bIndex = getSeatByUserID(retSeatInfo, switchB)

		switchSeatInfo(retSeatInfo, aIndex, seatBOld)
		switchSeatInfo(retSeatInfo, bIndex, seatAOld)
	end

	return retSeatInfo
end

--换桌
function GameManageBase:changeDesk( ... )
	-- body
	self.gameState = GameStateType.Enter

	self:getUpPlayer():changePlayer()
	self:getLeftPlayer():changePlayer()
	self:getRightPlayer():changePlayer()
	self.MyPlayer:changePlayer()
	self.DealCardLayer:changePlayer()
	self:getTipsAniLayer():changePlayer()
	self.FoldMenuLayer:changePlayer()

	--请求服务器重新匹配
	WhippedEggSceneProxy:changeDesk()
end
--继续游戏
function GameManageBase:continueGame( ... )
	-- body
	self.gameState = GameStateType.Enter

	self:getUpPlayer():continueGame()
	self:getLeftPlayer():continueGame()
	self:getRightPlayer():continueGame()
	self.MyPlayer:continueGame()

	--设置其他玩家没准备
	self.UpPlayerReady = false
	self.LeftPlayerReady = false
	self.RightPlayerReady = false
	self.MyPlayerReady = false

	--	请求服务器 
	WhippedEggSceneProxy:requestContinue()
	--继续的时候要先判断其他玩家是否已经准备好了
	self:notifyOtherPlayerState(Player_Type.UpPlayer)
	self:notifyOtherPlayerState(Player_Type.LeftPlayer)
	self:notifyOtherPlayerState(Player_Type.RightPlayer)
		
end
--清空牌桌
function GameManageBase:clearDesk( ... )
	-- body
	self:getUpPlayer():clearDesk()
	self:getLeftPlayer():clearDesk()
	self:getRightPlayer():clearDesk()
	self.MyPlayer:continueGame()

	--设置其他玩家没准备
	self.UpPlayerReady = false
	self.LeftPlayerReady = false
	self.RightPlayerReady = false
	self.MyPlayerReady = false
end
--哪个玩家离开
function GameManageBase:playerLeave( playerType )
	-- body
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():changePlayer()
		self.UpPlayerReady = false
		self:clearEamilFlyByPlayerType(playerType)

		wwlog(self.logTag,"上玩家 离开消息")
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():changePlayer()
		self.LeftPlayerReady = false
		self:clearEamilFlyByPlayerType(playerType)

		wwlog(self.logTag,"左玩家 离开消息")
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():changePlayer()
		self.RightPlayerReady = false
		self:clearEamilFlyByPlayerType(playerType)

		wwlog(self.logTag,"右玩家 离开消息")
	end
end

--清除播放加好友动画记录
function GameManageBase:clearEamilFlyByPlayerType( playerType )
	-- body
	self.emailFlyTable[playerType] = {}

	for k,v in pairs(self.emailFlyTable) do
		if k ~= playerType then
			for i=#v,1,-1 do
				if v[1] == playerType then
					table.remove(v,i)
					break
				end
			end
		end
	end
end

--哪个玩家准备
function GameManageBase:playerReady( playerType )
	-- body
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():setStateType(PlayerStateType.Ready)
		self.UpPlayerReady = true
		self:setOtherReady(playerType)
		wwlog(self.logTag,"收到续局 上玩家 准备消息")
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():setStateType(PlayerStateType.Ready)
		self:setOtherReady(playerType)
		self.LeftPlayerReady = true
		wwlog(self.logTag,"收到续局 左玩家 准备消息")
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():setStateType(PlayerStateType.Ready)
		self:setOtherReady(playerType)
		self.RightPlayerReady = true
		wwlog(self.logTag,"收到续局 右玩家 准备消息")
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayer:setStateType(PlayerStateType.Ready)
		self.MyPlayerReady = true
		wwlog(self.logTag,"收到续局 我玩家 准备消息")
		--我准备的时候要先判断其他玩家是否准备OK
		self:notifyOtherPlayerState(Player_Type.UpPlayer)
		self:notifyOtherPlayerState(Player_Type.LeftPlayer)
		self:notifyOtherPlayerState(Player_Type.RightPlayer)
	end

	--所有玩家都准备好 准备牌
	if self.UpPlayerReady and self.LeftPlayerReady and self.RightPlayerReady and self.MyPlayerReady then
		self:setDealCardReady()
		removeAll(self.othersReady)
	end
end

--玩家离开
function GameManageBase:playerPersonalLeave( playerType )
	-- body
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():setLeave()
		self.UpPlayerReady = false
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():setLeave()
		self.LeftPlayerReady = false
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():setLeave()
		self.RightPlayerReady = false
	end

	if not self.UpPlayerReady or not self.LeftPlayerReady or not self.RightPlayerReady then
		self.MyPlayer:ToastTipsPlayerLeave(true)
	end
end

--玩家返回
function GameManageBase:playerPersonalComeBack( playerType )
	-- body
	if playerType == Player_Type.UpPlayer then
		self:getUpPlayer():comeBack()
		self.UpPlayerReady = true
	elseif playerType == Player_Type.LeftPlayer then
		self:getLeftPlayer():comeBack()
		self.LeftPlayerReady = true
	elseif playerType == Player_Type.RightPlayer then
		self:getRightPlayer():comeBack()
		self.RightPlayerReady = true
	end

	if self.UpPlayerReady and self.LeftPlayerReady and self.RightPlayerReady then
		self.MyPlayer:ToastTipsPlayerLeave(false)
	end
end

function GameManageBase:setOtherReady(playerType)
	local has = false
	self.othersReady = self.othersReady or {}
	for _,v in ipairs(self.othersReady) do
		if v == playerType then
			has = true
			break
		end
	end
	
	if not has then
		table.insert(self.othersReady,playerType)
	end
end
--通知其他玩家准备状态
function GameManageBase:notifyOtherPlayerState(playerType)
	if not self.othersReady[playerType] then
		return
	end
	if playerType ==Player_Type.UpPlayer then
		wwlog(self.logTag,"预先设置 上玩家 准备消息")
		self.UpPlayerReady = true

		self:getUpPlayer():setStateType(PlayerStateType.Ready)
	elseif playerType ==Player_Type.LeftPlayer then
		wwlog(self.logTag,"预先设置 左玩家 准备消息")
		self.LeftPlayerReady = true
		self:getLeftPlayer():setStateType(PlayerStateType.Ready)
		
	elseif playerType ==Player_Type.RightPlayer then
		wwlog(self.logTag,"预先设置 右玩家 准备消息")
		self.RightPlayerReady = true
		self:getRightPlayer():setStateType(PlayerStateType.Ready)
		
	end
end

--播放特效
function GameManageBase:playCardFlash( typeCard,pos,isMyself )
	-- body
	--动画层
	if not self.FlashAniLayer then
		self.FlashAniLayer = cc.Layer:create()
		self.gameScene:addChild(self.FlashAniLayer,zorderLayer.FlashAniLayer)
	end
	
	GDAnimator:play(self.FlashAniLayer,self:getTipsAniLayer(),typeCard,pos,isMyself)
end

--右上角菜单还原位置
function GameManageBase:resetMenuMain()
	-- body
	self.FoldMenuLayer:resetMenuMain()
end

--请求托管操作
function GameManageBase:substitute(stType)
	wwlog(self.logTag,"请求托管操作 游戏类型 %d -- %d ",self.gameType,stType)
	if stType == 1 then
		WhippedEggSceneProxy:requestSubstitute(stType,self.gameType)
	else
		if self.canSendStitute then
			self.canSendStitute = false
			WhippedEggSceneProxy:requestSubstitute(stType,self.gameType)

			local function SendStituteCall( ... )
				-- body
				self.canSendStitute = true
				if self.SendStituteScriptFuncId then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.SendStituteScriptFuncId)
					self.SendStituteScriptFuncId = false
				end
			end

			if not self.SendStituteScriptFuncId then
				self.SendStituteScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(SendStituteCall, 2, false)
			end
		else
	  		Toast:makeToast(i18n:get('str_guandan','guandan_stitute'), 1.0):show()
		end
	end
end

--设置托管玩家托管状态
function GameManageBase:playerTrShipState( playerType,trShipState )
	-- body
	if playerType == Player_Type.UpPlayer then
		wwlog(self.logTag,"服务器设置 上玩家 托管返回%s",trShipState)

		self:getUpPlayer():setTrShipState(trShipState)
	elseif playerType == Player_Type.LeftPlayer then
		wwlog(self.logTag,"服务器设置 左玩家 托管返回%s",trShipState)

		self:getLeftPlayer():setTrShipState(trShipState)
	elseif playerType == Player_Type.RightPlayer then
		wwlog(self.logTag,"服务器设置 右玩家 托管返回%s",trShipState)

		self:getRightPlayer():setTrShipState(trShipState)
	elseif playerType == Player_Type.SelfPlayer then
		wwlog(self.logTag,"服务器设置 我 托管返回%s",trShipState)
		self.MyPlayer:setTrusteeShip(trShipState)
	end
end
--获取当前是否是托管状态
function GameManageBase:getIsTrShip( ... )
	-- body
	return self.MyPlayer.Trusteeship
end

--添加取消托管层
function GameManageBase:addCancleTrShipLayer() --是否是私人房有人退出
	-- body
		--取消托管层
	if not self.CancelTSpLayer then
		wwlog(self.logTag,"添加托管层")
		self.CancelTSpLayer = CancelTSpLayer:create()
		self.CancelTSpLayer.canCancle = self.canCancelTSp
		self.gameScene:addChild(self.CancelTSpLayer,zorderLayer.CancelTSpLayer)
	end
end
--删除取消托管层
function GameManageBase:delCancleTrShipLayer( ... )
	-- body
	if self.CancelTSpLayer and self.beginPlayFirstCard then
		wwlog(self.logTag,"删除托管层")
		self.CancelTSpLayer:removeFromParent()
		self.CancelTSpLayer = false
	end
end

--托管层点击有效和无效
function GameManageBase:setCancleTrShipLayerEffective( effective )
	-- body
	self.canCancelTSp = effective
	if self.CancelTSpLayer then
		self.CancelTSpLayer.canCancle = self.canCancelTSp
	end
end

--我走啦
function GameManageBase:leaveAway()
	wwlog(self.logTag,"退出游戏 并告诉服务器")
	WhippedEggSceneProxy:leaveAway()
	if (self.gameType == Game_Type.MatchRamdomCount or self.gameType == Game_Type.MatchRcircleCount) and (self.gameState == GameStateType.Enter or 
		self.gameState == GameStateType.None) then
		MatchProxy:quitSign(WhippedEggSceneProxy.gamezoneid)
	end

	--离开匹配 清空缓存 下次进来继续匹配
	self:clearGameData()
end
--请求对局用户数据
--@param UserID  用户id
--@param clearAll 是否清空以前数据  每次开局第一次请求的需要
function GameManageBase:requestUserInfo(userid,clearAll)
	self.reqUserId = userid
	WhippedEggSceneProxy:requestUserInfo(userid,clearAll)
end
--退出
function GameManageBase:exitGame( ... )
	-- body
  	self:leaveAway()
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then
		--FSRegistryManager:setJumpState("chooseRoom",{ zorder=3,crType = 2 })
		--ID,类型,优先级
		local jumpFilter = JumpFilter:create(1,FSConst.FilterType.Filter_Enter,1)
		jumpFilter:setJumpData("chooseRoom",{ zorder=3,crType = 2,gameid=wwConfigData.GAME_ID } )
		FSRegistryManager:getFSM(FSMConfig.FSM_HALL):addFilter("UIRoot",jumpFilter)

  		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	elseif self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then --比赛
		--FSRegistryManager:setJumpState("match",{ zorder=3,crType = 1 })
				--ID,类型,优先级
		local jumpFilter = JumpFilter:create(1,FSConst.FilterType.Filter_Enter,1)
		jumpFilter:setJumpData("match",{ zorder=3,crType = 1 } )
		FSRegistryManager:getFSM(FSMConfig.FSM_HALL):addFilter("UIRoot",jumpFilter)

  		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
  	elseif	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or
		self.gameType == Game_Type.PersonalRcircle then --私人房
		local request = require("hall.request.SiRenRoomRequest")
		local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
  		local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
		if WhippedEggSceneController.MasterID == DataCenter:getUserdataInstance():getValueByKey("userid") then --房主
	    	request.releaseRoom(proxy, WhippedEggSceneController.gameZoneId)
			--FSRegistryManager:setJumpState("siren",{ zorder=3,crType = 3 })
			local jumpFilter = JumpFilter:create(1,FSConst.FilterType.Filter_Enter,1)
			jumpFilter:setJumpData("siren",{ zorder=3,crType = 3 } )
			FSRegistryManager:getFSM(FSMConfig.FSM_HALL):addFilter("UIRoot",jumpFilter)
		
		else
	    	request.quitRoom(proxy, WhippedEggSceneController.gameZoneId)
		end

	  	WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	end
end

------------------------------------------------------------------------------------------------
--恢复对局
------------------------------------------------------------------------------------------------
function GameManageBase:recoverysetCurGamePlayNum( point,selfNum,otherNum,isBankerOurs )
	-- body
	wwlog(self.logTag,"恢复对局设置本局打几%d %d %d %s",point,selfNum,otherNum,isBankerOurs)
	self.DealCardLayer:recoveryOn()
	self:setRoomPoint(point)
	GameModel.myNumber = selfNum
  	GameModel.opppsiteNumber = otherNum
	GameModel.isPlayerBankerType = isBankerOurs
  	if isBankerOurs == lightWiner.winerLeft then --己方
		GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存
	elseif isBankerOurs == lightWiner.winerRight then --对方
		GameModel.nowCardVal = GameModel.opppsiteNumber-1 --本次打几保存
	elseif isBankerOurs == lightWiner.winerAll then --双方
		GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存
	end

	wwplyaCardLog("-------------------------本局主牌打"..PlayCardSwitch(GameModel.nowCardVal).."-----------------")

	self:getTipsAniLayer():recoveryOn()
	self.FoldMenuLayer:recoveryOn()
	self.FoldMenuLayer:addChatBtn()
	self.dealCardAlready = true
end
--恢复玩家信息 牌
function GameManageBase:recoveryPlayerInfo( playerType, players )
	-- body
	wwlog(self.logTag,"恢复玩家信息")
	if playerType == Player_Type.UpPlayer then
		self.UpPlayerID = players.side1[2].UserID
		self:getUpPlayer():setHeadInfo(players.side1[2])
		self:getUpPlayer():setCardsCount(#players.side1[2].pokerCards)
	elseif playerType == Player_Type.LeftPlayer then
		self.LeftPlayerID = players.side2[1].UserID
		self:getLeftPlayer():setHeadInfo(players.side2[1])
		self:getLeftPlayer():setCardsCount(#players.side2[1].pokerCards)
	elseif playerType == Player_Type.RightPlayer then
		self.RightPlayerID = players.side2[2].UserID
		self:getRightPlayer():setHeadInfo(players.side2[2])
		self:getRightPlayer():setCardsCount(#players.side2[2].pokerCards)
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayer:setHeadInfo(players.side1[1])
		self.MyPlayer:recoveryOn(players.side1[1].pokerCards)
	end
end

--查看玩家信息
function GameManageBase:checkPlayInfo( playerType,info )
	-- body
	if self.MyPlayer.dealCardEd then
		self:getMatchWaitLayer():checkPlayerInfo(playerType,info)
	end
end
--关闭玩家信息
function GameManageBase:closePlayerInfo( ... )
	-- body
	if isLuaNodeValid(self.MatchWaitLayer) then
		self.MatchWaitLayer:closePlayerInfo()
	end
	self.reqUserId = nil
end
--获取查看信息界面是否显示出来
function GameManageBase:getPlayerInfoVisible( ... )
	-- body
	return self.MatchWaitLayer:getPlayerInfoVisible()
end

function GameManageBase:setGameInfo( gameType,ismutiple )
	-- body
	soundEffectControl()
	if self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then --比赛
		playBackGroundMusic("sound/backMusic/matchBackGroundMusic",true)
	elseif self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then
		playBackGroundMusic("sound/backMusic/hallBackGroundMusic",true)
	elseif	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or
		self.gameType == Game_Type.PersonalRcircle then --私人房
		playBackGroundMusic("sound/backMusic/hallBackGroundMusic",true)
	end
end

function GameManageBase:clearGameData( ... )
	-- body
	--离开匹配 清空缓存 下次进来继续匹配
	wwlog(self.logTag,"清除游戏开局或者恢复对局数据")
	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)

	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_GAMESTART)
	DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_MATCH_RESUMEGAME)
end

--团团转换座
function GameManageBase:changeGameSeatInfo( seatsInfos )
	-- body
	local WhippedEggSceneMediator = MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE)
	if WhippedEggSceneMediator then
		WhippedEggSceneMediator:setGameLogicSeatInfos(seatsInfos)
	end

	self:setCruGameSeatInfo(seatsInfos)
end

--翻倍
function GameManageBase:addDouble( PlayerType )
	-- body
	if self.BackGrand then
		self.BackGrand:addDouble(PlayerType)
	end
end

--玩家加好友
function GameManageBase:reponseFriend( FromUserID,ToUserID )
	-- body
	local PlayerFromPosition = self:getPositionbyId(self.pSeatsInfos,FromUserID)
	local PlayerToPosition = self:getPositionbyId(self.pSeatsInfos,ToUserID)

	local function getPlayByPosition( playPosition )
		-- body
		if playPosition == Player_Type.UpPlayer then
			return self:getUpPlayer()
		elseif playPosition == Player_Type.LeftPlayer then
			return self:getLeftPlayer()
		elseif playPosition == Player_Type.RightPlayer then
			return self:getRightPlayer()
		elseif playPosition == Player_Type.SelfPlayer then
			return self.MyPlayer
		end
	end
	
	local PlayerFrom = getPlayByPosition(PlayerFromPosition)
	local PlayerTo = getPlayByPosition(PlayerToPosition)

	local function FromUserIDToUserID( PlayerFromPosition,PlayerToPosition )
		-- body
		self.emailFlyTable[PlayerFromPosition] = self.emailFlyTable[PlayerFromPosition] or {}
		for k,v in pairs(self.emailFlyTable[PlayerFromPosition]) do
			if v == PlayerToPosition then
				return true
			end
		end

		return false
	end

	if isLuaNodeValid(PlayerFrom) and isLuaNodeValid(PlayerTo) and not FromUserIDToUserID(PlayerFromPosition,PlayerToPosition) then
		table.insert(self.emailFlyTable[PlayerFromPosition],PlayerToPosition)
		self:getTipsAniLayer():moveEmailAni(PlayerFrom:getHeadPos(),PlayerTo:getHeadPos())
	end
end


return GameManageBase