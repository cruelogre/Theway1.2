---------------------------------------------
-- module : 任务过滤器
-- auther : cruelogre
-- Date:    2016.11.30
-- comment: 大厅任务过滤器 获取任务
--  		1. 核心过滤方法doFilter 触发状态机事件

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local TaskFilter = class("TaskFilter",require("packages.statebase.FSFilter"))

local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local HallCfg = import(".HallCfg","hall.mediator.cfg.")

require("hall.data.TaskManager")
require("hall.data.TaskFactory")

function TaskFilter:ctor(filterId,priority)
	TaskFilter.super.ctor(self,filterId,priority)
	self.jumpEventName = nil
	self.jumpParam = nil
	--self.filterId = filterId
	self.filterCount = -1 --无限次数
	self.filterType = bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume)
	self.handlers = {}
	
	
end
--分享成功消息
function TaskFilter:shareMsg(event)
	wwlog(self.logTag,"领取成功，重新请求")
	self:getTaskProxy():requestTaskList()
end
--分享成功回调 
function TaskFilter:shareOk(event)
	wwlog(self.logTag,"分享成功回调taskID %s",tostring(event._userdata[1]))
	wwlog(self.logTag,"分享成功回调taskType %s",tostring(event._userdata[2]))
	local taskid = event._userdata[1]
	local tasType = event._userdata[2]
	if taskid then
		self:getTaskProxy():notifyShare(tonumber(tasType),taskid)
	end	
end

function TaskFilter:registerListener()
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent():
			addEventListener(TaskCfg.InnerEvents.TASK_EVENT_TASKLIST,handler(self,self.setTaskData))
		_,self.handlers[#self.handlers+1] = self:eventComponent():
			addEventListener(TaskCfg.InnerEvents.TASK_EVENT_SHAREMESSAGE,handler(self,self.shareMsg))
	end
			
	self.shareListener = WWFacade:addCustomEventListener(TaskCfg.InnerEvents.TASK_EVENT_SHARESUCCESS,handler(self,self.shareOk))
end
function TaskFilter:unRegisterListener()
	if self:eventComponent() then
		for _,v in pairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
	end
	removeAll(self.handlers)
	
	if self.shareListener then
		WWFacade:removeEventListener(self.shareListener)
	end
end
--设置数据
function TaskFilter:setTaskData(event)
	
	if event.name==TaskCfg.InnerEvents.TASK_EVENT_TASKLIST then
		local taskDatas = DataCenter:getData(TaskCfg.InnerEvents.TASK_EVENT_TASKLIST)
		if taskDatas and taskDatas.TaskList then
			
			for _,data in pairs(taskDatas.TaskList) do
				if data.Status~=2 and not TaskManager:checkTask(data.TaskID) then --任务完成了的
					--data.TaskType  任务类型 	1：社交任务		2：牌局任务
					local task = nil
					if not TaskManager:checkTask(data.TaskID) then
						local taskType = (data.TaskType==1 and TaskCfg.TaskType.TASK_SHARE or TaskCfg.TaskType.TASK_PLAYCARD)
						local task = TaskFactory:createTask(taskType,{taskId = data.TaskID,fid = data.FID })
						TaskManager:addTask(data.TaskID,task)
						wwlog(self.logTag,"任务创建成功")

					end
					--data.FID  任务功能ID  10170001  微信分享  10170002  经典场对局	10170003  经典场赢局
				elseif data.Status == 2 then
					TaskManager:removeTask(data.TaskID)
					wwlog(self.logTag,"任务已经存在，或者奖励已经领取，任务不再创建")
				end
				
			end
			
			--有完成的任务添加小红点
			self:refreshRedPoint(self:checkTaskState(taskDatas.TaskList) )
			
		end
		
	end
	
	

end

function TaskFilter:checkTaskState(taskList)
	local hasComplete = false
	for _,data in pairs(taskList) do
		if data.Status==1 then 
			hasComplete = true
			break
		end
	end
	return hasComplete
end

function TaskFilter:refreshRedPoint(flag)
	
	WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "task",flag)
	
end

function TaskFilter:doFilter(filterChain,filterType)

		if bit._and(filterType,FSConst.FilterType.Filter_Enter)> 0 then
			if not self.handlers or not next(self.handlers) then
				self:registerListener()
			end
		elseif bit._and(filterType,FSConst.FilterType.Filter_Exit)> 0 then
			self:unRegisterListener()
		end

	if TaskFilter.super.doFilter(self,filterChain,filterType) then
		wwlog(self.logTag,"doFilter filterId %s 自有类型 %d 分发类型 %d 剩余次数 %d",
		tostring(self.filterId),self.filterType,filterType,self.filterCount)
		
		wwlog(self.logTag,"任务过滤器 filterId %s",tostring(self.filterId))
		local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
		if loginMsg and next(loginMsg) and loginMsg.hallversion then
			self:getTaskProxy():requestTaskList()
		end
		
--[[		local taskDatas = DataCenter:getData(TaskCfg.InnerEvents.TASK_EVENT_TASKLIST)
			
		if not taskDatas or not next(taskDatas) then --没有获取过任务
			self:getTaskProxy():requestTaskList()
		else
			self:setTaskData({name=TaskCfg.InnerEvents.TASK_EVENT_TASKLIST})
			
		end--]]
		
	end
	
	return true
end

function TaskFilter:getTaskProxy()
	return ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_TaskProxy)
end
function TaskFilter:eventComponent()
	return HallCfg.innerEventComponent
end


function TaskFilter:finalizer()
	self:unRegisterListener()
end

return TaskFilter