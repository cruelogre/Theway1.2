local RequestInfoRequest = class("RequestInfoRequest",require("app.request.BaseRequest"))
local userIssueNotifyModel = require("app.netMsgBean.userIssueNotifyModel")
RequestInfoRequest.orders = {
	{"ObjectID","int"}, -- 用户ID/宠物ID/语言
	{"Type","int"}, --Type= 35 领取金豆
	{"Parameter1","int"}, --Type=35,38 时GameID
	{"Parameter2","int"}, --
	{"StrParam","string"}, --
}
RequestInfoRequest.headers = {1,1,1}
function RequestInfoRequest:ctor()
	print("RequestInfoRequest ctor")
	RequestInfoRequest.super.ctor(self)
	self:init(RequestInfoRequest.orders)
end
function RequestInfoRequest:formatRequest(userid,mType,Parameter1,Parameter2,StrParam)
	self:setField("ObjectID",userid)
	self:setField("Type",mType)
	self:setField("Parameter1",Parameter1 or 0)
	self:setField("Parameter2",Parameter2 or 0)
	self:setField("StrParam",StrParam or "")
	return self.data
end
function RequestInfoRequest:send(target)
	print("RequestInfoRequest send")
	local msgParam = self:formatHeader2(self.data,userIssueNotifyModel.MSG_ID.Msg_RequestInfo_Send)
	dump(msgParam)
	
	NetWorkBridge:send(userIssueNotifyModel.MSG_ID.Msg_RequestInfo_Send, msgParam, target)
	removeAll(msgParam)
end
return RequestInfoRequest