local ChooseRoomRequest = class("ChooseRoomRequest",require("app.request.BaseRequest"))
local HallNetModel = require("hall.model.HallNetModel")
local HallNetModel2 = require("hall.model.HallNetModel2")
ChooseRoomRequest.orders = {
	{"type","char"}, -- request type (int1)1=进入游戏大厅 2=进入游戏区 3=快速开始  4=续局 5=离开 
	{"param1","int"}, --Type=1 1比赛场 2经典场 3私人定制场，Type=2游戏区域ID
	{"param2","int"}, --Type=8，9时当前PlayID
	{"param3","int"}, --Type=8，9时当前instMatchID
}

function ChooseRoomRequest:ctor()
	print("ChooseRoomRequest ctor")
	ChooseRoomRequest.super.ctor(self)
	self:init(ChooseRoomRequest.orders)
end
function ChooseRoomRequest:formatRequest(rmType,param1,param2,param3)
	self:setField("type",rmType)
	self:setField("param1",param1)
	self:setField("param2",param2 or wwConfigData.GAME_ID)
	self:setField("param3",param3 or 0)
	return self.data
end
function ChooseRoomRequest:send(target)
	print("ChooseRoomRequest send")
	local msgParam = self:formatHeader2(self.data,HallNetModel.MSG_ID.Msg_GDHallAction_send)
	dump(msgParam)
	
	NetWorkBridge:send(HallNetModel.MSG_ID.Msg_GDHallAction_send, msgParam, target)
	removeAll(msgParam)
end

function ChooseRoomRequest:send2(target)
	print("ChooseRoomRequest send2")
	local msgParam = self:formatHeader2(self.data,HallNetModel2.MSG_ID.Msg_GDHallAction_send2)
	dump(msgParam)
	
	NetWorkBridge:send(HallNetModel2.MSG_ID.Msg_GDHallAction_send2, msgParam, target)
	removeAll(msgParam)
end

return ChooseRoomRequest