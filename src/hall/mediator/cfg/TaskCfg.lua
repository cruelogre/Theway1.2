-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  任务配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local TaskCfg = {}
TaskCfg.innerEventComponent = nil
--设置中的UI事件
TaskCfg.InnerEvents = {
	TASK_EVENT_TASKLIST = "TASK_EVENT_TASKLIST", --获取到任务列表
	TASK_EVENT_SHARESUCCESS = "TASK_EVENT_SHARESUCCESS", --分享成功
	TASK_EVENT_SHAREMESSAGE = "TASK_EVENT_SHAREMESSAGE", --分享成功服务器消息
	TASK_EVENT_AWARDNOTIFY = "TASK_EVENT_AWARDNOTIFY", --分享奖励通知
	
}
--任务状态
TaskCfg.TaskState = {
	TASK_TODO = 0, --未完成
	TASK_PROGRESS = 1, --进行中
	TASK_DONE = 2, --已完成
	TASK_FINISHED = 3, -- 已经结束
}

--任务类型
TaskCfg.TaskType = {
	TASK_NULL = 0, --空
	TASK_PLAYCARD = 1, --打牌
	TASK_SHARE = 2, --分享
}

TaskCfg.JumpType = {
	
	
	
}
--经典房的FID
TaskCfg.chooseRoomFids = {
	10170101,10170102,10170201,10170202,10170301,10170302
}
--比赛房的FID
TaskCfg.matchFids = {
	
}
--私人房的FID
TaskCfg.sirenFids = {
	
}
--微信好友的FID
TaskCfg.friendFids = {
	10000001,
}

--朋友圈的FID
TaskCfg.circleFids = {
	10000002,
}

--排序规则 
--		1.有完成未领取的放最前面
--		2.已经完成已经领取的放最后边
--		3.其他位置不动
function TaskCfg.sort(tasklist)	
	local retTasks = {}
	local awardTasks = {}
	local unfinishTasks = {}
	local doneTasks = {}
	table.walk(tasklist,function (task,idx)
		if task.Status == 1 then -- 0：未完成 1：已完成 (待领奖) 2：已领取奖励
			awardTasks[#awardTasks+1] = task
		elseif task.Status == 0 then
			unfinishTasks[#unfinishTasks+1] = task
		elseif task.Status == 2 then
			doneTasks[#doneTasks+1] = task
		end
	end)
	
	table.walk(awardTasks,function (task,idx)
		table.insert(retTasks,task)
	end)
	table.walk(unfinishTasks,function (task,idx)
		table.insert(retTasks,task)
	end)
	table.walk(doneTasks,function (task,idx)
		table.insert(retTasks,task)
	end)
	removeAll(awardTasks)
	removeAll(unfinishTasks)
	removeAll(doneTasks)
	return retTasks
end


return TaskCfg