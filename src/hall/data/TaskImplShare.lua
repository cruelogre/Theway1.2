local TaskImplShare = class("TaskImplShare",import(".ITask","hall.data."))

local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge"):create()

function TaskImplShare:ctor()
	TaskImplShare.super.ctor(self)
	
	-- 任务类型
	self.taskType = TaskCfg.TaskType.TASK_SHARE
end

function TaskImplShare:init(param)
	TaskImplShare.super.init(self,param)
	if param and param.awards then
		self.awards = param.awards
	end
	self.taskId = param.taskId
	if param and param.fid then
		self.pfid = self:getShareType(param.fid)
		 
	end
end
function TaskImplShare:getShareType(fid)
	local shareId = 2
	if self:isFriendFid(fid) then
		shareId = 2
	elseif self:isCircleFid(fid) then
		shareId = 1
	end
	return shareId
end

--是否为经典场
function TaskImplShare:isFriendFid(fid)
	local isMatch = false
	for _,v in ipairs(TaskCfg.friendFids) do
		if v==fid then
			isMatch = true
			break
		end
	end
	return isMatch
end
--是否为私人房
function TaskImplShare:isCircleFid(fid)
	local isSiren = false
	for _,v in ipairs(TaskCfg.circleFids) do
		if v==fid then
			isSiren = true
			break
		end
	end
	return isSiren
end

--任务开始 用于进行任务的操作
function TaskImplShare:startTask(...)
	
	if TaskImplShare.super.startTask(self,...) then
		--分享
		wwlog(self.logTag,"开始执行微信分享任务")
		if self.pfid then
			LuaWxShareNativeBridge:callNativeShareByUrl(
				self.pfid,
				wwConst.CLIENTNAME,
				i18n:get("str_common", "comm_ShareContent"),
				wwURLConfig.SHARE_DOWNLOAD_URL, 
				"aa",handler(self,self.shareCB))
		end

	end
	return true
end
function TaskImplShare:shareCB(result)
	wwlog(self.logTag,"分享返回 %s",tostring(result))
	if result=="yes" then
		wwlog(self.logTag,"发送本地分享消息 %s",tostring(self.taskId))
		WWFacade:dispatchCustomEvent(import(".TaskCfg","hall.mediator.cfg.").InnerEvents.TASK_EVENT_SHARESUCCESS,self.taskId,self.pfid)
	end
	
end
--任务执行中 用于任务进度回报
function TaskImplShare:progress(...)
	TaskImplShare.super.progress(self,...)
end
--任务执行完毕 用于标识任务奖励可以领取
function TaskImplShare:finishTask(...)
	TaskImplShare.super.finishTask(self,...)
--[[	local retData = {}
	for _,v in ipairs(self.awards) do
		table.insert(retData,{fid = v.FID,num = v.magicCount})
	end
	self:playAwardUI(retData)--]]
	
end
--任务关闭 奖励已经领取
function TaskImplShare:endTask(...)
	TaskImplShare.super.endTask(self,...)
end

return TaskImplShare