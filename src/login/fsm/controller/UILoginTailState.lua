 local UILoginTailState = class("UILoginRootState",require("packages.statebase.UIState"))

import(".HallEvent", "hall.event.")

function UILoginTailState:onLoad(lastStateName,param)
	UILoginTailState.super.onLoad(self,lastStateName,param)

	
	
end
function UILoginTailState:onStateEnter()
	cclog("UILoginRootState onStateEnter")
	
	WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	
end
function UILoginTailState:onStateExit()
	cclog("UILoginRootState onStateExit")	
end

return UILoginTailState