-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  背景层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullBackGrand = class("BullBackGrand",cc.Layer)

function BullBackGrand:ctor()
	-- body
	self:init()
end

function BullBackGrand:init()
	-- body
	local bgUi = require("csb.bullfighting.PlayBGLayer"):create()
	if not bgUi then
		return
	end
	local root = bgUi["root"]
	root:setScaleY(ww.scaleY)
	self:addChild(root)

	self.Image_bg_house = root:getChildByName("Image_bg_house")
	self.Image_bg_desk = root:getChildByName("Image_bg_desk")
	local littlekuang = root:getChildByName("littlekuang")
	self.littlekuang = littlekuang:clone()
	self.count = self.littlekuang:getChildByName("count")
	self.littlekuang:setPosition(cc.p(littlekuang:getPositionX(),screenSize.height - littlekuang:getContentSize().height/2))
	self:addChild(self.littlekuang)
	littlekuang:setVisible(false)
end

function BullBackGrand:setScore( score )
	-- body
	self.count:setString(score.."")
end

return BullBackGrand