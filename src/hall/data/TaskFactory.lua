-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.28
-- Last: 
-- Content:  任务工厂
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local TaskFactory = class("TaskFactory")

local TaskImplPlayCard = import(".TaskImplPlayCard","hall.data.")
local TaskImplShare = import(".TaskImplShare","hall.data.")
local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")


function TaskFactory:ctor()
	self.logTag = self.__cname..".lua"
	
end
--创建任务
--@param taskType 任务类型 目前支持两种
--		 TASK_PLAYCARD  打牌任务
--		 TASK_SHARE 分享任务
--@param param 初始化数据
function TaskFactory:createTask(taskType,param)
	local task = nil
	if taskType==TaskCfg.TaskType.TASK_PLAYCARD then
		task = TaskImplPlayCard:create()
	elseif taskType == TaskCfg.TaskType.TASK_SHARE then
		task = TaskImplShare:create()
	end
	if task then
		task:init(param)
	end
	return task
end

cc.exports.TaskFactory = cc.exports.TaskFactory or TaskFactory:create()
return TaskFactory