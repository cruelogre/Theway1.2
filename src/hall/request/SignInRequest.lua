local SignInRequest = class("SignInRequest",require("app.request.BaseRequest"))
local userSignInModel = require("hall.model.userSignInModel")
SignInRequest.orders = {
	{"type","int"}, -- request type (int2)0=请求签到日历 1=当天签到 2=补签 3=连续签到
	{"dayNo","int"} --Type=2时补签的日期（1-31），Type=3时连续的天数，0=整月签到
}
SignInRequest.headers = {1,2,1}
function SignInRequest:ctor()
	print("SignInRequest ctor")
	SignInRequest.super.ctor(self)
	self:init(SignInRequest.orders)
end
function SignInRequest:formatRequest(signType,dayNo)
	self:setField("type",signType)
	self:setField("dayNo",dayNo)
	return self.data
end
function SignInRequest:send(target)
	print("SignInRequest send")
	local msgParam = self:formatHeader2(self.data,userSignInModel.MSG_ID.Msg_UserSignInReq_send)
	dump(msgParam)
	
	NetWorkBridge:send(userSignInModel.MSG_ID.Msg_UserSignInReq_send, msgParam, target)
	removeAll(msgParam)
end
return SignInRequest