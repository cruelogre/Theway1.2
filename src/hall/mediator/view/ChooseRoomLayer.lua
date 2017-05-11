-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.26
-- Last: 
-- Content:  房间选择界面
-- Modify:	
--			2016.12.07 添加上下触摸遮罩层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChooseRoomLayer = class("ChooseRoomLayer",require("app.views.uibase.PopWindowBase"))
local RoomTopLayer = import(".ChooseRoomLayer_widget_Top", "hall.mediator.view.widget.")

local HallBottomLayer = import(".HallBottomLayer", "hall.mediator.view.")

local ChooseRMContentLayer = import(".ChooseRoomLayer_widget_Content", "hall.mediator.view.widget.")

function ChooseRoomLayer:ctor(param)
	self.super.ctor(self)
	self:setOpacity(0)
	self.crType = (param.crType and param.crType or 1)
	if param.gameid and isdigit(param.gameid) then
		self.gameid = param.gameid
	else
		self.gameid = wwConfigData.GAMELOGICPARA.GUANDAN.GAME_ID
	end
	

	self.playType = param.playType
	
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
	
	self:setDisCallback(function ( ... )
		-- body
		
		FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
	end)
end

function ChooseRoomLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        --忽略
		--self:close()
    end
end
function ChooseRoomLayer:onEnter()
	self.super.onEnter(self)
	print("ChooseRoomLayer onEnter")
	
	--蒙板
--[[	local bgMask = display.newSprite("hall/choose/chooserm_bg_mak.png",display.cx,display.cy,{capInsets = {x = 768, y = 475, width = 403, height = 249}})
	FixUIUtils.stretchUI(bgMask)
	FixUIUtils.setRootNodewithFIXED(bgMask)
	self:addChild(bgMask, 0)
	bgMask:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE_MINUS_SRC_ALPHA))
	self:addChild(RoomTopLayer:create(), 2)
	
	self:addChild(HallBottomLayer:create(), 2)--]]
	local contentHeight = 640
	
	local topShade = self:createShade(true)
	topShade:setPosition(display.cx, display.cy+contentHeight/2)
	self:addChild(topShade, 2)
	local bottomShade = self:createShade(false)
	bottomShade:setPosition(display.cx, display.cy-contentHeight/2)
	self:addChild(bottomShade, 2)
	
	local rmContentView = ChooseRMContentLayer:create(self.crType, self.gameid, self.playType, {width = 1700,height = contentHeight})
	rmContentView:setPosition(display.cx,display.cy)
	self:addChild(rmContentView, 1)
	
	
end

--创建上下遮罩
--@param direction true 表示上 false 表示下
function ChooseRoomLayer:createShade(direction)

	local shade = ccui.Layout:create()
	shade:ignoreContentAdaptWithSize(false)
	shade:setClippingEnabled(false)
	shade:setTouchEnabled(true)
	shade:setLayoutComponentEnabled(true)
	shade:setCascadeColorEnabled(true)
	shade:setCascadeOpacityEnabled(true)

	shade:setSize(cc.size(1700,300))

	shade:setAnchorPoint(0.5, direction and 0.0 or 1.0)
	return shade
end
function ChooseRoomLayer:onExit()
	print("ChooseRoomLayer onExit")
	--LoadingManager:endLoading()
	self:removeAllChildren()
	ChooseRoomLayer.super.onExit(self)
	
end


return ChooseRoomLayer