-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  牌
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Card = class("Card",cc.Node)

function cc.exports.getNumImgName(color, val)
	if val < tonumber(CARD_VALUE.R2) or val > tonumber(CARD_VALUE.R_WB) then --越界
		return ""
	end

	local numSpriteName = false
	if color == tonumber(FOLLOW_TYPE.TYPE_B) or color == tonumber(FOLLOW_TYPE.TYPE_M) then                --黑桃和梅花
		numSpriteName = string.format("b_%s.png",val)
	elseif color == tonumber(FOLLOW_TYPE.TYPE_F) or color == tonumber(FOLLOW_TYPE.TYPE_H) then            --方块和红桃
		numSpriteName = string.format("r_%s.png",val)
	elseif color == tonumber(FOLLOW_TYPE.TYPE_L) then
		numSpriteName = string.format("r_%s.png",val)
	end

	return numSpriteName
end

function cc.exports.getSImgName( color )
	-- body
	local strName = false
	if color == tonumber(FOLLOW_TYPE.TYPE_B) then
		strName = "heitao.png"
	elseif color == tonumber(FOLLOW_TYPE.TYPE_H) then
		strName = "hongtao.png"
	elseif color == tonumber(FOLLOW_TYPE.TYPE_M) then
		strName = "meihua.png"
	elseif color == tonumber(FOLLOW_TYPE.TYPE_F) then
		strName = "fangkuai.png"
	elseif color == tonumber(FOLLOW_TYPE.TYPE_L) then
		strName = "laizi.png"
	end

	return strName
end

function cc.exports.getBImgName( color,val )
	-- body
	local strName = false
	if (val ~= tonumber(CARD_VALUE.RJ) and val ~= tonumber(CARD_VALUE.RQ) and val ~= tonumber(CARD_VALUE.RK)) then
		if color == tonumber(FOLLOW_TYPE.TYPE_B) then
			strName = "heitao.png"
		elseif color == tonumber(FOLLOW_TYPE.TYPE_H) then
			strName = "hongtao.png"
		elseif color == tonumber(FOLLOW_TYPE.TYPE_M) then
			strName = "meihua.png"
		elseif color == tonumber(FOLLOW_TYPE.TYPE_F) then
			strName = "fangkuai.png"
		elseif color == tonumber(FOLLOW_TYPE.TYPE_L) then
			strName = "laizi.png"
		end
	else
		--J Q K的时候 花色有变化
		if val == tonumber(CARD_VALUE.RJ) then
			if color == tonumber(FOLLOW_TYPE.TYPE_H) or color == tonumber(FOLLOW_TYPE.TYPE_F) then
				strName = "r_10_hua.png"
			else
				strName = "b_10_hua.png"
			end
		elseif val == tonumber(CARD_VALUE.RQ) then
			if color == tonumber(FOLLOW_TYPE.TYPE_H) or color == tonumber(FOLLOW_TYPE.TYPE_F) then
				strName = "r_11_hua.png"
			else
				strName = "b_11_hua.png"
			end
		elseif val == tonumber(CARD_VALUE.RK) then
			if color == tonumber(FOLLOW_TYPE.TYPE_H) or color == tonumber(FOLLOW_TYPE.TYPE_F) then
				strName = "r_12_hua.png"
			else
				strName = "b_12_hua.png"
			end
		end
	end

	return strName
end

function Card:clone()
	-- body
	local node = Card:create({color = self.color,val = self.val})
	node.col = self.col
	node.row = self.row
	node.mState = self.mState
	node.allLight = self.allLight
	node.isLaizi = self.isLaizi
	return node
end

function Card:ctor( data )
	-- body
	cc.SpriteFrameCache:getInstance():addSpriteFrames("guandan/poker.plist")
	self:init(data)
end

function Card:init( data )
	-- body
	local node = require("csb.guandan.cardNode"):create()
	if not node then
		return
	end
	local root = node["root"]
  	self:addChild(root)
	self.color = data.color
	self.val = data.val

	--癞子
	if self.val == GameModel.nowCardVal and self.color == tonumber(FOLLOW_TYPE.TYPE_H) then
		self.isLaizi = data.val
	end

	--背面
	self.backImg = root:getChildByName("black")
	self.backImg:setVisible(false)

	--正面
	self.faceImg = root:getChildByName("face")
	self.faceImg:setCascadeOpacityEnabled(true)
	self.numImg = self.faceImg:getChildByName("num") --数
	self.sImg = self.faceImg:getChildByName("sImg") --花色
	self.bImg = self.faceImg:getChildByName("bImg") --大花色
	self.numImg:ignoreContentAdaptWithSize(true)
	self.sImg:ignoreContentAdaptWithSize(true)
	self.bImg:ignoreContentAdaptWithSize(true)

	--牌值
	if self.val >= tonumber(CARD_VALUE.R_WA) then
		--王牌
		self.numImg:setVisible(false)
		self.sImg:setVisible(false)
		self.bImg:loadTexture(string.format("%s.png",self.val),UI_TEX_TYPE_PLIST)
		self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.faceImg:getContentSize().height/2))
	else
		--普通牌， 左上角点数和花色，右下角大花色
		if self.isLaizi then
			self.numImg:loadTexture(getNumImgName(FOLLOW_TYPE.TYPE_L, self.isLaizi),UI_TEX_TYPE_PLIST)
			self.sImg:loadTexture(getSImgName(FOLLOW_TYPE.TYPE_L),UI_TEX_TYPE_PLIST)
			self.bImg:loadTexture(getSImgName(FOLLOW_TYPE.TYPE_L),UI_TEX_TYPE_PLIST)
			self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.bImg:getContentSize().height*3/4))
		else
			self.numImg:loadTexture(getNumImgName(self.color, self.val),UI_TEX_TYPE_PLIST)
			self.sImg:loadTexture(getSImgName(self.color),UI_TEX_TYPE_PLIST)
			self.bImg:loadTexture(getBImgName(self.color, self.val),UI_TEX_TYPE_PLIST)

			--右下角大花色
			if self.val == tonumber(CARD_VALUE.RJ) or self.val == tonumber(CARD_VALUE.RQ) or self.val == tonumber(CARD_VALUE.RK) then
				self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.faceImg:getContentSize().height/2))
			else
				self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.bImg:getContentSize().height*3/4))
			end
		end
	end

	self.mState = Card_State.State_None
end

--s设置打出去状态
function Card:setPlayState( ... )
	-- body
	self.numImg:setScale(1.5)
	self.sImg:setVisible(false)
	if self.val >= tonumber(CARD_VALUE.R_WA) then
			--王牌
		self.numImg:setVisible(false)
		self.sImg:setVisible(false)
		self.bImg:loadTexture(string.format("%s.png",self.val),UI_TEX_TYPE_PLIST)
		self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.faceImg:getContentSize().height/2))
	else
		--普通牌， 左上角点数和花色，右下角大花色
		if self.isLaizi then
			self.numImg:loadTexture(getNumImgName(FOLLOW_TYPE.TYPE_L, self.isLaizi),UI_TEX_TYPE_PLIST)
			self.bImg:loadTexture(getSImgName(FOLLOW_TYPE.TYPE_L),UI_TEX_TYPE_PLIST)
		
			self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.bImg:getContentSize().height*3/4))
		else
			self.numImg:loadTexture(getNumImgName(self.color, self.val),UI_TEX_TYPE_PLIST)
			self.bImg:loadTexture(getSImgName(self.color),UI_TEX_TYPE_PLIST)
		
			self.bImg:setPosition(cc.p(self.faceImg:getContentSize().width/2,self.bImg:getContentSize().height*3/4))
		end
	end
end


function Card:setOpacity( opacity )
	-- body
	self.faceImg:setOpacity(opacity)
end

function Card:setGray( ... )
	-- body
	self.faceImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.numImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.sImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
	self.bImg:setColor(cc.c3b(0x7F,0x7F,0x7F))
end

function Card:reSetGray( ... )
	-- body
	self.faceImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.numImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.sImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
	self.bImg:setColor(cc.c3b(0xFF,0xFF,0xFF))
end

--开始发牌背面在上
function Card:beginDeal( ... )
	-- body
	self.backImg:setVisible(true)
	self.faceImg:setVisible(false)
end
--发牌一会后正面面在上
function Card:dalayDeal( ... )
	-- body
	self.backImg:setVisible(false)
	self.faceImg:setVisible(true)
end

function Card:isContainsTouch( touch,cardState,fix )
	-- body
	--打出去的牌不响应触摸事件
	if Card_State.State_Discard == self.mState then
		return false
	end

	local point = touch:getLocation()
	--转化成节点坐标系
	local nodePoint = self:convertToNodeSpace(point)
	local rect = self.faceImg:getBoundingBox()

	local touchFixUp = 0
	if self.moveUp then
		touchFixUp = MY_FIX_UP_EXPAND
	else
		touchFixUp = MY_FIX_UP
	end

	if cardState == Card_Check_Size.up then --上边
		rect.y = rect.height/2-touchFixUp
		rect.width = MY_FIX_WEIDTH
		rect.height = touchFixUp
	elseif cardState == Card_Check_Size.halpUp then --上一半
		rect.y = rect.height/2-touchFixUp
		rect.width = fix
		rect.height = touchFixUp
	elseif cardState == Card_Check_Size.half then --一半
		rect.width = fix
	elseif cardState == Card_Check_Size.all then --所有

	end

	if cc.rectContainsPoint(rect, nodePoint) then
		return true
    end

	return false
end

return Card