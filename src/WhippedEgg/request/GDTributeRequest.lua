local GDTributeRequest = class("GDTributeRequest",require("app.request.BaseRequest"))
local GDGameModel = require("WhippedEgg.Model.GDGameModel")
GDTributeRequest.orders = {
	{"gameplayId","int"}, -- 对局标识
	{"type","char"}, --Type=1 进贡  2 返回拍给进贡方 3 抗贡
	{"userid","int"}, --用户id
	{"card","char"}, -- 进贡的牌
	
}
GDTributeRequest.headers = {40,1,14}
function GDTributeRequest:ctor()
	print("GDTributeRequest ctor")
	GDTributeRequest.super.ctor(self)
	self:init(GDTributeRequest.orders)
end
function GDTributeRequest:formatRequest(gameplayId,reqType,userid,card)
	self:setField("gameplayId",gameplayId)
	self:setField("type",reqType)
	self:setField("userid",userid)
	self:setField("card",card)
	
	return self.data
end
function GDTributeRequest:send(target)
	print("ChooseRoomRequest send")
	local msgParam = self:formatHeader2(self.data,GDGameModel.MSG_ID.Msg_GDTribute_Send)
	dump(msgParam)
	
	NetWorkBridge:send(GDGameModel.MSG_ID.Msg_GDTribute_Send, msgParam, target)
	removeAll(msgParam)
end
return GDTributeRequest