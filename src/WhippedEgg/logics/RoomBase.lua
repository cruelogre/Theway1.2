-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.29
-- Last:
-- Content:  经典玩法逻辑处理  这里不做任何UI或数据相关处理，单纯的业务逻辑处理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RoomBase = class("RoomBase", require("packages.mvc.Mediator"))

local WhippedEggCfg = import(".WhippedEggCfg", "WhippedEgg.mediator.cfg.")
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local CardDetection = require("WhippedEgg.CardDetection")

local GDPokerUtil = import(".GDPokerUtil", "WhippedEgg.util.")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")

function RoomBase:ctor()
    self.logTag = "RoomBase.lua"
    self.maxPlayCardType = 1
    self.maxPlayCardValue = 0
    self.myPlayCardType = 1
    self.myPlayCardValue = 0
	self.currentRanks = {} --当前的排名
	self.showAll1 = {false,false}   -- 我们是否出完牌了
	self.showAll2 = {false,false}   -- 对手是否出完牌了
	self.playerCardSignMaps = {} --记录打牌 不出的table 表  用来判断当前是否是第一个出牌的
	self.handlers = {}
    self.seatInfos = false
    -- 记牌器
    self:init()

	self.canReturnBack = true
    self.applicationDidEnterBackground = false

    self.listenerLoginSucceed = WWFacade:addCustomEventListener("loginSucceed",function ( ... )
        if self.applicationDidEnterBackground then
            self.applicationDidEnterBackground = false
    		self.canReturnBack = true
            -- body
            if not self.returnBackScriptFuncId then
                self.returnBackScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
                    -- body
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.returnBackScriptFuncId)
                    self.returnBackScriptFuncId = false

                    if self.canReturnBack then
                        GameManageFactory:getCurGameManage():exitGame()
                    end
                end, 5, false)
            end

            --私人房切换前台告诉服务器重新拉取私人房消息
            if  GameManageFactory.gameType == Game_Type.PersonalPromotion or 
                GameManageFactory.gameType == Game_Type.PersonalRandom or
                GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
                local proxyHall = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
                proxyHall:requestHallHandle(1, 3 ,wwConfigData.GAME_ID)
				
				local request = require("hall.request.SiRenRoomRequest")
                local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
                local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
                request.returnRoom(proxy, WhippedEggSceneController.gameZoneId)
				
             end
        end
    end)

    --加好友等其他消息请求反馈
    self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST,handler(self, self.response))
end

--加好友等其他消息请求反馈
function RoomBase:response( event )
    -- body
    if event._eventName == CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST then
        if event._userdata[1] and event._userdata[1].type and event._userdata[1].type == 1 then --好友申请
            GameManageFactory:getCurGameManage():reponseFriend(event._userdata[1].FromUserID,event._userdata[1].ToUserID)
        end
    end
end

--创建记牌器
function RoomBase:createCardRecorder( ... )
    -- body
    if not self.cardRecorder then
        self.cardRecorder = require("WhippedEgg.View.CardRecorder"):create(self)
        self.cardRecorder:attachBtnCardRecorder(GameManageFactory:getCurGameManage().MyPlayer.Button_rmcard)
    end
end

-- 重新滞空
function RoomBase:recycle()
    if self.playerCardSignMaps then
        removeAll(self.playerCardSignMaps)
    end
    if WhippedEggCfg.innerEventComponent then
        if self.handlers then
            for _, handlerX in pairs(self.handlers) do
                WhippedEggCfg.innerEventComponent:removeEventListener(handlerX)
            end
        end
    end
    removeAll(self.handlers)
    if self.cardRecorder then
        self.cardRecorder = self.cardRecorder:onQuitRoom()
    end

    self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST)

    WWFacade:removeEventListener(self.listenerLoginSucceed)
end

function RoomBase:setSeatInfos(seatInfos)
    -- body
    self.seatInfos = seatInfos
end

--[[
开局后第一步处理  发牌后回调
tNextPlayID 续局开局，需要传这个参数
--]]
function RoomBase:handleFirstStep( tNextPlayID )
	--隐藏名次
	if GameManageFactory:getCurGameManage().playCardBeforeDealCardTurnClockInfo and 
		GameManageFactory:getCurGameManage().playCardBeforeDealCardTurnClockInfo.playerType then --有在没发完牌就开发打牌
	else
		GameManageFactory:getCurGameManage():setRank(Player_Type.LeftPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.RightPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.SelfPlayer,0)
		GameManageFactory:getCurGameManage():setRank(Player_Type.UpPlayer,0)
		--重置托管消息  开局后默认不托管
		GameManageFactory:getCurGameManage():playerTrShipState(Player_Type.SelfPlayer,false)
		local nextPlayID
	    if tNextPlayID then
	    	wwlog(self.logTag, "续局进贡逻辑结束后回调")
	    	nextPlayID = tNextPlayID
	    else
			wwlog(self.logTag, "速配当局第一手牌,选牌后回调")

            -- 第一首牌
            nextPlayID = self.startData.NextPlayerID
        end

        print("handleFirstStep nextPlayID", nextPlayID)

        wwlog(self.logTag, "步时" .. tostring(self.startData.PlayTimeout))
        wwlog(self.logTag, "首个出牌步时" .. tostring(self.startData.FHTimeout))
        GameManageFactory:getCurGameManage():setPlayCardTime(self.startData.FHTimeout or self.startData.PlayTimeout)
        -- 第一首牌  如果是我
        local playPosition = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, nextPlayID)
        if playPosition == Player_Type.SelfPlayer then
            GameManageFactory:getCurGameManage():showClockToPlay(playPosition, 1, 0, handler(self, self.requestPlayCard))
        else
            -- 如果不是我，那么闹钟不要隐藏
            GameManageFactory:getCurGameManage():showClockToPlay(playPosition)
        end
    end

	self:handleFirstStepEnd()
end

function RoomBase:handleFirstStepEnd( ... )
	-- body
	--开局没进来的玩家显示离开
    if self.cardRecorder then
        self.cardRecorder:onPlayFirstCard()
    end
end

--[[
通用出牌逻辑处理 （倒计时结束，或主动出牌）

--]]
-- @param playType 出牌类型 普通出牌  超时 不出
-- @param pokerCards 原始牌数据表
-- @param replacedCards 替换后牌数据表
-- @param cardType 牌类型
-- @param cardValue 牌值
function RoomBase:requestPlayCard(playType, pokerCards, replacedCards, cardType, cardValue)
    -- 打牌处理
    wwlog(self.logTag, "我出牌")
    -- if pokerCards then
    -- 	wwdump(pokerCards,"我出的原始牌")
    -- end
    -- if replacedCards then
    -- 	wwdump(replacedCards,"我出的替换后的牌")
    -- end
    local tempCards = pokerCards
    local tempCards2 = replacedCards
	if playType == PlayCardType.NORMAL then --正常出牌
		
	elseif playType == PlayCardType.OVER_TIME then --超时
		tempCards = nil
		tempCards2 = nil
	elseif playType == PlayCardType.NO_CARD then --不出
		tempCards = nil
		tempCards2 = nil
	end
	self.myPlayCardType = cardType
	self.myPlayCardValue = cardValue
	local gameplayid = self.startData.GamePlayID
	WhippedEggSceneProxy:requestPlayCard(gameplayid,tempCards,tempCards2,cardType,cardValue)
end

function RoomBase:handlePlayCard(eventid)
    if not self.StartGame then
        return
    end

    local playerdata = DataCenter:getData(eventid)
    wwdump(playerdata, "有人出牌")

    -- UserID
    if GameManageFactory:getCurGameManage():getIsTrShip() and
        tonumber(playerdata.UserID) == tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")) then
        -- 托管状态下，我打的牌
        self.myPlayCardType = playerdata.PlayCardType
        self.myPlayCardValue = playerdata.PlayCardValue
    end

    if playerdata.PlayCardType ~= 0 or playerdata.PlayCardValue ~= 0 then
        -- 王炸，顺子最大值
        self.maxPlayCardType = playerdata.PlayCardType
        self.maxPlayCardValue = playerdata.PlayCardValue

    end

	if playerdata.PlayCardValue==0 and playerdata.PlayCardType==0 then --不出
		table.insert(self.playerCardSignMaps,0)
	else --出牌
        table.insert(self.playerCardSignMaps, 1)
    end
    wwlog(self.logTag, "maxPlayCardType %d maxPlayCardValue %d ", self.maxPlayCardType, self.maxPlayCardValue)
    wwlog(self.logTag, "myPlayCardType %d myPlayCardValue %d ", self.myPlayCardType or 0, self.myPlayCardValue or 0)

    if tonumber(playerdata.NextPlayUseID) == tonumber(DataCenter:getUserdataInstance():getValueByKey("userid"))
        and self.maxPlayCardType == self.myPlayCardType and self.maxPlayCardValue == self.myPlayCardValue then
        -- 这一轮中就我的牌最大，其他人都打不过，这个时候重置最大牌值和牌型
        self.maxPlayCardType = 1
        self.maxPlayCardValue = 0
    end
    -- 接风
    if playerdata.Flag == 1 and
        tonumber(playerdata.NextPlayUseID) == tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")) then
        self.maxPlayCardType = 1
        self.maxPlayCardValue = 0

        removeAll(self.playerCardSignMaps)
        self.playerCardSignMaps = { }
        table.insert(self.playerCardSignMaps, 1)
    end
    -- 谁接风
    if playerdata.Flag == 1 then
        local playerType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, playerdata.NextPlayUseID)
        GameManageFactory:getCurGameManage():solitairePlay(playerType)
    end

    local isFirstPlayCard = GDPokerUtil.isFirstHandle(self.playerCardSignMaps, 4 - #self.currentRanks)
	if playerdata.Flag == 1 then --接风
		isFirstPlayCard  = true --接风是第一个出牌的
	end

    if isFirstPlayCard and #self.playerCardSignMaps > 1 then
        removeAll(self.playerCardSignMaps)
        self.playerCardSignMaps = { }
        table.insert(self.playerCardSignMaps, 1)
    end
    -- 播放打牌
    GameManageFactory:getCurGameManage():playCard(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, playerdata.UserID)
    , playerdata.pokerCard, playerdata.replaceCard, isFirstPlayCard)
    -- 下一个打牌计时
    GameManageFactory:getCurGameManage():setPlayCardTime(self.startData.PlayTimeout)
    local nextPosition = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, playerdata.NextPlayUseID)
    wwlog(self.logTag, "下一个打牌计时")
    if nextPosition == Player_Type.SelfPlayer then
        wwlog(self.logTag, "下一个打牌是我")
        GameManageFactory:getCurGameManage():showClockToPlay(nextPosition,
        self.maxPlayCardType, self.maxPlayCardValue, handler(self, self.requestPlayCard))
    elseif nextPosition and GameManageFactory:getCurGameManage():getPlayCardsCount(nextPosition) > 0 then
        wwlog(self.logTag, "下一个打牌不是我" .. nextPosition)
        GameManageFactory:getCurGameManage():showClockToPlay(nextPosition)
    end

    if (GameManageFactory:getCurGameManage():getPlayCardsCount(Player_Type.SelfPlayer) <= 0)
        and(next(playerdata.ParnerCard)) then
        GameManageFactory:getCurGameManage():seeFriendPlayerCard(playerdata.ParnerCard)
    end

    local someOneHide = function(uid)
        local hide = false
        local positionType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, uid)
        if positionType == Player_Type.SelfPlayer then
            if playerdata.UserID == self.seatInfos.side2[1].UserID
                and(playerdata.NextPlayUseID == self.seatInfos.side2[2].UserID
                or playerdata.NextPlayUseID == self.seatInfos.side1[2].UserID) then
                hide = true
            elseif playerdata.UserID == self.seatInfos.side1[2].UserID
                and playerdata.NextPlayUseID == self.seatInfos.side2[2].UserID then
                hide = true
            end
        elseif positionType == Player_Type.LeftPlayer then
            if playerdata.UserID == self.seatInfos.side1[2].UserID
                and(playerdata.NextPlayUseID == self.seatInfos.side1[1].UserID
                or playerdata.NextPlayUseID == self.seatInfos.side2[2].UserID) then
                hide = true
            elseif playerdata.UserID == self.seatInfos.side2[2].UserID
                and playerdata.NextPlayUseID == self.seatInfos.side1[1].UserID then
                hide = true
            end
        elseif positionType == Player_Type.RightPlayer then
            if playerdata.UserID == self.seatInfos.side1[1].UserID
                and(playerdata.NextPlayUseID == self.seatInfos.side1[2].UserID
                or playerdata.NextPlayUseID == self.seatInfos.side2[1].UserID) then
                hide = true
            elseif playerdata.UserID == self.seatInfos.side2[1].UserID
                and playerdata.NextPlayUseID == self.seatInfos.side1[2].UserID then
                hide = true
            end
        elseif positionType == Player_Type.UpPlayer then
            if playerdata.UserID == self.seatInfos.side2[2].UserID
                and(playerdata.NextPlayUseID == self.seatInfos.side2[1].UserID
                or playerdata.NextPlayUseID == self.seatInfos.side1[1].UserID) then
                hide = true
            elseif playerdata.UserID == self.seatInfos.side1[1].UserID
                and playerdata.NextPlayUseID == self.seatInfos.side2[1].UserID then
                hide = true
            end

        end
        local counts = GameManageFactory:getCurGameManage():getPlayCardsCount(positionType)
        -- 没牌了
        if counts == 0 then
            local has = false
            for _, ra in pairs(self.currentRanks) do
                if ra.positionType == positionType then
                    has = true
                end
            end
            if not has then
                table.insert(self.currentRanks, { positionType = positionType, hasChanged = true })
            end
        end

        if counts == 0 and hide then
            if positionType == Player_Type.SelfPlayer then
                GameManageFactory:getCurGameManage():showClockToPlay(Player_Type.SelfPlayer,true)
            else
                GameManageFactory:getCurGameManage():showClockToPlay(positionType,true)
            end

        end
    end

    someOneHide(self.seatInfos.side1[1].UserID)
    someOneHide(self.seatInfos.side1[2].UserID)
    someOneHide(self.seatInfos.side2[1].UserID)
    someOneHide(self.seatInfos.side2[2].UserID)
    -- 设置名字
    for i, v in pairs(self.currentRanks) do
        if v.hasChanged then
            v.hasChanged = false
            GameManageFactory:getCurGameManage():setRank(v.positionType, i)
			if v.positionType == Player_Type.UpPlayer then
				wwplyaCardLog(string.format("恭喜 上家 拿到第%d名",i))
			elseif v.positionType == Player_Type.LeftPlayer then
				wwplyaCardLog(string.format("恭喜 左家 拿到第%d名",i))
			elseif v.positionType == Player_Type.RightPlayer then
				wwplyaCardLog(string.format("恭喜 右家 拿到第%d名",i))
			elseif v.positionType == Player_Type.SelfPlayer then
				wwplyaCardLog(string.format("恭喜 我自己 拿到第%d名",i))
        end
    end
    end
    if self.cardRecorder then
        self.cardRecorder:onPlayCard(playerdata.pokerCard,DataCenter:getData(eventid).UserID)
    end
end
 
-- 结算
function RoomBase:handleGameOver(eventid)
    self.overdatas = DataCenter:getData(eventid) or { }

    local gameOverUsersSeats = GameManageFactory:getCurGameManage():getSeatsInfo(self.overdatas.players)

    local wasWin = false
    GameManageFactory:getCurGameManage():setRank(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, gameOverUsersSeats.side1[1].UserID), gameOverUsersSeats.side1[1].Ranking, true)
    GameManageFactory:getCurGameManage():setRank(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, gameOverUsersSeats.side1[2].UserID), gameOverUsersSeats.side1[2].Ranking, true)
    GameManageFactory:getCurGameManage():setRank(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, gameOverUsersSeats.side2[1].UserID), gameOverUsersSeats.side2[1].Ranking, true)
    GameManageFactory:getCurGameManage():setRank(GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, gameOverUsersSeats.side2[2].UserID), gameOverUsersSeats.side2[2].Ranking, true)

    if (gameOverUsersSeats.side1[1].Ranking == 1) or(gameOverUsersSeats.side1[2].Ranking == 1) then
        -- 判断如果side1 自己边 有第一名 则为胜利
        wasWin = true
    end

    GameManageFactory:getCurGameManage():Settlement(wasWin, self.overdatas, gameOverUsersSeats)
    -- 清空出牌信息
    removeAll(self.playerCardSignMaps)
    self.playerCardSignMaps = { }

    if self.cardRecorder then
        self.cardRecorder:onGameOver()
    end
    -- 清空玩家信息缓存 方便再次点击再次拉取
    DataCenter:clearData(WhippedEggCfg.InnerEvents.GD_EVENT_USERINFO_RESP)
end

-- 托管
function RoomBase:handleSubstitute(eventid)
    if not self.StartGame then
        return
    end
    local stTable = DataCenter:getData(eventid)
    if not stTable then
        return
    end
    wwlog(self.logTag, "托管消息收到了，当前托管状态%s %d", stTable.Type, stTable.UserID)
    -- 告诉客户端 当前的托管状态
    local playerType = GameManageFactory:getCurGameManage():getPositionbyId(self.seatInfos, stTable.UserID)
    GameManageFactory:getCurGameManage():playerTrShipState(playerType, stTable.Type == 0)
end

function RoomBase:resumeGameSet(...)
    -- body
    GameManageFactory:getCurGameManage().beginPlayFirstCard = true
    GameManageFactory:getCurGameManage().playCardBeforeDealCard = { }
    self.maxPlayCardType = 1
    self.maxPlayCardValue = 0
    self.myPlayCardType = 1
    self.myPlayCardValue = 0
end

--
function RoomBase:baseStartGame(gameStart)
    -- body
    if self.cardRecorder then
        self.cardRecorder:onGameStart(gameStart)
    end
end

function RoomBase:baseResumeGameGame(msgResume)
    -- body
    if self.cardRecorder then
        self.cardRecorder:onGameResume(msgResume)
    end
end

function RoomBase:getCardRecorder()
    return self.cardRecorder
end

return RoomBase