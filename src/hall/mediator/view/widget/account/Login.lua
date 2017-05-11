-------------------------------------------------------------------------
-- Title:       登录界面
-- Author:    Jackie Liu
-- Date:       2016/10/14 14:58:00
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local Login = class("Login", require("app.views.uibase.PopWindowBase"))
local NetWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
-- local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local ForgetPsw = "hall.mediator.view.widget.account.ForgetPsw"
local Register = "hall.mediator.view.widget.account.Register"
local Toast = require("app.views.common.Toast")
local TAG = "Login.lua"
-- 通用界面
local csbCommonPath = "csb.hall.account.common"
-- 修改头像
local csbLoginPath = "csb.hall.account.login"
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

function Login:ctor(userInfoLayer)
    Login.super.ctor(self)

    self._userInfoLayer = userInfoLayer
    self._broadcastHandles = { }
    self._inputPhoneNo = nil
    self._inputPsw = nil

    self._tmpPhoneNoLogin = nil
    self._tmpPswLogin = nil
    -- 区分当前的注销和登录。
    self._tmpFlagForCurRequest = nil

    self._loginStatus = true
    self._isMobilePlatform = device.platform == "android" or device.platform == "ios"

    self:init()
end

function Login:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    local container = getWidget(bg, "container_com")
    local login = require(csbLoginPath):create().root:addTo(container)
    local title = getWidget(bg, "title_com"):setString(getStr("login"))
    local txtBtnTitle =(DataCenter:getUserdataInstance():getValueByKey("BindPhone") ~= "" and "swtich_tourist" or "register")
    local btnTitle = getWidget(bg, "btn_title_com"):setTitleText(getStr(txtBtnTitle)):addClickEventListener(self:_safeClick(handler(self, self._btnCallback)))

    local btnBottom = getWidget(bg, "btn_down_com"):setTitleText(getStr("login"))
    btnBottom:addClickEventListener(self:_safeClick(handler(self, self._btnCallback), 2.5))
    self._inputPhoneNo = getNode(login, "bg_top_login", "input_phone_login"):onEvent(handler(self, self._inputCallback))
    self._inputPsw = getNode(login, "bg_down_login", "input_psw_login"):onEvent(handler(self, self._inputCallback))
    local txtNoPhone = getNode(login, "no_phone_login"):setVisible(false)
    local txtErrorPhone = getNode(login, "error_psw_login"):setVisible(false)
    local cbRemPsw = getNode(login, "cb_psw_login"):onEvent(handler(self, self._checkBoxCallback)):setSelected(ww.WWGameData:getInstance():getIntegerForKey("flag_remember_account", 1) == 1)
    getWidget(bg, "txt_forget_psw"):setTouchEnabled(true):setVisible(true):addClickEventListener(self:_safeClick(handler(self, self._btnCallback)))

    -- 记住了密码且绑定了手机号
    if cbRemPsw:isSelected() then
        local remBindPhoneNo = ww.WWGameData:getInstance():getStringForKey("remember_account_bind_phone_no")
        local remBindPhonePwd = ww.WWGameData:getInstance():getStringForKey("remember_account_bind_phone_psw")
        local curBindPhoneNo = DataCenter:getUserdataInstance():getValueByKey("BindPhone")
        local curBindPhonePwd = ww.WWGameData:getInstance():getStringForKey("pwd")
        local showNo, showPwd = remBindPhoneNo, remBindPhonePwd

        --        if curBindPhoneNo ~= "" then
        --            -- 当前的是绑定手机账号
        --            showNo, showPwd = curBindPhoneNo, curBindPhonePwd
        --        elseif remBindPhoneNo ~= "" then
        --            -- 当前不是绑定手机账号，记录上一次的绑定手机账号
        --            showNo, showPwd = remBindPhoneNo, remBindPhonePwd
        --        end
        self._inputPhoneNo:setString(showNo)
        self._inputPsw:setString(showPwd)
    end

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self.popOut = handler(self, self.readyToClose)

    self:_registerBroascast()
end

function Login:readyToClose()
    if not self._loginStatus then
        -- 退出登录界面呈非登录态，则登录老账号
        self._tmpFlagForCurRequest = "login_local_account"
        local para = { }
        local function relogin()
            --            NetWorkProxy:fastLoin()
            NetWorkProxy:connectServer()
        end
        local function loginTourist()
            if self._isMobilePlatform then
                self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                NetWorkProxy:sendRegisterTourist(self._tmpPswLogin)
            else
                self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                NetWorkProxy:sendRegister(self._tmpPswLogin)
            end
        end
        if DataCenter:getUserdataInstance():getValueByKey("BindPhone") ~= "" and false then
            para.leftBtnlabel = getStr("btn_relogin")
            para.rightBtnlabel = getStr("btn_login_tourist")
            para.leftBtnCallback = relogin
            para.rightBtnCallback = loginTourist
            para.showclose = false
            -- 是否显示关闭按钮
            para.content = getStr("keep_login_dialog_cntnt")
        else
            para.leftBtnlabel = getStr("btn_relogin")
            --            para.rightBtnlabel = i18n:get("str_common", "comm_sure")
            para.leftBtnCallback = relogin
            --            para.rightBtnCallback = dialogOk
            para.showclose = false
            -- 是否显示关闭按钮
            para.content = getStr("keep_login_dialog_cntnt")
        end
        import(".CommonDialog", "app.views.customwidget."):create(para):show()
    else
        self.super.popOut(self)
    end
end

function Login:_checkBoxCallback(event)
    if event.name == "selected" then
        -- selected
    else
        -- unselected
        ww.WWGameData:getInstance():setStringForKey("remember_account_bind_phone_no", "")
        ww.WWGameData:getInstance():setStringForKey("remember_account_bind_phone_psw", "")
    end
    ww.WWGameData:getInstance():setIntegerForKey("flag_remember_account", event.name == "selected" and 1 or 0)
end

function Login:_btnCallback(node)
    local name = node:getName()
    if not self._loginStatus and name ~= "btn_down_com" then
        self:readyToClose()
        return
    end
    if name == "btn_title_com" then
        if DataCenter:getUserdataInstance():getValueByKey("BindPhone") ~= "" then
            wwlog(TAG, "切换至游客账号")
            -- 两种情况：本地存在游客账号则登录，不存在则注册登录
            -- 游客账号和ID。
            local touristID = ww.WWGameData:getInstance():getIntegerForKey("tourist_account_userid", 0)
            local touristPwd = ww.WWGameData:getInstance():getStringForKey("tourist_account_pwd", "")
            if touristID and touristID ~= 0 and touristPwd and touristPwd ~= "" then
                -- 登录到本地已有的游客账号
                self._tmpFlagForCurRequest = "login_local_tourist_account"
                DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", true)
                --                NetWorkProxy:switchUser()
                -- 切换到本地保存的游客账号
                NetWorkProxy:sendLoginPhone(touristID, touristPwd)
                LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, getStr("waiting"))
            else
                -- 注册游客账号并登录
                self._tmpFlagForCurRequest = "register_tourist_account"
                --                                NetWorkProxy:switchUser()
                DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", true)
                -- 断开重连是要确保上一个账号已经下线，防止登录了游客账号，其实上一个账号还在线。
                ww.WWMsgManager:getInstance():logout()
                NetWorkProxy:connectServer()
                if self._isMobilePlatform then
                    -- 注册新的游客账号
                    self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                    ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                    NetWorkProxy:sendRegisterTourist(self._tmpPswLogin)
                else
                    -- 注册新的游客账号
                    self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                    ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                    NetWorkProxy:sendRegister(self._tmpPswLogin)
                end
                LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, getStr("waiting"))
            end
        else
            wwlog(TAG, "一键注册")
            self:_setView(Register)
        end
    elseif name == "btn_down_com" then
        wwlog(TAG, "登录")
        -- 检查手机号和密码的合法性
        local phoneNo, phonePsw = self._inputPhoneNo:getString(), self._inputPsw:getString()
        -- 按理还需要判断下登录的是不是当前已经登录的账号，因为后台只返回了是否绑定了手机号并没有返回号码，所以无法判断
        if (not phoneNo) or(#phoneNo ~= 11) or(not tonumber(phoneNo)) then
            -- 手机号不对
            Toast:makeToast(getStr("bindphone3"), 1.5):show()
        elseif (not phonePsw) or #phonePsw < 6 or #phonePsw > 12 then
            -- 密码不对
            Toast:makeToast(getStr("bindphone13"), 1.5):show()
        elseif string.match(phonePsw, "[^0-9a-zA-Z]") then
            Toast:makeToast(getStr("invalid_psw_1"), 1.5):show()
        elseif phoneNo == DataCenter:getUserdataInstance():getValueByKey("BindPhone") then
            Toast:makeToast(getStr("double_login"), 1.5):show()
        else
            -- 登录另一个绑定手机号的账号
            if self._inputPsw and self._inputPhoneNo and
                self._inputPsw._tmp_last_try_login_psw == self._inputPsw:getString() and
                self._inputPhoneNo._tmp_last_try_login_phoneno == self._inputPhoneNo:getString() then
                -- 重复上一次登录失败的账号，
                Toast:makeToast(getStr("error_account_psw"), 2.0):show()
                return
            end
            self._tmpFlagForCurRequest = "login_another_account"
            self._tmpPhoneNoLogin = self._inputPhoneNo:getString()
            self._tmpPswLogin = self._inputPsw:getString()
            -- 注销当前账号再登录新账号
            if self._loginStatus then
                NetWorkProxy:switchUser()
            else
                NetWorkProxy:sendLoginPhone("86" .. self._tmpPhoneNoLogin, self._tmpPswLogin)
            end
            DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", true)
            LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, getStr("waiting"))
        end
    elseif name == "txt_forget_psw" then
        wwlog(TAG, "忘记密码？")
        UmengManager:eventCount("MyInfoPWDGet")

        self:_setView(ForgetPsw, false)
    end
end

function Login:_inputCallback(event)
    local targetName = event.target:getName()
    if targetName == "input_phone_reg" then
        if event.name == "ATTACH_WITH_IME" then
        elseif event.name == "DETACH_WITH_IME" then
        elseif event.name == "INSERT_TEXT" then
        elseif event.name == "DELETE_BACKWARD" then
        end
    end
end

function Login:_registerBroascast()
    local _ = nil
    -- 验证码发送成功或失败
    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK, handler(self, self._handleProxy))
    -- 登录失败
    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINERROR, handler(self, self._handleProxy))
    -- 注销成功
    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGOUTOK, handler(self, self._handleProxy))
end

function Login:_handleProxy(event)
    if event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK then
        local gotIt = false
        self._loginStatus = true
        -- 登录成功。保证每次启动游戏都登录上次登录的账号
        if self._tmpFlagForCurRequest == "login_another_account" then
            -- 登录到另一个手机绑定账号
            if self._tmpPswLogin then
                ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")))
                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
            end
            LoadingManager:endLoading()
            gotIt = true
        elseif self._tmpFlagForCurRequest == "login_local_tourist_account" then
            -- 登录到本地保存的游客账号
            ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")))
            ww.WWGameData:getInstance():setStringForKey("pwd", ww.WWGameData:getInstance():getStringForKey("tourist_account_pwd", ""))
            gotIt = true
            LoadingManager:endLoading()
        elseif self._tmpFlagForCurRequest == "register_tourist_account" then
            -- 登录到新注册的游客账号
            --            if self._tmpPswLogin then
            --                ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")))
            --                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
            --                -- 保存到本地
            --                ww.WWGameData:getInstance():setStringForKey("tourist_account_pwd", self._tmpPswLogin)
            --                ww.WWGameData:getInstance():setIntegerForKey("tourist_account_userid", tonumber(DataCenter:getUserdataInstance():getValueByKey("userid")))
            --            end
            gotIt = true
        elseif self._tmpFlagForCurRequest == "login_local_account" then
            -- 登录回本地的老账号
            self:close()
        end
        if gotIt then
            Toast:makeToast(getStr("succ_login"), 1.5):show()
            DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", false)
            self:close()
            self._userInfoLayer:close()
        end
        LoadingManager:endLoading()
    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINERROR then
        -- 登录失败
        if self._tmpFlagForCurRequest == "login_another_account" or self._tmpFlagForCurRequest == "login_local_tourist_account"
            or self._tmpFlagForCurRequest == "register_tourist_account" or self._tmpFlagForCurRequest == "login_local_account" then
            -- kReasonType:-1：操作异常，-2：账号冻结，-3：账号不存在，-4：账号注销，-5：参数不正确，-6：账号已存在，-10：密码错误。
            if event._userdata.kReasonType == -3 or event._userdata.kReasonType == -10 then
                -- 账号不存在或者密码错误。
                -- 已经确认的错误账号无需请求，直接判定无效账号
                self._inputPsw._tmp_last_try_login_psw = self._tmpPswLogin
                self._inputPhoneNo._tmp_last_try_login_phoneno = self._tmpPhoneNoLogin
            end
            NetWorkProxy:connectServer()
            LoadingManager:endLoading()
            DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", false)
            self._tmpFlagForCurRequest = nil
            self._tmpPswLogin = nil
            self._tmpPhoneNoLogin = nil
        end
    elseif event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGOUTOK then
        -- do return end
        self._loginStatus = false
        -- 注销成功
        if self._tmpFlagForCurRequest == "login_another_account" then
            -- 登录到另一个手机绑定账号
            self._tmpPhoneNoLogin = self._inputPhoneNo:getString()
            self._tmpPswLogin = self._inputPsw:getString()
            ww.WWMsgManager:getInstance():logout()
            NetWorkProxy:connectServer()
            NetWorkProxy:sendLoginPhone("86" .. self._tmpPhoneNoLogin, self._tmpPswLogin)
        elseif self._tmpFlagForCurRequest == "login_local_tourist_account" then
            -- 切换到本地保存的游客账号
            local ttouristID = tostring(ww.WWGameData:getInstance():getIntegerForKey("tourist_account_userid", 0))
            local ouristPwd = ww.WWGameData:getInstance():getStringForKey("tourist_account_pwd", "")
            NetWorkProxy:sendLoginPhone(touristID, touristPwd)
        elseif self._tmpFlagForCurRequest == "register_tourist_account" then
            -- 注册新的游客账号
            if self._isMobilePlatform then
                self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                NetWorkProxy:sendRegisterTourist(self._tmpPswLogin)
            else
                self._tmpPswLogin = ww.IPhoneTool:getInstance():randomAsciiString(6)
                ww.WWGameData:getInstance():setStringForKey("pwd", self._tmpPswLogin)
                NetWorkProxy:sendRegister(self._tmpPswLogin)
            end
        end
    end
end

function Login:onEnter()
    Login.super.onEnter(self)
end

function Login:onExit()
    if ww.WWGameData:getInstance():getIntegerForKey("flag_remember_account", 1) == 1 then
        local phoneNo = self._inputPhoneNo:getString()
        local pwd = self._inputPsw:getString()
        if phoneNo ~= "" and pwd ~= ""
            and phoneNo == ww.WWGameData:getInstance():getStringForKey("cur_account_bind_phone_no", "")
            and pwd == ww.WWGameData:getInstance():getStringForKey("cur_account_bind_phone_psw", "") then
            ww.WWGameData:getInstance():setStringForKey("remember_account_bind_phone_no", phoneNo)
            ww.WWGameData:getInstance():setStringForKey("remember_account_bind_phone_psw", pwd)
        end
    end

    DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", false)
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            NetWorkCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    Login.super.onExit(self)
end

function Login:_setView(name, ...)
    require(name):create(self._userInfoLayer, ...):addTo(self._userInfoLayer)
    --    self:removeFromParent()
    self:close()
end

-- 屏蔽按钮连续点击
-- click_sensivity两次有效点击之间的最小时间间隔。默认1.0秒。
function Login:_safeClick(callback, click_sensivity)
    local isInClick = false
    click_sensivity = click_sensivity or 1.0
    return function(btn)
        if not isInClick then
            isInClick = true
            btn:executeDelay( function() isInClick = false end, click_sensivity)
            if callback then callback(btn) end
        end
    end
end

return Login