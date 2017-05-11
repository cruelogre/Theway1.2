--[[
	note:中介器基类为app.mediator.Mediator.lua，所有自定义的中介器必须继承此类

	中介器管理器实例(全局实例，直接访问)
	1、初始化注册的中介器
	2、管理各个Mediator子类的实例及生命同期
	3、查询并获取指定标记的Mediator实例

	<code>
		a.查询
		MediatorMgr:retrieveMediator(name)
	</code>

	TODO:是否需要添加手动加入和移除指定Mediator实例的接口
--]]

local MediatorMgr = class("MediatorManager")

function MediatorMgr:ctor()
	-- body
	self:init()
end

function MediatorMgr:init()
	-- body
	print("MediatorMgr:init")
	self._mediators = self._mediators or {}

	local registry = self:getMediatorRegistry()

	for _, v in pairs(registry) do
		print(_, v)
		self._mediators[v] = require(v):create()
	end

	self.PopWindowCounts = 0 --当前Popup弹出数量
end

function MediatorMgr:getMediatorRegistry()
	-- body
	return cc.exports.MediatorRegistry
end

-- 获取指定标记的Mediator子类实例
-- name - Mediator子类标记，可以参考MediatorRegistry.lua中定义的注册表中的key值
function MediatorMgr:retrieveMediator(name)
	-- body
	assert(type(name) == "string")
	if string.len(name) <= 0 then
		print("<MediatorMgr | retrieveMediator - argument(name) is empty");
		return
	end

	self._mediators = self._mediators or {}

	local ret = self._mediators[name]
	if not ret then
		print("<MediatorMgr | retrieveMediator - mediator(" .. name .. ") unfound")
	end
	return ret
end

function MediatorMgr:finalizer()
	for _, v in pairs(self._mediators) do
		v:finalizer()
	end
end

function MediatorMgr:setPopupNodeCount(nowCount)
	self.PopWindowCounts = nowCount
end

function MediatorMgr:getPopupNodeCount()
	return self.PopWindowCounts
end

cc.exports.MediatorMgr = cc.exports.MediatorMgr or MediatorMgr:create()
return cc.exports.MediatorMgr