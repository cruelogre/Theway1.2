-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  牌
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullProgressTimer = class("BullProgressTimer",cc.Node)


function BullProgressTimer:ctor(time)
	-- body
	self.time = time or BullCaculateCardTime
	self.bplaySoundEffect = true
	self.timeNow = self.time
	self.back = ccui.ImageView:create("countdownback.png",UI_TEX_TYPE_PLIST)
	self:addChild(self.back)

	local sprite = cc.Sprite:createWithSpriteFrameName("countdownup.png")
    --新建progressTimer对象，将图片载入进去
    self.progressTimer = cc.ProgressTimer:create(sprite);
    self:addChild(self.progressTimer)
    --设置初始的百分比，0~100 可以是0或者100
    self.progressTimer:setPercentage(100);
    --选择类型，是条型还是时针型
    self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.progressTimer:setReverseDirection(true);
    local ProgressTo = cc.ProgressTo:create(self.time,0)
    self.progressTimer:runAction(ProgressTo)

    self.timeText = ccui.TextAtlas:create(self.timeNow.."","bullfighting/wenzishu4.png",40,53,"0")
	local charMap = cc.Director:getInstance():getTextureCache():getTextureForKey("bullfighting/wenzishu4.png")
	if cc.Director:getInstance():getContentScaleFactor() == 1 then
		self.timeText:setProperty(self.timeNow.."","bullfighting/wenzishu4.png",40,53,"0")
	else
		self.timeText:setProperty(self.timeNow.."","bullfighting/wenzishu4.png",27,36,"0")
	end

    self:addChild(self.timeText)

	self:registerScriptHandler(handler(self,self.onNodeEvent))
end

--onEnter onExit
function BullProgressTimer:onNodeEvent( event )
	-- body
	if event == "enter" then
		
    elseif event == "exit" then
       	if self.timeScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timeScriptFuncId)
			self.timeScriptFuncId = false
		end
    end
end

function BullProgressTimer:timeCutDown( ... )
	-- body
	if self.timeNow <= 3 and self.bplaySoundEffect then
		playSoundEffect("sound/effect/bullfight/cutdowntime")
	end

	self.timeNow = self.timeNow - 1
	if self.timeNow <= 0 then
		--回调
		if self.callBack then
			self.callBack()
		end

		if self.timeScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timeScriptFuncId)
			self.timeScriptFuncId = false
		end
	end
    self.timeText:setString(self.timeNow.."")
end

function BullProgressTimer:reSet(time,callBack)
	-- body
	self.callBack = callBack
	self.time = time or self.time 
	self.timeNow = self.time
	self.bplaySoundEffect = true

	self.progressTimer:stopAllActions()
    self.progressTimer:setPercentage(self.timeNow*100/10)
	local ProgressTo = cc.ProgressTo:create(self.time,0)
    self.progressTimer:runAction(ProgressTo)
    self.timeText:setString(self.timeNow.."")
    if not self.timeScriptFuncId then
		self.timeScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.timeCutDown), 1, false)
	end
end

function BullProgressTimer:getNowTime( ... )
	-- body
	return self.timeNow
end

function BullProgressTimer:setplaySoundEffect( bplaySoundEffect )
	-- body
	self.bplaySoundEffect = bplaySoundEffect
end
return BullProgressTimer