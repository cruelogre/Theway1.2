local LoginRequest = class("LoginRequest",import(".BaseRequest","app.request."))
local loginModel = require("app.netMsgBean.loginModel")
LoginRequest.orders = {
		{"userId","string"},
		{"userPwd","string"},
		{"loginType","char"},
		{"sp","int"},
		{"op","short"},
		{"moduleid","int"},
		{"language","char"},
		{"hallid","int"},
		{"version","string"},
		{"model","string"},
		{"dmenu","char"},
		{"guagua","char"},
		{"imgformat","char"},
		{"sdkapid","string"},
		{"key","string"},
		{"md5","string"},
		{"width","short"},
		{"height","short"},
		{"mobilemodel","string"},
		{"resFileCount","short"},
		{"ext1","short"},
		{"monsterid","int"},
		{"operatorCode","int"},
		{"phoneModel","string"},
		{"manufacture","string"},
		{"apnType","string"},
		{"idCode","string"},
		{"imei","string"},
		{"sdkversion","string"},
		{"ext2","int"},
		{"playmode","short"},
		{"loginReward","char"},
		{"mac","string"},
        {"signatureMd5","string"},
        {"functionId","char"},
		{"signId","int"},
		{"ext3","char"},
		{"locAccount","string"},
		{"locPassword","string"},
		{"iccid","string"}
}
function LoginRequest:ctor()
	
	print("LoginRequest ctor")
	LoginRequest.super.ctor(self)
	self:init(LoginRequest.orders)
	
end


function LoginRequest:formatRequest(userId,userPwd,logonType, mid,key,md5)
	
	self:setField("userId",userId)
	self:setField("userPwd",userPwd)
	self:setField("loginType",logonType)
	self:setField("sdkapid",mid)
	self:setField("key",key)
	self:setField("md5",md5) 
	self:setField("op",wwConst.OP)
	self:setField("sp",wwConst.SP)
	self:setField("moduleid",wwConfigData.GAME_MODULE_ID)
	self:setField("language",wwConfigData.GAME_LANGUAGE)
	self:setField("hallid",wwConfigData.GAME_HALL_ID)
	self:setField("version",wwConfigData.GAME_VERSION)
	self:setField("model",wwConfigData.GAME_MODEL())
	self:setField("imgformat",4)
	
	self:setField("width",ww.IPhoneTool:getInstance():getScreenWidth())
	self:setField("height",ww.IPhoneTool:getInstance():getScreenHeight())
	self:setField("mobilemodel",ww.IPhoneTool:getInstance():getMobileModel())
	self:setField("operatorCode",ww.IPhoneTool:getInstance():getNetworkOperatorCode())
	self:setField("phoneModel",ww.IPhoneTool:getInstance():getPhoneModel())
	self:setField("manufacture",ww.IPhoneTool:getInstance():getPhoneMANUFACTURER())
	self:setField("apnType",ww.IPhoneTool:getInstance():getApnType())
	self:setField("idCode",ww.IPhoneTool:getInstance():getIdCode())
	self:setField("imei",ww.IPhoneTool:getInstance():getIMEI())
	self:setField("sdkversion",ww.IPhoneTool:getInstance():getSDkVersion())
	self:setField("loginReward",1)
	self:setField("functionId",1)
	self:setField("signId",10010005)
	self:setField("iccid",ww.IPhoneTool:getInstance():getICCID())
	return self.data
end

function LoginRequest:send(target)
	local msgParam = {}
	copyTable(self.data,msgParam)
	table.insert(msgParam,1,2)
	table.insert(msgParam,2,1)
	table.insert(msgParam,3,1)
	--dump(msgParam)
	

	NetWorkBridge:send(loginModel.MSG_ID.Msg_Login_send, msgParam, target)
	removeAll(msgParam)
end

return LoginRequest