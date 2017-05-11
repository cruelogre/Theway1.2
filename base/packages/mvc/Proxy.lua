--[[
		中介器基类
		1、framework级自定义事件相关的注册、移除以及事件派发
--]]

local Proxy = class("Proxy")

function Proxy:ctor()
	-- body
	self.logTag = self.__cname..".lua"
	self:init()
end

function Proxy:init()
	-- body
end

-- 自定义事件派发
-- eventName - 事件名
-- ... - 事件参数
function Proxy:dispatchEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	WWFacade:dispatchCustomEvent(eventName, ...)
end

-- 获取委托器(Proxy)注册表
function Proxy:getProxyRegistry()
	-- body
	return ProxyMgr:getProxyRegistry()
end

-- 获取指定标记的委托器(Proxy)
-- name - 委托器(Proxy)标记
function Proxy:getProxy(name)
	-- body
	assert(type(name) == "string")

	local proxy = ProxyMgr:retrieveProxy(name)
	if not proxy then
		print("<Proxy | getProxy - proxy(" .. name .. ") unfound.")
	end

	return proxy
end

--[[
	向服务端发送消息
	sendMsgId - 通过消息Model注册的发送消息id
	msgParam - 创建buffer需要用到的数据组成的表
--]]
function Proxy:sendMsg(sendMsgId, msgParam)
	-- body
	NetWorkBridge:send(sendMsgId, msgParam, self)
end

function Proxy:sendMsgEx(sendMsgId, ...)
	-- body
	local param = {...}
	NetWorkBridge:send(sendMsgId, param, self)
end

--[[
	注册需要监听的服务端消息对应的消息号
	msgId - 待监听的消息号
	callback - 服务端消息过来时，需要调用的回调
	tag - 用于标记msgId所属，
	说明：
		1、回调的函数原型为function (msgId, msgTable)
			-- msgId - 服务端的消息号
			-- msgTable - 服务端数据解析之后的结果
		2、关于tag参数
			由于不同的模块可能注册同样的消息id，所以用于区分不同的消息id值就是依赖传入的tag值了
			即msgId和tag共同决定了这个监听的所属
			建议tag用当前注册监听的模块名的字符串来表示，如:registerMsgId(msgId, callback, "LoginProxy")
--]]
function Proxy:registerMsgId(msgId, callback, tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:registerMsgId(msgId, callback, tag, self)
end

function Proxy:bindMsgId(msgId, msgTable)
	-- body
	WWNetAdapter:bindMsgTable(msgId, msgTable)
end


--[[
	注册服务端的root消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:registerRootMsgId(msgId, callback, tag)
	-- body
	if nil == tag then
		tag = self.__cname
	end 
	WWNetAdapter:registerRootMsgId(msgId, callback, tag, self)
end
--[[
	注册服务端的网络状态消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:registerNetId(msgId, callback, tag)
		-- body
	if nil == tag then
		tag = self.__cname
	end 
	WWNetAdapter:registerNetEventMsg(msgId, callback, tag, self)
end
--[[
	注册服务端的更新消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:registerUpdateId(msgId, callback, tag)
		-- body
	if nil == tag then
		tag = self.__cname
	end 
	WWNetAdapter:registerUpgradeEventMsg(msgId, callback, tag, self)
end

--[[
	取消服务端消息的监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterMsgId(msgId, tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterMsgId(msgId, tag, self)
end

function Proxy:unregisterAllMsgId(tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterAllMsgId(tag, self)
end


--[[
	取消服务端root消息的监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterRootMsgId(msgId, tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterRootMsgId(msgId, tag, self)
end

function Proxy:unregiserAllRootMsgId(tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterRootMsgId(tag, self)
end
--[[
	取消服务端的网络状态消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterNetId(msgId, tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterNetEvent(msgId, tag, self)
end

--[[
	取消服务端的更新消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterUpdateId(msgId, tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterUpgradeEvent(msgId, tag, self)
end

--[[
	取消服务端的网络状态消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterAllNetId(tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterAllNetEvent(tag, self)
end

--[[
	取消服务端的网络状态消息监听
	参数说明见registerMsgId接口注释
--]]
function Proxy:unregisterAllUpdateId(tag)
	-- body
	if nil == tag then 
		tag = self.__cname
	end 
	WWNetAdapter:unregisterAllUpgradeEvent(tag, self)
end

function Proxy:finalizer()
	-- body
end


return Proxy