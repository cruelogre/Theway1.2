-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.11.22
-- Last:
-- Content:  任务状态  
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIActivityState = class("UIActivityState",require("packages.statebase.UIState"))


function UIActivityState:onLoad(lastStateName,param)
	UIActivityState.super.onLoad(self,lastStateName,param)
	wwlog(self.logTag,"活动状态机 onLoad")
	
	UmengManager:eventCount("HallActity")
end

function UIActivityState:onStateEnter()
	cclog("UIActivityState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
--[[	local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
	SocialContactProxy:requestAllCardPartner()--]]
end
function UIActivityState:onStateExit()
	cclog("UIActivityState onStateExit")
	
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIActivityState