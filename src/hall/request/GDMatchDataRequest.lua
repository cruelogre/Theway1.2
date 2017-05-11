-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.12
-- Last: 
-- Content:  请求数据比赛
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local GDMatchDataRequest = class("GDMatchDataRequest",require("app.request.BaseRequest"))
local GDMatchModel = require("hall.model.GDMatchModel")
GDMatchDataRequest.orders = {
	{"type","char"}, -- request type (int1)1= 请求比赛列表 2=比赛详情 3=面对面加好友 4=邀请比赛配对的好友列表  5=邀请好友组队

	{"param1","int"}, --Type=2时，Param1=MatchID  Type=3时，Param1=4位数字密码 Type=4，5时，Param1=InstMatchID,比赛实例ID
	{"param2","int"} --Type=5时，Param2=好友ID
}
GDMatchDataRequest.headers = {40,3,1}
function GDMatchDataRequest:ctor()
	print("GDMatchDataRequest ctor")
	GDMatchDataRequest.super.ctor(self)
	self:init(GDMatchDataRequest.orders)
end
function GDMatchDataRequest:formatRequest(rmType,param1,param2)
	self:setField("type",rmType)
	if param1 then
		self:setField("param1",param1)
	end
	if param2 then
		self:setField("param2",param2)
	end
	return self.data
end
function GDMatchDataRequest:send(target)
	print("GDMatchDataRequest send")
	local msgParam = self:formatHeader2(self.data,GDMatchModel.MSG_ID.Msg_GDMatchData_Send)
	dump(msgParam)
	print(GDMatchModel.MSG_ID.Msg_GDMatchData_Send)
	NetWorkBridge:send(GDMatchModel.MSG_ID.Msg_GDMatchData_Send, msgParam, target)
	removeAll(msgParam)
end
return GDMatchDataRequest