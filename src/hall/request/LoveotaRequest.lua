local LoveotaRequest = class("LoveotaRequest",require("app.request.BaseRequest"))
local LoveotaModel = require("hall.model.LoveotaModel")
LoveotaRequest.orders = {
	{"HallID","string"}, --大厅ID
	{"UserID","string"}, --用户ID
	{"SP","int"}, -- SP
	{"HallOldVersion","string"}, --被更新的版本号
	{"HallNewVersion","string"}, --更新后的版本号
	{"ZMUserID","string"}, --卓盟的用户ID
	{"UpdateTime","string"}, --时间
}

function LoveotaRequest:ctor()
	print("LoveotaRequest ctor")
	LoveotaRequest.super.ctor(self)
	self:init(LoveotaRequest.orders)
end
function LoveotaRequest:formatRequest(userid,HallOldVersion,HallNewVersion,ZMUserID)
	self:setField("HallID",tostring(wwConfigData.GAME_HALL_ID))
	self:setField("SP",wwConst.SP)
	self:setField("UserID",userid or "")
	self:setField("HallOldVersion",HallOldVersion or "")
	self:setField("HallNewVersion",HallNewVersion or "")
	self:setField("ZMUserID",ZMUserID or "")
	local timeStr = os.date("%Y-%m-%d %H:%M:%S", os.time())
	self:setField("UpdateTime",timeStr)
	return self.data
end
function LoveotaRequest:send(target)
	print("LoveotaRequest send")
	local msgParam = self:formatHeader2(self.data,LoveotaModel.MSG_ID.Msg_CheckVersion_send)
	dump(msgParam)
	
	NetWorkBridge:send(LoveotaModel.MSG_ID.Msg_CheckVersion_send, msgParam, target)
	removeAll(msgParam)
end
return LoveotaRequest