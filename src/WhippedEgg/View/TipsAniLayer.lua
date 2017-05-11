-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  设置层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local TipsAniLayer = class("TipsAniLayer",cc.Layer)
local Toast = require("app.views.common.Toast")
local GDAnimator = require("WhippedEgg.util.GDAnimator")
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

function TipsAniLayer:ctor( ... )
	-- body
	self:init()
end

function TipsAniLayer:init( ... )
	-- body
	self.logTag = "TipsAniLayer.lua"
  	--本次打几
	local BlackTipsPoint = require("csb.guandan.BlackTipsPoint"):create()
	if not BlackTipsPoint then
		return
	end
	self.rootBlackTips = BlackTipsPoint["root"]
	self.rootBlackTipsAni = BlackTipsPoint["animation"]
	self.rootBlackTips:setVisible(false)
	self.rootBlackTips:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootBlackTips)
	self.rootBlackTips:runAction(self.rootBlackTipsAni)
	self.Lunci = self.rootBlackTips:getChildByName("Image_2")
	self.TipsNum = self.rootBlackTips:getChildByName("Text_2")


	local skewPint = require("csb.guandan.BlackTipsPoint2"):create()
	if not skewPint then
		return
	end
	self.rootskewPint = skewPint["root"]
	self.rootskewPintAni = skewPint["animation"]
	self.rootskewPint:setVisible(false)
	GameManageFactory:getCurGameManage().FoldMenuLayer.rootTopLeftLayer:addChild(self.rootskewPint)
	self.rootskewPint:setPosition(cc.p(25,-20))
	self.rootskewPint:runAction(self.rootskewPintAni)
	self.leftBefore = self.rootskewPint:getChildByName("left_before")
	self.right_before = self.rootskewPint:getChildByName("right_before")
	self.left_end = self.rootskewPint:getChildByName("left_end")
	self.right_end = self.rootskewPint:getChildByName("right_end")
	self.skew_left = self.rootskewPint:getChildByName("skew_left")
	self.skew_right = self.rootskewPint:getChildByName("skew_right")
	self.leftBefore:setVisible(true)
	self.right_before:setVisible(true)
	self.left_end:setVisible(false)
	self.right_end:setVisible(false)

	--进贡闹钟
	self.PayClock = ccui.ImageView:create("guandan_btngp_ialarm.png",UI_TEX_TYPE_PLIST)
	self.PayClock:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self.PayClock:setVisible(false)
	self.PayClockText = ccui.Text:create("","FZZhengHeiS-B-GB.ttf",38)
	self.PayClockText:setTextColor(cc.c3b(0x00,0x00,0x00))
	self.PayClockText:setPosition(cc.p(self.PayClock:getContentSize().width/2,self.PayClock:getContentSize().height/2))
	self.PayClock:addChild(self.PayClockText)
	self:addChild(self.PayClock)


	--抗贡动画
	local Notribute = require("csb.guandan.animation.Node_notribute"):create()
	if not Notribute then
		return
	end
	self.rootNotribute = Notribute["root"]
--	self.rootNotribute:setScale(cc.Director:getInstance():getContentScaleFactor())
	self.rootNotributeAni = Notribute["animation"]
	self.rootNotribute:setVisible(false)
	self.rootNotribute:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootNotribute)
	self.rootNotribute:runAction(self.rootNotributeAni)

	--随机打几蛋碎动画
	local randomEggPain = require("csb.guandan.animation.Node_laizi"):create()
	if not randomEggPain then
		return
	end
	self.rootRandomEggPain = randomEggPain["root"]
--	self.rootRandomEggPain:setScale(cc.Director:getInstance():getContentScaleFactor())
	self.rootRandomEggPainAni = randomEggPain["animation"]
	self.rootRandomEggPain:setVisible(false)
	self.rootRandomEggPain:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootRandomEggPain)
	self.rootRandomEggPain:runAction(self.rootRandomEggPainAni)
	self.EggPainCardNode = self.rootRandomEggPain:getChildByName("FileNode_card")
	self.EggPainCardNodeFace = self.EggPainCardNode:getChildByName("face")
	self.EggPainCardNodeNum = self.EggPainCardNodeFace:getChildByName("num")
	self.EggPainCardNodesImg = self.EggPainCardNodeFace:getChildByName("sImg")
	self.EggPainCardNodebImg = self.EggPainCardNodeFace:getChildByName("bImg")
	self.EggPainCardNodeNum:ignoreContentAdaptWithSize(true)
	self.EggPainCardNodesImg:ignoreContentAdaptWithSize(true)
	self.EggPainCardNodebImg:ignoreContentAdaptWithSize(true)

	--比赛开始动画
	local GDMatchOpening1 = require("csb.guandan.GDMatchOpening1"):create()
	if not GDMatchOpening1 then
		return
	end
	self.rootGDMatchOpening1 = GDMatchOpening1["root"]
	self.rootGDMatchOpening1Ani = GDMatchOpening1["animation"]
	self.rootGDMatchOpening1:setVisible(false)
	self.rootGDMatchOpening1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootGDMatchOpening1)
	self.rootGDMatchOpening1:runAction(self.rootGDMatchOpening1Ani)

	--成功晋级动画
	local GDMatchOpening2 = require("csb.guandan.GDMatchOpening2"):create()
	if not GDMatchOpening2 then
		return
	end
	self.rootGDMatchOpening2 = GDMatchOpening2["root"]
	self.rootGDMatchOpening2Ani = GDMatchOpening2["animation"]
	self.rootGDMatchOpening2:setVisible(false)
	self.rootGDMatchOpening2:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
  	self:addChild(self.rootGDMatchOpening2)
	self.rootGDMatchOpening2:runAction(self.rootGDMatchOpening2Ani)

	self:registerScriptHandler(handler(self,self.onNodeEvent))
end

--onEnter onExit
function TipsAniLayer:onNodeEvent( event )
	-- body
	if event == "enter" then
    elseif event == "exit" then
       if self.ScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
			self.ScriptFuncId = false
		end
    end
end

--比赛开始动画
function TipsAniLayer:beginMatchAni( callBack,data )
	-- body
	if data and data.SetNo == 1 and data.PlayNo == 1 then
		wwlog(self.logTag,"播放比赛开始动画")
    	playSoundEffect("sound/effect/bisaikaishi")
		self.rootGDMatchOpening1:setVisible(true)
		self.rootGDMatchOpening1Ani:play("animation0",false)
		self.rootGDMatchOpening1Ani:setAnimationEndCallFunc1("animation0",function (frame)
			self.rootGDMatchOpening1:setVisible(false)
			if callBack then
				callBack()
			end
		end)
	elseif data and data.PlayNo == 1 then
		wwlog(self.logTag,"播放晋级动画")
    	playSoundEffect("sound/effect/bisaikaishi")
		self.rootGDMatchOpening2:setVisible(true)
		self.rootGDMatchOpening2Ani:play("animation0",false)
		self.rootGDMatchOpening2Ani:setAnimationEndCallFunc1("animation0",function (frame)
			self.rootGDMatchOpening2:setVisible(false)
			if callBack then
				callBack()
			end
		end)
	else
		if callBack then
			callBack()
		end
	end
end

--蛋碎动画
function TipsAniLayer:playEggPain( callBack )
	-- body	
	wwlog(self.logTag,"播放蛋碎动画")
	playSoundEffect("sound/effect/xuanlaizi")

	self.EggPainCardNodeNum:loadTexture(getNumImgName(GameModel.nowCardColor, GameModel.nowCardVal),UI_TEX_TYPE_PLIST)
	self.EggPainCardNodesImg:loadTexture(getSImgName(GameModel.nowCardColor),UI_TEX_TYPE_PLIST)
	self.EggPainCardNodebImg:loadTexture(getBImgName(GameModel.nowCardColor, GameModel.nowCardVal),UI_TEX_TYPE_PLIST)

	--右下角大花色
	if GameModel.nowCardVal == tonumber(CARD_VALUE.RJ) or GameModel.nowCardVal == tonumber(CARD_VALUE.RQ) or GameModel.nowCardVal == tonumber(CARD_VALUE.RK) then
		self.EggPainCardNodebImg:setPosition(cc.p(self.EggPainCardNodeFace:getContentSize().width/2,
			self.EggPainCardNodeFace:getContentSize().height/2))
	else
		self.EggPainCardNodebImg:setPosition(cc.p(self.EggPainCardNodeFace:getContentSize().width/2,
			self.EggPainCardNodebImg:getContentSize().height*3/4))
	end

	self.rootRandomEggPain:setVisible(true)
	self.rootRandomEggPainAni:play("animation0",false)
	self.rootRandomEggPainAni:setAnimationEndCallFunc1("animation0",function (frame)
		self.rootRandomEggPain:setVisible(false)
		if callBack then
			callBack(GameModel.nowCardVal+1)
		end
	end)
end

--打几动画
function TipsAniLayer:setCurGamePlayNum( num,callBack,data)
	-- body	
	wwlog(self.logTag,"播放本次打几动画")
	local function playNum( num )
		-- body
		if num <= 10 then
			return tostring(num)
		elseif num == 11 then
			return	"J"
		elseif num == 12 then
			return	"Q"
		elseif num == 13 then
			return	"K"
		elseif num == 14 then
			return	"A"
		end
	end
	self.left_end:setString(playNum(GameModel.myNumber))
	self.right_end:setString(playNum(GameModel.opppsiteNumber))
	self.TipsNum:setString(playNum(num))

	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or 
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		self.Lunci:setVisible(false)
  	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.Lunci:setVisible(true)
		local TextNode = self.Lunci:getChildByName("Text_1")
		TextNode:setString("")
		TextNode:removeAllChildren()
		TextNode:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_setlayer_play'),data.SetNo or 0,data.PlayNo or 0),
			TextNode:getFontSize(),TextNode:getTextColor()))
  	end
	self.rootBlackTips:setVisible(true)
	self.rootBlackTipsAni:play("animation0",false)
	self.rootBlackTipsAni:setFrameEventCallFunc(function (frame)
  		self.leftBefore:setVisible(false)
		self.right_before:setVisible(false)
		self.left_end:setVisible(true)
		self.right_end:setVisible(true)

		self.rootskewPintAni:play("animation0",false)
		self.rootskewPint:setVisible(true)

		wwlog(self.logTag,"回调到发牌去")
		if callBack then
			callBack()
		end

		GameManageFactory:getCurGameManage().FoldMenuLayer:setCurGamePlayNum()
	end)
end

--恢复对局
function TipsAniLayer:recoveryOn()
	-- body
  	self.rootBlackTips:setVisible(false)
  	self.rootskewPint:setVisible(false)
end

--更换玩家
function TipsAniLayer:changePlayer( ... )
	GameManageFactory:getCurGameManage():setRoomPoint(GameModel.roomPoints)
  	self.rootskewPint:setVisible(false)
  	self.leftBefore:setVisible(true)
	self.right_before:setVisible(true)
	self.left_end:setVisible(false)
	self.right_end:setVisible(false)
  	self.leftBefore:setString("?")
	self.right_before:setString("?")
end

function TipsAniLayer:setTributeBegin( sec )
	-- body
	wwlog("设置进贡退贡所需时间"..sec or 15)
	self.PayClock:setVisible(true)
	self.secCount = sec or 15
	self.PayClockText:setString(tostring(self.secCount)) --闹钟数字

	if self.ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
		self.ScriptFuncId = false
	end
		
	if not self.ScriptFuncId then
		self.ScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)
	end
end

function TipsAniLayer:setTributeEnd( ... )
	-- body
	self.PayClock:setVisible(false)

	if self.ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
		self.ScriptFuncId = false
	end
end

function TipsAniLayer:countDown( ... )
	-- body
	self.secCount = self.secCount - 1
	if self.secCount >= 0 then
  		self.PayClockText:setString(tostring(self.secCount)) --闹钟数字
  	else
  		--倒计时结束
		GameManageFactory:getCurGameManage().MyPlayer:TributeOverTime()
		self.PayClock:setVisible(false)
  		if self.ScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
			self.ScriptFuncId = false
		end
  	end
end

function TipsAniLayer:Notribute( callBack )
	-- body
	playSoundEffect("sound/effect/kanggong")
	self.rootNotribute:setVisible(true)
	self.rootNotributeAni:play("animation0",false)
	self.rootNotributeAni:setAnimationEndCallFunc1("animation0",function (frame)
		if callBack then
			callBack()
		end
	end)
end

function TipsAniLayer:stopAllAni( ... )
	-- body
	self.rootBlackTipsAni:stop()
	self.rootBlackTips:setVisible(false)

	self.leftBefore:setVisible(false)
	self.right_before:setVisible(false)
	self.left_end:setVisible(true)
	self.right_end:setVisible(true)

	self.rootskewPintAni:stop()
	self.rootskewPint:setVisible(false)

	self.rootRandomEggPainAni:stop()
	self.rootRandomEggPain:setVisible(false)
	stopSoundEffect("sound/effect/xuanlaizi")

	self.rootGDMatchOpening1Ani:stop()
	self.rootGDMatchOpening1:setVisible(false)
    stopSoundEffect("sound/effect/bisaikaishi")

	self.rootGDMatchOpening2Ani:stop()
	self.rootGDMatchOpening2:setVisible(false)
    stopSoundEffect("sound/effect/bisaikaishi")
end

--信封漂移动画
function TipsAniLayer:moveEmailAni(srcPos,destPos)
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

return TipsAniLayer