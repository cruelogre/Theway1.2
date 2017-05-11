-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  取消托管层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local CancelTSpLayer = class("CancelTSpLayer",cc.LayerColor)

function CancelTSpLayer:ctor( ... )
	-- body
	self:init()
end

function CancelTSpLayer:init( ... )
	-- body
    self.logTag = "CancelTSpLayer.lua"

	self:setOpacity(0)
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    self.canCancle = true
end

----------------------------------------------------
--触摸事件
----------------------------------------------------
function CancelTSpLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        playSoundEffect("sound/effect/anniu")
    	if self.canCancle then
      		GameManageFactory:getCurGameManage():substitute(1) --取消
            GameManageFactory:getCurGameManage():closePlayerInfo()
      	end
    end
end

return CancelTSpLayer