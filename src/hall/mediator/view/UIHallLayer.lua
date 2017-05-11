-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.10.18
-- Last:
-- Content:  大厅首页界面 状态机界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local UIHallLayer = class("UIHallLayer", function()
    return display.newLayer()
end )
local HallTopLayer = import(".HallTopLayer", "hall.mediator.view.")
local HallContentLayer = import(".HallContentLayer", "hall.mediator.view.")
local HallBottomLayer = import(".HallBottomLayer", "hall.mediator.view.")
local Noticecroll = require("hall.mediator.view.Noticecroll")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local HallCfg = require("hall.mediator.cfg.HallCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

require("WhippedEgg.ConstType")

local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)


function UIHallLayer:ctor()
    self:init()
    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )

end
--
function UIHallLayer:init()
    self.logTag = "UIHallLayer.lua"
    cclog("显示大厅背景")

    playBackGroundMusic("sound/backMusic/hallBackGroundMusic", true)


    self:showView()
    -- 上传大厅场景ID
    ToolCom:uploadSceneID(wwConfigData.SCENE_ID.HALL)
end

function UIHallLayer:showView()

    -- 中间内容区布局
    self.hallContent = HallContentLayer:create()
    self:addChild(self.hallContent, 2)
    -- 顶部布局
    self.topview = HallTopLayer:create()
    self:addChild(self.topview, 2)
    -- 底部布局
    self.bottomView = HallBottomLayer:create()
    self:addChild(self.bottomView, 2)

    self.noticecroll = Noticecroll:create()
    self:addChild(self.noticecroll, 4)
end

function UIHallLayer:setContentVisible(visible)
    print("HallSceneMediator setContentVisible %d", visible and 1 or 0)
    if isLuaNodeValid(self.hallContent) then
        print("HallSceneMediator hallContent visible")
        self.hallContent:setVisible(visible)
    end
    if isLuaNodeValid(self.topview) then
        self.topview:setVisible(visible)
    end
    if isLuaNodeValid(self.bottomView) then
        self.bottomView:setVisible(visible)
    end
    if isLuaNodeValid(self.hallContent) then
        self.hallContent:setVisible(visible)
    end
    if isLuaNodeValid(self.noticecroll) then
        self.noticecroll:setVisible(visible)
    end
end
-- 装载组建消息事件
function UIHallLayer:installInnerEventListeners()
    -- 个人信息刷新区域监听
    self.listener1 = WWFacade:addCustomEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
    self.listener2 = WWFacade:addCustomEventListener(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, handler(self, self.refreshHallList))

end




function UIHallLayer:refreshHallList(event)
    if isLuaNodeValid(self.hallContent) then
        self.hallContent:refreshContent(unpack(event._userdata))
    end
end
--[[
handleType 为消息处理类型
--]]
function UIHallLayer:refreshInfo(event)
    local handleType = unpack(event._userdata)
    if handleType == 1 then
        -- 刷新个人信息区域
        wwlog(self.logTag, "更新大厅信息")
        if self.bottomView then
            self.bottomView:valueHandle()
        end
    elseif handleType == 2 then
        -- 红点通知
    end
end

function UIHallLayer:onEnter()
    self:installInnerEventListeners()

    local cash = DataCenter:getUserdataInstance():getValueByKey("GameCash")
	local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
    if cash and tonumber(cash) < HallCfg.bankRuptLimit and loginMsg and next(loginMsg) and loginMsg.hallversion then
        -- 不要频繁发送 本地先判断我的金币
        wwlog(self.logTag, "请求破产标志")
        local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
        HallSceneProxy:requestIsBankrupt()
    end
end

function UIHallLayer:onExit()
    print("UIHallLayer  onExit")

    if self.listener1 then
        WWFacade:removeEventListener(self.listener1)
    end
    if self.listener1 then
        WWFacade:removeEventListener(self.listener2)
    end


    self.topview = nil
    self.hallContent = nil
    self.bottomView = nil
    self.scene = nil
end


return UIHallLayer