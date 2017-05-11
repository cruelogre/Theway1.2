-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   cruelogre
-- Date:     2016/09/28
-- Last:    
-- Content:  Dialog系统提示框
-- 2016/09/28    系统提示框 重新连接

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------

--[[
    local para = {}
    para.type = 1 --提示类型  1 未连接网络 2 网络断开 3 正在连接中
	para.isAnim = false --是否需要进入动画
	param.btnCallback = handler(self, self.activityHandler)
	
    local SystemInfoDialog = import(".SystemInfoDialog", "app.views.customwidget."):create( para ):show()
--]]

local SystemInfoDialog = class("SystemInfoDialog",cc.LayerColor)
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local SystemInfoLayer = require("csb.common.SystemInfoLayer")
local typeStringMap = {
	[1] = {'str_common','comm_net_closed'},
	[2] = {'str_common','comm_net_discontent'},
	[3] = {'str_common','comm_net_connectding'},
}

function SystemInfoDialog:ctor(param)
	self.para = param or {}
	self:initUI()
end


function SystemInfoDialog:initUI()
	self:setOpacity(156)
	local systemBundle = SystemInfoLayer:create()
	self.node = systemBundle.root
	self:addChild(self.node)
	self.animation = systemBundle.animation
	self.node:runAction(self.animation)
	--self.animation:retain()
	FixUIUtils.setRootNodewithFIXED(self.node)
	local imgBg = self.node:getChildByName("Image_bg")
	local strArr = typeStringMap[self.para.type]
	if strArr then
		imgBg:getChildByName("Text_content"):setString(i18n:get(strArr[1],strArr[2]))
		imgBg:getChildByName("Text_content"):setFontName("FZZhengHeiS-B-GB.ttf")
	end
	local btnConnect = imgBg:getChildByName("Button_connect")
	self.timeText = imgBg:getChildByName("Text_time")
	if self.para.type==3 then
		btnConnect:setVisible(false)
		self.timeText:setVisible(true)
	else
		self.timeText:setVisible(false)
		btnConnect:setVisible(true)
		
		btnConnect:addTouchEventListener(handler(self,self.touchEventListener))
	end
	local function keyboardPressed(keyCode, event) 
        
        if keyCode == cc.KeyCode.KEY_BACK then  
            event:stopPropagation()
           
        end  
     
    end  
 
    self.listener2 = cc.EventListenerKeyboard:create()  
    self.listener2:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)  
  
    eventDispatcher:addEventListenerWithFixedPriority(self.listener2, KEYBOARD_EVENTS.KETBOARD_POPDIALOG)
	
	self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler( function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
	
end
function SystemInfoDialog:touchEventListener(ref,eventType)
	if not ref or not ref:isVisible() then
		return
	end
	if eventType == ccui.TouchEventType.ended then
		if ref:getName()=="Button_connect" then
			if self.para.btnCallback then
				self.para.btnCallback(self.para.type)
				if isLuaNodeValid(self) then
					self:close()
				end
			end
		end
		
	end
	
end


function SystemInfoDialog:show()
	if self.para.isAnim then
		 self.animation:play("animation0",false)
	else
		self.animation:gotoFrameAndPause(0)
	end
   
    if self.para.type then
        --存在相同类型的节点时候
        display.getRunningScene():removeChildByName("SystemInfoDialog"..tostring(self.para.type))
        self:setName("SystemInfoDialog"..tostring(self.para.type))
    end
    self:addTo(display.getRunningScene(),ww.topOrder+1)
end

function SystemInfoDialog:close()
	if self.listener2 and eventDispatcher then
        eventDispatcher:removeEventListener(self.listener2)
    end
	if self.m_pListener and eventDispatcher then
        eventDispatcher:removeEventListener(self.m_pListener)
    end
	
    self.listener2 = nil
	self.m_pListener = nil
    self:removeFromParent(true)
end

--[[function SystemInfoDialog:close()
    --self.animation:play("animation1",false)
	--self.animation:setAnimationEndCallFunc1("animation1",handler(self,self.closeOver))
end--]]


return SystemInfoDialog