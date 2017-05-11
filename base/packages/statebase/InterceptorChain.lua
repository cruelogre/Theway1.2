---------------------------------------------
-- module : 拦截器链
-- auther : cruelogre
-- Date:    2016.11.18
-- comment: 拦截器集合 分发器
--  		1. 核心拦截方法doChain 迭代拦截器集合 判断拦截

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local InterceptorChain = class("InterceptorChain")

function InterceptorChain:ctor()
	self.logTag = self.__cname..".lua"
	self.interceptors = {}
end
--插入拦截器
function InterceptorChain:addInterceptor(interceptor)
	if not self:isInterceptorExists(interceptor) then
		table.insert(self.interceptors,interceptor)
		self:sortChain()
	end
	
end
--清空拦截器
function InterceptorChain:clearInterceptor()
	while true do
        local k =next(self.interceptors)
        if not k then break end
		table[k].finalizer()
        table[k] = nil
    end
end

--排序拦截器，按照优先级从高到底 priority越小  优先级越高
function InterceptorChain:sortChain()
	if table.getn(self.interceptors)>1 then
		table.sort(self.interceptors,function (i1,i2)
			return i1.priority < i2.priority
		end)
	end
end

--通过interceptor ID 查询是否存在
function InterceptorChain:isInterceptorExists(interceptorID)
	local hasInter = false
	table.walk(self.interceptors,function (v,k)
		if v.interceptorID==interceptorID then
			hasInter = true
		end
	end)
	return hasInter
end
--拦截方法
--@return true 表示成功 未被拦截 false 表示失败   阻止进入
function InterceptorChain:doChain(...)
	local success = true --是否被拦截下来了
	for _,interceptor in pairs(self.interceptors) do
		if interceptor:intercept(...) then
			interceptor:stopEnter(...)
			success = false
			break
		else
			interceptor:startExecute(...)
		end
		
	end
	return success
end

return InterceptorChain