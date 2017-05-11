local RoomChatRequest = class("RoomChatRequest",require("app.request.BaseRequest"))

local RoomChatModel = require("hall.model.RoomChatModel")
RoomChatRequest.orders = {
	{"GamePlayID","int"}, -- 对局标志
	{"GameID","short"}, -- 游戏ID
	{"RoomID","int"}, -- 私人房ID
	{"UserID","int"}, --用户id
	{"Content","string"}, --聊天内容类型


	
}

			
RoomChatRequest.headers = {40,1,25}
function RoomChatRequest:ctor()
	print("RoomChatRequest ctor")
	RoomChatRequest.super.ctor(self)
	self:init(RoomChatRequest.orders)
end
--封装请求
--@param Content  聊天内容
--@param GamePlayID 对局ID
--@param RoomID 私人房房间ID
function RoomChatRequest:formatRequest(Content,GamePlayID,RoomID,gameid)

	self:setField("UserID",DataCenter:getUserdataInstance():getValueByKey("userid"))
	self:setField("Content",Content)
	self:setField("GameID",gameid or wwConfigData.GAME_ID)
	self:setField("GamePlayID",GamePlayID)
	self:setField("RoomID",RoomID)
	
	return self.data
end
function RoomChatRequest:send(target)
	print("RoomChatRequest send")
	local msgParam = self:formatHeader2(self.data,RoomChatModel.MSG_ID.Msg_RoomChat_send)
	
	
	NetWorkBridge:send(RoomChatModel.MSG_ID.Msg_RoomChat_send, msgParam, target)
	dump(msgParam)
	removeAll(msgParam)
end
return RoomChatRequest