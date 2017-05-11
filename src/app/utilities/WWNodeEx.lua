-------------------------------------------------------------------------
-- Desc:     对cc.Node进行了扩展
-- Author:   Jackie刘龙
-- Date:  	 2015-11-19 14:35:24
-- Last: 	
-- Content:  添加了一些方便实用的方法，用法如下：

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
-- = class("WWNodeEx")
local WWNodeEx = cc.Node
-- local EXPORTED_METHODS = {
--    "width",
--    "width2",
--    "height",
--    "height2",
--    "size",
--    "scale",
--    "scaleX",
--    "scaleY",
--    "rect",
--    "posX",
--    "posY",
--    "pos",
--    "offsetX",
--    "offsetY",
--    "offset",
--    "center",
--    "centerX",
--    "centerY",
--    "executeDelay",
--    "getPosByPos",
--    "innerBottom",
--    "innerRight",
--    "innerLeft",
--    "innerTop",
--    "left",
--    "right",
--    "top",
--    "bottom",
--    "playActionDelay"
-- }

-- function WWNodeEx:init_()

-- end

-- function WWNodeEx:bind(target)
--    self:init_()
--    cc.setmethods(target, self, EXPORTED_METHODS)
--    self.target_ = target
-- end

-- function WWNodeEx:unbind(target)
--    cc.unsetmethods(target, EXPORTED_METHODS)
--    self:init_()
-- end

-- 返回node缩放后的宽度
function WWNodeEx:width(countScale)
    local scaleX =(countScale == true) and self:getScaleX() or 1
    return self:getContentSize().width * scaleX
end

-- 返回node缩放后的宽度一半
function WWNodeEx:width2(countScale)
    local scaleX =(countScale == true) and self:getScaleX() or 1
    return self:width() * 0.5 * scaleX
end

-- 返回node的高度
function WWNodeEx:height(countScale)
    local scaleY =(countScale == true) and self:getScaleY() or 1
    return self:getContentSize().height * scaleY
end

function WWNodeEx:height2(countScale)
    local scaleY =(countScale == true) and self:getScaleY() or 1
    return self:height() * 0.5 * scaleY
end

function WWNodeEx:size(countScale)
    return self:getContentSize()
end

function WWNodeEx:scale(scale)
    if type(scale) == "number" then
        self:setScale(scale)
    elseif scale == nil then
        return self:getScale()
    end
    return self
end
function WWNodeEx:scaleX(scaleX)
    if scaleX then
        self:setScaleX(scaleX)
    else
        return self:getScaleX()
    end
    return self
end
function WWNodeEx:scaleY(scaleY)
    if scaleY then
        self:setScaleY(scaleY)
    else
        return self:getScaleY()
    end
    return self
end

function WWNodeEx:rect()
    local ret = { }
    ret.x = 0.0
    ret.y = 0.0
    ret.width = self:width()
    ret.height = self:height()
    return ret
end

function WWNodeEx:color(color)
    if color then
        self:setColor(color)
    end
    return self
end

function WWNodeEx:posX(x)
    if x then
        self:setPositionX(x)
    else
        return self:getPositionX()
    end
    return self
end
-- 将世界坐标转换到node上
function WWNodeEx:posXAbs(worldX)
    if self:getParent() and worldX then
        self:posX(self:getParent():convertToNodeSpace(cc.p(worldX, 0)).x)
    end
    return self
end

function WWNodeEx:posY(y)
    if y then
        self:setPositionY(y)
    else
        return self:getPositionY()
    end
    return self
end
-- 将世界坐标转换到node上
function WWNodeEx:posYAbs(worldY)
    if self:getParent() and worldY then
        self:posY(self:getParent():convertToNodeSpace(cc.p(0, worldY)).y)
    end
    return self
end
-- pos()--返回坐标
-- pos({x=100,y=200})--设置坐标
-- pos(100,200)--设置坐标
function WWNodeEx:pos(x, y)
    if not y and type(x) == "table" then
        self:setPosition(x)
    elseif not x and not y then
        return cc.p(self:getPositionX(), self:getPositionY())
    else
        self:setPosition(cc.p(x, y))
    end
    return self
end
-- posAbs()--返回坐标
-- posAbs({x=100,y=200})--设置坐标
-- posAbs(100,200)--设置坐标
function WWNodeEx:posAbs(x, y)
    if not y and type(x) == "table" then
        self:posXAbs(x.x)
        self:posYAbs(x.y)
    elseif not x and not y then
        return self:getParent() and self:getParent():convertToWorldSpace(self:pos()) or nil
    else
        if x then
            self:posXAbs(x)
        end
        if y then
            self:posYAbs(y)
        end
    end
    return self
end

function WWNodeEx:offsetX(x)
    self:setPositionX(self:getPositionX() + x)
    return self
end

function WWNodeEx:offsetY(y)
    self:setPositionY(self:getPositionY() + y)
    return self
end

function WWNodeEx:offset(x, y)
    if not y and type(x) == "table" then
        self:offsetX(x.x)
        self:offsetY(x.y)
    else
        self:offsetX(x)
        self:offsetY(y)
    end
    return self
end

--------------------------------------------------------------------
-- 注意！！！以下返回位置的方法满足以下条件才能生效：
-- 1、节点已被加到父亲节点上
--------------------------------------------------------------------
local preCond = function(node)
    if node and node:getParent() == nil then
        error("before excute method in WWNodeEx.lua,target node must be added to parent node firstly")
    end
end

function WWNodeEx:center(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(node:width2(), node:height2()), node, targetParent)
        end
        if pos then
            self:setPosition(pos)
        end
    end
    return self
end

function WWNodeEx:centerX(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(node:width2(), 0), node, targetParent)
        end
        if pos then
            self:setPositionX(pos.x)
        end
    end
    return self
end

function WWNodeEx:centerY(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(0, node:height2()), node, targetParent)
        end
        if pos then
            self:setPositionY(pos.y)
        end
    end
    return self
end

-- node1在node2上面，返回node1的Y坐标位置
function WWNodeEx:top(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(0, node:height() + self:height2(true)), node, targetParent)
        end
        if pos then
            self:setPositionY(pos.y)
        end
    end
    return self
end

function WWNodeEx:top1(node, parent)
    return self:top(node, parent):offsetY(- self:height2())
end

function WWNodeEx:innerTop(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(0, node:height() - self:height2(true)), node, targetParent)
        end
        if pos then
            self:setPositionY(pos.y)
        end
    end
    return self
end

function WWNodeEx:bottom(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(0, - self:height2(true)), node, targetParent)
        end
        if pos then
            self:setPositionY(pos.y)
        end
    end
    return self
end

function WWNodeEx:innerBottom(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(0, self:height2(true)), node, targetParent)
        end
        if pos then
            self:setPositionY(pos.y)
        end
    end
    return self
end

-- node1在node2的右边，返回node1的位置
function WWNodeEx:right(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(node:width() + self:width2(true), 0), node, targetParent)
        end
        if pos then
            self:setPositionX(pos.x)
        end
    end
    return self
end

function WWNodeEx:right1(node, parent)
    return self:right(node, parent):offsetX(- self:width2())
end

function WWNodeEx:innerRight(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(node:width() - self:width2(true), 0), node, targetParent)
        end
        if pos then
            self:setPositionX(pos.x)
        end
    end
    return self
end

function WWNodeEx:left(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(- self:width2(true), 0), node, targetParent)
        end
        if pos then
            self:setPositionX(pos.x)
        end
    end
    return self
end

function WWNodeEx:innerLeft(node, parent)
    if node then
        local pos = nil
        local targetParent = self:getParent() and self:getParent() or parent
        if targetParent then
            pos = self:getPosByPos(cc.p(self:width2(true), 0), node, targetParent)
        end
        if pos then
            self:setPositionX(pos.x)
        end
    end
    return self
end

-- 返回node上pos的位置对应在parent或者self:getParent()坐标系中的位置
function WWNodeEx:getPosByPos(pos, node, parent)
    local realPos = nil
    if pos and node then
        local targetParent = parent and parent or self:getParent()
        realPos = targetParent:convertToNodeSpace(node:convertToWorldSpace(pos))
    end
    return realPos
end

function WWNodeEx:playActionDelay(action, delay)
    delay = checknumber(delay)
    if action and type(delay) == "number" then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delay), action))
    end
    return self
end

function WWNodeEx:executeDelay(callback, delay)
    if callback and type(delay) == "number" then
        self:playActionDelay(cc.CallFunc:create(callback), delay)
    end
    return self
end

function WWNodeEx:dispatchCustomEvent(eventName, ...)
    WWFacade:dispatchCustomEvent(eventName, unpack( { ...}))
    return self
end

function WWNodeEx:dispatchGlobalEvent(eventName, ...)
    WWFacade:dispatchGlobalCustomEvent(eventName, unpack( { ...}))
    return self
end

function WWNodeEx:visible(flag)
    if flag == nil then
        return self:isVisible()
    else
        self:setVisible(flag and true or false)
    end
    return self
end

function WWNodeEx:addTouch(onTouchBegan, onTouchMoved, onTouchEnded, onTouchCancelled, swallow)
    self:cancelTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    self.WWNodeEx_Node_Single_Touch_Listener = listener
    listener:setSwallowTouches(swallow == nil and true or swallow)
    onTouchBegan = onTouchBegan or function() end
    if onTouchBegan then
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    end
    if onTouchMoved then
        listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    end
    if onTouchEnded then
        listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    end
    if onTouchCancelled then
        listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    end
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    return listener
end

function WWNodeEx:addTouches(onTouchBegan, onTouchMoved, onTouchEnded, onTouchCancelled, swallow)
    self:cancelTouches()
    local listener = cc.EventListenerTouchAllAtOnce:create()
    self.WWNodeEx_Node_Multi_Touch_Listener = listener
    -- allAtOnce没有此方法
    --    listener:setSwallowTouches(swallow == nil and true or swallow)
    if onTouchBegan then
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
    end
    if onTouchMoved then
        listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    end
    if onTouchEnded then
        listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCHES_ENDED)
    end
    if onTouchCancelled then
        listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCHES_CANCELLED)
    end
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    return listener
end
-- 取消单点触摸，只对用addTouch或addTouches添加的方式有效 removeTouch和LayerEx中的同名，不能用
function WWNodeEx:cancelTouch()
    if self.WWNodeEx_Node_Single_Touch_Listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.WWNodeEx_Node_Single_Touch_Listener)
    end
    return self
end
function WWNodeEx:cancelTouches()
    if self.WWNodeEx_Node_Multi_Touch_Listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.WWNodeEx_Node_Multi_Touch_Listener)
    end
    return self
end

function WWNodeEx:getNodePos(pos)
    local ret = nil
    if pos then
        ret = self:convertToNodeSpace(pos)
    end
    return ret
end

function WWNodeEx:swallowTouch()
    return self:addTouch( function(touch, event) return true end)
end

function WWNodeEx:enableClick(callback)
    local function onTouchBegan(touch, event)
        if cc.rectContainsPoint(self:rect(), self:convertToNodeSpace(touch:getLocation())) then
            return true
        end
        return false
    end
    local function onTouchEnded(touch, event)
        if callback then
            callback(self)
        end
    end
    self:addTouch(onTouchBegan, nil, onTouchEnded, nil, true)
    return self
end

return WWNodeEx