---------------------------------------------
-- module : 状态机操作类
-- auther : cruelogre
-- comment: 外界调用，状态的切换，以及对栈的管理，Pop和Push操作以及状态的注册
--修改日志
--2016.11.07 v1.1 添加模块监测
--2016.11.18 v1.1.1 修改模块监测  统一命名为拦截器
--2016.11.23 v1.2  添加过滤器
--2015.12.08 v1.3	优化状态机队列资源
-- 2017.1.5 v1.2  添加资源清除标识配置
---------------------------------------------
local FiniteStateMachine = class("FiniteStateMachine")
local Stack = require("packages.statebase.Stack")
local FSState = require("packages.statebase.FSState")
local WWList = require("packages.statebase.WWList")
--[[FiniteStateMachine.mStates = {}
FiniteStateMachine.mStateStack = nil
FiniteStateMachine.mEntryPoint = nil--]]
function FiniteStateMachine:ctor()
	--状态集合，供注册
	self.mStates = {}
	--栈状态，提供状态切换
	self.mStateStack = Stack:create()
	--保存状态的资源
	self.resList = WWList:create() 
	--可能释放的资源队列
	self.resRemoveList = WWList:create()
	
	self.resLimit = 1
	--入口状态
	self.mEntryPoint = nil
	self.logTag = "FiniteStateMachine.lua"
end
--设置队列资源长度
function FiniteStateMachine:setResourceLimit(limit)
	
	self.resLimit = limit and tonumber(limit) or self.resLimit
end
--[[
--	返回栈顶状态
--]]
function FiniteStateMachine:currentState()
	if self.mStateStack:size()==0 then
		self.mStateStack:push(self.mStates[self.mEntryPoint])
		--return nil
	end
	return self.mStateStack:top()
end
function FiniteStateMachine:update()
--[[	if self:currentState()==nil then
		self.mStateStack:push(self.mStates[self.mEntryPoint])
		local curstate= self:currentState()
		curstate.mStateObject:onLoad()
	end--]]
end
--[[
--	进入初始状态
--]]
function FiniteStateMachine:onEntry(param)
	if self:currentState()==nil then
		self.mStateStack:push(self.mStates[self.mEntryPoint])
	end

	local curstate = self:currentState()
	curstate.mStateObject:onLoad(nil,param)

end
--[[
--	注册状态
-- @param stateName 状态名字
-- @param stateObject 状态对象
--]]
function FiniteStateMachine:register(stateName,stateObject,handlerObject,filterObj)
	if table.nums(self.mStates) == 0 then
		self.mEntryPoint = stateName
	end
	--self.mStates
	local fs = self.mStates[stateName] 
	if not fs then --状态名字和状态对象一一对应
		fs = FSState:create(stateObject,self,stateName,
			handler(self,FiniteStateMachine.enter),handler(self,FiniteStateMachine.push),
			handler(self,FiniteStateMachine.pop),handler(self,self.checkInterceptor))
		
		fs:setHandlerObj(handlerObject)
		fs:setFilterObj(filterObj)
	
		self.mStates[stateName]= fs
	else
		wwlog(self.logTag,string.format("FiniteStateMachine:register has registered state %s",stateName))
	end
	
end
--[[
--	获取状态对象
-- @param stateName 状态名字
--]]
function FiniteStateMachine:state(stateName)
	return self.mStates[stateName]
end
--[[
--	设置入口状态
-- @param stateName 状态名字
--]]
function FiniteStateMachine:entryPoint(stateName)
	self.mEntryPoint = stateName
end
--监测拦截器
function FiniteStateMachine:checkInterceptor(stateName)
	local fs = self.mStates[stateName]
	if not fs then
		return true
	else
		if fs.mStateName ==self.mEntryPoint then --根状态 不需要监测
			return true
		elseif fs.handlerObject then --拦截器链
			--fs.handlerObject:initUpgradeMgr() --先初始化一下
			return fs.handlerObject:doChain()
		else
			return true --没有配置检测器
		end
	end

end
--enter 回调
function FiniteStateMachine:enter(stateName,param)
	
	self:push(stateName,self:pop(stateName),param)
end

--push 回调
function FiniteStateMachine:push(newState,param)
	local lastName = nil
	if self.mStateStack:size()>=1 then
		lastName = self.mStateStack:top().mStateName
	end
	self:push(newState,lastName)
end

function FiniteStateMachine:push(stateName,lastStateName,param)

	--如果新状态机底部有状态机 那么那个状态机要onStatePause
	local lastState = self.mStateStack:top()
	if lastState then
		if lastState.mStateObject and lastState.mStateObject.onStatePause then
			lastState.mStateObject:onStatePause()
		end
	end
	self.mStateStack:push(self.mStates[stateName])
	self.mStateStack:top().mStateObject:onLoad(lastStateName,param)
	local curUniqueId = self.mStateStack:top().mStateObject.uniqueId
	
	self.resList:pushBack(curUniqueId)
end
--pop 回调
function FiniteStateMachine:pop(newName,clearRes)
	local lastState = self.mStateStack:top()
	local newState = nil
	if newName==nil and self.mStateStack:size()>1 then
		newState = self.mStateStack:at(self.mStateStack:size()-1)
	else
		newState = newName
	end
	
	local lastStateName = nil
	if lastState then
		if not clearRes then
			clearRes = lastState.clearRes
		end
		lastStateName = lastState.mStateName
		lastState.mStateObject:onUnload(type(newState)=="string" and newState or (newState and newState.mStateName or nil),clearRes)
		local curUniqueId = lastState.mStateObject.uniqueId
		self.resRemoveList:pushBack(curUniqueId)
		if clearRes then
			self.resList:remove(curUniqueId)
			self.resRemoveList:remove(curUniqueId)
		end
		
		if self.resRemoveList:getSize()>self.resLimit then
			local clearId = self.resRemoveList:getFront()
			if clearId then
				WWAsynResLoader:unloadSound(clearId)
				WWAsynResLoader:unloadPlist(clearId)
				WWAsynResLoader:unloadFrameAnimation(clearId)
				WWAsynResLoader:unloadTexture(clearId)
				self.resRemoveList:popFront()
				self.resList:remove(clearId)
				print("删除缓存状态资源",clearId)
			else
				print("删除缓存状态资源不存在")
			end

		end
		
	end
	self.mStateStack:pop()
	if newState and type(newState)~="string" then
		if newState.mStateObject and newState.mStateObject.onStateResume then
			newState.mStateObject:onStateResume()
		end
	end
	return lastStateName
	
end


function FiniteStateMachine:trigger(eventName,param)
	self:currentState():trigger(eventName,param)
end



return FiniteStateMachine