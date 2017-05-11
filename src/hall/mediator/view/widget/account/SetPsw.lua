-------------------------------------------------------------------------
-- Desc:          更改密码：需求文档要求，在绑定手机号之后需要设置(更改)密码。
-- Author:        Jackie Liu
-- CreateDate:    2016/10/13 17:29:18
-- Purpose:       purpose
-- Copyright (c) Jackie Liu All right reserved.
-------------------------------------------------------------------------
local SetPsw = class("SetPsw", require("app.views.uibase.PopWindowBase"))
local NetWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local Login = "hall.mediator.view.widget.account.Login"
local Toast = require("app.views.common.Toast")
local TAG = "SetPsw.lua"
-- 通用界面
local csbCommonPath = "csb.hall.account.common"
-- 修改头像
local csbSetPswPath = "csb.hall.account.set_psw"
local getStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local getWidget = function(node, flag) return ccui.Helper:seekWidgetByName(node, flag) end
local getNode = function(node, ...)
    local ret = nil
    for k, v in ipairs( { ...}) do
        if ret then
            ret = ret:getChildByName(v)
        else
            ret = node:getChildByName(v)
        end
    end
    return ret
end
local userData = DataCenter:getUserdataInstance()

function SetPsw:ctor(userInfoLayer)
    SetPsw.super.ctor(self)
    self._userInfoLayer = userInfoLayer
    self._inputPsw = nil
    self._inputPsw1 = nil
    self._broadcastHandles = { }
    self._tmpPsw = nil
    self:init()
end

function SetPsw:init()

    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    local container = getWidget(bg, "container_com")
    local setPsw = require(csbSetPswPath):create().root:addTo(container)
    local title = getWidget(bg, "title_com"):setString(getStr("set_psw"))
    local btnTitle = getWidget(bg, "btn_title_com"):setTitleText(getStr("login_1")):addClickEventListener(handler(self, self._btnCallback))
    local btnBottom = getWidget(bg, "btn_down_com"):setTitleText(getStr("register_1")):addClickEventListener(handler(self, self._btnCallback))
    self._inputPsw = getNode(setPsw, "bg_top_set", "input_top_set"):onEvent(handler(self, self._inputCallback))
    self._inputPsw1 = getNode(setPsw, "bg_down_set", "input_down_set"):onEvent(handler(self, self._inputCallback))
    local txtErrorPsw = getNode(setPsw, "error_psw_set"):setVisible(false)
    local txtDiffPsw = getNode(setPsw, "diff_psw_set"):setVisible(false)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self:_registerBroascast()
end

function SetPsw:_btnCallback(node)
    local name = node:getName()
    if name == "btn_title_com" then
        wwlog(TAG, "登录已有账号")
        self:_setView(Login)
    elseif name == "btn_down_com" then
        wwlog(TAG, "注册")
        local psw, psw1 = self._inputPsw:getString(), self._inputPsw1:getString()
        if (not psw) or(#psw < 6) or(#psw > 12) then
            Toast:makeToast(getStr("invalid_psw"), 1.5):show()
        elseif (not psw) or(#psw < 6) or(#psw > 12) or(psw ~= psw1) then
            Toast:makeToast(getStr("diff_psw"), 1.5):show()
        elseif string.match(psw, "[^0-9a-zA-Z]") then
            Toast:makeToast(getStr("invalid_psw_1"), 1.5):show()
        else
            self._tmpPsw = psw
            NetWorkProxy:modifyUserInfo( { Password = psw })
        end
    end
end

function SetPsw:_registerBroascast()
    local _ = nil
    -- 密码修改成功
    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO, handler(self, self._handleProxy))
    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO_ERROR, handler(self, self._handleProxy))
end

function SetPsw:_handleProxy(event)
    if event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO then
        -- 成功，绑定手机成功
        --        self:_setView(Login)
        Toast:makeToast(getStr("modify_succ"), 1.5):show()
        ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPsw)
        self._tmpPsw = nil
        self:removeFromParent()
    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO_ERROR then
        Toast:makeToast(getStr("modify_fail"), 1.5):show()
        self._tmpPsw = nil
    end
end

function SetPsw:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            NetWorkCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    SetPsw.super.onExit(self)
end

function SetPsw:_inputCallback(event)
    local targetName = event.target:getName()
    if targetName == "input_phone_reg" then
        if event.name == "ATTACH_WITH_IME" then
        elseif event.name == "DETACH_WITH_IME" then
        elseif event.name == "INSERT_TEXT" then
        elseif event.name == "DELETE_BACKWARD" then
        end
    end
end

function SetPsw:_setView(name, ...)
    require(name):create(self._userInfoLayer, ...):addTo(self._userInfoLayer)
    self:removeFromParent()
end

return SetPsw