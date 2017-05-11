-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  房间聊天委托
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RoomChatProxy = class("RoomChatProxy", require("packages.mvc.Proxy"))

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

local RoomChatModel = require("hall.model.RoomChatModel")

local RoomChatRequest = require("hall.request.RoomChatRequest")

function RoomChatProxy:init()
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	
	self:bindInnerEventComponent()
	
	
	self._roomChatModel = RoomChatModel:create(self) --聊天消息
	
		--打到结算分
	self:registerMsgId(self._roomChatModel.MSG_ID.Msg_RoomChat_Ret,
	handler(self,self.response),RoomChatCfg.InnerEvents.RMCHAT_EVENT_RECIEVED_DATA)
	
end




--封装请求
--@param Content  聊天内容
--@param GamePlayID 对局ID
--@param RoomID 私人房房间ID
--@param GAMEID 游戏ID
function RoomChatProxy:sendChatData(Message,GamePlayID,RoomID,GAMEID)
	local crquest = RoomChatRequest:create()

	crquest:formatRequest(Message,GamePlayID,RoomID,GAMEID)
	crquest:send(self)
	--发送后关闭

	
end



function RoomChatProxy:response(msgId, msgTable)
	local dispatchEventId = nil
	local dispatchData = nil
	if msgId==self._roomChatModel.MSG_ID.Msg_RoomChat_Ret then
		dispatchEventId = RoomChatCfg.InnerEvents.RMCHAT_EVENT_RECIEVED_DATA
		dispatchData = msgTable
	end
	wwdump(dispatchData,"dsda")
	--存入缓存中
	if dispatchEventId and dispatchData and type(dispatchData)=="table" then
		--DataCenter:clearData(dispatchEventId)

		local storeData = DataCenter:getData(dispatchEventId)
		if not storeData or not next(storeData) then
			local temp = {}
			table.insert(temp,dispatchData)
			DataCenter:cacheData(dispatchEventId,temp)
		else
			table.insert(storeData,dispatchData)
		end
		
		
	end
	
		--发送消息
	if dispatchEventId and RoomChatCfg.innerEventComponent then
		RoomChatCfg.innerEventComponent:dispatchEvent({
					name = dispatchEventId;
					_userdata = dispatchData;
					
				})
	end
	
end


function RoomChatProxy:bindInnerEventComponent()
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	RoomChatCfg.innerEventComponent = self._innerEventComponent
end

function RoomChatProxy:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		RoomChatCfg.innerEventComponent = nil
	end
end

function RoomChatProxy:finalizer()
	self:unbindInnerEventComponent()
end

return RoomChatProxy