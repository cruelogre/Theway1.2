-------------------------------------------------------------------------
-- Desc:    社交数据请求
-- Author:  cruelogre
-- Info:   
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SocialDataRequest = class("SocialDataRequest",require("app.request.BaseRequest"))
local SocialContactModel = require("hall.model.SocialContactModel")
SocialDataRequest.orders = {
	{"type","char"}, -- 请求类型,1=面对面加好友 2=请求牌友列表 3=比赛可邀请好友列表 4=私人房可邀请好友列表 5=搜索指定用户 6=请求加好友

	{"Param1","int"}, --请求参数1 Type=1时，Param1=4位数字密码 Type=3时，Param1=比赛实例ID Type=4时，Param1=房间ID Type=5,6,7,8时，Param1=蛙号
	{"Start","short"}, --开始序号，从1开始
	{"Count","short"}, --数量
	{"StrParam1","string"}, --字符串请求参数1 Type=6,7,8时，StrParam1=消息发起者昵称
	{"StrParam2","string"}, --Type=6时，StrParam2=加好友的场景相关参数，格式“GameID,PlayID,RoomID
}

function SocialDataRequest:ctor()
	print("SocialDataRequest ctor")
	SocialDataRequest.super.ctor(self)
	self:init(SocialDataRequest.orders)
end
--请求社交数据
--@param stype 1=面对面加好友 2=请求牌友列表 3=比赛可邀请好友列表 4=私人房可邀请好友列表 5=搜索指定用户 6=请求加好友
--@param Param1 Type=1时，Param1=4位数字密码 Type=3时，Param1=比赛实例ID Type=4时，Param1=房间ID Type=5,6,7,8时，Param1=蛙号
--@param Start 开始序号，从1开始
--@param Count 数量
--@param StrParam1 Type=6,7,8时，StrParam1=消息发起者昵称
function SocialDataRequest:formatRequest(stype,Param1,Start,Count,StrParam1,StrParam2)
	self:setField("type",stype)
	self:setField("Param1",Param1)
	self:setField("Start",Start or 1)
	self:setField("Count",Count or 1)
	self:setField("StrParam1",StrParam1 or "")
	self:setField("StrParam2",StrParam2 or "")
	return self.data
end
function SocialDataRequest:send(target)
	print("SocialDataRequest send")
	local msgParam = self:formatHeader2(self.data,SocialContactModel.MSG_ID.Msg_RSCData_Req)
	wwdump(msgParam)
	
	NetWorkBridge:send(SocialContactModel.MSG_ID.Msg_RSCData_Req, msgParam, target)
	removeAll(msgParam)
end
return SocialDataRequest