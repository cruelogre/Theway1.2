--[[
	note:委托器基类为app.proxy.Proxy.lua，所有自定义的委托器必须继承此类

	委托器管理器实例(全局实例，直接访问)
	1、初始化注册的委托器
	2、管理各个Proxy子类的实例及生命同期
	3、查询并获取指定标记的Proxy实例

	<code>
		a.查询
		ProxyMgr:retrieveProxy(name)
	</code>

	TODO:是否需要添加手动加入和移除指定Proxy实例的接口
--]]

local ProxyMgr = class("ProxyManager")

function ProxyMgr:ctor()
	-- body
	self:init()
end

function ProxyMgr:init()
	-- body
	print("ProxyMgr:init")
	self._proxys = self._proxys or {}

	local registry = self:getProxyRegistry()

	for _, v in pairs(registry) do
		print(_, v)
		self._proxys[v] = require(v):create()
	end
end

function ProxyMgr:getProxyRegistry()
	-- body
	return cc.exports.ProxyRegistry
end

-- 获取指定标记的Proxy子类实例
-- name - Proxy子类标记，可以参考ProxyRegistry.lua中定义的注册表中的key值
function ProxyMgr:retrieveProxy(name)
	-- body
	assert(type(name) == "string")
	if string.len(name) <= 0 then
		printn("<ProxyMgr | retrieveProxy - argument(name) is empty")
		return
	end

	self._proxys = self._proxys or {}
	local ret = self._proxys[name]
	if not ret then
		print("<ProxyMgr | retrieveProxy - proxy(" .. name .. ") unfound")
	end
	return ret
end

function ProxyMgr:finalizer()
	-- body
	for _, v in pairs(self._proxys) do
		v:finalizer()
	end
end

cc.exports.ProxyMgr = cc.exports.ProxyMgr or ProxyMgr:create()
return cc.exports.ProxyMgr