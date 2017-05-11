-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.26
-- Last: 
-- Content:  房间选择的代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChooseRoomProxy = class("ChooseRoomProxy",require("packages.mvc.Proxy"))
local ChooseRoomRequest = require("hall.request.ChooseRoomRequest")
local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")
local Toast = require("app.views.common.Toast")


function ChooseRoomProxy:init()
	print("ChooseRoomProxy init")
	self._hallNetModel = require("hall.model.HallNetModel"):create(self)
	
	self._hallNetModel2 = require("hall.model.HallNetModel2"):create(self)
end

function ChooseRoomProxy:requestHallList(param1, param2, param3)
	LoadingManager:startLoading(0.8,LOADING_MODE.MODE_TOUCH_CLOSE)
	local msgIds = self._hallNetModel.MSG_ID
	DataCenter:cacheData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,nil)
	self:registerMsgId(msgIds.Msg_GDGameZoneList_Ret, (function (msgId,msgTable)
		self:onHallListReceived(msgId,msgTable,param1)
		
	end), ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(1,param1, param2, param3)
	crquest:send2(self)
	
end

--请求进入游戏
-- @param gamezoneid 游戏区域id

function ChooseRoomProxy:requestEnterGame(gamezoneid)
	print("ChooseRoomProxy:requestEnterGame ",gamezoneid)
	local msgIds = self._hallNetModel.MSG_ID	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(2,gamezoneid)
	crquest:send(self)
	
end

--请求快速开始游戏
function ChooseRoomProxy:requestFastGame()
	print("ChooseRoomProxy:requestFastGame ")
	local msgIds = self._hallNetModel.MSG_ID	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(3,0)
	crquest:send(self)
end

function ChooseRoomProxy:onHallListReceived(msgId,msgTable,param1)
	print("ChooseRoomProxy onHallListReceived")
	LoadingManager:endLoading()
	--dump(msgTable)
	if msgId==self._hallNetModel.MSG_ID.Msg_GDGameZoneList_Ret then
		--判断成功或者失败
		if msgTable.kResult and tonumber(msgTable.kResult)==1 then
			--失败
			isOk = false
			local result = msgTable.kReason
			Toast:makeToast(result,1.0):show()
		else
			--成功
			if DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST) then
				DataCenter:updateData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,param1,msgTable)
			else
				local tempTable = {}
				tempTable[param1] = msgTable
				DataCenter:cacheData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,tempTable)
			end
			
			if ChooseRoomCfg.innerEventComponent then
				ChooseRoomCfg.innerEventComponent:dispatchEvent({
					name = ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST;
					userTag = param1
				})
			end

		
		end
		
		self:unregisterMsgId(self._hallNetModel.MSG_ID.Msg_GDGameZoneList_Ret, ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	end
end


function ChooseRoomProxy:getRoomData(GameZoneID)
	local tempGameZoneData  = nil
	local allData = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	
	if not allData or not allData[2] or not next(allData[2].looptab1) then
		--
		print("房间数据还未获取到")
		return tempGameZoneData
	end
	local tempGameZone = allData[2].looptab1
	
	if tempGameZone then
		for _,gamedata in pairs(tempGameZone) do
			if gamedata.GameZoneID==GameZoneID then
				tempGameZoneData = gamedata
				break
			end
		end
	end
	return tempGameZoneData
end

return ChooseRoomProxy