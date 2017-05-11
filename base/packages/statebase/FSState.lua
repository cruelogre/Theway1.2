---------------------------------------------
-- module : 状态的基本操作
-- auther : cruelogre
-- comment: 这里类主要是状态的基本操作以及事件触发
--  		1.包装事件，注册事件
--			2.通过事件ID，触发事件

-- 2016.11.07 v1.1  添加模块监测
-- 2016.11.23 v1.2  添加过滤器 
-- 2017.1.5 v1.2  添加资源清除标识配置 
---------------------------------------------

local FSState = class("FSState")
local FSEvent = require("packages.statebase.FSEvent")

--[[FSState.mEnterDelegate = nil
FSState.mPushDelegate = nil
FSState.mPopDelegate = nil

FSState.mStateObject = nil
FSState.mStateName = ""
FSState.mOwner = nil
FSState.mTranslationEvents = {}--]]

function FSState:ctor(obj,owner,name,enter,push,pop,handler)
	--UIState 实体对象
	self.mStateObject = obj
	--状态机
	self.mOwner = owner
	--UIState 实体对象的状态名字
	self.mStateName = name
	
	self.handlerObject = nil
	self.clearRes  = false --默认清除资源
	if enter and type(enter)=="function" then
		self.mEnterDelegate = enter
	end
	if push and type(push)=="function" then
		self.mPushDelegate = push
	end
	if pop and type(pop)=="function" then
		self.mPopDelegate = pop
	end
	if handler and type(handler)=="function" then
		self.mModuleDelegate = handler
	end
	--事件集合
	self.mTranslationEvents = {}
	
end
function FSState:setHandlerObj(handlerObj)
	self.handlerObject = handlerObj
end

function FSState:setFilterObj(filterObj)
	self.filterObject = filterObj
end

--获取或者创建一个事件
function FSState:on(eventName)
	local newEvent = self.mTranslationEvents[eventName]
	if not newEvent then
		newEvent = FSEvent:create(eventName,nil,self,self.mOwner,self.mEnterDelegate,self.mPushDelegate,self.mPopDelegate,self.mModuleDelegate)
		self.mTranslationEvents[eventName] = newEvent
	end
	
	return newEvent
end

function FSState:doFilter(filterType)
	if self.filterObject then
		self.filterObject:doFilter(filterType)
	end
end
--通过事件ID的,触发事件
--@param eventName 事件名字
--@param param 参数表(一般是node，或者table表)
function FSState:trigger(eventName,param)
	local fsevent = self.mTranslationEvents[eventName]
	--这里先判断是否有模块监测功能
	if fsevent then
		if fsevent:check(fsevent.mTargetState) then
			fsevent:excute(param)
			
			--self.filterObject:doFilter(eventName)
		else
			--被拦截下来
			cclog(string.format("FSState:trigger has been Intercepted %s",eventName))
		end
		
	else
		cclog(string.format("FSState:trigger error: %s trigger an unregistered event %s",self.mStateName,eventName))
	end
	--self.mTranslationEvents[eventName]:excute(param)
end

return FSState