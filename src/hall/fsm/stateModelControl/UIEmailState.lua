local UIEmailState = class("UIEmailState",require("packages.statebase.UIState"))
local EamilCfg = require("hall.mediator.cfg.EmailCfg")
function UIEmailState:onLoad(lastStateName,param)
	self:init()
	UIEmailState.super.onLoad(self,lastStateName,param)
	
	UmengManager:eventCount("HallMSG")
end


function UIEmailState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIEmailState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	EamilCfg.innerEventComponent = self._innerEventComponent
end

function UIEmailState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		EamilCfg.innerEventComponent = nil
	end
end

function UIEmailState:onStateEnter()
	cclog("UIEmailState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UIEmailState:onStateExit()
	cclog("UIEmailState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIEmailState