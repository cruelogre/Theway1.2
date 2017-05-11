local UIUpdateAssetState = class("UIUpdateAssetState",require("packages.statebase.UIState"))

function UIUpdateAssetState:onLoad(lastStateName,param)
	UIUpdateAssetState.super.onLoad(self,lastStateName,param)

	
end
function UIUpdateAssetState:onStateEnter()
	cclog("UIUpdateAssetState onStateEnter")
	-- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
	
end
function UIUpdateAssetState:onStateExit()
	cclog("UIUpdateAssetState onStateExit")
	
	
end

return UIUpdateAssetState