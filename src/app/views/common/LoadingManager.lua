-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.11
-- Last:
-- Content:  加载等待旋转界面
-- Modify: 
--			2017.1.11 修改计时器bug，showloading之后计时器归零
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local LoadingManager = class("LoadingManager")
import(".wwGameConst","app.config.")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function LoadingManager:ctor()
	self.loadingLayer = nil
	self.schedulerID  = -1
	self.actime = 0
	self.interval = 0.1
	self.trigerTime = 0.8
	self.curMode = LOADING_MODE.MODE_NORMAL
	self.orTrigerTime = self.trigerTime
	self.scheduler = cc.Director:getInstance():getScheduler()
end
--延时启动loading
--@param trTime  延时
--@param mode 启动模式
--@param str 显示的字符串
function LoadingManager:startLoading(trTime,mode,str)
	if self.loadingLayer then
		return
	end
--[[	if not cc.Director:getInstance():getRunningScene() then
		self.loadingLayer = nil
		return
	end--]]
	self.showStr = str
	if trTime and type(trTime)=="number" then
		self.trigerTime = trTime
	end
	if mode and type(mode)== "number" and mode>=LOADING_MODE.MODE_NORMAL and mode<=LOADING_MODE.MODE_TOUCH_CLOSE then
		self.curMode = mode
	end
	
	if self.schedulerID>0 then
		self.scheduler:unscheduleScriptEntry(self.schedulerID) 
	end
	
	self.schedulerID = self.scheduler:scheduleScriptFunc(handler(self,self.countTimer), self.interval, false)
	
end
function LoadingManager:isShowing()
	return self.loadingLayer ~=nil
end

function LoadingManager:endLoading()
	if self.schedulerID>0 then
		self.scheduler:unscheduleScriptEntry(self.schedulerID)
		self.trigerTime = self.orTrigerTime
		self.schedulerID = -1
	end
	
	if isLuaNodeValid(self.loadingLayer) then
		self.loadingLayer:stopAllActions()
		self.loadingLayer:removeAllChildren()
		self.loadingLayer:removeFromParent()
		--self.loadingLayer = nil
	end
	self.loadingLayer = nil
	self.curMode = LOADING_MODE.MODE_NORMAL
	
	if self.listener2 and eventDispatcher then
		eventDispatcher:removeEventListener(self.listener2)
	end
	self.listener2 = nil
end
function LoadingManager:showLoading()
	
	if not isLuaNodeValid(cc.Director:getInstance():getRunningScene()) then
		self.loadingLayer = nil
		return
	end
	
	local tBundles =  require("csb.common.WaittingLayer"):create()
	self.loadingLayer = tBundles.root
	local panelbg = self.loadingLayer:getChildByName("Panel_bg")
	FixUIUtils.stretchUI(panelbg)
	
	local textcontent = ccui.Helper:seekWidgetByName(panelbg,"Text_1")
	if self.showStr then
		textcontent:setString(self.showStr)
	end
	cc.Director:getInstance():getRunningScene():addChild(self.loadingLayer,ww.topOrder)
						   --animation1
	tBundles.animation:play("animation1",true)
	self.loadingLayer:runAction(tBundles.animation)
	self.scheduler:unscheduleScriptEntry(self.schedulerID)
	self.trigerTime = self.orTrigerTime
	self.schedulerID = -1
	self.actime = 0
	
	if self.curMode == LOADING_MODE.MODE_TOUCH_CLOSE then
		self.loadingLayer:getChildByName("Panel_bg"):addTouchEventListener(function (ref,eventType)
			if eventType==ccui.TouchEventType.ended then
				self:endLoading()
			end
		end)
	end
	
	local function keyboardPressed(keyCode, event) 
		
        if keyCode == cc.KeyCode.KEY_BACK then  
            if self.loadingLayer then
				self:endLoading()
				event:stopPropagation()
			end
        end  
     
    end  
 
    self.listener2 = cc.EventListenerKeyboard:create()  
    self.listener2:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)  
  
    
    eventDispatcher:addEventListenerWithFixedPriority(self.listener2, KEYBOARD_EVENTS.KETBOARD_LOADING)
	
end
function LoadingManager:countTimer(dt)
	self.actime = self.actime + self.interval
	if self.actime >= self.trigerTime then
		self:showLoading()
		
	end
end
cc.exports.LoadingManager = cc.exports.LoadingManager or LoadingManager:create()
return cc.exports.LoadingManager