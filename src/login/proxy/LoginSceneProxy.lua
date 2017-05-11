local LoginSceneProxy = class("LoginSceneProxy", require("packages.mvc.Proxy"))
--[[local LoginRequest = require("login.request.LoginRequest")
local RegisteRequest = require("login.request.RegisterRequest")
local LogoutRequest = require("login.request.LogoutRequest")
local registerModel = require("login.model.registerModel")
local loginModel = require("login.model.loginModel")--]]

local LoginRequest = require("app.request.LoginRequest")
local RegisteRequest = require("app.request.RegisterRequest")
local LogoutRequest = require("app.request.LogoutRequest")
local registerModel = require("app.netMsgBean.registerModel")
local loginModel = require("app.netMsgBean.loginModel")

local Toast = require("app.views.common.Toast")
import(".NetEventId", "app.netMsgCfg.")
import(".LoginEvent", "login.event.")
import(".LoadingManager", "app.views.common.")
function LoginSceneProxy:init()
    self.logTag = "LoginSceneProxy.lua"
    print("HallSceneProxy init")
    registerModel:create(self)
    loginModel:create(self)
    --    local userid = ww.WWGameData:getInstance():getIntegerForKey("userid", 0)
    --    local pwd = ww.WWGameData:getInstance():getStringForKey("pwd", "")
end

function LoginSceneProxy:start()
    self:registerRootMsgId(registerModel.MSG_ID.Msg_Rgister_Ret, handler(self, LoginSceneProxy.registerReceivedMsg), "LoginSceneProxy.registerReceivedMsg")
    self:registerMsgId(loginModel.MSG_ID.Msg_Login_Ret, handler(self, LoginSceneProxy.loginRecivedMsg), "LoginSceneProxy.loginRecivedMsg")
    self:registerMsgId(loginModel.MSG_ID.Msg_LogoutInfo_Ret, handler(self, LoginSceneProxy.loginoutRecivedMsg), "LoginSceneProxy.loginoutRecivedMsg")
    -- Msg_Login_send
    self:registerRootMsgId(loginModel.MSG_ID.Msg_Login_send, handler(self, self.rootMsg), "LoginSceneProxy.rootMsg")
    return self
end

function LoginSceneProxy:stop()
    self:unregisterMsgId(loginModel.MSG_ID.Msg_Login_Ret)
    self:unregisterMsgId(loginModel.MSG_ID.Msg_LogoutInfo_Ret)
    self:unregisterRootMsgId(loginModel.MSG_ID.Msg_Login_send)
    self:unregisterRootMsgId(registerModel.MSG_ID.Msg_Rgister_Ret)
    return self
end


function LoginSceneProxy:rootMsg(msgId, msgTable)
    print("rootMsg", msgId)
    dump(msgTable)
    if msgTable.kReason and msgTable.kResult == 1 then
        Toast:makeToast(msgTable.kReason, 1.0):show()
        -- μ???ê§°ü
        WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
    end
end

function LoginSceneProxy:registerReceivedMsg(msgId, msgTable)
    print("registerReceivedMsg", msgId)
    wwdump(msgTable)
    if msgTable.kResult and tonumber(msgTable.kResult) == 0 then
        ww.WWGameData:getInstance():setIntegerForKey("userid", tonumber(msgTable.kReason))

        local pwd = ww.WWGameData:getInstance():getStringForKey("pwd", 0)
        ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK):sendLogin(msgTable.kReason, pwd)

        -- TODO test  更新定位信息
        local UserInfoProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
        UserInfoProxy:getAndUpdateCity()
    else
        -- toast error msgTable.kReason
        LoadingManager:endLoading()
        Toast:makeToast(msgTable.kReason, 1.0):show()
        wwlog("register error!%s", msgTable.kReason)
        WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
    end

end

function LoginSceneProxy:loginRecivedMsg(msgId, msgTable)
    print("loginRecivedMsg", msgId)
    dump(msgTable)
    DataCenter:setUserLoginData(msgTable)
    if msgTable.downloadURL then
        ww.UpgradeAssetsMgrContainer:getInstance():setUpdateUrl(msgTable.downloadURL)
    end
    -- JUMP_TO_HALL
    LoadingManager:endLoading()
    WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.JUMP_TO_HALL)

end

function LoginSceneProxy:loginoutRecivedMsg(msgId, msgTable)
    print(string.format("loginoutRecivedMsg:%s", msgId))
    dump(msgTable)
end

function LoginSceneProxy:netEventMsg(msgId, msgTable)
    print(string.format("netEventMsg:%s", msgId))
    -- dump(msgTable)
    if msgId == NetEventId.Event_onConnected then
        ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK):loginOrRegister()

        -- msgId, tag, target
        self:unregisterNetId(NetEventId.Event_onConnected, "LoginSceneProxy.netEventMsg")
    end

end

function LoginSceneProxy:connectServer()
    self:registerNetId(NetEventId.Event_onConnected, handler(self, LoginSceneProxy.netEventMsg), "LoginSceneProxy.netEventMsg")
    -- WWNetAdapter:registerNetEventMsg(NetEventId.Event_onConnected,handler(self,LoginSceneProxy.netEventMsg),"LoginSceneProxy.netEventMsg",self)
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
        LoadingManager:startLoading()
        ww.WWMsgManager:getInstance():setNewSocketUrl(wwConfigData.NEW_SOCKET_URL)
        ww.WWMsgManager:getInstance():parallelConnect(ips, ports)
    else
        -- no network avaliable
        cclog("network unavaliable!")
        -- toast ,when dismiss, show button view
        WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
    end

    -- WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE)
end

-- function LoginSceneProxy:fastLoin()
--    if ww.WWMsgManager:getInstance():hasConnected() then
--        self:loginOrRegister()
--    else
--        self:connectServer()
--    end
-- end

function LoginSceneProxy:onEnter()

end

function LoginSceneProxy:onExit()

    self:unregisterAllMsgId()
    self:unregisterRootMsgId()
end

return LoginSceneProxy