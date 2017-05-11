-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.24
-- Last: 
-- Content:  每日任务的代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local TaskProxy = class("TaskProxy",require("packages.mvc.Proxy"))
local UserInfoRequest = require("hall.request.UserInfoRequest")

local Toast = require("app.views.common.Toast")
local userData = DataCenter:getUserdataInstance()
local TaskCfg = require("hall.mediator.cfg.TaskCfg")
local HallCfg = import(".HallCfg","hall.mediator.cfg.")
function TaskProxy:init()
	print("TaskProxy init")
	self._userInfoModel = require("hall.model.userInfoModel"):create(self)
	self:registerMsg()
end
function TaskProxy:registerMsg()
	--每日任务列表
	self:registerMsgId(self._userInfoModel.MSG_ID.Msg_GDTaskList_Ret,handler(self,self.response))
end

--请求任务列表
function TaskProxy:requestTaskList()
	--LoadingManager:startLoading(0.8,LOADING_MODE.MODE_TOUCH_CLOSE)
    local userinfo = UserInfoRequest:create()
    userinfo:formatRequest(13, tonumber(userData:getValueByKey("userid")))
    userinfo:send(self)
end
--领取任务奖励
function TaskProxy:requestTaskAward(taskId)
    local userinfo = UserInfoRequest:create()
    userinfo:formatRequest(14, tonumber(userData:getValueByKey("userid")),tostring(taskId))
    userinfo:send(self)
end
--通知服务器分享成功
--@param shareType 分享类型  1 朋友圈 2 好友
function TaskProxy:notifyShare(shareType,taskId)
	local reqType = 15
	if shareType==1 then
		reqType = 17
	elseif shareType == 2 then
		reqType = 15
	end
    local userinfo = UserInfoRequest:create()
	
    userinfo:formatRequest(reqType, tonumber(userData:getValueByKey("userid")),tostring(taskId))
    userinfo:send(self)
end
function TaskProxy:response(msgId,msgTable)
	print("TaskProxy response")
	--LoadingManager:endLoading()
	local dispatchId = nil
	local dispachData = nil
	--dump(msgTable)
	if msgId == self._userInfoModel.MSG_ID.Msg_GDTaskList_Ret then
		dispatchId = TaskCfg.InnerEvents.TASK_EVENT_TASKLIST
		dispachData = self:handleTaskList(msgId,msgTable)
	end
	
	
	if dispatchId and dispachData and type(dispachData)=="table" and next(dispachData) then
		local temp2 = {}
		copyTable(dispachData,temp2)
		DataCenter:cacheData(dispatchId,temp2)
	end
	if dispatchId and TaskCfg.innerEventComponent then
			TaskCfg.innerEventComponent:dispatchEvent({
				name = dispatchId;
			
			})
	end
	if dispatchId and HallCfg.innerEventComponent then
			HallCfg.innerEventComponent:dispatchEvent({
				name = dispatchId;
			
			})
	end
end


--处理任务列表
function TaskProxy:handleTaskList(msgId,msgTable)
	
	--wwdump(msgTable)
	
	return msgTable
end
return TaskProxy