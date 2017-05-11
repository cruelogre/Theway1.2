-------------------------------------------------------------------------
-- Desc:    
-- Author:  sonic
-- Date:    2016.12.20
-- Last:    
-- Content:  斗牛消息委托
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullFightingSceneProxy = class("BullFightingSceneProxy",require("packages.mvc.Proxy"))

local Toast = require("app.views.common.Toast")
local BullFinghtingCfg = require("BullFighting.mediator.cfg.BullFinghtingCfg")
local BullfightPokerUtil = require("BullFighting.util.BullfightPokerUtil")
local GDUserInfoRequest = require("WhippedEgg.request.GDUserInfoRequest")

function BullFightingSceneProxy:init()
	self.logTag = "BullFightingSceneProxy.lua"
	wwlog(self.logTag, "BullFightingSceneProxy.lua init")

	self.bullfightingModel = import(".BullfightingMode", "BullFighting.model."):create(self) --消息实体
	self.gdGameMsgModel = import(".GDGameModel", "WhippedEgg.Model."):create(self) --消息实体
	
	self:registerMsg()
end

function BullFightingSceneProxy:registerMsg()
	--游戏开局
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNGameStart,
		handler(self, self.response))
	--响应玩家亮牌
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNShowPokerRes_ret,
		handler(self, self.response))
	--通知下注/ 亮牌
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNStartBetShowRes,
		handler(self, self.response))
	--响应玩家下注
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNBetRes_ret,
		handler(self, self.response))
	--牌局结束
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNGameOver,
		handler(self, self.response))
	--响应进入房间
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNInNorRoomRes,
		handler(self, self.response))
	--通知进/出房间(随机、看牌新玩法)
	self:registerMsgId(self.bullfightingModel.MSG_ID.Msg_NMessage_DNNoticeInOutRes,
		handler(self, self.response))
	--玩家信息
	self:registerMsgId(self.gdGameMsgModel.MSG_ID.Msg_GDGamePlayerInfo_Ret,
	handler(self,self.response),BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP)
end

function BullFightingSceneProxy:response(msgId, msgTable)
	local dispatchEventId = nil
	local dispatchData = nil

	if msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNGameStart then --游戏开局
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_GAMESTART
		self:gameStart(msgTable)
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNShowPokerRes_ret then --响应玩家亮牌
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_SHOWPOKER
		self:showCard(msgTable)
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNStartBetShowRes then --通知下注/ 亮牌
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_STARTBETSHOW
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNBetRes_ret then --响应玩家下注
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_BET
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNGameOver then --牌局结束
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_GAMEOVER
		self:gameOver(msgTable)
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNInNorRoomRes then --响应进入房间
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM
		self:inorRoomMsg( msgTable )
		dispatchData = msgTable
	elseif msgId==self.bullfightingModel.MSG_ID.Msg_NMessage_DNNoticeInOutRes then --通知进/出房间(随机、看牌新玩法)
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_NOTICEINOUT
		local IconTable = Split(msgTable.Icon,":")
		msgTable.Icon = IconTable[1]  --用户1头像
		msgTable.Gender = IconTable[2]  --用户1头像
		dispatchData = msgTable
	elseif msgId == self.gdGameMsgModel.MSG_ID.Msg_GDGamePlayerInfo_Ret then --玩家信息
		dispatchEventId = BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP
		dispatchData = self:handleUserinfo(dispatchEventId,msgTable)
	end

	--存入缓存中
	if dispatchEventId and dispatchData and type(dispatchData)=="table" then
		--DataCenter:clearData(dispatchEventId)
		local temp = {}
		copyTable(dispatchData,temp)
		DataCenter:cacheData(dispatchEventId,temp)
	end
	
	--发送消息
	if dispatchEventId and BullFinghtingCfg.innerEventComponent then
		BullFinghtingCfg.innerEventComponent:dispatchEvent({
					name = dispatchEventId;
					_userdata = dispatchData;
					
				})
	end
	
end

--响应进入房间
function BullFightingSceneProxy:inorRoomMsg( msgTable )
	-- body
    msgTable.MyBetScore = BullfightPokerUtil.parseBetScore(msgTable.MyBetScore)
    for k,v in pairs(msgTable.MyBetScore) do
    	if v > 127 then
    		v = -(255 - v + 1)
    	end
    end

	for k,v in pairs(msgTable.UserTable) do
		v.Card = BullfightPokerUtil.parseServerData(v.Card)

		local IconTable = Split(v.Icon,":")
		v.Icon = IconTable[1]  --用户1头像
		v.Gender = IconTable[2]  --用户1头像
	end
end

--开局
function BullFightingSceneProxy:gameStart( msgTable )
	-- body
	msgTable.MyCard = BullfightPokerUtil.parseServerData(msgTable.MyCard)
    msgTable.MyBetScore = BullfightPokerUtil.parseBetScore(msgTable.MyRobScore)

    for i=1,#msgTable.MyBetScore do
    	if msgTable.MyBetScore[i] > 127 then
    		msgTable.MyBetScore[i] = -(255 - msgTable.MyBetScore[i] + 1)
    	end
    end
end

--亮牌
function BullFightingSceneProxy:showCard( msgTable )
	-- body
	msgTable.Card = BullfightPokerUtil.parseServerData(msgTable.Card)
end

--结束
function BullFightingSceneProxy:gameOver( msgTable )
	-- body
	for k,v in pairs(msgTable.PlayTable) do
		v.Card = BullfightPokerUtil.parseServerData(v.Card)
	end
end

function BullFightingSceneProxy:handleUserinfo(msgId,msgTable)
	wwlog(self.logTag,"获取到了用户数据")
	local msgtables = DataCenter:getData(msgId)
	if not msgtables then --从来没请求过
		local tempTable = {}
		tempTable[msgTable.UserID] = {}
		copyTable(msgTable,tempTable[msgTable.UserID])
		DataCenter:cacheData(msgId,tempTable)
	else
		-- msgtables[msgTable.UserID]
		--直接更新
		local tempTable = {}
		copyTable(msgTable,tempTable)
		DataCenter:updateData(msgId,msgTable.UserID,tempTable)
	end
	return msgTable.UserID --返回请求的userid
end

--游戏相关请求
--PlayType 玩法类型
--Type
--Param1 扩展字段1
--Param2 扩展字段2 结算类型
function BullFightingSceneProxy:requestLobbyAction(PlayType, Type, Param1, Param2 )
	local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
	local paras = {
	    45,
	    1,
	    26,
	    userid,
	    PlayType, --PlayType
	    Type, --Type
	    Param1, --Param1
	    Param2, --Param2
	}
	wwdump(paras, "斗牛消息调试")
	self:sendMsg(self.bullfightingModel.MSG_ID.Msg_NMessage_DNLobbyActionReq_send, paras)
end

--游戏相关请求 k扩展
--type
--=13 请求进入随机、看牌场房间
--=14 请求退出随机、看牌场房间
--=15 请求准备(随机、看牌场)
--=16 请求换桌(随机、看牌场)
function BullFightingSceneProxy:requestLobbyActionHandle(GameZoneID, Type)
	self:requestLobbyAction(8, Type, tostring(GameZoneID), 3) --第三个参数直接写死，根据协定文档，作为按地方棋牌结算斗牛
end

--请求玩家下注
--GamePlayId,  本局对应的房间Id/桌子ID/对局ID 
--PlayType,  玩法类型
--SeatId,  位置ID 
--Chip,   下注额度
--GamePlayId2  对局ID
function BullFightingSceneProxy:requestDNBetReq(GamePlayId, PlayType, SeatId, Chip, GamePlayId2)
	local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
	local paras = {
	    45,
	    1,
	    7,
	    GamePlayId, --GamePlayId
	    PlayType, --PlayType
	    userid, --Type
	    SeatId, --位置ID 
		Chip, --下注额度
		"", --SendTime
		GamePlayId2, --GamePlayId2
	}
	self:sendMsg(self.bullfightingModel.MSG_ID.Msg_NMessage_DNBetReq_send, paras)
end

--请求玩家亮牌
--GamePlayId,  对局标示
--PlayType, 玩法类型
--Card,  用户的牌
--Type 默认传0
function BullFightingSceneProxy:requestDNShowPokerReq(GamePlayId, PlayType, Card, Type)
	local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
	local paras = {
	    45,
	    1,
	    2,
	    GamePlayId, --GamePlayId
	    PlayType, --PlayType
	    userid, --Type
	    Card, --用户的牌 
	    Type
	}
	self:sendMsg(self.bullfightingModel.MSG_ID.Msg_NMessage_DNShowPokerReq_send, paras)
end


function BullFightingSceneProxy:requestUserInfo(userid,clearAll)
	--先取缓存 这个数据最好一局释放一次
	
	local msgId = BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP
	
	if clearAll then --是否清空内存中的用户数据
		DataCenter:clearData(msgId)
	end
	
	local msgTable = DataCenter:getData(msgId)
	
	
	if msgTable and msgTable[userid] then
		--如果存在，直接发送消息
		wwlog(self.logTag,"数据已经有了，直接通知")
		if msgId and BullFinghtingCfg.innerEventComponent then
			BullFinghtingCfg.innerEventComponent:dispatchEvent({
					name = msgId;
					_userdata = userid;
					
				})
		end
		
	else
		--没有 请求
		local userReq = GDUserInfoRequest:create()
		userReq:setGameId(wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID)
		userReq:formatRequest(1,userid)
		userReq:send(self)
	end
end

return BullFightingSceneProxy