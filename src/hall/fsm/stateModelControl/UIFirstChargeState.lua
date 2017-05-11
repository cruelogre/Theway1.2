-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.11.22
-- Last:
-- Content:  任务状态  
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIFirstChargeState = class("UIFirstChargeState",require("packages.statebase.UIState"))
local FirstChargeCfg = require("hall.mediator.cfg.FirstChargeCfg")


function UIFirstChargeState:onLoad(lastStateName,param)
	self:initEvent()
	UIFirstChargeState.super.onLoad(self,lastStateName,param)
	
	

	UmengManager:eventCount("HallFirstCharge")
end


function UIFirstChargeState:initEvent()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIFirstChargeState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	FirstChargeCfg.innerEventComponent = self._innerEventComponent
end

function UIFirstChargeState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		FirstChargeCfg.innerEventComponent = nil
	end
end

function UIFirstChargeState:onStateEnter()
	cclog("UIFirstChargeState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UIFirstChargeState:onStateExit()
	cclog("UIFirstChargeState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIFirstChargeState