-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.25
-- Last:
-- Content:  场景管理器(大厅)
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local WWSceneBase = class("WWSceneBase", cc.Scene)
local ExitGameLayer = require("app.views.customwidget.ExitGameLayer")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local LuaLoginNativeBridge = require("app.utilities.LuaLoginNativeBridge"):create()
import(".KeyBoardEvent", "app.event.")
local IPhoneTool = ww.IPhoneTool:getInstance()
local NetWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)

function WWSceneBase:ctor(callback)
    self.callback = callback
    self.logTag = "WWSceneBase.lua"
    self.listener2 = nil
    self.systemInfoNode = nil
    self.handles = { }
    self:initListener()
    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )

end

function WWSceneBase:createExitGameDialog()
    LuaLoginNativeBridge:callNativeLogout(
    handler(self, self._logoutSuccThridParty),
    handler(self, self._logoutFailThridParty),
    function()
        -- 非第三方登录情况
        local function exitCallback(...)
            -- body
            if self.ExitGameLayer then
                self.ExitGameLayer:close()
                self.ExitGameLayer = nil
            end
        end
        self.ExitGameLayer = ExitGameLayer:create(exitCallback)
        self.ExitGameLayer:show()
    end )
end

-- sdk退出成功
function WWSceneBase:_logoutSuccThridParty(result)
    wwlog(self.logTag, "_logoutSuccThridParty result=%s:", result or "")
    cc.Director:getInstance():endToLua()
end

-- sdk退出失败
function WWSceneBase:_logoutFailThridParty(result)
    wwlog(self.logTag, "_logoutFailThridParty result=%s:", result or "")
end

function WWSceneBase:onEnter()
    local function keyboardPressed(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK then
            if MediatorMgr:getPopupNodeCount() == 0 then
                playSoundEffect("sound/effect/anniu")
                if self.callback then
                    -- 有回调优先回调
                    self.callback()
                else
                    -- 弹出退出提示界面
                    if self.ExitGameLayer then
                        self.ExitGameLayer:close()
                        self.ExitGameLayer = nil
                    else
                        self:createExitGameDialog()
                    end
                end
            end
        end
    end

    self.listener2 = cc.EventListenerKeyboard:create()
    self.listener2:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    eventDispatcher:addEventListenerWithFixedPriority(self.listener2, KEYBOARD_EVENTS.KETBOARD_SCENE)
end

function WWSceneBase:initListener()
    if self:getEventComponent() ~= nil then
        local _, handle1 = self:getEventComponent():addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR,
        handler(self, self.networkEvent))
        table.insert(self.handles, handle1)
        local _, handle2 = self:getEventComponent():addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_CONNECTED,
        handler(self, self.networkEvent))
        table.insert(self.handles, handle2)
        local _, handle3 = self:getEventComponent():addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_RELOGIN,
        handler(self, self.networkEvent))
        table.insert(self.handles, handle3)
        local _, handle4 = self:getEventComponent():addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK,
        handler(self, self.networkEvent))
        table.insert(self.handles, handle4)
    end
end
function WWSceneBase:networkEvent(event)
    wwlog(self.logTag, "WWSceneBase:networkEvent %s", event.name)
    if isLuaNodeValid(self.systemInfoNode) then
        self.systemInfoNode:close()

    end
    self.systemInfoNode = nil
    if event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR then
        -- 网络异常
        local para = { }

        -- 提示类型  1 未连接网络 2 网络断开 3 正在连接中
        para.type = IPhoneTool:isNetworkConnected() and 2 or 1
        para.isAnim = true
        para.btnCallback = function(mType)
            -- wwConfigData.REQUEST_IPS = {"192.168.10.53", }
            if mType == 1 then

                NetWorkProxy:connectServer()
            else
                -- NetWorkProxy:fastLoin()
                NetWorkProxy:connectServer()
            end

            -- self.systemInfoNode = nil
            LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get('str_common', 'comm_net_connectding'))

        end

        self.systemInfoNode = import(".SystemInfoDialog", "app.views.customwidget."):create(para)

        self.systemInfoNode:show()

    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_CONNECTED then
        -- 网络连接成功
        wwlog(self.logTag, "网络连接成功")
        if DataCenter:getUserdataInstance():getValueByKey("Flag_Logout_Manually") then
            -- 主动注销，即切换账号这类行为时，不能让自动登录。由具体业务逻辑自行登录。
        else
            NetWorkProxy:fastLoin()
        end
    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_RELOGIN then
        -- 网络需要重新登录

    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK then
        -- 登录成功
        LoadingManager:endLoading()
        wwlog(self.logTag, "登录成功")

        -- 登录成功发送
        WWFacade:dispatchCustomEvent("loginSucceed", { })
    end

end
function WWSceneBase:onExit()

    if self.listener2 and eventDispatcher then
        eventDispatcher:removeEventListener(self.listener2)
    end
    self.listener2 = nil
    if self:getEventComponent() and next(self.handles) then
        for _, v in pairs(self.handles) do
            self:getEventComponent():removeEventListener(v)
        end
        removeAll(self.handles)
    end
end
function WWSceneBase:getEventComponent()
    return NetWorkCfg.innerEventComponent
end

return WWSceneBase