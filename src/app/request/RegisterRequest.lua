local RegisterRequest = class("RegisterRequest", require("app.request.BaseRequest"))
local registerModel = require("app.netMsgBean.registerModel")
RegisterRequest.orders = {
    { "userType", "char" },
    { "vip", "char" },
    { "password", "string" },
    { "mid", "short" },
    { "mdn", "short" },
    { "language", "char" },
    { "nickname", "string" },
    { "sex", "char" },
    { "header", "int" },
    { "gameregion", "int" },
    { "op", "short" },
    { "sp", "int" },
    { "manufacture", "string" },
    { "mdnHK", "short" },
    { "registerType", "char" },
    { "mail", "short" },
    { "mac", "string" },
    { "gameid", "int" },
    { "hallid", "int" },
    --    { "imei", "string" },
    --    { "imsi", "string" },
}

function RegisterRequest:ctor()
    RegisterRequest.super.ctor(self)
    self:init(RegisterRequest.orders)

end
function RegisterRequest:formatRequest(pwd, registerTourist)

    self:setField("password", tostring(pwd))
    self:setField("userType", wwConfigData.USER_TYPE)
    self:setField("language", wwConfigData.GAME_LANGUAGE)
    self:setField("gameregion", wwConfigData.GAME_REGION)
    self:setField("op", wwConst.OP)
    self:setField("sp", wwConst.SP)
    self:setField("mac", registerTourist and ww.IPhoneTool:getInstance():getMacAddress() or "")
    self:setField("gameid", wwConfigData.GAME_ID)
    self:setField("hallid", wwConfigData.GAME_HALL_ID)
    --    self:setField("imei", registerTourist and ww.IPhoneTool:getInstance():getIMEI() or "")
    --    self:setField("imsi", registerTourist and ww.IPhoneTool:getInstance():getIMSI() or "")
    local platformid = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS ~= platformid then
        self:setField("manufacture", ww.IPhoneTool:getInstance():getPhoneMANUFACTURER())
    else
        self:setField("manufacture", wwConfigData.GAME_MODEL())
    end
    self:setField("registerType", 2)

    -- dump(self.data)
    return self.data 
end
function RegisterRequest:send(target)
    local msgParam = { }
    copyTable(self.data, msgParam)
    table.insert(msgParam, 1, 1)
    table.insert(msgParam, 2, 1)
    table.insert(msgParam, 3, 5)
   -- dump(msgParam)
    NetWorkBridge:send(registerModel.MSG_ID.Msg_Register_send, msgParam, target)
    removeAll(msgParam)
end
return RegisterRequest