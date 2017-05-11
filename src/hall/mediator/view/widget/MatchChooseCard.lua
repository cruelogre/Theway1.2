-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.13
-- Last: 
-- Content:  比赛界面选项卡管理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchChooseCard = class("MatchChooseCard")
function MatchChooseCard:ctor(touchView,changeInfo)
	self:init(touchView,changeInfo)
end
function MatchChooseCard:init(touchView,changeInfo)
	self._selected = false
	self._touchView = touchView
	self._changeInfo = changeInfo
end


function MatchChooseCard:bindView(viewparent,viewContent)
	
	self._viewparent = viewparent
	self._viewContent = viewContent
	self._viewContent:retain()
end
function MatchChooseCard:addTouchEventListener(...)
	self._touchView:addTouchEventListener(...)
end

function MatchChooseCard:getPosition()
	return cc.p(self._touchView:getPositionX(),self._touchView:getPositionY())
end
function MatchChooseCard:changeChooseState(selected)
	self._selected = selected
	
	--change text color
	if self._selected then
		--self.img:loadTexture(self._normalPath)
		
		if self._viewContent and self._viewparent and not self._viewContent:getParent() then
		
			self._viewparent:addChild(self._viewContent)
			self._viewContent:active()
			--self._view:setLocalZOrder(1)
		end
	else
		--self.img:loadTexture(self._highlightPath)
		
		if self._viewContent and self._viewContent:getParent() then
			
			self._viewContent:removeFromParent(true)
		end
	end
end

function MatchChooseCard:clear()
	self:changeChooseState(false)
	if isLuaNodeValid(self._viewContent) then
		self._viewContent:removeFromParent(true)
		self._viewContent:release()
	end
	self._viewContent = nil
	removeAll(self._changeInfo)
	self._viewparent = nil
	self._touchView = nil
end
return MatchChooseCard