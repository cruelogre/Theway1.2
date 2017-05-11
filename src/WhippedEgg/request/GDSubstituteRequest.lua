local GDSubstituteRequest = class("GDSubstituteRequest",require("app.request.BaseRequest"))
local GDGameModel = require("WhippedEgg.Model.GDGameModel")
GDSubstituteRequest.orders = {
	{"gameID","int"}, --GameID 游戏标识
	{"gameZoneID","int"}, -- gameZoneID 游戏区ID
	{"gameplayID","int"}, -- gameplayID 对局ID
	{"userID","int"}, -- UserID 用户ID
	{"type","char"}, -- type  0 托管 1 取消托管

}
GDSubstituteRequest.headers = {6,1,15}
function GDSubstituteRequest:ctor()
	print("GDSubstituteRequest ctor")
	GDSubstituteRequest.super.ctor(self)
	self:init(GDSubstituteRequest.orders)
end
function GDSubstituteRequest:formatRequest(gameZoneID,gameplayID,rmType)
	self:setField("gameID",wwConfigData.GAME_ID)
	self:setField("gameZoneID",gameZoneID)
	self:setField("gameplayID",gameplayID)
	self:setField("userID", ww.WWGameData:getInstance():getIntegerForKey("userid",0))
	self:setField("type",rmType)
	return self.data
end
function GDSubstituteRequest:send(target)
	print("GDSubstituteRequest send")
	local msgParam = self:formatHeader2(self.data,GDGameModel.MSG_ID.Msg_GDTrusteeship_send)
	dump(msgParam)
	
	NetWorkBridge:send(GDGameModel.MSG_ID.Msg_GDTrusteeship_send, msgParam, target)
	removeAll(msgParam)
end
return GDSubstituteRequest