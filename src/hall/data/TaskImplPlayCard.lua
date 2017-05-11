-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.28
-- Last: 
-- Content:  打牌任务 
--			跳转到打牌的房间选择界面
--			目前只配置了经典房间的，如果新增私人房和比赛，牛牛等，需要重新配置
-- Modify: 
--			2017.2.6 修改跳转参数中添加gameid
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local TaskImplPlayCard = class("TaskImplPlayCard",import(".ITask","hall.data."))

local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local JumpFilter = require("packages.statebase.filter.JumpFilter")
local CorFilter = require("packages.statebase.filter.CorFilter")

function TaskImplPlayCard:ctor()
	TaskImplPlayCard.super.ctor(self)
	
	-- 任务类型
	self.taskType = TaskCfg.TaskType.TASK_PLAYCARD
	self.taskInfo = {}
	self.awards = {}
end

function TaskImplPlayCard:init(param)
	TaskImplPlayCard.super.init(self,param)
	if param and param.fid then
	
		self.taskInfo = self:getTaskInfo(param.fid)
	end
	if param and param.awards then
		self.awards = param.awards
	end
end

--任务开始 用于进行任务的操作
function TaskImplPlayCard:startTask(...)

	if TaskImplPlayCard.super.startTask(self,...) then
		
		
		self:gotoTask(self.taskInfo.eventName, --事件名
		self.taskInfo.stateName, --状态名
		self.taskInfo.jumpData) --跳转的状态机参数
		
	end
	return true
end
--是否为经典场
function TaskImplPlayCard:isChooseRoomFid(fid)
	local isChoose = false
	for _,v in ipairs(TaskCfg.chooseRoomFids) do
		if v==fid then
			isChoose = true
			break
		end
	end
	return isChoose
end
--是否为经典场
function TaskImplPlayCard:isMatchFid(fid)
	local isMatch = false
	for _,v in ipairs(TaskCfg.matchFids) do
		if v==fid then
			isMatch = true
			break
		end
	end
	return isMatch
end
--是否为私人房
function TaskImplPlayCard:isSirenFid(fid)
	local isSiren = false
	for _,v in ipairs(TaskCfg.sirenFids) do
		if v==fid then
			isSiren = true
			break
		end
	end
	return isSiren
end
--
--获取任务信息
--@param fid  任务功能ID  10170001  微信分享  10170002  经典场对局	10170003  经典场赢局
function TaskImplPlayCard:getTaskInfo(fid)
	local taskinfo = {}
	if self:isChooseRoomFid(fid) then --经典场
		taskinfo.eventName = "chooseRoom"
		taskinfo.stateName = "UIChooseRoomState"
		taskinfo.jumpData = {zorder = 3,crType = 2,gameid=wwConfigData.GAME_ID}
		taskinfo.crType = 2
	elseif self:isMatchFid(fid) then --比赛
		taskinfo.eventName = "match"
		taskinfo.stateName = "UIMatchState"
		taskinfo.jumpData = {zorder = 3,crType = 1}
		taskinfo.crType = 1
		--taskinfo.externalData = 13
	elseif self:isSirenFid(fid) then
		taskinfo.eventName = "siren"
		taskinfo.stateName = "UISiRenRoomState"
		taskinfo.jumpData = {zorder = 3,crType = 3}
		taskinfo.crType = 3		
	end
	return taskinfo
end
--任务跳转 跳转至指定的状态机
--@param eventName 跳转到状态机的事件名
--@param stateName 状态机名
--@crType 几个打牌的请求类型 1 经典 2 比赛 3 私人
function TaskImplPlayCard:gotoTask(eventName,stateName,jumpData)
	
	local jumpFilter = JumpFilter:create(1,bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume),1)
	
	jumpFilter:setJumpData(eventName, jumpData)
	FSRegistryManager:currentFSM():addFilter("UIRoot",jumpFilter)
	
	--如果这个state就在堆栈中
	local cor = CorFilter:create(2,FSConst.FilterType.Filter_Resume,1)
	cor:setCorData(function ()
		wwlog( self.__cname..".lua","删除过滤器")
		FSRegistryManager:currentFSM():removeFilter("UIRoot",1)
		
	end)
	FSRegistryManager:currentFSM():addFilter(stateName,jumpFilter)
	
	local curStateName = FSRegistryManager:currentFSM():currentState().mStateName
	while curStateName~="UIRoot" and curStateName~=stateName do
		
		FSRegistryManager:currentFSM():trigger("back")
		curStateName = FSRegistryManager:currentFSM():currentState().mStateName


	end
	

end

--任务执行中 用于任务进度回报
function TaskImplPlayCard:progress(...)
	TaskImplPlayCard.super.progress(self,...)
end
--任务执行完毕 用于标识任务奖励可以领取
function TaskImplPlayCard:finishTask(...)
	TaskImplPlayCard.super.finishTask(self,...)
	--领取奖励
	
	wwlog(self.logTag,"领取任务奖励%d",self.taskId)
--[[	local retData = {}
	for _,v in ipairs(self.awards) do
		table.insert(retData,{fid = v.FID,num = v.magicCount})
	end
	self:playAwardUI(retData)--]]
	
end
--任务关闭 奖励已经领取
function TaskImplPlayCard:endTask(...)
	TaskImplPlayCard.super.endTask(self,...)
end

return TaskImplPlayCard