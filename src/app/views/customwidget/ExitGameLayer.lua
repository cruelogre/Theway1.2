-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.09.15
-- Last: 
-- Content:  退出游戏
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ExitGameLayer = class("ExitGameLayer", cc.LayerColor)
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local NetWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
function ExitGameLayer:ctor( exitCallback )
	-- body
	self.exitCallback = exitCallback
    self:setOpacity(200)

    --重写触摸 截断下层消息
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_ENDED)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

	self:init()
end

----------------------------------------------------
--触摸事件
----------------------------------------------------
function ExitGameLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
    end
end

function ExitGameLayer:init( ... )
	-- body
	local ExitGameBundle = require("csb.common.ExitGame"):create()
	if not ExitGameBundle then
		return
	end
	
	local root = ExitGameBundle["root"]
	root:addTo(self)
	FixUIUtils.setRootNodewithFIXED(root)

	self.Image_di = root:getChildByName("Image_1")
	self.TextTitle = self.Image_di:getChildByName("Text_1")
	self.TextContent = self.Image_di:getChildByName("Text_1_0")
	self.ButtonContinue = self.Image_di:getChildByName("btnContinue") --再玩一会
	self.ButtonExit = self.Image_di:getChildByName("btnExit") --残忍退出
	self.TextContent:setString("")
	self.TextContent:removeAllChildren()


	local recentSignKey = ww.WWGameData:getInstance():getIntegerForKey(COMMON_TAG.C_RECENTSIGN_DAY,0)
	local curTime = os.date("*t")
	curTime.min = 0
	curTime.sec = 0
	curTime.hour = 0
	local tt = os.time(curTime)

	if tt == recentSignKey then
		--签到过
		self.TextContent:addChild(SimpleRichText:create(i18n:get('str_hall','hall_game_exit'),
			self.TextContent:getFontSize(),self.TextContent:getTextColor()))
	else
		self.TextContent:addChild(SimpleRichText:create(i18n:get('str_hall','hall_game_exit_notsign'),
			self.TextContent:getFontSize(),self.TextContent:getTextColor()))
	end

  	self.ButtonContinue:addClickEventListener(handler(self,self.btnClick))
  	self.ButtonExit:addClickEventListener(handler(self,self.btnClick))

	self.Image_di:setScale(0)
	self.Image_di:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0)))

end

--按钮事件
function ExitGameLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")
	
	if ref:getName() == "btnContinue" then --再玩一会
		if self.exitCallback then
			self.exitCallback()
		end
  	elseif ref:getName() == "btnExit" then --残忍退出
		--退出登录
		NetWorkProxy:switchUser()
  		cc.Director:getInstance():endToLua()
	end
end


function ExitGameLayer:show()
    self:addTo(display.getRunningScene(),ww.topOrder)
end

function ExitGameLayer:close()
    self:removeFromParent(true)
end

return ExitGameLayer