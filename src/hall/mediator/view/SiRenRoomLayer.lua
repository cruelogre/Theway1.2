-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.26
-- Last:
-- Content:  私人定制界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SiRenRoomLayer = class("SiRenRoomLayer", require("app.views.uibase.PopWindowBase"))
local TAG = "SiRenRoomLayer"
local SiRenRoomCfg = import("..cfg.SiRenRoomCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local proxyHall = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local request = require("hall.request.SiRenRoomRequest")
local getStr = function(flag) return i18n:get("str_sirenrm", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local viewConf = nil
local userData = DataCenter:getUserdataInstance()

function SiRenRoomLayer:ctor(param)
	self.param = param
    self.uis = nil
    -- 执行私人定制操作是否成功
    self._enter_siren_act_succ = false
    self._broadcastHandles = { }
    -- name在没有历史记录弹框中需要用到，用来获取这个layer
    self:setName("SiRenRoomLayer")
    -- 当前所在房间，进入房间赋值，退出房间或者解散房间清空。
    -- 房间ID，是不是自己创建
    --    {roomid = nil,isself = nil}
    self._tmp_room_info = nil

    self.super.ctor(self)

    self:setOpacity(0)
    self:init()
    --    self:swallowTouch()
    self:setDisCallback( function(...)
        -- body
        FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
    end )

    -- 刷新物品箱信息	
    proxyHall:requestGoodsBoxInfo()
    -- 进入私人定制操作
    proxyHall:requestHallHandle(1, 3 ,wwConfigData.GAME_ID)
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, getComStr("comm_loading"))
end

function SiRenRoomLayer:init()
    cc.Layer:create():addTo(self):swallowTouch()
    self.uis = UIFactory:createLayoutNode(viewConf, self)
    self:bindListener()
    self.uis.txt_create_room:retain():removeFromParent():addTo(self.uis.btn_create_room:getRendererNormal()):release()
    self.uis.txt_join_room:retain():removeFromParent():addTo(self.uis.btn_join_room:getRendererNormal()):release()
end

function SiRenRoomLayer:bindListener()
    -- 控件key及函数对应表
    local itemKeys = {
        ["btn_create_room"] = handler(self,self._clickCreateRoom),
        -- 高手房
        ["btn_join_room"] = handler(self,self._clickJoinRoom),
    }
    for k, v in pairs(itemKeys) do
        self.uis[k]:addTouchEventListener( function(sender, event)
            if event == ccui.TouchEventType.ended then
                v(self.uis[k])
            end
        end )
    end
end

function SiRenRoomLayer:_clickCreateRoom(node)
    playSoundEffect("sound/effect/anniu")
    -- 请求历史记录
    if self._enter_siren_act_succ then
        if self._tmp_room_info then
            if self._tmp_room_info.isself then
                -- 当前自己已经创建了房间，进入即可
                request.returnRoom(proxy, self._tmp_room_info.roomid)
            else
                -- 当前自己已经在别人创建的房间，进入即可
                request.returnRoom(proxy, self._tmp_room_info.roomid)
            end
        else
            -- 当前没有在哪个房间里，创建房间
            request.roomConf(proxy)
        end
    else
        toast(getStr("invalid_status"), 2.0)
    end
end

function SiRenRoomLayer:_clickJoinRoom(node)
    playSoundEffect("sound/effect/anniu")
    if self._enter_siren_act_succ then
        if self._tmp_room_info then
            if self._tmp_room_info.isself then
                -- 自己创建了房间，直接进入即可
                request.returnRoom(proxy, self._tmp_room_info.roomid)
            else
                -- 当前在别人房间里。
                request.returnRoom(proxy, self._tmp_room_info.roomid)
            end
        else
            -- 当前在没在哪个房间里
            require("hall.mediator.view.widget.siren.SiRen_join_room"):create(self:getParent()):addTo(self:getParent(), self.param.zorder+1)
        end
    else
        toast(getStr("invalid_status"), 2.0)
    end
end

function SiRenRoomLayer:_handleProxy(event)
    if event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE then
        -- 创建房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT then
        -- 加入房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF then
        -- 获取玩法配置成功
        require("hall.mediator.view.widget.siren.SiRen_create_room"):create(self:getParent(), event._userdata):addTo(self:getParent(), self.param.zorder+1)
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY then
        -- 进入私人定制成功
        self._enter_siren_act_succ = true
        local data = event._userdata
        if data.RoomID > 0 and data.Type == 1 then
            -- 当前已经在某个房间中，直接进入该房间
            -- 通知玩家当前时间。
            self._tmp_room_info = { roomid = data.RoomID, isself = false }
            local new = display.newSprite("#siren_txt_back.png"):addTo(self.uis.btn_create_room:getRendererNormal()):pos(self.uis.txt_create_room:pos())
            self.uis.txt_create_room:removeFromParent()
            self.uis.txt_create_room = new
            --            request.joinRoom(proxy, data.RoomID)
            request.returnRoom(proxy, data.RoomID)
        elseif data.Type == 2 then
            -- 解散房间成功
            -- Desc并没有描述
            toast(getStr("room_released"), 2.0)
            local new = display.newSprite("#siren_txt_create.png"):addTo(self.uis.btn_create_room:getRendererNormal()):pos(self.uis.txt_create_room:pos())
            self.uis.txt_create_room:removeFromParent()
            self.uis.txt_create_room = new
            --            if self._tmp_room_info.isself then
            --                -- 是创建者的话，需要把返回房间变成创建房间
            --            else
            --                -- 别人解散了房间
            --            end

            --            -- 退还房卡
            --            if data.Param1 > 0 then
            --                updataGoods(getGoodsByFlag("fangk").fid, data.Param1)
            --            end

            self._tmp_room_info = nil
        elseif data.Type == 3 then
            -- 游戏开始，data.RoomID
            local jumpType = false
            if self._roomInfo.Playtype == Play_Type.PromotionGame then
                jumpType = Game_Type.PersonalPromotion
            elseif self._roomInfo.Playtype == Play_Type.RandomGame then
                jumpType = Game_Type.PersonalRandom
            elseif self._roomInfo.Playtype == Play_Type.RcircleGame then
                jumpType = Game_Type.PersonalRcircle
            end

            if jumpType then
                wwlog(self.logTag, "发送进入游戏事件 私人房")
                WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY, jumpType, self._roomInfo.RoomID, self._roomInfo.DWinPoint, self._roomInfo.MasterID, self._roomInfo.MultipleData)
            end
        elseif data.Type == 4 then
            -- 创建房间失败
            toast(getStr("create_room_fail"), 2.0)
        elseif data.Type == 7 then
            -- 离开房间通知，自己不能收到这条通知。
            if data.Param1 == userData:getValueByKey("userid") then
            end
        end
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO then
        -- 进入房间成功
        local data = event._userdata
        self._roomInfo = data
        self._tmp_room_info = { roomid = data.RoomID, isself = data.MasterID == userData:getValueByKey("userid") }

        local new = display.newSprite("#siren_txt_back.png"):addTo(self.uis.btn_create_room:getRendererNormal()):pos(self.uis.txt_create_room:pos())
        self.uis.txt_create_room:removeFromParent()
        self.uis.txt_create_room = new
        -- if self._tmp_room_info.isself then
        ---- 创建者需要把创建房间字样变成返回房间字样
        -- end
        -- 成功进入房间
        require("hall.mediator.view.widget.siren.SiRen_invite"):create(self:getParent(), data):addTo(self:getParent(), self.param.zorder+1)
        --    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY then
        --        -- 请求房间历史记录成功
        --        local historyInfo = data.history
        --        if #historyInfo > 0 then
        --            require("hall.mediator.view.widget.siren.SiRen_history"):create(self:getParent(), historyInfo):addTo(self:getParent(), 3)
        --        else
        --            -- 记录为空
        --            require("hall.mediator.view.widget.siren.SiRen_no_history"):create(self:getParent()):addTo(self:getParent(), 3)
        --        end
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_LEFT_SELF then
        -- 自己离开了房间
        self._tmp_room_info = nil
        local new = display.newSprite("#siren_txt_create.png"):addTo(self.uis.btn_create_room:getRendererNormal()):pos(self.uis.txt_create_room:pos())
        self.uis.txt_create_room:removeFromParent()
        self.uis.txt_create_room = new
    end
end

function SiRenRoomLayer:onEnter()
    SiRenRoomLayer.super.onEnter(self)
    local _ = nil
    -- 创建房间
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE, handler(self, self._handleProxy))
    -- 房间操作
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT, handler(self, self._handleProxy))
    -- 玩法局数配置
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF, handler(self, self._handleProxy))
    -- 房间通知
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY, handler(self, self._handleProxy))
    -- 房间信息
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self._handleProxy))
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_LEFT_SELF, handler(self, self._handleProxy))
    --    -- 历史记录
    --    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY, handler(self, self._handleProxy))

    -- 入场动画
    local winSize = cc.Director:getInstance():getVisibleSize()
    local posBtnCreate, posBtnJoin = self.uis.btn_create_room:pos(), self.uis.btn_join_room:pos()
    self.uis.btn_create_room:posX(- self.uis.btn_create_room:width2() -20)
    self.uis.btn_join_room:posX(winSize.width + self.uis.btn_create_room:width2() + 20)
    self.uis.btn_create_room:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.EaseSineOut:create(cc.MoveTo:create(0.2, posBtnCreate))))
    self.uis.btn_join_room:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.EaseSineOut:create(cc.MoveTo:create(0.2, posBtnJoin))))
end

function SiRenRoomLayer:onExit()
    print("SiRenRoomLayer onExit")

    --    -- 注销监听广播的句柄，在UISiRenRoomState进行了innerEventComponent的最终销毁，在那儿也注销了剩下的listener
    --    if self._broadcastHandles and #self._broadcastHandles > 0 then
    --        table.map(self._broadcastHandles, function(v, k)
    --            if SiRenRoomCfg.innerEventComponent then
    --                SiRenRoomCfg.innerEventComponent:removeEventListener(v)
    --            else
    --                dump(self._innerEventComponent)
    --                self._innerEventComponent:removeEventListener(v)
    --            end
    --        end )
    --    end

    SiRenRoomLayer.super.onExit(self)
end

viewConf =
{
    {
        n = "btn_create_room",
        t = "btn",
        x = ww.px(1920 * 0.25 + 50),
        y = ww.py(540),
        res = { "siren_btn_create.png", "", "", ccui.TextureResType.plistType }
    },
    {
        n = "txt_create_room",
        t = "sp",
        parent = "btn_create_room",
        res = "#siren_txt_create.png",
        centerX = "btn_create_room",
        innerBottom = "btn_create_room",
        offsetY = 10,
    },
    {
        n = "btn_join_room",
        t = "btn",
        x = ww.px(1920 * 0.75 - 50),
        y = ww.py(540),
        res = { "siren_btn_join.png", "", "", ccui.TextureResType.plistType }
    },
    {
        n = "txt_join_room",
        t = "sp",
        parent = "btn_join_room",
        res = "#siren_txt_join.png",
        centerX = "btn_join_room",
        innerBottom = "btn_join_room",
        offsetY = 10,
    },
}


return SiRenRoomLayer