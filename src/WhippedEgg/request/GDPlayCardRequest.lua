local GDPlayCardRequest = class("GDPlayCardRequest",require("app.request.BaseRequest"))
local GDGameModel = require("WhippedEgg.Model.GDGameModel")
GDPlayCardRequest.orders = {
	{"gameplayId","int"}, -- 对局标识
	{"userid","int"}, --用户id
	{"pokerCard","string"}, --打出的实际牌
	{"replaceCard","string"}, -- 替换后的牌
	{"nextPlayUseID","int"}, --下一个出牌的
	{"flag","char"}, --接风标志
	{"partnerCard","string"}, --对家剩余手牌
	{"playCardType","char"}, --牌型
	{"playCardValue","char"}, --牌值

}
GDPlayCardRequest.headers = {40,1,16}
function GDPlayCardRequest:ctor()
	print("GDPlayCardRequest ctor")
	GDPlayCardRequest.super.ctor(self)
	self:init(GDPlayCardRequest.orders)
end
function GDPlayCardRequest:formatRequest(gameplayId,userid,pokerCard,replaceCard,playCardType,playCardValue)
	self:setField("gameplayId",gameplayId)
	self:setField("userid",userid)
	self:setField("pokerCard",pokerCard)
	self:setField("replaceCard",replaceCard)
	--self:setField("flag",flag)
	--self:setField("nextPlayUseID",nextPlayUseID)
	if playCardType then
		self:setField("playCardType",playCardType)
	end
	
	if playCardValue then
		self:setField("playCardValue",playCardValue)
	end
	
	return self.data
end
function GDPlayCardRequest:send(target)
	print("GDPlayCardRequest send")
	local msgParam = self:formatHeader2(self.data,GDGameModel.MSG_ID.Msg_GDPlayCard_Send)
	
	
	NetWorkBridge:send(GDGameModel.MSG_ID.Msg_GDPlayCard_Send, msgParam, target)
	removeAll(msgParam)
end
return GDPlayCardRequest