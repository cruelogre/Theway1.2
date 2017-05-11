-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.29
-- Last:
-- Content:  经典玩法逻辑处理  这里不做任何UI或数据相关处理，单纯的业务逻辑处理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullBaseLogic = class("BullBaseLogic",require("packages.mvc.Mediator"))
local BullFinghtingCfg = require("BullFighting.mediator.cfg.BullFinghtingCfg")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

function BullBaseLogic:ctor()
    self.logTag = "BullBaseLogic.lua"
    -- 记牌器
    self:init()
end

function BullBaseLogic:init()
    self.logTag = "BullBaseLogic.lua"
    self.innorRoomswitch = false

    --这里要判断一下信息是否已经进来了 最后一个人进来的时候 数据最先过来
    local bullStart = DataCenter:getData(BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM)
    if bullStart and next(bullStart) then
        local event  = {name = BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM, _userdata = bullStart }
        wwlog(self.logTag, "进来前就收到响应进入房间")
        self:commondEventHandle(event)
    end

    self.handlers = {}

    local _,handler1 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_GAMESTART,handler(self,self.commondEventHandle))
    local _,handler2 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_SHOWPOKER,handler(self,self.commondEventHandle))
    local _,handler3 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_STARTBETSHOW,handler(self,self.commondEventHandle))
    local _,handler4 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_BET,handler(self,self.commondEventHandle))
    local _,handler5 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_GAMEOVER,handler(self,self.commondEventHandle))
    local _,handler6 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM,handler(self,self.commondEventHandle))
    local _,handler7 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_NOTICEINOUT,handler(self,self.commondEventHandle))
    local _,handler8 = BullFinghtingCfg.innerEventComponent:addEventListener(BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP,handler(self,self.commondEventHandle))

    table.insert(self.handlers,handler1)
    table.insert(self.handlers,handler2)
    table.insert(self.handlers,handler3)
    table.insert(self.handlers,handler4)
    table.insert(self.handlers,handler5)
    table.insert(self.handlers,handler6)
    table.insert(self.handlers,handler7)
    table.insert(self.handlers,handler8)

    --加好友等其他消息请求反馈
    self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST,handler(self, self.response))

    --断线重连
    self:registerEventListener("loginSucceed",function ( ... )
        -- body
        self.innorRoomswitch = false

        if not self.loginSucceedScriptFuncId then
            self.loginSucceedScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
                -- body
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loginSucceedScriptFuncId)
                self.loginSucceedScriptFuncId = false

                if not self.innorRoomswitch then
                    BullFightingManage:exitGame()
                end
            end, 5, false)
        end

        --重新发送准备消息
        BullFightingManage:clearGame()

        local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
        local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)

        BullFightingSceneProxy:requestLobbyActionHandle(BullFightingSceneController.GameZoneID, 13)  --请求进入随机、看牌场房间
    end)

end

-- 重新滞空
function BullBaseLogic:recycle()
   
    if BullFinghtingCfg.innerEventComponent then
        if self.handlers then
            for _, handlerX in pairs(self.handlers) do
                BullFinghtingCfg.innerEventComponent:removeEventListener(handlerX)
            end
        end
    end
    removeAll(self.handlers)

    self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST)
    self:unregisterEventListener("loginSucceed")
end

--加好友等其他消息请求反馈
function BullBaseLogic:response( event )
    -- body
    if event._eventName == CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST then
        if event._userdata[1] and event._userdata[1].type and event._userdata[1].type == 1 then --好友申请
            BullFightingManage:reponseFriend(event._userdata[1].FromUserID,event._userdata[1].ToUserID)
        end
    end
end

-- 斗牛消息反馈
function BullBaseLogic:commondEventHandle(event)
    wwlog(self.logTag, "斗牛玩法消息回调处理")
    wwdump(event._userdata)
    if event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_GAMESTART then --开局
        if self.innorRoomswitch then
            wwlog(self.logTag,"收到斗牛游戏开局消息")
            self:startGame(event._userdata)
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_SHOWPOKER then --亮牌 --显示完成
        if self.innorRoomswitch then
            wwlog(self.logTag,"响应玩家亮牌")
            BullFightingManage:CanShowCompleteCard( event._userdata.UserID )
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_STARTBETSHOW then --通知亮牌
        if self.innorRoomswitch then
            wwlog(self.logTag,"通知发牌")
            BullFightingManage:bullDealCard(event._userdata)
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_BET then --响应玩家下注
        if self.innorRoomswitch then
            wwlog(self.logTag,"响应玩家下注")
            BullFightingManage:setMultiple(event._userdata.UserId,tonumber(event._userdata.Chip))
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_GAMEOVER then --牌局结束
        if self.innorRoomswitch then
            wwlog(self.logTag,"牌局结束")
            BullFightingManage:settment(event._userdata)
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM then --响应进入房间
        wwlog(self.logTag,"响应进入房间数据")
        self:innorRoom(event._userdata)
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_NOTICEINOUT then --通知进/出房间(随机、看牌新玩法)
        if self.innorRoomswitch then
            wwlog(self.logTag,"通知进/出房间")
            self:noticeInOrOut(event._userdata)
        end
    elseif event.name == BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP then --玩家信息
        if self.innorRoomswitch then
            wwlog(self.logTag,"收到玩家信息通知")
            self:handleUserInfo(event.name,event._userdata)
        end
    end
end

--开始游戏
function BullBaseLogic:startGame( userdata )
    -- body
    local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)
    BullFightingSceneController.GamePlayID = userdata.GamePlayID
    BullFightingSceneController.PlayType = userdata.PlayType
	--存储开赛信息
	DataCenter:cacheData(COMMON_EVENTS.C_EVENT_GAMEDATA,{GamePlayID = userdata.GamePlayID })


    BullFightingManage:updateBeginPlayerData(userdata)
    --播放开始动画
    BullFightingManage:playBeginAni(function ( ... )
        -- body
        BullFightingManage:chooseMultiple(userdata)
    end,userdata.BankUserID)
end

--响应进入房间
function BullBaseLogic:innorRoom( userdata )
    -- body
    self.innorRoomswitch = true
    local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
    local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)
    BullFightingSceneController.GamePlayID = userdata.GamePlayID
    BullFightingSceneController.PlayType = userdata.PlayType
	
	--存储开赛信息
	DataCenter:cacheData(COMMON_EVENTS.C_EVENT_GAMEDATA,{GamePlayID = userdata.GamePlayID })

    local para = {}
    para.leftBtnlabel = i18n:get('str_bullfighting','bull_exit_room')
    para.rightBtnlabel = i18n:get('str_bullfighting','bull_repeat')
    para.rightBtnCallback = function ( ... )
        -- body
        BullFightingSceneProxy:requestLobbyActionHandle(BullFightingSceneController.GameZoneID, 13)  --请求进入随机、看牌场房间
    end
    para.leftBtnCallback = function ( ... )
    -- body
        BullFightingManage:exitGame()
    end
    para.showclose = false  --是否显示关闭按钮
    wwlog(self.logTag,"状态userdata.GameStatus %d",userdata.GameStatus)
    if userdata.ReturnCode == 1 then --0-失败  1-成功9-筹码不足10-在玩其他场次11-房间已达到限制  13-没有匹配到空闲桌子
        BullFightingManage:initRoom(userdata)
        return
    elseif userdata.ReturnCode == 0 then
        para.content = i18n:get('str_bullfighting','bull_join_room_fail')
    elseif userdata.ReturnCode == 9 then
        para.content = i18n:get('str_bullfighting','bull_money_not_enough')
    elseif userdata.ReturnCode == 10 then
        para.content = i18n:get('str_bullfighting','bull_play_other')
    elseif userdata.ReturnCode == 11 then
        para.content = i18n:get('str_bullfighting','bull_room_limit')
    elseif userdata.ReturnCode == 13 then
        para.content = i18n:get('str_bullfighting','bull_have_no_desk')
    end
    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

--有人离开或进来
function BullBaseLogic:noticeInOrOut( userdata )
    -- body
    userdata.Status = 1 --(int1) 状态1= 旁观者2= 对局者
    userdata.BetRate = -1 --(int1)用户1 下注倍数-1 表示自己还没下注
    userdata.CardStatus = -1 --(int1) 状态1：四张暗牌2：四张明牌3：五张暗牌4：五张明牌
    userdata.Card = {} --用户1的牌
    userdata.BullNum = -1 --用户1的牌型；0-无牛 1-牛丁 以此类推 10-牛牛11-四炸 12-五花牛 13-五小牛
    userdata.ShowPokerTime = -1 --用户1的亮牌时间
    userdata.isShow = -1 --(int1) 是否亮牌0：未亮牌1：已亮牌
    userdata.Gender = tonumber(userdata.Gender)
    if userdata.Type == 1 then
        wwlog(self.logTag,"有人进来")
        BullFightingManage:addPlayerBySit(userdata)
    elseif userdata.Type == 2 then
        wwlog(self.logTag,"有人离开")
        BullFightingManage:addDelPlayer(userdata)
    end
end

function BullBaseLogic:handleUserInfo(eventid,reqUserid)
    wwlog(self.logTag, "显示玩家头像信息"..tostring(eventid)..","..tostring(reqUserid))
    local userinfoTables = DataCenter:getData(eventid)
    if not userinfoTables or not userinfoTables[reqUserid] then
        return
    end
    if BullFightingManage.reqUserId ~= nil and 
        userinfoTables[BullFightingManage.reqUserId] then
        local playerInfo = BullFightingManage:getPlayerInfoById( BullFightingManage.reqUserId )
        if playerInfo then
            local playerType = playerInfo.SeatId
            userinfoTables[BullFightingManage.reqUserId].fileName = "guandan/head_boy.png"
            BullFightingManage:checkPlayInfo(playerType,userinfoTables[BullFightingManage.reqUserId])
        end
    end
end

return BullBaseLogic