local GDUserInfoRequest = class("GDUserInfoRequest",require("app.request.BaseRequest"))

local GDGameModel = require("WhippedEgg.Model.GDGameModel")
GDUserInfoRequest.orders = {
	{"type","char"}, -- (int1)请求类型  1=对局中玩家数据 2=个人信息 3=个人破产状态 11=更新性别 12=更新昵称

	{"UserID","int"}, --用户id
	{"strParam1","string"}, --请求参数
	{"GameID","short"}, --游戏ID
}

GDUserInfoRequest.headers = {40,1,21}
function GDUserInfoRequest:ctor()
	print("GDUserInfoRequest ctor")
	GDUserInfoRequest.super.ctor(self)
	self:init(GDUserInfoRequest.orders)
end

function GDUserInfoRequest:setGameId( gameid )
	-- body
	self.GameID = gameid or wwConfigData.GAME_ID 
end

function GDUserInfoRequest:formatRequest(mType,userid,strParam1)
	self:setField("type",mType)
	self:setField("GameID",self.GameID or wwConfigData.GAME_ID)
	self:setField("UserID",userid)
	if strParam1 then
		self:setField("strParam1",strParam1)
	end

	
	return self.data
end
function GDUserInfoRequest:send(target)
	print("GDUserInfoRequest send")
	local msgParam = self:formatHeader2(self.data,GDGameModel.MSG_ID.Msg_GDUserInfo_send)
	
	
	NetWorkBridge:send(GDGameModel.MSG_ID.Msg_GDUserInfo_send, msgParam, target)
	dump(msgParam)
	removeAll(msgParam)
end
return GDUserInfoRequest