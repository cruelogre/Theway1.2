-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.12
-- Last: 
-- Content:  比赛报名和退赛
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------


local GDMatchEnterRequest = class("GDMatchEnterRequest",require("app.request.BaseRequest"))
local GDMatchModel = require("hall.model.GDMatchModel")
GDMatchEnterRequest.orders = {
	{"type","char"}, -- request type (int1)1=报名 2=退赛 3=组队报名
	{"MatchID","int"}, --比赛ID
	{"EnterType","char"}, --报名方式0=免费	1=金币	2=钻石	3=门票
	{"EnterData","int"}, --报名费数额或者门票ID
	{"FriendID","int"}, --好友ID	Type=1时,FriendID是邀请方ID，可以为空，表示单人参赛
						--			Type=3时，FriendID是被邀请方ID，不能为空
	{"Confirm","char"}, --1=确认报名标志，会自动退赛前面的比赛报名
}
GDMatchEnterRequest.headers = {40,3,5}
function GDMatchEnterRequest:ctor()
	print("GDMatchEnterRequest ctor")
	GDMatchEnterRequest.super.ctor(self)
	self:init(GDMatchEnterRequest.orders)
end
--报名请求封装
function GDMatchEnterRequest:formatRequest(rType,MatchID,EnterType,EnterData,FriendID,Confirm)
	self:setField("type",rType)
	self:setField("MatchID",MatchID)
	self:setField("EnterType",EnterType)
	self:setField("EnterData",EnterData)
	if FriendID then
		self:setField("FriendID",FriendID)
	end
	if Confirm then
		self:setField("Confirm",Confirm)
	end
	
	return self.data
end
function GDMatchEnterRequest:send(target)
	print("GDMatchEnterRequest send")
	local msgParam = self:formatHeader2(self.data,GDMatchModel.MSG_ID.Msg_GDMatchEnter_Send)
	wwdump(msgParam)
	
	NetWorkBridge:send(GDMatchModel.MSG_ID.Msg_GDMatchEnter_Send, msgParam, target)
	removeAll(msgParam)
end
return GDMatchEnterRequest