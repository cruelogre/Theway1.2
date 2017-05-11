-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  选项卡组管理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchChooseCardGroup = class("MatchChooseCardGroup")
function MatchChooseCardGroup:ctor(...)
	self:init()
	self:initWithCard(...)
end
function MatchChooseCardGroup:init()
	self._cards = {}
	
end
--设置标签视图 用于切换的时候的移动
function MatchChooseCardGroup:setTagView(view)
	self.tagView = view
	
end
function MatchChooseCardGroup:initWithCard(...)
	if args then
		for _,v in pairs(...) do
			self:addCard(v)
		end
	end
	
end

function MatchChooseCardGroup:addCard(card)
	table.insert(self._cards,#self._cards+1,card)
	
	card:changeChooseState(false)
	card:addTouchEventListener(handler(self,self.touchListener))
	
end
function MatchChooseCardGroup:chooseCard(index)
	local destX = self.tagView:getPositionX()
	if index>0 or index<=#self._cards then
		for i=1,#self._cards do
			if i==index then
				self._cards[i]:changeChooseState(true)
				self:changeTextInfo(self._cards[i]._touchView,self._cards[i]._changeInfo,true)
				destX = self._cards[i]:getPosition().x
				self.tagView:stopAllActions()
				self.tagView:runAction(cc.MoveTo:create(0.05,cc.p(destX,self.tagView:getPositionY())))
				
			else
				self._cards[i]:changeChooseState(false)
				self:changeTextInfo(self._cards[i]._touchView,self._cards[i]._changeInfo,false)
			end
		end
	end
end
function MatchChooseCardGroup:touchListener(ref,eventType)
	if not ref then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local destX = self.tagView:getPositionX()
		for _,v in pairs(self._cards) do
			if v._touchView==ref then
				v:changeChooseState(true)
				self:changeTextInfo(v._touchView,v._changeInfo,true)
				destX = v:getPosition().x
				self.tagView:stopAllActions()
				self.tagView:runAction(cc.MoveTo:create(0.1,cc.p(destX,self.tagView:getPositionY())))
			else
				v:changeChooseState(false)
				self:changeTextInfo(v._touchView,v._changeInfo,false)
			end
		end
	end
end


function MatchChooseCardGroup:changeTextInfo(view,changeInfo,isOn)
	if changeInfo then
		local textView = ccui.Helper:seekWidgetByName(view,changeInfo.textName)
		textView = tolua.cast(textView,"ccui.Text")
		if isLuaNodeValid(textView) then
			textView:setFontSize(isOn and changeInfo.onTag.size or changeInfo.offTag.size)
			textView:setTextColor(isOn and changeInfo.onTag.color or changeInfo.offTag.color)
		end
	end
end
function MatchChooseCardGroup:removeCard(index)
	if index<=0 or index>#self._cards then
		print("invalide index:%d",index)
		return
	end
	local card = self._cards[index]
	card:clear()
	table.remove(self._cards,index)
	card = nil
	
end
return MatchChooseCardGroup