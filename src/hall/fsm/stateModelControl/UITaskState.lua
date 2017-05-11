-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.11.22
-- Last:
-- Content:  任务状态  
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UITaskState = class("UITaskState",require("packages.statebase.UIState"))
local TaskCfg = require("hall.mediator.cfg.TaskCfg")


function UITaskState:onLoad(lastStateName,param)
	self:initEvent()
	UITaskState.super.onLoad(self,lastStateName,param)
	wwlog(self.logTag,"设置状态机 onLoad")

	UmengManager:eventCount("HallTask")
end


function UITaskState:initEvent()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UITaskState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	TaskCfg.innerEventComponent = self._innerEventComponent
end

function UITaskState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		TaskCfg.innerEventComponent = nil
	end
end

function UITaskState:onStateEnter()
	cclog("UITaskState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UITaskState:onStateExit()
	cclog("UITaskState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UITaskState