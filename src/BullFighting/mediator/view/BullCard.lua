-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  牌
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullCard = class("BullCard",cc.Node)

function BullCard:clone()
	-- body
	local node = BullCard:create({color = self.color,val = self.val})
	node.mState = self.mState
	return node
end

function BullCard:ctor( data )
	-- body
	self:init(data)
end

function BullCard:init( data )
	-- body
	local node = require("csb.bullfighting.niuCard"):create()

	self.rootCard = node["root"]
	self.aniCard = node["animation"]
	self.rootCard:runAction(self.aniCard)
  	self:addChild(self.rootCard)

  	self:setCard(data.val,data.color)
	self.mState = Card_State.State_None
end

function BullCard:setCard( val,color )
	-- body
	self.color = color --花色
	self.val = val --牌值

	self.bullVal = self.val --换成斗牛计算的牌值
	if self.bullVal > BullCardValue.R10 then
		self.bullVal = BullCardValue.R10
	end

	--背面
	self.backImg = self.rootCard:getChildByName("back")
	self.backImg:setVisible(false)

	--正面
	self.faceImg = self.rootCard:getChildByName("face")
	self.Image_shu1 = self.faceImg:getChildByName("Image_shu1") --数1
	self.Image_shu2 = self.faceImg:getChildByName("Image_shu2") --数2
	self.Image_colorS1 = self.faceImg:getChildByName("Image_colorS1") --小花色
	self.Image_colorS2 = self.faceImg:getChildByName("Image_colorS2") --小花色
	self.Image_colorB = self.faceImg:getChildByName("Image_colorB") --大花色

	self.Image_shu1:ignoreContentAdaptWithSize(true)
	self.Image_shu2:ignoreContentAdaptWithSize(true)
	self.Image_colorS1:ignoreContentAdaptWithSize(true)
	self.Image_colorS2:ignoreContentAdaptWithSize(true)
	self.Image_colorB:ignoreContentAdaptWithSize(true)

	--牌值
	if self.color == BullFollowType.TYPE_F or self.color == BullFollowType.TYPE_H then --红桃 方块
		self.Image_shu1:loadTexture(string.format("red_%s.png",self.val),UI_TEX_TYPE_PLIST)
		self.Image_shu2:loadTexture(string.format("red_%s.png",self.val),UI_TEX_TYPE_PLIST)
		if self.color == BullFollowType.TYPE_F then --方块
			self.Image_colorS1:loadTexture("fang_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorS2:loadTexture("fang_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorB:loadTexture("fang_b.png",UI_TEX_TYPE_PLIST)
		else
			self.Image_colorS1:loadTexture("hong_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorS2:loadTexture("hong_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorB:loadTexture("hong_b.png",UI_TEX_TYPE_PLIST)
		end
	else
		self.Image_shu1:loadTexture(string.format("black_%s.png",self.val),UI_TEX_TYPE_PLIST)
		self.Image_shu2:loadTexture(string.format("black_%s.png",self.val),UI_TEX_TYPE_PLIST)
		if self.color == BullFollowType.TYPE_M then --梅花
			self.Image_colorS1:loadTexture("mei_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorS2:loadTexture("mei_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorB:loadTexture("mei_b.png",UI_TEX_TYPE_PLIST)
		else
			self.Image_colorS1:loadTexture("hei_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorS2:loadTexture("hei_s.png",UI_TEX_TYPE_PLIST)
			self.Image_colorB:loadTexture("hei_b.png",UI_TEX_TYPE_PLIST)
		end
	end
	
	--右下角大花色
	if self.val > BullCardValue.R10 then
		self.Image_shu2:setVisible(false)
		self.Image_colorS2:setVisible(false)

		if self.color == BullFollowType.TYPE_F or self.color == BullFollowType.TYPE_H then --红桃 方块
			self.Image_colorB:loadTexture(string.format("red_%d_hua.png",self.val),UI_TEX_TYPE_PLIST)
		else
			self.Image_colorB:loadTexture(string.format("black_%d_hua.png",self.val),UI_TEX_TYPE_PLIST)
		end
	end
end

function BullCard:overTurn( callBack )
	-- body
	self.aniCard:play("animation0",false)
	self.aniCard:setAnimationEndCallFunc1("animation0",function ( ... )
		-- body
		if callBack then
			callBack()
		end
	end)
end

function BullCard:setGray( ... )
	-- body
	self.faceImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.numImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.sImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.bImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
end

function BullCard:reSetGray( ... )
	-- body
	self.faceImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.numImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.sImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.bImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
end

--开始发牌背面在上
function BullCard:beginDeal( ... )
	-- body
	self.backImg:setVisible(true)
	self.faceImg:setVisible(false)
end
--发牌一会后正面面在上
function BullCard:dalayDeal( ... )
	-- body
	self.backImg:setVisible(false)
	self.faceImg:setVisible(true)
end

function BullCard:isContainsTouch( touch )
	-- body
	--打出去的牌不响应触摸事件
	if Card_State.State_Discard == self.mState then
		return false
	end
	local point = touch:getLocation()
	--转化成节点坐标系
	local nodePoint = self:convertToNodeSpace(point)
	local rect = self.faceImg:getBoundingBox()
	if cc.rectContainsPoint(rect, nodePoint) then
		return true
    end

	return false
end

return BullCard