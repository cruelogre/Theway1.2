--[[
	note:控制器基类为app.controller.Controller.lua，所有自定义的控制器必须继承此类
	控制器管理器实例(全局实例，直接访问)
	1、初始化注册的控制器
	2、管理各个Controller子类的实例及生命同期
	3、查询并获取指定标记的Controller实例

	<code>
		a.查询
		ControllerMgr:retrieveController(name)
	</code>

	TODO:是否需要添加手动加入和移除指定Controller实例的接口
--]]

local ControllerMgr = class("ControllerManager")

function ControllerMgr:ctor()
	-- body
	print("ControllerMgr:ctor")
	self:init()
end

function ControllerMgr:init()
	-- body
	print("ControllerMgr:init")
	self._controllers = self._controllers or {}

	local registry = self:getControllerRegistry()

	for _, v in pairs(registry) do
		print(_, v)
		self._controllers[v] = require(v):create()
	end
end

function ControllerMgr:getControllerRegistry()
	-- body
	return cc.exports.ControllerRegistry
end

-- 获取指定标记的Controller子类实例
-- name - Controller子类标记，可以参考ControllerRegistry.lua中定义的注册表中的key值
function ControllerMgr:retrieveController(name)
	-- body
	assert(type(name) == "string")
	if string.len(name) <= 0 then
		print("<ControllerMgr | retrieveController - argument(name) is empty")
		return
	end

	self._controllers = self._controllers or {}

	local ret = self._controllers[name]
	if not ret then
		print("<ControllerMgr | retrieveController - controller(" .. name .. ") unfound");
	end
	return ret
end

function ControllerMgr:finalizer()
	-- body
	for _, v in pairs(self._controllers) do
		v:finalizer()
	end
end

cc.exports.ControllerMgr = cc.exports.ControllerMgr or ControllerMgr:create()
return cc.exports.ControllerMgr