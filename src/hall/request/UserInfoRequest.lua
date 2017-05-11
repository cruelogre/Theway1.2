local UserInfoRequest = class("UserInfoRequest",require("app.request.BaseRequest"))
local userInfoModel = require("hall.model.userInfoModel")
UserInfoRequest.orders = {
	{"type","char"}, -- request type (int1)请求类型, 1=对局中玩家数据 2=个人信息 3=个人破产状态
	-- 11=更新性别 12=更新昵称 13=更新地区城市 13=请求每日任务列表14=请求任务奖励

 
	{"userid","int"}, --用户id
	{"strParam1","string"}, --(String)请求参数1
	{"GameID","short"}, --(short)游戏ID
}
UserInfoRequest.headers = {40,1,21}
function UserInfoRequest:ctor()
	print("UserInfoRequest ctor")
	UserInfoRequest.super.ctor(self)
	self:init(UserInfoRequest.orders)
end
function UserInfoRequest:formatRequest(rmType,userid,strParam1,gameid)
	self:setField("type",rmType)
	self:setField("userid",userid or 0)
	self:setField("strParam1",strParam1 or "")
	self:setField("GameID",gameid or wwConfigData.GAME_ID)
	return self.data
end
function UserInfoRequest:send(target)
	print("UserInfoRequest send")
	local msgParam = self:formatHeader2(self.data,userInfoModel.MSG_ID.Msg_GDUserInfo_send)
	dump(msgParam)
	
	NetWorkBridge:send(userInfoModel.MSG_ID.Msg_GDUserInfo_send, msgParam, target)
	removeAll(msgParam)
end
return UserInfoRequest