--[[
	全局的控制与协调类
	由于是全局的实例，所以在代码中直接使用WWFacade获取到的就是此类的实例

	1、框架的事件监听注册与移除，事件派发功能
	(此功能块的EventDispatcher与cocos引擎的EventDispatcher实例相互独立互不影响)
		<code>
			a.事件监听
				WWFacade:addEventListener(eventListener)
			 	WWFacade:addCustomEventListener(eventName, eventCallback)
			 	
			 b.事件移除
			 	WWFacade:removeEventListener(eventListener)
			 	WWFacade:removeCustomEventListener(eventName)

			 c.事件派发
			 	WWFacade:dispatchEvent(event)
			 	WWFacade:dispatchCustomEvent(eventName, param_list)

		</code>
	
	2、引擎范围内的事件监听注册与移除，事件派发功能
	(此模块使用cocos引擎的EventDispatcher实例进行操作)
		<code>
			a.事件监听
				WWFacade:addGlobalEventListener(eventListener)
			 	WWFacade:addGlobalCustomEventListener(eventName, eventCallback)
			 	
			 b.事件移除
			 	WWFacade:removeGlobalEventListener(eventListener)
			 	WWFacade:removeGlobalCustomEventListener(eventName)

			 c.事件派发
			 	WWFacade:dispatchGlobalEvent(event)
			 	WWFacade:dispatchGlobalCustomEvent(eventName, param_list)

		</code>

	TODO:是否有场景管理方面的需求统一放在此处进行管理的情况
--]]

local WWFacade = class("WWFacade")

function WWFacade:ctor()
	-- body
	self:init()
end

function WWFacade:init()
	-- body
	self._eventDispatcher = cc.EventDispatcher:new();
	assert(self._eventDispatcher)
	self._eventDispatcher:retain()
	self:setEventDispatcherEnabled(true)

	-- 初始化时，设置系统随机种子
	math.randomseed(os.time())
end

-- framework EventDispatcher
-- 获取framework事件派发器实例
function WWFacade:getEventDispatcher()
	-- body
	assert(self._eventDispatcher)
	return self._eventDispatcher;
end

-- 设置frameframework事件派发器是否可用
-- enabled[boolean] - true:可用；false:不可用
function WWFacade:setEventDispatcherEnabled(enabled)
	-- body
	assert(type(enabled) == "boolean")
	self:getEventDispatcher():setEnabled(enabled)
end

-- 添加事件监听器
function WWFacade:addEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<WWFacade | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getEventDispatcher():addEventListenerWithFixedPriority(eventListener, 1)
end

-- 添加自定义的事件监听器
-- eventName - 事件名
-- eventCallback - 事件回调
function WWFacade:addCustomEventListener(eventName, eventCallback)
	-- body
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) == 0 then
		cclog("<WWFacade | registerEvent -- eventName is empty.")
		return
	end

	local listener = cc.EventListenerCustom:create(eventName, eventCallback)
	self:addEventListener(listener, 1)
	return listener
end

-- 移除事件监听器
function WWFacade:removeEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<WWFacade | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getEventDispatcher():removeEventListener(eventListener)
end

-- 派发事件
function WWFacade:dispatchEvent(event)
	-- body
	assert(iskindof(event, "cc.Event"))
	self:getEventDispatcher():dispatchEvent(event)
end

-- 派发自定义事件
function WWFacade:dispatchCustomEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	local event = cc.EventCustom:new(eventName)
	event._userdata = {...}
	event._eventName = eventName

   	self:dispatchEvent(event)
end

-- cocos EventDispatcher 
-- 获取cocos事件派发器实例
function WWFacade:getGlobalEventDispatcher()
	-- body
	return cc.Director:getInstance():getEventDispatcher()
end

-- 设置cocos事件派发器是否可用
-- enabled[boolean] - true:可用；false:不可用
function WWFacade:setGlobalEventDispatcherEnabled(enabled)
	-- body
	assert(type(enabled) == "boolean")
	self:getGlobalEventDispatcher():setEnabled(enabled)
end

-- 添加事件监听器
function WWFacade:addGlobalEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<WWFacade | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getGlobalEventDispatcher():addEventListenerWithFixedPriority(eventListener, 1)
end

-- 添加自定义的事件监听器
-- eventName - 事件名
-- eventCallback - 事件回调
function WWFacade:addGlobalCustomEventListener(eventName, eventCallback)
	-- body
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) == 0 then
		cclog("<WWFacade | registerEvent -- eventName is empty.")
		return
	end

	local listener = cc.EventListenerCustom:create(eventName, eventCallback)
	self:addGlobalEventListener(listener, 1)
	return listener
end

-- 移除事件监听器
function WWFacade:removeGlobalEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<WWFacade | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getGlobalEventDispatcher():removeEventListener(eventListener)
end

-- 派发事件
function WWFacade:dispatchGlobalEvent(event)
	-- body
	assert(iskindof(event, "cc.Event"))
	self:getGlobalEventDispatcher():dispatchEvent(event)
end

-- 派发自定义事件
function WWFacade:dispatchGlobalCustomEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	local event = cc.EventCustom:new(eventName)
	event._userdata = {...}

   	self:dispatchGlobalEvent(event)
end

-- 伪构造函数
function WWFacade:finalizer()
	self._eventDispatcher:release()
end

cc.exports.WWFacade = cc.exports.WWFacade or WWFacade:create()
return cc.exports.WWFacade