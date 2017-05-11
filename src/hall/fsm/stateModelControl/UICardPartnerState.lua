-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.12.24
-- Last:
-- Content:  牌友状态  
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UICardPartnerState = class("UICardPartnerState",require("packages.statebase.UIState"))

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
function UICardPartnerState:onLoad(lastStateName,param)
	UICardPartnerState.super.onLoad(self,lastStateName,param)
	self:initMatch()
	self:initCard()
end

function UICardPartnerState:onStateEnter()
	UICardPartnerState.super.onStateEnter(self)
	cclog("UICardPartnerState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UICardPartnerState:onStateExit()
	UICardPartnerState.super.onStateExit(self)
	cclog("UICardPartnerState onStateExit")
	self:unbindInnerEventComponentMatch()
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end
--比赛的component 也要初始化
function UICardPartnerState:initMatch()
	-- body
	self._innerEventComponentMatch = {}
	self._innerEventComponentMatch.isBind = false
	self:bindInnerEventComponentMatch()
end

function UICardPartnerState:bindInnerEventComponentMatch()
	-- body
	self:unbindInnerEventComponentMatch()

	if not MatchCfg.innerEventComponent then
		cc.bind(self._innerEventComponentMatch, "event")
		self._innerEventComponentMatch.isBind = true
		MatchCfg.innerEventComponent = self._innerEventComponentMatch
	end
end

function UICardPartnerState:unbindInnerEventComponentMatch()
	-- body
--[[	if self._innerEventComponentMatch.isBind then 
		cc.unbind(self._innerEventComponentMatch, "event")
		self._innerEventComponentMatch.isBind = false
		MatchCfg.innerEventComponent = nil
	end--]]
end



function UICardPartnerState:initCard()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UICardPartnerState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	CardPartnerCfg.innerEventComponent = self._innerEventComponent
end

function UICardPartnerState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		CardPartnerCfg.innerEventComponent = nil
	end
end


return UICardPartnerState