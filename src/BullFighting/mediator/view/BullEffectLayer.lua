------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  设置层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullEffectLayer = class("BullEffectLayer",cc.Layer)

function BullEffectLayer:ctor( ... )
	-- body
	self:init()
end

function BullEffectLayer:init( ... )
	-- body
	self.logTag = "BullEffectLayer.lua"
	--游戏开始
	local gameStart = require("csb.bullfighting.animation.gameStart"):create()
	if not gameStart then
		return
	end
	self.rootGameStart = gameStart["root"]
	self.aniGameStart = gameStart["animation"]
	self.rootGameStart:runAction(self.aniGameStart)
	self.start_di_8 = self.rootGameStart:getChildByName("start_di_8")
	self.rootGameStart:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootGameStart)
  	self.rootGameStart:setVisible(false)

  	--庄家通吃
	local allKill = require("csb.bullfighting.animation.allKill"):create()
	if not allKill then
		return
	end
	self.rootAllKill = allKill["root"]
	self.aniAllKill = allKill["animation"]
	self.rootAllKill:runAction(self.aniAllKill)
	self.zhuang_di_1 = self.rootAllKill:getChildByName("zhuang_di_1")
	self.rootAllKill:setPosition(cc.p(self:getContentSize().width - self.zhuang_di_1:getContentSize().width/2,
		self:getContentSize().height/2))
  	self:addChild(self.rootAllKill)
  	self.rootAllKill:setVisible(false)
end

function BullEffectLayer:beginAniamte( callBack )
	-- body
	wwlog(self.logTag,"播放开始动画")
	playSoundEffect("sound/effect/bullfight/begin")

  	self.rootGameStart:setVisible(true)
	self.aniGameStart:play("animation0",false)
	self.aniGameStart:setAnimationEndCallFunc1("animation0",function ()
			self.rootGameStart:setVisible(false)
			if callBack then
				callBack()
			end
		end)
end

function BullEffectLayer:alkillAniamte( callBack )
	-- body
	wwlog(self.logTag,"播放通杀动画")
  	self.rootAllKill:setVisible(true)
	self.aniAllKill:play("animation0",false)
	self.aniAllKill:setAnimationEndCallFunc1("animation0",function ()
			self.rootAllKill:setVisible(false)
			if callBack then
				callBack()
			end
		end)
end

function BullEffectLayer:rollGold( srcPos,destPos,count,callBack )
	-- body
  	local goldBatchNode = cc.SpriteBatchNode:create("common/common_gold_efficon.png")
  	self:addChild(goldBatchNode)
  	local goldNodeTable = {}
  	for i=1,count do
  		local goldNode = cc.Sprite:create("common/common_gold_efficon.png")
  		if goldNode then
  			-- goldNode:setPosition(cc.p(screenSize.width/2,screenSize.height*0.5))
  			goldNode:setPosition(cc.p(srcPos.x + math.random(-BullRadomArea,BullRadomArea),srcPos.y+ math.random(-BullRadomArea,BullRadomArea)))
  			goldBatchNode:addChild(goldNode)
  			table.insert(goldNodeTable,goldNode)
  		end
  	end
  	--金币滚动
	playSoundEffect("sound/effect/bullfight/goldroll")

  	for k,v in pairs(goldNodeTable) do
		if v then
			local r = 50.0
			local angle = math.pi * 2 * math.random()
			local lr = r * 0.5 + r * 0.5 * math.random()
			local dx = math.sin(angle) * lr
			local dy = math.cos(angle) * lr
			local toPos = cc.p(destPos.x + dx, destPos.y + dy)

			local moveAction = cc.EaseBackOut:create(cc.MoveTo:create(0.5, toPos))
			local config = {v:pos(), cc.p(toPos.x+(destPos.x-toPos.x)*0.5, toPos.y+(destPos.y-toPos.y)*0.5+200), destPos}
			local bezierAction = cc.BezierTo:create(0.5, config)

			v:runAction(cc.Sequence:create(cc.DelayTime:create(0.25/count* (count - k)), 
				cc.EaseSineOut:create(bezierAction), 
				cc.CallFunc:create(function ( node )
					-- body
					node:setVisible(false)
				end),
				cc.DelayTime:create(0.5),
				cc.CallFunc:create(function (node)
					-- body
					if callBack and k == #goldNodeTable then
						callBack()
					end
					
					if node then
						node:removeFromParent()
					end
				end)))
		end
	end
end

--信封漂移动画
function BullEffectLayer:moveEmailAni(srcPos,destPos)
	--庄家通吃
	if not self.emailFlyAni then
		local emailFly = require("csb.bullfighting.animation.emailfly"):create()
		if not emailFly then
			return
		end
		self.rootEmailFly = emailFly["root"]
		self.emailFlyAni = emailFly["animation"]
		self.rootEmailFly:runAction(self.emailFlyAni)
	  	self:addChild(self.rootEmailFly)
	end

	self.rootEmailFly:setVisible(true)
	self.rootEmailFly:setPosition(srcPos)
	self.emailFlyAni:play("animation0",false)
	self.emailFlyAni:setAnimationEndCallFunc1("animation0",function ()
			self.rootEmailFly:runAction(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveTo:create(0.6,destPos)),cc.CallFunc:create(function ( ... )
			-- body
			self.emailFlyAni:play("animation1",false)
			self.emailFlyAni:setAnimationEndCallFunc1("animation1",function ()
				self.rootEmailFly:setVisible(false)
			end)
		end)))
	end)
end

return BullEffectLayer