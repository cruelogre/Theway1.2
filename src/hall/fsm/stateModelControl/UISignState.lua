local UISignState = class("UISignState",require("packages.statebase.UIState"))
local SignCfg = require("hall.mediator.cfg.SignCfg")
function UISignState:onLoad(lastStateName,param)
	self:init()
	UISignState.super.onLoad(self,lastStateName,param)

	UmengManager:eventCount("HallSignin")
end


function UISignState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UISignState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	SignCfg.innerEventComponent = self._innerEventComponent
end

function UISignState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		SignCfg.innerEventComponent = nil
	end
end

function UISignState:onStateEnter()
	cclog("UISignState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end

--重新进入 在上层状态机被弹出时，这个调用 不是走加载流程
function UISignState:onStateResume()
	cclog("UISignState onStateResume")
	if isLuaNodeValid(self.viewNode) and self.viewNode.refreshTopInfo then
		self.viewNode:refreshTopInfo()
	end
end

function UISignState:onStateExit()
	cclog("UISignState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UISignState