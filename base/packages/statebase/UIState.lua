---------------------------------------------
-- module : 状态基础类
-- auther : cruelogre
-- comment: 状态基础类，所有UI的状态都必须继承它
--  		1.实现方法onEnter，onExit
--			2.如果要实现onLoad，onUnload 那必须要用基础类的此方法
-- v1.1 添加过滤器 生命周期的时候执行过滤器
---------------------------------------------
local UIState = class("UIState")

--UIState.parentNode = nil
--UIState.localZorder = 0
--UIState.res = {}
local ResourceType = {
	Texture = 1;
	Plist = 2;
	Armature = 3;
	Music = 4;
	FrameAnim = 5;
}

function UIState:ctor()
	self.moduleHandler = nil
	self.logTag = self.__cname..".lua"
end

function UIState:clear()
	self.res = {}
	self.res[ResourceType.Texture] = {}
	self.res[ResourceType.Plist] = {}
	self.res[ResourceType.Armature] = {}
	self.res[ResourceType.Music] = {}
	self.res[ResourceType.FrameAnim] = {}
	--父节点
	self.parentNode = nil 
	--跟节点
	self.rootNode = nil
	--UI节点
	self.viewNode = nil
	
	self.localZorder  =0 
end
--[[
-- 	返回该状态的标识符
--]]
function UIState:stateName()
	return self.uniqueId
end
--[[
-- 	初始化资源
--]]
function UIState:initRes(resTable)
	self:clear()
	self.uniqueId = tostring(self.class.__cname)
	if not resTable then return end
	if resTable.Texture and type(resTable.Texture)=="table" then
		copyTable(resTable.Texture,self.res[ResourceType.Texture])
	end
	if resTable.Plist and type(resTable.Plist)=="table" then
		copyTable(resTable.Plist,self.res[ResourceType.Plist])
	end
	if resTable.Armature and type(resTable.Armature)=="table" then
		copyTable(resTable.Armature,self.res[ResourceType.Armature])
	end
	if resTable.Sound and type(resTable.Sound)=="table" then
		copyTable(resTable.Sound,self.res[ResourceType.Music])
	end
	if resTable.FrameAnim and type(resTable.FrameAnim)=="table" then
		copyTable(resTable.FrameAnim,self.res[ResourceType.FrameAnim])
	end
	
end
--[[
-- 	设置界面路径
--]]
function UIState:initViewData(viewPath)
	self.viewPath = viewPath
end

--[[
-- 	提供状态机调用，加载资源具体实现
-- 加载顺序：纹理(异步)-->图集,帧动画,音效-->骨骼动画(异步)
-- 如果要在及资源加载前显示UI，可以在子类的这个函数中写，通过self.rootNode 来添加
--]]
function UIState:onLoad(lastStateName,param)
	cclog(self.logTag.." onload")
	self.param = param
	if iskindof(param,"cc.Node") then
		self.parentNode = param
	elseif type(param) == "Number" then
		self.localZorder = param
		self.parentNode = param.parentNode or display.getRunningScene()
	elseif type(param) == "table" then
		self.parentNode = param.parentNode or display.getRunningScene()
		self.localZorder = param.zorder or 1
	end
	if isLuaNodeValid(self.parentNode) then
		self.rootNode = cc.Layer:create()
		self.rootNode:addTo(self.parentNode,self.localZorder)
	end

	WWAsynResLoader:loadTexture(self.uniqueId,self.res[ResourceType.Texture],handler(self,UIState.textureCB))
end

--[[
-- 	纹理加载回调
--]]
function UIState:textureCB()
	
	WWAsynResLoader:loadPlist(self.uniqueId,self.res[ResourceType.Plist])
	WWAsynResLoader:loadFrameAnimation(self.uniqueId,self.res[ResourceType.FrameAnim])
	WWAsynResLoader:loadMusic(self.uniqueId,self.res[ResourceType.Music])
	WWAsynResLoader:loadAmature(self.uniqueId,self.res[ResourceType.Armature],handler(self,UIState.armatureCB))
	
	
end
--[[
-- 	骨骼动画加载回调
--]]
function UIState:armatureCB()
	--所有资源加载完毕，创建界面
	if self.viewPath then
		local view = require(self.viewPath):create(self.param)
		self.viewNode = nil
		if view.root and self.parentNode then
			if isLuaNodeValid(self.rootNode) then
				self.rootNode:addChild(view.root,self.localZorder)
			else
				self.parentNode:addChild(view.root,self.localZorder)
				self.rootNode = view.root
			end
			self.viewNode = view.root
		elseif iskindof(view,"cc.Node") and self.parentNode then
			if isLuaNodeValid(self.rootNode) then
				self.rootNode:addChild(view,self.localZorder)
			elseif self.parentNode then
				self.parentNode:addChild(view,self.localZorder)
				self.rootNode = view
			end
			self.viewNode = view
		end
	end
	--进入界面
	--资源没加载完，就退出了
	if isLuaNodeValid(self.parentNode) then
		self:onStateEnter()
	end
	
	FSRegistryManager:currentFSM():doFilter(FSConst.FilterType.Filter_Enter)
end
function UIState:onStateEnter()
	cclog(self.logTag.." onEnter")
end
--重新进入 在上层状态机被弹出时，这个调用 不是走加载流程
function UIState:onStateResume()
	cclog(self.logTag.." onStateResume")
	FSRegistryManager:currentFSM():doFilter(FSConst.FilterType.Filter_Resume)
end

--其他状态机覆盖在当前状态机上时 调用
function UIState:onStatePause()
	cclog(self.logTag.." onStatePause")
	FSRegistryManager:currentFSM():doFilter(FSConst.FilterType.Filter_Pause)
end

function UIState:onStateExit()
	cclog(self.logTag.." onExit")

end
--[[
-- 	提供状态机调用，卸载资源
--]]
function UIState:onUnload(newStateName,clearRes)
	cclog(self.logTag.." onUnload")
	if clearRes then
		WWAsynResLoader:unloadSound(self.uniqueId)
		WWAsynResLoader:unloadPlist(self.uniqueId)
		WWAsynResLoader:unloadFrameAnimation(self.uniqueId)
		WWAsynResLoader:unloadTexture(self.uniqueId)
	end
	self:onStateExit()
	
	--删除当前界面
	if isLuaNodeValid(self.viewNode) then
		self.viewNode:stopAllActions()
		self.viewNode:removeAllChildren()
		self.viewNode:removeFromParent()
	end
	self.viewNode = nil

	if isLuaNodeValid(self.rootNode) then
		self.rootNode:stopAllActions()
		self.rootNode:removeAllChildren()
		self.rootNode:removeFromParent()
	end
	self.parentNode = nil
	self.viewNode = nil
	self.rootNode = nil
	FSRegistryManager:currentFSM():doFilter(FSConst.FilterType.Filter_Exit)
end

return UIState