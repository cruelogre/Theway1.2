-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.27
-- Last:
-- Content:  网络的代理类
-- Modify: 2017/1/23 防止重复生成注册密码问题
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local NetWorkProxy = class("NetWorkProxy", require("packages.mvc.Proxy"))

local LoginRequest = require("app.request.LoginRequest")
local RegisteRequest = require("app.request.RegisterRequest")
local LogoutRequest = require("app.request.LogoutRequest")
local registerModel = require("app.netMsgBean.registerModel")
local loginModel = require("app.netMsgBean.loginModel")
local Toast = require("app.views.common.Toast")
local LuaLoginNativeBridge = require("app.utilities.LuaLoginNativeBridge"):create()
local TAG = "NetWorkProxy"
import(".LoadingManager", "app.views.common.")

require("app.netMsgCfg.NetWorkCfg")
import(".NetEventId", "app.netMsgCfg.")

-- local gdGameMsgModel = import(".GDGameModel", "WhippedEgg.Model."):create(self) --消息实体
-- local BankruptLayer = require("app.views.customwidget.BankruptLayer")

function NetWorkProxy:ctor()
    self.super.ctor(self)
    -- 是否是第三方登录
    self._is_third_party_login = false
    self._innerEventComponent = { }
    self._innerEventComponent.isBind = false
    self:bindInnerEventComponent()
    self:registNetListener()

    registerModel:create(self)
    loginModel:create(self)

    local userid = ww.WWGameData:getInstance():getIntegerForKey("userid", 0)
    local pwd = ww.WWGameData:getInstance():getStringForKey("pwd", "")
    self:registerMsgId(loginModel.MSG_ID.Msg_Login_Ret, handler(self, self.loginRecivedMsg), "NetWorkProxy.loginRecivedMsg")
    self:registerMsgId(loginModel.MSG_ID.Msg_LogoutInfo_Ret, handler(self, self.loginoutRecivedMsg), "NetWorkProxy.loginoutRecivedMsg")
    self:registerRootMsgId(registerModel.MSG_ID.Msg_Rgister_Ret, handler(self, self.registerReceivedMsg), "NetWorkProxy.registerReceivedMsg")
    -- 更新用户信息
    self:registerRootMsgId(registerModel.MSG_ID.Msg_UpdateUserInfo_send, handler(self, self.updateReceivedMsg), "NetWorkProxy.updateReceivedMsg")

    -- Msg_Login_send
    self:registerRootMsgId(loginModel.MSG_ID.Msg_Login_send, handler(self, self.rootMsg), "NetWorkProxy.rootMsg")
    self:registerRootMsgId(loginModel.MSG_ID.Msg_putClientModuleID_send, handler(self, self.rootMsg), "NetWorkProxy.rootMsg1")
    local MSG_COMMON_ID = 0x0
    self:registerRootMsgId(MSG_COMMON_ID, handler(self, self.rootMsg), "NetWorkProxy.rootMsgRoot")

    self._flagDoubleLoginVar = nil
end

function NetWorkProxy:bindInnerEventComponent()
    -- body
    self:unbindInnerEventComponent()

    cc.bind(self._innerEventComponent, "event")
    self._innerEventComponent.isBind = true
    NetWorkCfg.innerEventComponent = self._innerEventComponent
end

function NetWorkProxy:unbindInnerEventComponent()
    -- body
    if self._innerEventComponent.isBind then
        cc.unbind(self._innerEventComponent, "event")
        self._innerEventComponent.isBind = false
        NetWorkCfg.innerEventComponent = nil
    end
end
function NetWorkProxy:registNetListener()
    for _, v in pairs(NetEventId) do
        self:registerNetId(v, handler(self, self.netEventMsg), "NetWorkProxy.netEventMsg" .. tostring(v))
    end

end

function NetWorkProxy:netEventMsg(msgId, msgTag)
    wwlog(self.logTag, "NetWorkProxy netEventMsg", msgId)
    wwdump(msgTag)
    local dispatchNext = true
    local eventName = NetWorkCfg.getEventById(msgId)
    if msgId == NetEventId.Event_onConnected then

    elseif msgId == NetEventId.Event_reConnect then
        -- show waitting
        dispatchNext = false
        print("show waitting......")
    elseif msgId == NetEventId.Event_reLogin then
        -- logout and relogin
        dispatchNext = false
        -- DataCenter:clearData(COMMON_TAG.C_LOGIN_MESSAGE)
        local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
        if loginMsg and next(loginMsg) then
            loginMsg.hallversion = nil
        end

        ww.WWMsgManager:getInstance():logout()
        -- 状态机清除工作
        FSRegistryManager:clearFSM()
        WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.MAIN_ENTRY)
    elseif msgId == NetEventId.Event_onExceptionCaught then
        -- 网络连接异常
        print(type(msgTag))
        -- DataCenter:clearData(COMMON_TAG.C_LOGIN_MESSAGE)
        local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
        if loginMsg and next(loginMsg) then
            loginMsg.hallversion = nil
        end
        WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
    end
    wwlog(self.logTag, "NetWorkProxy eventName %s", eventName)
    if dispatchNext and eventName then
        NetWorkCfg.innerEventComponent:dispatchEvent( {
            name = eventName;
            eventId = msgId;
            _userdata = msgTag
        } )
    end
end

function NetWorkProxy:rootMsg(msgId, msgTable)
    wwdump(msgTable, string.format("NetWorkProxy收到通用消息[%d]", msgId))
    local dispatchName, dispatchData = nil, nil
    if msgId == 0x0 then
        if msgTable.kReasonType == 0 and msgTable.kResult == 1 then
			--Modified by cruelogre 2017/2/16
			--这里添加登出后，大厅版本号滞空表示未登录
			local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
			if loginMsg and next(loginMsg) then
				loginMsg.hallversion = nil
			end
            -- 账号在其他地方登陆，与服务器连接将关闭,msgTable.kUserId =0
            local bindPhoneNo = DataCenter:getUserdataInstance():getValueByKey("BindPhone")
            local userid = ww.WWGameData:getInstance():getIntegerForKey("userid")
            local pwd = ww.WWGameData:getInstance():getStringForKey("pwd")
            local para = { }
            DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", true)
            NetWorkProxy:connectServer()
            if bindPhoneNo ~= "" then
                -- 本地有已注册账号，
                para.leftBtnlabel = i18n:get("str_userInfo", "btn_relogin")
                para.rightBtnlabel = i18n:get("str_userInfo", "btn_login_tourist")
                -- 屏蔽物理返回键
                para.keyBackClose = false
                para.leftBtnCallback = function()
                    -- 重新登录
                    self._flagDoubleLoginVar = "double_login_relogin"
                    self:sendLogin(userid, pwd)
                    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_userInfo", "waiting"))
                    return true
                end
                para.rightBtnCallback = function()
                    -- 登录游客账号
                    self._flagDoubleLoginVar = "double_login_select_login_tourist"
                    NetWorkProxy:connectServer()
                    local touristPwd = ww.IPhoneTool:getInstance():randomAsciiString(6)
                    ww.WWGameData:getInstance():setStringForKey("pwd", touristPwd)
                    self:sendRegisterTourist(touristPwd)
                    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_userInfo", "waiting"))
                    return true
                end
            else
                -- 本地只有游客账号
                para.leftBtnlabel = i18n:get("str_userInfo", "btn_relogin")
                para.leftBtnCallback = function()
                    -- 重新登录
                    self._flagDoubleLoginVar = "double_login_relogin"
                    self:sendLogin(userid, pwd)
                    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_userInfo", "waiting"))
                    return true
                end
            end

			-- 屏蔽物理返回键
            para.keyBackClose = false
            -- 是否显示关闭按钮
            para.showclose = false
            para.content = string.format(i18n:get("str_common", "double_login_notify"))
            local dialog = import(".CommonDialog", "app.views.customwidget."):create(para):show()
            -- 登录成功监听
            local _, loginOKListener = nil, nil
            _, loginOKListener = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK,
            function()
                -- 登录成功
                if loginOKListener then
                    NetWorkCfg.innerEventComponent:removeEventListener(loginOKListener)
                    loginOKListener = nil
                end
                if self._flagDoubleLoginVar == "double_login_relogin" then
                    self._flagDoubleLoginVar = nil
                    DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", false)
                    LoadingManager:endLoading()
                end
                dialog:close()
            end )
        end
    elseif msgId == loginModel.MSG_ID.Msg_putClientModuleID_send then
        -- 上传场景ID
        --        local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
        --        toast("上传场景ID")
    elseif msgId == loginModel.MSG_ID.Msg_Login_send then
        -- 登录请求失败
        if msgTable.kReason and msgTable.kResult == 1 then
            Toast:makeToast(msgTable.kReason, 2.0):show()
            dispatchName = NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINERROR
            -- kReasonType:-1：操作异常，-2：账号冻结，-3：账号不存在，-4：账号注销，-5：参数不正确，-6：账号已存在，-10：密码错误。
            dispatchData = msgTable
            WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
        elseif msgTable.kReason and msgTable.kResult == 0 then
            dispatchName = NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK
        end
    end
    NetWorkCfg.innerEventComponent:dispatchEvent( {
        name = dispatchName,
        _userdata = dispatchData
    } )
end

function NetWorkProxy:registerReceivedMsg(msgId, msgTable)
    print("registerReceivedMsg", msgId)
    wwdump(msgTable)
    if msgTable.kResult and tonumber(msgTable.kResult) == 0 then
        local userid, pwd = nil, nil
        if tonumber(msgTable.kReason) then
            -- normal register
            userid = msgTable.kReason
            pwd = ww.WWGameData:getInstance():getStringForKey("pwd", "")
            ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(userid))
        else
            local parts = { string.find(msgTable.kReason, "^(%d+):(%w+)") }
            if parts and #parts == 4 then
                -- 和手机mac地址绑定的账号msgTable.kReason == 100239800:9zPfv1
                userid, pwd = parts[3], parts[4]
                ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(userid))
                ww.WWGameData:getInstance():setStringForKey("pwd", pwd)
            end
        end
        if self._flagDoubleLoginVar == "double_login_select_login_tourist" then
            DataCenter:getUserdataInstance():setUserInfoByKey("Flag_Logout_Manually", false)
            self._flagDoubleLoginVar = nil
            LoadingManager:endLoading()
        end
        self:sendLogin(userid, pwd)
    else
        -- toast error msgTable.kReason
        LoadingManager:endLoading()
        Toast:makeToast(msgTable.kReason, 1.0):show()
        wwlog(self.logTag, "register error!%s", msgTable.kReason)
        -- WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
        NetWorkCfg.innerEventComponent:dispatchEvent( {
            name = NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR;
            _userdata = NetEventId.Event_onExceptionCaught
        } )
    end
end

-- 更改用户信息，通用消息
function NetWorkProxy:updateReceivedMsg(msgId, msgTable)
    print("updateReceivedMsg", msgId)
    wwdump(msgTable)
    local dispatchEventId, dispatchEventData = nil, nil
    if msgTable.kResult and tonumber(msgTable.kResult) == 0 then
        -- 成功
        dispatchEventId = NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO

    else
        -- 失败
        dispatchEventId = NetWorkCfg.InnerEvents.NETWORK_EVENT_MODIFY_USERINFO_ERROR

    end
    NetWorkCfg.innerEventComponent:dispatchEvent( {
        name = dispatchEventId,
        _userdata = dispatchEventData,
    } )
end

-- 用户退出确认消息
-- UserID	(int4)用户ID
-- ExitType	(int1)退出方式
-- 1 正常退出
-- 2超时退出
-- 3重复登录强制退出
-- 4系统超时(挂线、空闲超时)
-- Power	(int4)改变的战斗力值
-- Longevity	(int4)改变的经验值
-- Charm	(int4)改变的魅力值
-- Cash	(int4)改变的财富值
-- logonID	(int4)用户的登录ID
-- onlineTime	(int2)在线时长(分钟)
-- Magic701	(int1)双倍经验值；0-没使用，1－使用
-- Bean	(int4)改变的蛙豆值
-- GameCash	(String)改变的银子等游戏币财富
-- 备注：
-- Bean=诈金花的下次登录签到获得金子数量
-- GameCash=斗地主的晶石变化值
function NetWorkProxy:loginoutRecivedMsg(msgId, msgTable)
    wwlog(TAG, "loginoutRecivedMsg:" .. msgId)
    wwdump(msgTable, "NetWorkProxy收到注销消息")
    -- 退出是清除数据
    -- DataCenter:clearData(COMMON_TAG.C_LOGIN_MESSAGE)
    local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
    if loginMsg and next(loginMsg) then
        loginMsg.hallversion = nil
    end
    if msgTable.ExitType == 1 then
        -- 正常退出
    elseif msgTable.ExitType == 2 then
        -- 超时退出
    elseif msgTable.ExitType == 3 then
        -- 重复登录强制退出
    elseif msgTable.ExitType == 4 then
        -- 系统超时(挂线、空闲超时)
    end
    -- 注销成功或者说退出成功
    NetWorkCfg.innerEventComponent:dispatchEvent( {
        name = NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGOUTOK,
    } )
end

function NetWorkProxy:loginRecivedMsg(msgId, msgTable)
    print("loginRecivedMsg", msgId)
    wwdump(msgTable, "NetWorkProxy收到登录消息")
    local tempTable = { }
    copyTable(msgTable, tempTable)
    local oldData = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
    if oldData and next(oldData) then
        tempTable.hasRequestUpdate = true
    end
	if msgTable.userid and tonumber(msgTable.userid)~=0 then
		ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(msgTable.userid))
	end
	if msgTable.userPwd and string.len(msgTable.userPwd)>0 then
		ww.WWGameData:getInstance():setStringForKey("pwd", tostring(msgTable.userPwd))
	end
    DataCenter:clearData(COMMON_TAG.C_LOGIN_MESSAGE)
    DataCenter:cacheData(COMMON_TAG.C_LOGIN_MESSAGE, tempTable)
    DataCenter:setUserLoginData(msgTable)
    if msgTable.downloadURL then
        ww.UpgradeAssetsMgrContainer:getInstance():setUpdateUrl(msgTable.downloadURL)
    end
    -- JUMP_TO_HALL
    LoadingManager:endLoading()
    -- 登录成功
    NetWorkCfg.innerEventComponent:dispatchEvent( {
        name = NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK;
    } )
end

function NetWorkProxy:loginOrRegister()
	wwlog(self.logTag,"执行登录或者注册")
    LuaLoginNativeBridge:callNativeLogin(handler(self, self._loginSuccThridParty), handler(self, self._loginFailThridParty), handler(self, self._localloginOrRegister))
end

function NetWorkProxy:_localloginOrRegister()
    -- 非第三方登录注册
    local userid = ww.WWGameData:getInstance():getIntegerForKey("userid", 0)
    local pwd = ww.WWGameData:getInstance():getStringForKey("pwd", "")
	wwlog(self.logTag, "保存的帐号密码:userid="..tostring(userid)..",pwd="..tostring(pwd))
    if userid == 0 then --帐号没有
        wwlog(self.logTag, "非第三方账号注册")
		if string.len(pwd)==0 then --这里如果以前有密码保存，则证明之前发送过注册消息这里直接用就行了 
			 pwd = ww.IPhoneTool:getInstance():randomAsciiString(6)
			 ww.WWGameData:getInstance():setStringForKey("pwd", pwd)
			wwlog(self.logTag, "使用生成的随即密码登录:"..pwd)
		else
			wwlog(self.logTag, "直接使用之前的密码登录:"..pwd)
		end
       
       

        self:sendRegisterTourist(pwd)
    else
        wwlog(self.logTag, "非第三方账号登录")
        self:sendLogin(tostring(userid), pwd)
    end
end

-- 这个只在windows测试，正式情况都用下面的注册和手机绑定的游客账号
function NetWorkProxy:sendRegister(pwd)
    local registerrequest = RegisteRequest:create()
    registerrequest:formatRequest(pwd)
    registerrequest:send(self)
end

-- 获取当前账号的游客账号，前提是当前账号必须是绑定了手机号
function NetWorkProxy:sendRegisterTourist(pwd)
    local registerrequest = RegisteRequest:create()
    registerrequest:formatRequest(pwd, true)
    registerrequest:send(self)
end

-- userid和pwd必须，其他可选。
function NetWorkProxy:sendLogin(userid, pwd, mid, logintype)
    -- wwlog(TAG, "sendLogin params:userid::" .. userid .. "  " .. pwd .. "  " .. mid .. "  " .. logintype)
    local loginrequest = LoginRequest:create()
    loginrequest:formatRequest(tostring(userid), tostring(pwd) or "", tonumber(logintype or 0), mid or "", "", "")
    loginrequest:send(self)
end

-- 手机账号密码登录
function NetWorkProxy:sendLoginPhone(phoneNo, psw)
    if string.match(phoneNo, "^86") then
        -- 手机号必须加上86开头
        local loginrequest = LoginRequest:create()
        loginrequest:formatRequest(tostring(phoneNo), psw, 6, "", "", "")
        loginrequest:send(self)
    else
        wwlog(TAG, "invalid phoneNo:%s which must began with 86", tostring(phoneNo))
    end
end

-- 登出当前账号
function NetWorkProxy:switchUser()
    -- ww.WWMsgManager:getInstance():logout()

    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    if userid then
        local logoutrequest = LogoutRequest:create()
        logoutrequest:formatRequest(tonumber(userid), 1)
        logoutrequest:send(self)
    end


end

function NetWorkProxy:connectServer()

    -- WWNetAdapter:registerNetEventMsg(NetEventId.Event_onConnected,handler(self,NetWorkProxy.netEventMsg),"NetWorkProxy.netEventMsg",self)
    if ww.IPhoneTool:getInstance():isNetworkConnected() then
        cclog("network avaliable!")
        local ips = { }
        copyTable(wwConfigData.REQUEST_IPS, ips)
        local ports = { }

        copyTable(wwConfigData.REQUEST_PORTS, ports)

        local serverip = ww.WWGameData:getInstance():getStringForKey(wwGameConst.SERVER_IP, "")
        local serverport = ww.WWGameData:getInstance():getIntegerForKey(wwGameConst.SERVER_PORT, 0)
        if string.len(serverip) ~= 0 then
            table.insert(ips, serverip)
        end
        if serverport ~= 0 then
            table.insert(ports, serverport)
        end
        dump(ips, "ips")
        dump(ports, "ports")
        -- LoadingManager:startLoading()
        ww.WWMsgManager:getInstance():setNewSocketUrl(wwConfigData.NEW_SOCKET_URL)
        ww.WWMsgManager:getInstance():parallelConnect(ips, ports)
    else
        -- no network avaliable
        cclog("network unavaliable!")
        -- toast ,when dismiss, show button view
        -- WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
        NetWorkCfg.innerEventComponent:dispatchEvent( {
            name = NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR;
            _userdata = NetEventId.Event_onExceptionCaught
        } )
    end

    -- WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
end

function NetWorkProxy:fastLoin()
    if ww.WWMsgManager:getInstance():hasConnected() then
        self:loginOrRegister()
    else
        self:connectServer()
    end
end

-- 修改用户信息，包括密码
function NetWorkProxy:modifyUserInfo(params)
    local header = require("app.netMsgBean.registerModel").MSG_ID
    self:sendMsg(header.Msg_UpdateUserInfo_send, {
        bit.band(bit.rshift(header.Msg_UpdateUserInfo_send,4 * 4),0xff),
        bit.band(bit.rshift(header.Msg_UpdateUserInfo_send,2 * 4),0xff),
        bit.band(bit.rshift(header.Msg_UpdateUserInfo_send,0 * 4),0xff),
        DataCenter:getUserdataInstance():getValueByKey("userid"),
        params.Password or "",
        params.NickName or "",
        params.Gender or -1,
        params.IconID or -1,
        params.GameWatch or -1,
        params.PetName or "",
        params.PetImageID or -1,
        params.PetStatus or -1,
        params.EatStyle or -1,
        params.Sign or "",
        params.PetPlayMoney or -2,
        params.Province or -1,
        params.City or -1,
        params.BloodType or "",
        params.Hobby or "",
        params.Mail or "",
        params.RealName or "",
        params.BirthDay or "",
        params.Introduce or "",
        params.OpenPrivacy or -1,
    } )
end

-- 客户端通知后台当前功能模块ID
-- moduleID：场景ID，只能收到当前场景的广播
function NetWorkProxy:uploadSceneID(sceneID)
    wwlog(self.logTag, "NetWorkProxy:uploadModuleID")
    local paras = {
        bit.band(bit.rshift(loginModel.MSG_ID.Msg_putClientModuleID_send,4 * 4),0xff),
        bit.band(bit.rshift(loginModel.MSG_ID.Msg_putClientModuleID_send,2 * 4),0xff),
        bit.band(bit.rshift(loginModel.MSG_ID.Msg_putClientModuleID_send,0 * 4),0xff),
        sceneID,
        wwConst.SP,
        wwConfigData.GAME_LANGUAGE,
        wwConfigData.GAME_HALL_ID
    }
    --    local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
    --    toast(wwConst.SP .. wwConfigData.GAME_LANGUAGE .. wwConfigData.GAME_HALL_ID)
    self:sendMsg(loginModel.MSG_ID.Msg_putClientModuleID_send, paras)
end 

--[[
sdk登录成功的接口（第三方sdk登录成功 lua方根据返回过来的消息和服务端进行交互。服务端返回成功后，进入游戏。失败则提示）
@parem  result=username;password;mid;logintype
分别表示账号;密码;mid;登录类型(mid有时为空)
]]
function NetWorkProxy:_loginSuccThridParty(result)
    wwlog(TAG, "_loginSuccThridParty result=%s:", result or "")
    self._is_third_party_login = true
    self:sendLogin(unpack(string.split(result, ";")))
end

-- 第三方sdk登录失败（客户端提示一下即可！！继续停留在登录的封面）
function NetWorkProxy:_loginFailThridParty(result)
    wwlog(TAG, "_loginFailThridParty result=%s:", result or "")
    self._is_third_party_login = true
    require("app.views.common.Toast"):makeToast(i18n:get("str_userInfo", "login_fail"), 2.0):show()
end

-- 判断当前是否是第三方登录，如果放在userdata中，在登录成功时，userdata整个会被清空，所以就放在这儿判断了。
function NetWorkProxy:isThirdPartyLogin()
    return self._is_third_party_login
end

return NetWorkProxy