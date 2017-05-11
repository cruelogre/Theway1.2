local FeedBackRequest = class("FeedBackRequest",require("app.request.BaseRequest"))
local settingModel = require("hall.model.settingModel")
FeedBackRequest.orders = {
	{"Touserid","int"}, -- gameid
	{"ToWay","char"}, -- 8
	{"content","string"}, -- 内容
	{"waFont","char"}, -- 0
	{"toUser","string"}, -- ""
	{"Subject","string"}, -- ""
}


FeedBackRequest.headers = {4,2,10}
function FeedBackRequest:ctor()
	print("FeedBackRequest ctor")
	FeedBackRequest.super.ctor(self)
	self:init(FeedBackRequest.orders)
end
function FeedBackRequest:formatRequest(content)
	self:setField("content",content)
	self:setField("Touserid",wwConfigData.SYSTEM_USERID)
	self:setField("ToWay",8) --email
	
	return self.data
end
function FeedBackRequest:send(target)
	local msgParam = self:formatHeader2(self.data,settingModel.MSG_ID.Msg_SettingFeedback_send)
	dump(msgParam)
	
	NetWorkBridge:send(settingModel.MSG_ID.Msg_SettingFeedback_send, msgParam, target)
	removeAll(msgParam)
end
return FeedBackRequest