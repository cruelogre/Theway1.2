local UIUserInfoState = class("UIUserInfoState",require("packages.statebase.UIState"))
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
function UIUserInfoState:onLoad(lastStateName,param)
	self:init()
	UIUserInfoState.super.onLoad(self,lastStateName,param)	
	
	UmengManager:eventCount("HallHead")
end


function UIUserInfoState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIUserInfoState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	UserInfoCfg.innerEventComponent = self._innerEventComponent
end

function UIUserInfoState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		UserInfoCfg.innerEventComponent = nil
	end
end

function UIUserInfoState:onStateEnter()
	cclog("UIUserInfoState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	if self.param and isLuaNodeValid(self.viewNode) and self.viewNode["setEnterAction"] then
		self.viewNode:setEnterAction(self.param.openType)
	end
end
function UIUserInfoState:onStateExit()
	cclog("UIUserInfoState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIUserInfoState