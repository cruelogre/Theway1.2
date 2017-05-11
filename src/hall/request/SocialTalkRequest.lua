-------------------------------------------------------------------------
-- Desc:    社交聊天请求
-- Author:  cruelogre
-- Info:   
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SocialTalkRequest = class("SocialTalkRequest",require("app.request.BaseRequest"))
local SocialContactModel = require("hall.model.SocialContactModel")
SocialTalkRequest.orders = {
	{"type","short"}, --0=好友聊天(上下行)1=好友申请（系统消息下行） 2=同意加好友(上下行) 3=拒绝加好友(上下行)
	{"FromUserID","int"}, --好友ID
	{"ToUserID","int"}, --好友ID
	{"Content","string"}, --聊天内容
	{"TalkMsgID","string"}, --聊天消息ID(type>0有效)

}

function SocialTalkRequest:ctor()
	print("SocialTalkRequest ctor")
	SocialTalkRequest.super.ctor(self)
	self:init(SocialTalkRequest.orders)
end
--聊天请求
--@param stype 0=好友聊天(上下行) 1=好友申请（系统消息下行） 2=同意加好友(上下行) 3=拒绝加好友(上下行)
--@param FromUserID 好友ID
--@param ToUserID 好友ID
--@param Content 聊天内容
--@param TalkMsgID 聊天消息ID(type>0有效)
function SocialTalkRequest:formatRequest(stype,FromUserID,ToUserID,Content,TalkMsgID)
	self:setField("type",stype)
	self:setField("FromUserID",FromUserID)
	self:setField("ToUserID",ToUserID)
	self:setField("Content",Content or "")
	self:setField("TalkMsgID",TalkMsgID or "")
	return self.data
end
function SocialTalkRequest:send(target)
	print("SocialTalkRequest send")
	local msgParam = self:formatHeader2(self.data,SocialContactModel.MSG_ID.Msg_RSCBuddyTalk_Req)
	dump(msgParam)
	
	NetWorkBridge:send(SocialContactModel.MSG_ID.Msg_RSCBuddyTalk_Req, msgParam, target)
	removeAll(msgParam)
end
return SocialTalkRequest