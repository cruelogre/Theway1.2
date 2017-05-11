local ITask = class("ITask")
local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")

function ITask:ctor(...)
	self.logTag = self.__cname..".lua"
	--任务ID
	self.taskId = nil 
	-- 任务类型
	self.taskType = TaskCfg.TaskType.TASK_NULL
	--任务状态 
	self.taskState = TaskCfg.TaskState.TASK_TODO
	
end
--初始化任务数据
function ITask:init(param)
	if param then
		self.taskData = param

		self.taskState = param.taskState or TaskCfg.TaskState.TASK_TODO
		self.taskId = param.taskId or self.taskId
	end

end
--任务开始 用于进行任务的操作
function ITask:startTask(...)
	if self.taskState==TaskCfg.TaskState.TASK_DONE or 
		self.taskState==TaskCfg.TaskState.TASK_FINISHED then --已经结束了
		wwlog(self.logTag,"任务已经结束或者完成，不能开始",self.taskState)
		return false
	end
	self.taskState = TaskCfg.TaskState.TASK_PROGRESS
	wwlog(self.logTag,"开始做任务%s",tostring(self.taskId))
	return true
end
--任务执行中 用于任务进度回报
function ITask:progress(...)
	self.taskState = TaskCfg.TaskState.TASK_PROGRESS
	wwlog(self.logTag,"任务进行中%s",tostring(self.taskId))
end
--任务执行完毕 用于标识任务奖励可以领取
function ITask:finishTask(...)
	self.taskState = TaskCfg.TaskState.TASK_DONE
	wwlog(self.logTag,"任务完成%s",tostring(self.taskId))
	if self.taskId then
		self:getTaskProxy():requestTaskAward(tonumber(self.taskId))
	end
	
end
--任务关闭 奖励已经领取
function ITask:endTask(...)
	self.taskState = TaskCfg.TaskState.TASK_FINISHED
	wwlog(self.logTag,"任务结束%s",tostring(self.taskId))
	--任务删除的时候，重新请求
	self:getTaskProxy():requestTaskList()
end
--播放领取动画
--@param retData 领奖内容
--   fid 物品fid,num 物品数量 
function ITask:playAwardUI(retData)
	import(".ItemShowView", "app.views.customwidget."):create(retData):show()
end
function ITask:getTaskProxy()
	return ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_TaskProxy)
end
function ITask:finalizer()
	
end
return ITask