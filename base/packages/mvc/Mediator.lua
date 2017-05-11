--[[
		中介器基类
		1、framework级自定义事件相关的注册、移除以及事件派发
		2、获取指定的委托器(Proxy)实例
			<code>self:getProxy(proxyName)</code>
--]]

local Mediator = class("Mediator")

function Mediator:ctor()
	-- body
	self:init()
end

function Mediator:init()
	-- body
end

-- 注册自定义事件监听器
-- eventName - 事件名
-- eventCallback - 指定的回调接口
function Mediator:registerEventListener(eventName, eventCallback)
	-- body
	self._listeners = self._listeners or {}
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) <= 0 then
		print("<Mediator | registerEvent - eventName is empty.");
		return 
	end

	if self._listeners[eventName] then
		print("<Mediator | registerEvent - event(" .. eventName .. ") be registered.")
		return
	end

	local listener = WWFacade:addCustomEventListener(eventName, eventCallback)
	if not listener then
		print("<Mediator | registerEvent - failure.")
		return
	end

	self._listeners[eventName] = listener
end

-- 注销自定义事件监听器
-- eventName - 事件名
function Mediator:unregisterEventListener(eventName)
	-- body
	assert(type(eventName) == "string")
	if string.len(eventName) <= 0 then
		print("<Mediator | unregisterEventListener - eventName is empty");
		return
	end	

	self._listeners = self._listeners or {}
	if self._listeners[eventName] then
		WWFacade:removeEventListener(self._listeners[eventName])
		self._listeners[eventName] = nil
	end
end

-- 自定义事件派发
-- eventName - 事件名
-- ... - 事件参数
function Mediator:dispatchEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	WWFacade:dispatchCustomEvent(eventName, ...)
end

-- 获取委托器(Proxy)注册表
function Mediator:getProxyRegistry()
	-- body
	return ProxyMgr:getProxyRegistry()
end

-- 获取指定标记的委托器(Proxy)
-- name - 委托器(Proxy)标记
function Mediator:getProxy(name)
	-- body
	assert(type(name) == "string")

	local proxy = ProxyMgr:retrieveProxy(name)
	if not proxy then
		print("<Mediator | getProxy - proxy(" .. name .. ") unfound.")
	end

	return proxy
end

function Mediator:finalizer()
	-- body
	self._listeners = self._listeners or {}
	for k, v in pairs(self._listeners) do 
		WWFacade:removeEventListener(v)
		self._listeners[k] = nil
	end
end

return Mediator
