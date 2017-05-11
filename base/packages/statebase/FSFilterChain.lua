---------------------------------------------
-- module : 过滤器链
-- auther : cruelogre
-- Date:    2016.11.23
-- comment: 过滤器集合 分发器
--  		1. 核心过滤方法doFilter 迭代过滤器 判断过滤

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local FSFilterChain = class("FSFilterChain")


function FSFilterChain:ctor(name)
	self.name = name
	self.logTag = self.__cname..".lua"
	if self.name then
		self.logTag = self.logTag.." "..self.name
	end
	self.filters = {}
	self.pos = 1
	
end
--插入过滤器
function FSFilterChain:addFilter(filter)
	wwlog(self.logTag,"添加过滤器 filterId %s",tostring(filter.filterId))
	if not self:isFilterExists(filter) then
		table.insert(self.filters,filter)
		self:sortChain()
	end
	wwlog(self.logTag,"过滤器-->  长度%d",table.maxn(self.filters))
end
--清空过滤器
function FSFilterChain:clearFilter()
	while true do
        local k =next(self.filters)
        if not k then break end
		table[k].finalizer()
        table[k] = nil
    end
end

--排序过滤器，按照优先级从高到底 priority越小  优先级越高
function FSFilterChain:sortChain()
	if table.getn(self.filters)>1 then
		table.sort(self.filters,function (i1,i2)
			return i1.priority < i2.priority
		end)
	end
end

function FSFilterChain:removeFilter(filterID)
	local filterPos = -1
	table.walk(self.filters,function (v,k)
		if v.filterID==filterID then
			filterPos = k
		end
	end)
	if filterPos>0 then
		self.filters[filterPos]:finalizer()
		self.filters[filterPos] = nil
	end
end
--通过filter ID 查询是否存在
function FSFilterChain:isFilterExists(filterID)
	local hasInter = false
	table.walk(self.filters,function (v,k)
		if v.filterID==filterID then
			hasInter = true
		end
	end)
	return hasInter
end


--过滤方法
--@return 
function FSFilterChain:doFilter(eventName)
	
	local tableLen = table.maxn(self.filters)
	wwlog(self.logTag,"过滤  长度%d",tableLen)
	if tableLen==0 then
		return
	end
	self.pos = math.min(self.pos,tableLen)
	local deleteFilters = {}
	
	while self.pos<=tableLen do
		local filter = self.filters[self.pos]
		if filter.filterCount ~=0 then
			if filter:doFilter(self,eventName) then
				local fCount = filter.filterCount
				wwlog(self.logTag,"过滤器剩余次数%d",fCount)
				if fCount==0 then --过滤次数完成 要删除
					table.insert(deleteFilters,filter.filterID)
				end
			else
				break
			end
		else
			table.insert(deleteFilters,filter.filterID)
		end
		self.pos = self.pos +1
	end

	
	for _,v in pairs(deleteFilters) do
		self:removeFilter(v)
	end
	if next(deleteFilters) then
		self:sortChain()
	end
	removeAll(deleteFilters)
	self.pos = 1
end


return FSFilterChain