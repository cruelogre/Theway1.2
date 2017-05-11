---------------------------------------------
-- module : 状态机配置管理
-- auther : cruelogre
-- comment: 从配置文件中读取状态列表，实例化
--2016.11.07 v1.1 添加模块监测
--2016.11.23 v1.2  添加过滤器 
--2017.1.5 v1.2  添加资源清除标识配置
---------------------------------------------
local FSRegistry = class("FSRegistry")
--local registry = require("login.fsm.init")
local FiniteStateMachine = require("packages.statebase.FiniteStateMachine")
--FSRegistry.fsm = nil
--配置文件
function FSRegistry:ctor(registry)
	self.fsm = FiniteStateMachine:create()
	self.registry = registry
	self:init(registry)
	
end
-- 从配置文件中
function FSRegistry:init(registry)
	for _,v in pairs(registry) do
		local cfg = require(v)
		
		local controller = require(cfg.controller):create()
		controller:initRes(cfg.resData)
		controller:initViewData(cfg.view)
		local mInterceptorChain = nil
		--初始化拦截器
		if cfg.interceptor and next(cfg.interceptor) then
			mInterceptorChain = require("packages.statebase.InterceptorChain"):create()
			local interceptor = nil
			for _,v in pairs(cfg.interceptor) do
				
				interceptor = require(v.name):create(v.id,v.priority)
				mInterceptorChain:addInterceptor(interceptor)
			end
			
			
		end
		--初始化过滤器 过滤器是可以动态添加的
		local mFilterChain = require("packages.statebase.FSFilterChain"):create(cfg.stateName)
		
		if cfg.filter and next(cfg.filter) then
			local filter = nil
			for _,v in pairs(cfg.filter) do
				
				filter = require(v.name):create(v.id,v.priority)
				mFilterChain:addFilter(filter)
			end
			
		end
		
		self.fsm:register(cfg.stateName,controller,mInterceptorChain,mFilterChain)

		
		if cfg.entry then
			self.fsm:entryPoint(cfg.stateName)
			self.fsm:setResourceLimit(cfg.resLimit)
		end
	end
	
	for _,v in pairs(registry) do
		local cfg = require(v)
		
		if cfg.enter and cfg.stateName then
			for _,e in pairs(cfg.enter) do
				if self.fsm:state(e.stateName) then
					self.fsm:state(cfg.stateName):on(e.eventName):enter(e.stateName)
				end
				
			end
		end
		
		if cfg.push and cfg.stateName then
			for _,p in pairs(cfg.push) do
				if self.fsm:state(p.stateName) then
					self.fsm:state(cfg.stateName):on(p.eventName):push(p.stateName)
				end
				
			end
		end
		
		if cfg.pop and cfg.stateName then
			for _,p in pairs(cfg.pop) do
					self.fsm:state(cfg.stateName):on(p.eventName):pop()
			end
		end
		if cfg.clearRes and self.fsm:state(cfg.stateName) then
			self.fsm:state(cfg.stateName).clearRes = cfg.clearRes
		end
	end
end
--触发事件
function FSRegistry:trigger(eventName,param)
	self.fsm:trigger(eventName,param)
end
--添加过滤器到状态中
--@param stateName 状态名
--@param filter 过滤器实例
function FSRegistry:addFilter(stateName,filter)
	local fstate = self.fsm:state(stateName)
	if fstate and fstate.filterObject then
		fstate.filterObject:addFilter(filter)
	end
end
--删除状态中的过滤器
--@param stateName 状态名
--@param filterId 过滤器ID
function FSRegistry:removeFilter(stateName,filterId)
	local fstate = self.fsm:state(stateName)
	if fstate and fstate.filterObject then
		fstate.filterObject:removeFilter(filterId)
	end
end
--执行当前状态的过滤器
--@param filterType 过滤类型
function FSRegistry:doFilter(filterType)
	self:currentState():doFilter(filterType)
end
function FSRegistry:currentState()
	return self.fsm:currentState()
end
function FSRegistry:onEntry(param)
	self.fsm:onEntry(param)
end
--状态机退出
function FSRegistry:clear()
	while self.fsm:currentState().mStateName ~= self.fsm.mEntryPoint do
		local lastStateName = self.fsm:pop(nil,true)
		print("pop state",lastStateName)
	end
	--最后弹出入口
	if self.fsm then
		self.fsm:pop(nil,true)
	end
end
--状态机重置
function FSRegistry:reInit()
	self:clear()
	self.fsm = nil
	self.fsm = FiniteStateMachine:create()
	self:init(self.registry)
	
end
return FSRegistry