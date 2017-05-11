---------------------------------------------
-- module : 状态机事件封装类
-- auther : cruelogre
-- comment: 事件描述，以及事件类型，执行事件
--  		1.事件类型，push，enter(push new one pop last one)，pop
--			2.执行事件
--修改日志
--2016.11.07 添加模块监测
---------------------------------------------
local FSEvent = class("FSEvent")
local EventType = {
	NONE = 1;
	ENTER = 2;
	PUSH = 3;
	POP = 4}
--[[ self.mEnterDelegate = nil
 FSEvent.mPushDelegate = nil
 FSEvent.mPopDelegate = nil

 FSEvent.eType = EventType.NONE

 FSEvent.mEventName = ""
 FSEvent.mStateOwner = nil
 FSEvent.mTargetState = ""
 FSEvent.mOwner = nil
 FSEvent.mAction = nil--]]

--创建状态机事件
--@param name 事件的名字
--@param target 目标状态名字
--@param state 状态实例
--@param owner 状态机实例
--@param ent enter回调
--@param pu push回调
--@param po pop回调
--@param mh 模块监测回调

function FSEvent:ctor(name,target,state,owner,ent,pu,po,mh)
	self.mEventName = name
	self.mStateOwner = state
	self.mTargetState = target
	self.mOwner = owner
	
	if ent and type(ent) == "function" then
		self.mEnterDelegate = ent
	end
	if pu and type(pu) == "function" then
		self.mPushDelegate = pu
	end
	if po and type(po) == "function" then
		self.mPopDelegate = po
	end
	if mh and type(mh) == "function" then
		self.moduleHandler = mh
	end
	
	
	self.eType = EventType.NONE
end

function FSEvent:enter(stateName)
	self.mTargetState = stateName
    self.eType = EventType.ENTER
    return self.mStateOwner
end
function FSEvent:push(stateName)
	self.mTargetState = stateName
    self.eType = EventType.PUSH
    return self.mStateOwner
end

function FSEvent:pop()
	self.eType = EventType.POP
end
function FSEvent:excute(param)
	
	if self.eType == EventType.POP then
		self.mPopDelegate()
	elseif self.eType == EventType.PUSH then
		self.mPushDelegate(self.mTargetState, self.mOwner:currentState().mStateName,param)
	elseif self.eType == EventType.ENTER then
		self.mEnterDelegate(self.mTargetState,param)
	elseif self.mAction then
		self.mAction(param)
	end
end

function FSEvent:check(param)
	if self.moduleHandler then
		return self.moduleHandler(param)
	else
		 return true --默认返回true
	end
	
end
return FSEvent