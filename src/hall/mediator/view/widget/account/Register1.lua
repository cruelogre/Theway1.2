-------------------------------------------------------------------------
-- Title:        手机注册号2：输入验证码注册
-- Author:    Jackie Liu
-- Date:       2016/10/14 14:58:00
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local Register1 = class("Register1", require("app.views.uibase.PopWindowBase"))
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local Login = "hall.mediator.view.widget.account.Login"
local SetPsw = "hall.mediator.view.widget.account.SetPsw"
local Register = "hall.mediator.view.widget.account.Register"
local Toast = require("app.views.common.Toast")
local TAG = "Register1.lua"
-- 通用界面
local csbCommonPath = "csb.hall.account.common"
local csbRegister1Path = "csb.hall.account.verify_code"
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

function Register1:ctor(userInfoLayer, phoneNo)
    Register1.super.ctor(self)

    self._userInfoLayer = userInfoLayer
    self._phoneNo = phoneNo
    self._flagSendCountDown = nil
    self._broadcastHandles = { }
    self._btnSend = nil
    self._inputCode = nil
    self._btnVerify = nil

    self:init()

end

function Register1:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    local container = getWidget(bg, "container_com")
    local verifyCode = require(csbRegister1Path):create().root:addTo(container)
    local title = getWidget(bg, "title_com"):setString(getStr("input_verify_code"))
    local btnTitle = getWidget(bg, "btn_title_com"):setTitleText(getStr("login_1")):addClickEventListener(handler(self, self._btnCallback))
    self._btnVerify = getWidget(bg, "btn_down_com"):setTitleText(getStr("verify"))
    self._btnVerify:addClickEventListener(handler(self, self._btnCallback))
    self._inputCode = getNode(verifyCode, "bg_input_verify", "input_code_verify")
    local txtPhone = getNode(verifyCode, "phone_verify", "phone_txt_verify"):setString(string.format(getStr("your_phone"), self._phoneNo))

    local txtHint = getNode(verifyCode, "phone_txt1_verify")
    self._btnSend = getNode(verifyCode, "btn_send_verify")
    self._btnSend:addClickEventListener(handler(self, self._btnCallback))

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self:_registerBroascast()
    self:_sendCountDown()
end

function Register1:_sendCountDown()
    if not self._flagSendCountDown then
        local countTime = 60
        self._flagSendCountDown = self._btnSend:setEnabled(false):setTitleText(string.format(getStr("send_again"), countTime)):runAction(
        cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create( function()
            countTime = countTime - 1
            if countTime <= 0 then
                self._btnSend:setEnabled(true):setTitleText(getStr("send"))
                self._flagSendCountDown = nil
            else
                self._btnSend:setTitleText(string.format(getStr("send_again"), countTime))
            end
        end ), cc.DelayTime:create(1.0)), countTime))
    end
end

function Register1:_btnCallback(node)
    local name = node:getName()
    if name == "btn_title_com" then
        wwlog(TAG, "登录已有账号")
        self:_setView(Login)
    elseif name == "btn_down_com" then
        wwlog(TAG, "验证信息")
        local verifyCode = tonumber(self._inputCode:getString())
        if verifyCode then
            -- 注册，也就是绑定手机
            if fuckingbind then
                UserProxy:bindPhone(self._phoneNo, verifyCode)
            else
                UserProxy:unbindPhone(self._phoneNo, verifyCode)
            end
            --            node:setEnabled(false)
        else
            Toast:makeToast(getStr("error_verify_code"), 1.5):show()
        end
    elseif name == "btn_send_verify" then
        wwlog(TAG, "重新发送")
        --        node:setEnabled(false)
        UserProxy:bindPhoneVerify(self._phoneNo)
    end
end

function Register1:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            UserInfoCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    Register1.super.onExit(self)
end

function Register1:_registerBroascast()
    local _ = nil
    -- 验证码发送成功或失败
    _, self._broadcastHandles[#self._broadcastHandles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE, handler(self, self._handleProxy))
    _, self._broadcastHandles[#self._broadcastHandles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_BIND_PHONE, handler(self, self._handleProxy))
end

function Register1:_handleProxy(event)
    if event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE then
        -- 验证码发送
        if event._userdata then
            -- 成功
            self:_sendCountDown()
        else
            -- 失败
            if not self._flagSendCountDown then
                self._btnSend:setEnabled(true)
            end
        end
    elseif event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_BIND_PHONE then
        self._btnVerify:setEnabled(true)
        if event._userdata then
            -- 注册手机账号成功，也就是绑定手机号成功
            -- 需要显示更新密码界面，界面上显示是设置密码界面
            DataCenter:getUserdataInstance():setUserInfoByKey("BindPhone", tostring(self._phoneNo))
            self._userInfoLayer:bindphone()
            self:_setView(SetPsw)
        else
            -- 失败
        end
    end
end

function Register1:_setView(name, ...)
    require(name):create(self._userInfoLayer, ...):addTo(self._userInfoLayer)
    self:removeFromParent()
end

return Register1