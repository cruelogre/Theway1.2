local UIChooseRoomState = class("UIChooseRoomState",require("packages.statebase.UIState"))
local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")



function UIChooseRoomState:onLoad(lastStateName,param)
	self:init()
	UIChooseRoomState.super.onLoad(self,lastStateName,param)
	local Image_bg = ccui.ImageView:create()
	--Image_bg:ignoreContentAdaptWithSize(false)
	Image_bg:loadTexture("hall/hallbg.jpg",0)
	Image_bg:setTouchEnabled(true);
	Image_bg:setName("Image_bg")
	Image_bg:setCascadeColorEnabled(true)
	Image_bg:setCascadeOpacityEnabled(true)
    Image_bg:setPosition(display.center)
    Image_bg:setScaleY(ww.scaleY)
    self.rootNode:addChild(Image_bg)

    dump(param, "选择房间状态机")
	
	local RoomTopLayer = import(".ChooseRoomLayer_widget_Top", "hall.mediator.view.widget.")

	local HallBottomLayer = import(".HallBottomLayer", "hall.mediator.view.")

	local bgMask = display.newSprite("hall/choose/chooserm_bg_mak.png",display.cx,display.cy,{capInsets = {x = 768, y = 475, width = 403, height = 249}})
	FixUIUtils.stretchUI(bgMask)
	FixUIUtils.setRootNodewithFIXED(bgMask)
	self.rootNode:addChild(bgMask, 0)
	bgMask:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE_MINUS_SRC_ALPHA))
	self.topLayer = RoomTopLayer:create(param.crType, param.gameid)
	self.topLayer:playButtonAnim()
	print("----------display.top------------",display.top)
	self.topLayer:setPosition(cc.p(display.cx,display.top - self.topLayer:getContentSize().height/2))
	self.rootNode:addChild(self.topLayer, self.localZorder+1)
	
	self.rootNode:addChild(HallBottomLayer:create(), self.localZorder+2)
	
	UmengManager:eventCount("HallClassic")
end


function UIChooseRoomState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIChooseRoomState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	ChooseRoomCfg.innerEventComponent = self._innerEventComponent
end

function UIChooseRoomState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		ChooseRoomCfg.innerEventComponent = nil
	end
end

function UIChooseRoomState:onStateEnter()
	UIChooseRoomState.super.onStateEnter(self)
	cclog("UIChooseRoomState onStateEnter")
	
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	if self.param and isLuaNodeValid(self.topLayer) then
		self.topLayer:setEnterAction(self.param.fStart)
	end
end
function UIChooseRoomState:onStateExit()
	UIChooseRoomState.super.onStateEnter(self)
	cclog("UIChooseRoomState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIChooseRoomState