---------------------------------------------
-- module : 跳转过滤器
-- auther : cruelogre
-- Date:    2016.11.23
-- comment: 状态机跳转过滤器
--  		1. 核心过滤方法doFilter 触发状态机事件

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local JumpFilter = class("JumpFilter",require("packages.statebase.FSFilter"))

function JumpFilter:ctor(filterId,filterType,priority)
	JumpFilter.super.ctor(self,filterId,priority)
	self.jumpEventName = nil
	self.jumpParam = nil
	--self.filterId = filterId
	self.filterType = filterType
end

function JumpFilter:setJumpData(eventName,param)
	self.jumpEventName = eventName
	self.jumpParam = param
end
function JumpFilter:doFilter(filterChain,filterType)
	--wwlog(self.logTag,"doFilter filterId %s 自有类型 %d 分发类型 %d",tostring(self.filterId),self.filterType,filterType)
	if JumpFilter.super.doFilter(self,filterChain,filterType) then
		--wwlog(self.logTag,"跳转过滤器 filterId %s %s",tostring(self.filterId),self.jumpEventName)		
		if self.jumpEventName then
			FSRegistryManager:currentFSM():trigger(self.jumpEventName,self.jumpParam)
		end
	end
	
	return true
end

return JumpFilter