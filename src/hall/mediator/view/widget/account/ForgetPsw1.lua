-------------------------------------------------------------------------
-- Desc:          忘记密码。其实就是消息文档中的重置密码
-- Author:        Jackie Liu
-- CreateDate:    2016/10/13 17:29:18
-- Purpose:       purpose
-- Copyright (c) Jackie Liu All right reserved.
-------------------------------------------------------------------------
local ForgetPsw1 = class("ForgetPsw1", require("app.views.uibase.PopWindowBase"))
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local Login = require("hall.mediator.view.widget.account.Login")
local Register = require("hall.mediator.view.widget.account.Register")
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local Toast = require("app.views.common.Toast")
local TAG = "ForgetPsw1"
-- 通用界面
local csbCommonPath = "csb.hall.account.common"
local csbForgetPswPath = "csb.hall.account.forget_psw"
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

function ForgetPsw1:ctor(userInfoLayer, phoneNo)
    ForgetPsw1.super.ctor(self)
    self._phoneNo = phoneNo
    self._userInfoLayer = userInfoLayer
    self._inputPsw = nil
    self._inputPsw1 = nil
    self._inputVerifyCode = nil
    self._btnSend = nil
    self._flagCountDown = nil
    self._broadcastHandles = { }
    self:init()
end

function ForgetPsw1:init()

    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    local container = getWidget(bg, "container_com")
    local setPsw = require(csbForgetPswPath):create().root:addTo(container)
    local title = getWidget(bg, "title_com"):setString(getStr("reset_psw"))
    local btnTitle = getWidget(bg, "btn_title_com"):setTitleText(getStr("register")):addClickEventListener(handler(self, self._btnCallback))
    self._btnSend = getNode(setPsw, "bg_top_reset_0", "btn_send_reset")
    self._btnSend:addClickEventListener(handler(self, self._btnCallback))
    getWidget(bg, "btn_down_com"):setTitleText(getStr("reset_psw")):addClickEventListener(handler(self, self._btnCallback))
    self._inputPsw = getNode(setPsw, "bg_top_reset", "input_top_reset"):onEvent(handler(self, self._inputCallback))
    self._inputPsw1 = getNode(setPsw, "bg_down_reset", "input_down_reset"):onEvent(handler(self, self._inputCallback))
    self._inputVerifyCode = getNode(setPsw, "bg_top_reset_0", "input_top_reset1"):onEvent(handler(self, self._inputCallback))
    local txtErrorPsw = getNode(setPsw, "error_psw_reset"):setVisible(false)
    local txtDiffPsw = getNode(setPsw, "diff_psw_reset"):setVisible(false)
    local txtErrorVerify = getNode(setPsw, "bg_top_reset_0", "error_verify_code"):setVisible(false)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self:_registerBroascast()
    self:_countDown()
end

-- 重新发送
function ForgetPsw1:_countDown()
    if not self._flagCountDown then
        local countTime = 60
        self._flagCountDown = self._btnSend:setEnabled(false):runAction(cc.Repeat:create(
        cc.Sequence:create(cc.CallFunc:create( function()
            countTime = countTime - 1
            if countTime <= 0 then
                self._btnSend:setEnabled(true):setTitleText(getStr("send"))
            else
                self._btnSend:setTitleText(string.format(getStr("send_again"), countTime))
                self._flagCountDown = nil
            end
        end ), cc.DelayTime:create(1.0)), countTime))
    end
end

function ForgetPsw1:_registerBroascast()
    local _ = nil
    -- 验证码发送成功或失败
    _, self._broadcastHandles[#self._broadcastHandles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE, handler(self, self._handleProxy))
    -- 重置密码
    _, self._broadcastHandles[#self._broadcastHandles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_RESET_PSW, handler(self, self._handleProxy))
end

function ForgetPsw1:_handleProxy(event)
    if event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE then
        if not self._flagCountDown then
            self._btnSend:setEnabled(true)
        end
        if event._userdata then
            -- 验证码发送成功
            self:_countDown()
        end
    elseif event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_RESET_PSW then
        -- 重置密码
        local result = event._userdata
        if result.isSucc then
            -- 成功，修改的是当前的账号，则及时更新到本地。
            if result.account == tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")) then
                ww.WWGameData:getInstance():setStringForKey("pwd", self._newPsw)
            end
            self:_setView(Login)
        end
        self._newPsw = nil
    end
end

function ForgetPsw1:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            UserInfoCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    ForgetPsw1.super.onExit(self)
end

function ForgetPsw1:_btnCallback(node)
    local name = node:getName()
    if name == "btn_title_com" then
        wwlog(TAG, "一键注册")
        self:_setView(Register)
    elseif name == "btn_down_com" then
        wwlog(TAG, "重置密码")
        local psw, psw1, verifyCode = self._inputPsw:getString(), self._inputPsw1:getString(), self._inputVerifyCode:getString()
        if (not verifyCode) or(#verifyCode ~= 6) then
            -- 验证码格式不对
            Toast:makeToast(getStr("error_verify"), 1.5):show()
        elseif (not psw) or(#psw < 6) or(#psw > 12) then
            Toast:makeToast(getStr("invalid_psw"), 1.5):show()
        elseif (not psw) or(#psw < 6) or(#psw > 12) or(psw ~= psw1) then
            Toast:makeToast(getStr("diff_psw"), 1.5):show()
        elseif string.match(psw, "[^0-9a-zA-Z]") then
            Toast:makeToast(getStr("invalid_psw_1"), 1.5):show()
        else
            self._newPsw = psw
            UserProxy:resetPswByPhone(self._phoneNo, verifyCode, psw)
        end
    elseif name == "btn_send_reset" then
        -- 发送重置密码的验证码
        UserProxy:resetPswVerify(self._phoneNo)
    end
end

function ForgetPsw1:_inputCallback(event)
    local targetName = event.target:getName()
    if targetName == "input_phone_reg" then
        if event.name == "ATTACH_WITH_IME" then
        elseif event.name == "DETACH_WITH_IME" then
        elseif event.name == "INSERT_TEXT" then
        elseif event.name == "DELETE_BACKWARD" then
        end
    end
end

function ForgetPsw1:_setView(cls, ...)
    cls:create(self._userInfoLayer, ...):addTo(self._userInfoLayer)
    self:removeFromParent()
end

return ForgetPsw1