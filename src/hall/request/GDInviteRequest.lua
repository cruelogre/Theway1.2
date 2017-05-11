-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.10.09
-- Last: 
-- Content:  比赛邀请好友
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------


local GDInviteRequest = class("GDInviteRequest",require("app.request.BaseRequest"))
local GDMatchModel = require("hall.model.GDMatchModel")
GDInviteRequest.orders = {
	{"type","char"}, -- request type (int1)1=请求加好友 2=同意加好友 3=拒绝加好友 4=邀请好友组队 5=拒绝组队

	{"toUserID","int"}, --对方蛙号
	{"IconID","int"}, --头像
	{"nickname","string"}, --昵称
	{"Param1","int"}, -- InstMatchID
	{"Param2","int"}, --MatchID
	{"Gender","char"}, --MatchID
}
GDInviteRequest.headers = {40,3,10}
function GDInviteRequest:ctor()
	print("GDInviteRequest ctor")
	GDInviteRequest.super.ctor(self)
	self:init(GDInviteRequest.orders)
end
--报名请求封装
function GDInviteRequest:formatRequest(rType,toUserID,IconID,nickname,Param1,Param2,Gender)
	self:setField("type",rType)
	self:setField("toUserID",toUserID)
	self:setField("IconID",IconID)
	self:setField("nickname",nickname)
	if Param1 then
		self:setField("Param1",Param1)
	end
	if Param2 then
		self:setField("Param2",Param2)
	end
	if Gender then
		self:setField("Gender",Gender)
	end
	return self.data
end
function GDInviteRequest:send(target)
	print("GDInviteRequest send")
	local msgParam = self:formatHeader2(self.data,GDMatchModel.MSG_ID.Msg_GDMatchAddBuddy_Send)
	dump(msgParam)
	
	NetWorkBridge:send(GDMatchModel.MSG_ID.Msg_GDMatchAddBuddy_Send, msgParam, target)
	removeAll(msgParam)
end
return GDInviteRequest