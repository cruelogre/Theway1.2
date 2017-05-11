local UIMatchState = class("UIMatchState",require("packages.statebase.UIState"))
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

function UIMatchState:onLoad(lastStateName,param)
	self:init()
	-- wwdump(param, "UIMatchState:onLoad:param")
	if param.enterMatchId then --需要进入就打开的比赛ID
		MatchCfg.enterMatchId = param.enterMatchId
	end
	UIMatchState.super.onLoad(self,lastStateName,param)
	local Image_bg = ccui.ImageView:create()
	--Image_bg:ignoreContentAdaptWithSize(false)
	Image_bg:loadTexture("hall/hallbg.jpg",0)
	Image_bg:setTouchEnabled(true);
	Image_bg:setName("Image_bg")
	Image_bg:setCascadeColorEnabled(true)
	Image_bg:setCascadeOpacityEnabled(true)
    Image_bg:setPosition(display.center)
    Image_bg:setScaleY(ww.scaleY)
    self.rootNode:addChild(Image_bg,self.localZorder-2)
	
	local RoomTopLayer = import(".ChooseRoomLayer_widget_Top", "hall.mediator.view.widget.")

	local HallBottomLayer = import(".HallBottomLayer", "hall.mediator.view.")

	local bgMask = display.newSprite("hall/choose/chooserm_bg_mak.png",display.cx,display.cy,{capInsets = {x = 768, y = 475, width = 403, height = 249}})
	FixUIUtils.stretchUI(bgMask)
	FixUIUtils.setRootNodewithFIXED(bgMask)
	self.rootNode:addChild(bgMask, self.localZorder-1)
	--bgMask:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE_MINUS_SRC_ALPHA))
	
	local topLayer = RoomTopLayer:create()
	topLayer:setPosition(cc.p(display.cx,display.top - topLayer:getContentSize().height/2))
	local panelbg = topLayer:getChildByName("Node"):getChildByName("Panel_bg")
	local title = ccui.Helper:seekWidgetByName(panelbg,"Image_title")
	if title and title ~=panelbg then
		title:ignoreContentAdaptWithSize(true)
		title:loadTexture("hall/match/match_rm_title.png")
	end
	local fStart = panelbg:getChildByName("FileNode_fStart")
	if fStart and fStart ~=panelbg then
		fStart:setVisible(false)
	end
	--Button_fStart
	
	self.rootNode:addChild(topLayer, self.localZorder+1)
	
	self.rootNode:addChild(HallBottomLayer:create(), self.localZorder+2)
	
	UmengManager:eventCount("HallMatch")
end


function UIMatchState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIMatchState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	if not MatchCfg.innerEventComponent then
		cc.bind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = true
		MatchCfg.innerEventComponent = self._innerEventComponent
	end
end

function UIMatchState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		MatchCfg.innerEventComponent = nil
	end
end

function UIMatchState:onStateEnter()
	cclog("UIMatchState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UIMatchState:onStateExit()
	cclog("UIMatchState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIMatchState