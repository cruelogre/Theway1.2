--[[
		控制器基类
		1、framework级自定义事件相关的注册、移除以及事件派发
		2、获取指定的委托器(Proxy)实例
			<code>self:getProxy(proxyName)</code>
		3、获取指定的中介器(Mediator)实例
			<code>self:getMediator(mediatorName)</code>
		4、获取指定的其它的控制器(Controller)实例
			<code>self:getController(controllerName)</code>
--]]

local Controller = class("Controller")

function Controller:ctor()
	-- body
	self:init()
end

function Controller:init()
	-- body
end

-- 注册自定义事件监听器
-- eventName - 事件名
-- eventCallback - 指定的回调接口
function Controller:registerEventListener(eventName, eventCallback)
	-- body
	self._listeners = self._listeners or {}
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) <= 0 then
		print("<Controller | registerEvent - eventName is empty.");
		return 
	end

	if self._listeners[eventName] then
		print("<Controller | registerEvent - event(" .. eventName .. ") be registered.")
		return
	end

	local listener = WWFacade:addCustomEventListener(eventName, eventCallback)
	if not listener then
		print("<Controller | registerEvent - failure.")
		return
	end

	self._listeners[eventName] = listener
end

-- 注销自定义事件监听器
-- eventName - 事件名
function Controller:unregisterEventListener(eventName)
	-- body
	assert(type(eventName) == "string")
	if string.len(eventName) <= 0 then
		print("<Controller | unregisterEventListener - eventName is empty");
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
function Controller:dispatchEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	WWFacade:dispatchCustomEvent(eventName, ...)
end

-- 获取中介器(Mediator)注册表
function Controller:getMediatorRegistry()
	-- body
	return MediatorMgr:getMediatorRegistry()
end

-- 获取指定标记的中介器(Mediator)
-- name - 中介器(Mediator)标记
function Controller:getMediator(name)
	-- body
	assert(type(name) == "string")

	local mediator = MediatorMgr:retrieveMediator(name)
	if not mediator then
		print("<Controller | getMediator - mediator(" .. name .. ") unfound.")
	end
    
	return mediator;
end

-- 获取委托器(Proxy)注册表
function Controller:getProxyRegistry()
	-- body
	return ProxyMgr:getProxyRegistry()
end

-- 获取指定标记的委托器(Proxy)
-- name - 委托器(Proxy)标记
function Controller:getProxy(name)
	-- body
	assert(type(name) == "string")

	local proxy = ProxyMgr:retrieveProxy(name)
	if not proxy then
		print("<Controller | getProxy - proxy(" .. name .. ") unfound.");
	end

	return proxy
end

-- 获取控制器(Controller)注册表
function Controller:getControllerRegistry()
	-- body
	return ControllerMgr:getControllerRegistry()
end

-- 获取指定标记的控制器(Controller)
-- name - 控制器(Controller)标记
function Controller:getController(name)
	-- body
	assert(type(name) == "string")

	local controller = ControllerMgr:retrieveController(name)
	if not controller then
		print("<Controller | getController - controller(" .. name .. ") unfound.")
	end

	return controller
end

function Controller:finalizer()
	-- body
	self._listeners = self._listeners or {}
	for k, v in pairs(self._listeners) do 
		WWFacade:removeEventListener(v)
		self._listeners[k] = nil
	end
end

return Controller