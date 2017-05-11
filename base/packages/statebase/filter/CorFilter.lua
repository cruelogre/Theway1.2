---------------------------------------------
-- module : 协同过滤器
-- auther : cruelogre
-- Date:    2016.11.23
-- comment: 状态机协同过滤器
--  		1. 核心过滤方法doFilter 

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local CorFilter = class("CorFilter",require("packages.statebase.FSFilter"))

function CorFilter:ctor(filterId,filterType,priority)
	CorFilter.super.ctor(self,filterId,priority)
	self.jumpEventName = nil
	self.jumpParam = nil
	--self.filterId = filterId
	self.filterType = filterType
end

function CorFilter:setCorData(co)
	self.co = co
end
function CorFilter:doFilter(filterChain,filterType)
	--wwlog(self.logTag,"doFilter filterId %s 自有类型 %d 分发类型 %d",tostring(self.filterId),self.filterType,filterType)
	
	if CorFilter.super.doFilter(self,filterChain,filterType) then
		--wwlog(self.logTag,"跳转过滤器 filterId %s %s",tostring(self.filterId),self.jumpEventName)		
		if self.co then
			print("self.filterCount",self.filterCount)
			coroutine.resume(self.co)
		end
	end
	
	return true
end

return CorFilter