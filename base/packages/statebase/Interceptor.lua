---------------------------------------------
-- module : 拦截器基类
-- auther : cruelogre
-- Date:    2016.11.18
-- comment: 结合状态机使用
--  		1. 核心拦截方法intercept
--			2. 实现 startExecute 进入模块
--			3. 实现 startExecute 进入模块
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local Interceptor = class("Interceptor")

--@param iID(string) 拦截器ID 
--@param priority(number) 拦截器优先级 
function Interceptor:ctor(iID,priority)
	
	self.logTag = self.__cname..".lua"
	self.interceptorID = iID or self.logTag
	self.priority = priority or 0
end

--拦截方法
--@return true 表示成功，阻止进入 false 表示失败  进入下一逻辑
-- 当返回 true 拦截成功 阻止进入
-- 返回 false 时 拦截失败 进入下一逻辑
function Interceptor:intercept(...)
	return true
end
--这里是一个空的实现 进入
function Interceptor:startExecute(...)
	wwlog(self.logTag,"拦截失败，继续执行...")
end
--这里是一个空的实现 阻止
function Interceptor:stopEnter(...)
	wwlog(self.logTag,"拦截成功，阻止执行...")
end

--回收
function Interceptor:finalizer()

end
return Interceptor