-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  发牌层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local DealCard = class("DealCard",cc.Layer)

function DealCard:ctor( ... )
	-- body
	self:init()
end

--初始化界面
function DealCard:init( ... )
	-- body
  	--正在为你匹配玩家倒计时动画
  	local waittingAniNode = require("csb.guandan.animation.Mathing_waitting"):create()
	if not waittingAniNode then
		return
	end
	self.Skeleton = waittingAniNode["root"]
	self:addChild(self.Skeleton)
	waittingAniNode["root"]:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height*7/12))
	self.waittingAni = waittingAniNode["animation"]
	self.waittingAni:play("animation0",true)
	self.Skeleton:runAction(self.waittingAni)
	self.Skeleton:setVisible(true)

	self.match_waitting = self.Skeleton:getChildByName("match_waitting")
	self.match_waitting:ignoreContentAdaptWithSize(true)
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
		self.match_waitting:loadTexture("guandan/animation/match_waitting.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.match_waitting:loadTexture("guandan/animation/match_must_begin.png")
	elseif	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or
		GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
		self.Skeleton:setVisible(false)

		-- self.match_waitting:loadTexture("guandan/animation/match_must_begin.png")
	end
end

--创建待发的牌
function DealCard:createCards( ... )
	-- body
	self.Skeleton:setVisible(false)
	--准备要发的牌
	if not self.CardBatchNode then
	  	self.cards = {}
	  	self.CardBatchNode = cc.SpriteBatchNode:create("guandan/guandan_remain_card_bg1.png")
	  	self:addChild(self.CardBatchNode)
	  	for i=1,DISTRIBUTE_CARD_MAX_NUM do
	  		local cardNode = cc.Sprite:create("guandan/guandan_remain_card_bg1.png")
	  		if cardNode then
	  			-- cardNode:setScale(0.75)
	  			cardNode:setPosition(cc.p(screenSize.width/2,screenSize.height*0.55+i*20/DISTRIBUTE_CARD_MAX_NUM))
	  			self.CardBatchNode:addChild(cardNode,i,i)
	  			table.insert(self.cards,cardNode)
	  		end
	  	end
	end
  	self.CardBatchNode:setVisible(true)
end


--更换玩家
function DealCard:changePlayer( ... )
	self.Skeleton:setVisible(true)

	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
		self.match_waitting:loadTexture("guandan/animation/match_waitting.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.match_waitting:loadTexture("guandan/animation/match_must_begin.png")
	elseif	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or
		GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房	
	end
end

--恢复对局要隐藏动画
function DealCard:recoveryOn( ... )
	-- body
	self.Skeleton:setVisible(false)
end

--删除牌节省内存
function DealCard:releaseCards( ... )
	-- body
	if self.CardBatchNode then
		self.CardBatchNode:removeFromParent()
		self.CardBatchNode = nil
	end
	self.cards = {}
end

--通过索引获得牌
function DealCard:getCardByIdx( idx )
	-- body
	if idx > 0 and idx <= #self.cards then
		return self.cards[idx]
	end
end

return DealCard
