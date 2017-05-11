---------------------------------------------
-- module : 过滤取器基类
-- auther : cruelogre
-- Date:    2016.11.23
-- comment: 结合状态机使用
--  		1. 过滤方法doFilter
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local FSFilter = class("FSFilter")
require("packages.statebase.FSConst")
--filterCount 过滤器次数 
--			-1 永久
--			1 一次性
function FSFilter:ctor(fID,priority)
	self.logTag = self.__cname..".lua"
	self.filterCount = 1 --默认只过滤一次
	self.priority = priority
	self.filterId = fID
	self.filterType = 0
end
--过滤方法
--@return true 表示过滤器继续执行 false 表示过滤器停止过滤
-- 当返回 true 过滤器继续执行
-- 返回 false 时 停止过滤
function FSFilter:doFilter(filterChain,filterType)
	--wwlog(self.logTag,"过滤器开始过滤")
	if  bit._and(self.filterType,filterType)> 0 and self.filterCount~=0 then
		if self.filterCount>0 then
			self.filterCount = self.filterCount - 1
		end
		return true
	end
	
	return false
end

function FSFilter:finalizer()
	
end
return FSFilter