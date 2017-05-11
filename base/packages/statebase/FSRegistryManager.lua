---------------------------------------------
-- module : 状态机管理器类
-- auther : cruelogre
-- comment: 外界调用，场景状态机注册，切换

---------------------------------------------

local FSRegistryManager = class("FSRegistryManager")
local FSRegistry = require("packages.statebase.FSRegistry")
require("app.fsm.FSMConfig")
function FSRegistryManager:ctor()
	self.fsms = {}
	self.curFSMName = nil
	self.logTag = "FSRegistryManager.lua"
	self:initConfig()
end
--注册 初始化
function FSRegistryManager:initConfig()
	removeAll(self.fsms)
	for name,iniPath in pairs(FSMConfig) do
		self.fsms[iniPath] = FSRegistry:create(require(iniPath))
	end
end
--仅仅返回状态机实例 外部一般不用调用这个
function FSRegistryManager:getFSM(name)
	return self.fsms[name]
end
--清除某个状态机实例的堆栈 这个在断线重新登录的时候，跳转到登录界面的时候调用，和切换状态机的时候调用
-- 切换状态内容自动调用
function FSRegistryManager:clearFSM(name)
	if name then
		if self.fsms[name] then
			self.fsms[name]:clear()
		end
	else
		if self.curFSMName and self.fsms[self.curFSMName] then
			self.fsms[self.curFSMName]:clear()
			self.curFSMName = nil
		end
	end

	local releaseTag = true
	for k,v in pairs(FSMRetain) do
		if v == name then
			releaseTag = false
			break
		end
	end

	if releaseTag then
		cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
		cc.Director:getInstance():getTextureCache():removeUnusedTextures()
		wwlog(self.logTag,cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	end
end
-- 把某个状态机设置为当前状态机，清空以前的状态机
function FSRegistryManager:runWithFSM(name)
	local curFSM = self:getFSM(name)
	if not curFSM then
		return nil
	end
	if self.curFSMName and self.curFSMName~=name then
		self:clearFSM(self.curFSMName)
	end
	
	self.curFSMName = name
	return curFSM
end
function FSRegistryManager:currentFSM()
	return self:runWithFSM(self.curFSMName)
end
--设置进入后就打开的状态
function FSRegistryManager:setJumpState(stateName,param)
	
	self.stateName = stateName
	self.jumpParam = param
	wwlog(self.logTag,"self.stateName %s",self.stateName)
end
function FSRegistryManager:getJumpState()
	return self.stateName
end
function FSRegistryManager:getJumpParam()
	return self.jumpParam
end

--直接跳转到状态机
function FSRegistryManager:jumpToState()

end
--清空打开状态，防止重复打开
function FSRegistryManager:clearJumpState()
	self.stateName = nil
	self.jumpParam = nil
end
cc.exports.FSRegistryManager = cc.exports.FSRegistryManager or FSRegistryManager:create()
return cc.exports.FSRegistryManager