-------------------------------------------------------------------------
-- Title:        忘记密码1：输入手机号。
-- Author:    Jackie Liu
-- Date:       2016/10/18 16:34:28
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ForgetPsw = class("ForgetPsw", require("app.views.uibase.PopWindowBase"))
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local Register = require("hall.mediator.view.widget.account.Register")
local ForgetPsw1 = require("hall.mediator.view.widget.account.ForgetPsw1")
local Toast = require("app.views.common.Toast")
local TAG = "ForgetPsw.lua"
-- 通用界面
local csbCommonPath = "csb.hall.account.common"
-- 修改头像
local csbRegisterPath = "csb.hall.account.register"
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

function ForgetPsw:ctor(userInfoLayer)
    ForgetPsw.super.ctor(self)

    self._userInfoLayer = userInfoLayer
    self._broadcastHandles = { }
    -- 输入手机号
    self._inputPhone = nil
    -- 发送
    self._btnSend = nil
    -- 登录已有账号
    self._btnLogin = nil
    self._txtExistPhone = nil
    -- 手机号，string
    self._phoneNo = nil
    self:init()
end

function ForgetPsw:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    local container = getWidget(bg, "container_com")
    local register = require(csbRegisterPath):create().root:addTo(container)
    -- 找回密码
    local title = getWidget(bg, "title_com"):setString(getStr("find_psw"))
    self._btnLogin = getWidget(bg, "btn_title_com"):setTitleText(getStr("register"))
    self._btnLogin:addClickEventListener(handler(self, self._btnCallback))
    self._btnSend = getWidget(bg, "btn_down_com"):setTitleText(getStr("get_verify_code"))
    self._btnSend:addClickEventListener(handler(self, self._btnCallback))
    self._txtExistPhone = getNode(register, "exist_phone_reg"):setVisible(false)
    self._inputPhone = getNode(register, "bg_phone_reg", "input_phone_reg"):onEvent(handler(self, self._inputCallback))

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self:_registerBroascast()
end

function ForgetPsw:_btnCallback(node)
    local name = node:getName()
    -- 忘记密码
    if name == "btn_title_com" then
        wwlog(TAG, "一键注册")
        self:_setView(Register)
    elseif name == "btn_down_com" then
        wwlog(TAG, "获取找回手机验证码")
        self._phoneNo = self._inputPhone:getString()
        if self._phoneNo and #self._phoneNo == 11 and tonumber(self._phoneNo) then
            UserProxy:resetPswVerify(self._phoneNo)
            node:setEnabled(false)
        else
            -- 手机格式不正确
            Toast:makeToast(getStr("bindphone3"), 1.5):show()
        end
    end
end

function ForgetPsw:_inputCallback(event)
    local targetName = event.target:getName()
    if targetName == "input_phone_reg" then
        if event.name == "ATTACH_WITH_IME" then
        elseif event.name == "DETACH_WITH_IME" then
        elseif event.name == "INSERT_TEXT" then
        elseif event.name == "DELETE_BACKWARD" then
        end
    end
end

function ForgetPsw:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            UserInfoCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    ForgetPsw.super.onExit(self)
end

function ForgetPsw:_registerBroascast()
    local _ = nil
    -- 验证码发送成功或失败
    _, self._broadcastHandles[#self._broadcastHandles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE, handler(self, self._handleProxy))
end

function ForgetPsw:_handleProxy(event)
    if event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE then
        self._btnSend:setEnabled(true)
        if event._userdata then
            -- 验证码发送成功
            -- 输入验证码
            self:_setView(ForgetPsw1, self._phoneNo)
        end
    end
end

function ForgetPsw:_setView(class, ...)
    class:create(self._userInfoLayer, ...):addTo(self._userInfoLayer)
    self:removeFromParent()
end

return ForgetPsw