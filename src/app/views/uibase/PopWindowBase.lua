-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  PopupWindows 基础类
-- 2016.11.10 添加屏蔽返回键功能
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local PopWindowBase = class("PopWindowBase",cc.LayerColor)
local Node_touch = require("csb.hall.animation.Node_touch")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local PopWindowBaseTable = {}

--定义方向
cc.exports.Pop_Dir = {
    Up = 0,
    Down = 1,
    Left = 2,
    Right = 3,
}
--是否有半透明的
local function hasTranslucence()
	local has = false
	for _,v in pairs(PopWindowBaseTable) do
		if isLuaNodeValid(v) and v:getOpacity() > 0 then
			has = true
			break
		end
	end
	return has
end

function PopWindowBase:ctor(half)
    --body
    self.isHalf = half or true
	self.canCancel = true --是否能够返回键关闭
	self.logTag = self.__cname..".lua"
	if not hasTranslucence() then
        self:setOpacity(156)
    else
        self:setOpacity(0)
    end
    table.insert( PopWindowBaseTable, self )
    MediatorMgr:setPopupNodeCount(#PopWindowBaseTable)
	print("PopWindowBaseTable len",#PopWindowBaseTable)
    --重写触摸 截断下层消息
    self.listenerTouch = cc.EventListenerTouchOneByOne:create()
    self.listenerTouch:setSwallowTouches(true)
    self.listenerTouch:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
    self.listenerTouch:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_ENDED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerTouch, self)

	local function keyboardPressed(keyCode, event) 
		
        if keyCode == cc.KeyCode.KEY_BACK then  
            if #PopWindowBaseTable>0 then
				if isLuaNodeValid(PopWindowBaseTable[#PopWindowBaseTable]) and
					PopWindowBaseTable[#PopWindowBaseTable].canCancel then
					PopWindowBaseTable[#PopWindowBaseTable]:close()
				elseif isLuaNodeValid(PopWindowBaseTable[#PopWindowBaseTable]) then
					PopWindowBaseTable[#PopWindowBaseTable]:cantCloseOnBack()
				end
				event:stopPropagation()
			end
        end  
     
    end  
 
    self.listener2 = cc.EventListenerKeyboard:create()  
    self.listener2:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)  
  
    
    eventDispatcher:addEventListenerWithFixedPriority(self.listener2, KEYBOARD_EVENTS.KETBOARD_POPLAYER)
	
    self:registerScriptHandler(handler(self,self.onNodeEvent))

    -- local returnBtn = cc.Sprite:create("common/common_btn_back_1.png")
    -- local winSize = cc.Director:getInstance():getVisibleSize() 
    -- returnBtn:setPosition({
    --     x=returnBtn:getContentSize().width * 1.5, 
    --     y=winSize.height * 0.95 })
    -- self:addChild(returnBtn)
end
--不能返回关闭的回调
function PopWindowBase:cantCloseOnBack()
	
end

--onEnter onExit
function PopWindowBase:onNodeEvent( event )
    -- body
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    end
end

function PopWindowBase:onEnter( ... )
    -- body
	self.isFirst = ww.WWGameData:getInstance():getBoolForKey(wwGameConst.FIRST_TOUCH,true)
	print("PopWindowBase:onEnter")
	if self.isFirst and self:getOpacity() > 0 and self.isHalf then
		--添加手指动画
		local touchNode = Node_touch:create()
		touchNode.root:setName("finger")
		touchNode.root:runAction(touchNode.animation)
		touchNode.animation:play("animation0",true)
		touchNode.root:setPosition(cc.p(display.cx/2,display.cy))
		self:addChild(touchNode.root,2)
		print(touchNode.root:getName())
	end
end

function PopWindowBase:onExit( ... )
    -- body
    playSoundEffect("sound/effect/anniu")

    removeItem( PopWindowBaseTable,self)
    MediatorMgr:setPopupNodeCount(#PopWindowBaseTable)
	if self.listener2 and eventDispatcher then
		eventDispatcher:removeEventListener(self.listener2)
	end
	self.listener2 = nil
	if self.listenerTouch and eventDispatcher then
		eventDispatcher:removeEventListener(self.listenerTouch)
	end
	self.listenerTouch = nil
	if self.isFirst and self:getOpacity()>0 then
		self.isFirst = false
		ww.WWGameData:getInstance():setBoolForKey(wwGameConst.FIRST_TOUCH,false)
	end
end

function PopWindowBase:setDisCallback( callback )
    -- body
    self.DisCallback = callback
end

----------------------------------------------------
--触摸事件
----------------------------------------------------
function PopWindowBase:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        self:close()
    end
end
--关闭
function PopWindowBase:close()
	if self.node then
		self:popOut()
	else
		removeItem( PopWindowBaseTable,self)
        MediatorMgr:setPopupNodeCount(#PopWindowBaseTable)
		if self.DisCallback then
            self.DisCallback()
		else			
            self:removeFromParent()
		end
	end
end

----------------------------------------------------
--弹出效果
----------------------------------------------------
function PopWindowBase:popOut()
    -- body
    local size = cc.Director:getInstance():getVisibleSize()
    local x = self.node:getPositionX()
    local y = self.node:getPositionY()
    local ConSize = self.node:getContentSize()

    local pos = false
    if self.popInDir == Pop_Dir.Up then
        pos = cc.p(x,size.height + ConSize.height/2)
    elseif self.popInDir == Pop_Dir.Down then
        pos = cc.p(x,-ConSize.height/2)
    elseif self.popInDir == Pop_Dir.Left then
        pos = cc.p(-ConSize.width,y)
    elseif self.popInDir == Pop_Dir.Right then
        pos = cc.p(size.width+ConSize.width/2,y)
    end

    local duration = 0.15
    if self.DisCallback then
        self.node:runAction(cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(duration, pos)),
            cc.CallFunc:create(function ( ... )
                -- body
                removeItem( PopWindowBaseTable,self)
                MediatorMgr:setPopupNodeCount(#PopWindowBaseTable)

                self.DisCallback()
                -- self:removeFromParent()
            end)))
    else
        self.node:runAction(cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(duration, pos)),
             cc.CallFunc:create(function ( ... )
                -- body
                removeItem( PopWindowBaseTable,self)
                MediatorMgr:setPopupNodeCount(#PopWindowBaseTable)
                self:removeFromParent()
            end)))
    end
end

----------------------------------------------------
--进入效果
----------------------------------------------------
function PopWindowBase:popIn( node,dir)
    -- body
    self.node = node
    self.popInDir = dir

    local size = cc.Director:getInstance():getVisibleSize()
    local x = node:getPositionX()
    local y = node:getPositionY()

    local ConSize = node:getContentSize()

    if dir == Pop_Dir.Up then
        node:setPosition(x,size.height + ConSize.height/2)
    elseif dir == Pop_Dir.Down then
        node:setPosition(x,-ConSize.height/2)
    elseif dir == Pop_Dir.Left then
        node:setPosition(-ConSize.width,y)
    elseif dir == Pop_Dir.Right then
        node:setPosition(size.width+ConSize.width/2,y)
    end

    local duration = 0.2
    node:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(duration, cc.p(x,y)))))
end


return PopWindowBase