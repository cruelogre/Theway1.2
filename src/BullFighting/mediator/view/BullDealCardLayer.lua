-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  发牌层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullDealCard = class("BullDealCard",cc.Layer)

function BullDealCard:ctor()
	-- body
	self:init()
end

--初始化界面
function BullDealCard:init()
	-- body
  	--正在为你匹配玩家倒计时动画
  	local waittingAniNode = require("csb.bullfighting.animation.Mathing_waitting"):create()
	if not waittingAniNode then
		return
	end
	self.Skeleton = waittingAniNode["root"]
	self:addChild(self.Skeleton)
	waittingAniNode["root"]:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height*7/12))
	self.waittingAni = waittingAniNode["animation"]
	self.waittingAni:play("animation0",true)
	self.Skeleton:runAction(self.waittingAni)
	self.Skeleton:setVisible(false)
end

--创建待发的牌
function BullDealCard:createCards( playerCount )
	-- body
	self:releaseCards()
	self.Skeleton:setVisible(false)
	--准备要发的牌
	if not self.CardBatchNode then
	  	self.cards = {}
	  	self.CardBatchNode = cc.SpriteBatchNode:create("bullfighting/back.png")
	  	self:addChild(self.CardBatchNode)
	  	local cardNum = playerCount*BULL_DISTRIBUTE_CARD_MIN_NUM
	  	for i=1,cardNum do
	  		local cardNode = cc.Sprite:create("bullfighting/back.png")
	  		if cardNode then
	  			cardNode:setScale(BullCardScale)
	  			cardNode.createIdx = i
	  			cardNode:setPosition(cc.p(screenSize.width/2,screenSize.height*0.5+i*20/cardNum))
	  			self.CardBatchNode:addChild(cardNode,i,i)
	  			table.insert(self.cards,cardNode)
	  		end
	  	end
	end
  	self.CardBatchNode:setVisible(true)
end

--删除牌节省内存
function BullDealCard:releaseCards( ... )
	-- body
	if self.CardBatchNode then
		self.CardBatchNode:removeFromParent()
		self.CardBatchNode = nil
	end
	self.cards = {}
end

--通过索引获得牌
function BullDealCard:getCardByIdx( idx )
	-- body
	for k,v in pairs(self.cards) do
		if v.createIdx == idx then
			return v
		end
	end
end

function BullDealCard:setMatchingVisible( visible )
	-- body
	self.Skeleton:setVisible(visible)
end

return BullDealCard
