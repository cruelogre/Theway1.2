-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer = class("MatchLayer",require("app.views.uibase.PopWindowBase"))
local RoomTopLayer = import(".ChooseRoomLayer_widget_Top", "hall.mediator.view.widget.")

local HallBottomLayer = import(".HallBottomLayer", "hall.mediator.view.")

local MatchContentLayer = import(".MatchLayer_widget_Content", "hall.mediator.view.widget.")

function MatchLayer:ctor(param)
	self.super.ctor(self)
	self:setOpacity(0)
	self.crType = (param.crType and param.crType or 1)
	
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

function MatchLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        --忽略
    end
end

function MatchLayer:onEnter()
	self.super.onEnter(self)
	print("MatchLayer onEnter")
	
	--蒙板
--[[	local bgMask = display.newSprite("hall/choose/chooserm_bg_mak.png",display.cx,display.cy,{capInsets = {x = 768, y = 475, width = 403, height = 249}})
	FixUIUtils.stretchUI(bgMask)
	FixUIUtils.setRootNodewithFIXED(bgMask)
	self:addChild(bgMask, 0)
	bgMask:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE_MINUS_SRC_ALPHA))
	
	local topLayer = RoomTopLayer:create()
	local panelbg = topLayer:getChildByName("Layer"):getChildByName("Panel_bg")
	local title = ccui.Helper:seekWidgetByName(panelbg,"Image_title")
	if title and title ~=panelbg then
		title:ignoreContentAdaptWithSize(true)
		title:loadTexture("hall/match/match_rm_title.png")
	end
	local fStart = ccui.Helper:seekWidgetByName(panelbg,"Button_fStart")
	if fStart and fStart ~=panelbg then
		fStart:setVisible(false)
	end
	--Button_fStart
	
	self:addChild(topLayer, 2)
	
	self:addChild(HallBottomLayer:create(), 2)--]]
	local rmContentView = MatchContentLayer:create(self.crType,{width = 1740,height = 660})
	rmContentView:setPosition(display.cx,display.cy+6)
	self:addChild(rmContentView, 1)
	
	
end

function MatchLayer:onExit()
	print("MatchLayer onExit")
	self:removeAllChildren()
	self.super.onExit(self)
	
end


return MatchLayer