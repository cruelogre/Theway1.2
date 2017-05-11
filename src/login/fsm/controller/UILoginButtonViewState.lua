local UILoginButtonViewState = class("UILoginButtonViewState",require("packages.statebase.UIState"))

function UILoginButtonViewState:onLoad(lastStateName,param)
	UILoginButtonViewState.super.onLoad(self,lastStateName,param)
--[[	local sp = cc.Sprite:create("login/test/goodsbluebg.png")
	
	sp:setPosition(cc.p(100,100))
	sp:addTo(self.rootNode)--]]
	
end
function UILoginButtonViewState:onStateEnter()
	cclog("UILoginButtonViewState onStateEnter")
	-- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
--[[	local sp = require("csb.login.LoginButtonView"):create().root
	sp:addTo(self.rootNode)
	
	--FixUIUtils.setFixScale(sp)
	--FixUIUtils.fixScene(sp)
	local x = sp:getChildByName("Button_1")
	dump(x:getPosition())
	FixUIUtils.fixUI(sp)
	dump(x:getPosition())--]]
	
end
function UILoginButtonViewState:onStateExit()
	cclog("UILoginButtonViewState onStateExit")
	
	
end

return UILoginButtonViewState