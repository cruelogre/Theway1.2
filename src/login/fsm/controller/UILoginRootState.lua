local UILoginRootState = class("UILoginRootState",require("packages.statebase.UIState"))

function UILoginRootState:onLoad(lastStateName,param)
	print("UILoginRootState  onLoad")
	UILoginRootState.super.onLoad(self,lastStateName,param)
	self.LoginSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().LOGIN_SCENE)
	self.LoginSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().LOGIN_SCENE)
end
function UILoginRootState:onStateEnter()
	cclog("UILoginRootState onStateEnter")
	if self.LoginSceneController then
		self.LoginSceneController.hasJumpOut = false
	end
	if self.LoginSceneProxy then
		self.LoginSceneProxy:onEnter()
	end
end
function UILoginRootState:onStateExit()
	cclog("UILoginRootState onStateExit")
	if self.LoginSceneController then
		self.LoginSceneController.hasJumpOut = true	
	end
	if self.LoginSceneProxy then
		self.LoginSceneProxy:onExit()
	end
end

return UILoginRootState