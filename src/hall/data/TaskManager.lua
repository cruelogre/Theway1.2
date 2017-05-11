-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.28
-- Last: 
-- Content:  任务管理器
-- Modify:
--			2016.12.05 添加回收方法
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local TaskManager = class("TaskManager")
local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")

function TaskManager:ctor()
	self.logTag = self.__cname..".lua"
	self.taskMap = {}
	
end
--添加任务
--@param taskId 任务ID
--@param task 任务实例
function TaskManager:addTask(taskId,task)
	if task and taskId then
		if not self.taskMap[tostring(taskId)] then
			self.taskMap[tostring(taskId)] = task
		else
			wwlog(self.logTag,"这个任务还未完成%s",tostring(taskId))
		end
		
	end
	
end
function TaskManager:getTask(taskId)
	return self.taskMap[tostring(taskId)]
end
--获取任务状态
--@param taskId 任务ID
--@return 返回任务的状态
function TaskManager:getTaskState(taskId)
	if not taskId or not self.taskMap[tostring(taskId)] then
		return TaskCfg.TaskState.TASK_TODO
	else
		return self.taskMap[tostring(taskId)].taskState
	end
	
end
--检查任务是否存在
--@param taskId 任务ID
function TaskManager:checkTask(taskId)
	return taskId and self.taskMap[tostring(taskId)]
end
--改变任务的状态
--@param taskId 任务的ID
--@param taskState 任务状态
function TaskManager:changeTaskState(taskId,taskState)
	if not taskId or not self.taskMap[tostring(taskId)] then
		wwlog(self.logTag,"任务不存在%s",tostring(tostring(taskId)))
		return
	end
	local tempTask = self.taskMap[tostring(taskId)]
	if taskState== TaskCfg.TaskState.TASK_TODO then
		tempTask:startTask()
	elseif taskState == TaskCfg.TaskState.TASK_PROGRESS then
		tempTask:progress()
	elseif taskState == TaskCfg.TaskState.TASK_DONE then
		tempTask:finishTask()
	elseif taskState == TaskCfg.TaskState.TASK_FINISHED then
		tempTask:endTask()
	end
	
end
--删除任务
--@param taskId 任务ID
function TaskManager:removeTask(taskId)
	if not taskId or not self.taskMap[tostring(taskId)] then
		wwlog(self.logTag,"删除的任务不存在%s",tostring(taskId))
		return
	end
	wwlog(self.logTag,"任务删除成功%s",tostring(taskId))
	local tempTask = self.taskMap[tostring(taskId)]
	tempTask:finalizer()
	tempTask = nil
	self.taskMap[tostring(taskId)] = nil
	
end

function TaskManager:finalizer()
	table.walk(self.taskMap,function (v,k)
		v:finalizer()
		v = nil
	end)
	removeAll(self.taskMap)
end

cc.exports.TaskManager = cc.exports.TaskManager or TaskManager:create()
return TaskManager