local UISettingState = class("UISettingState",require("packages.statebase.UIState"))
local SettingCfg = require("hall.mediator.cfg.SettingCfg")


function UISettingState:onLoad(lastStateName,param)
	UISettingState.super.onLoad(self,lastStateName,param)
	wwlog(self.logTag,"设置状态机 onLoad")
	self:initEvent()

	UmengManager:eventCount("HallSet")
end


function UISettingState:initEvent()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UISettingState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	SettingCfg.innerEventComponent = self._innerEventComponent
end

function UISettingState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		SettingCfg.innerEventComponent = nil
	end
end

function UISettingState:onStateEnter()
	cclog("UISettingState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UISettingState:onStateExit()
	cclog("UISettingState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UISettingState