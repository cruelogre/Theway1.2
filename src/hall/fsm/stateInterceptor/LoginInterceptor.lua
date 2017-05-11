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
local LoginInterceptor = class("LoginInterceptor",require("packages.statebase.Interceptor"))

local IPhoneTool = ww.IPhoneTool:getInstance()

--@param iID(string) 拦截器ID 
--@param priority(number) 拦截器优先级 
function LoginInterceptor:ctor(iID,priority)
	LoginInterceptor.super.ctor(self,iID,priority)
end

--拦截方法
--@return true 表示成功，阻止进入 false 表示失败  进入下一逻辑
-- 当返回 true 拦截成功 阻止进入
-- 返回 false 时 不拦截 进入下一逻辑
function LoginInterceptor:intercept(...)
	wwlog(self.logTag,"登录拦截器开始拦截...")
	local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
	if loginMsg and next(loginMsg) and loginMsg.hallversion then
		return false
	end
	return true
end
--这里是一个空的实现 进入
function LoginInterceptor:startExecute(...)
	wwlog(self.logTag,"拦截失败，继续执行...")
end
--这里是一个空的实现 阻止
function LoginInterceptor:stopEnter(...)
	wwlog(self.logTag,"拦截成功，阻止执行...")
	local para = {}
	para.type = IPhoneTool:isNetworkConnected() and 2 or 1
	para.isAnim = true
	local NetWorkProxy = self:getNetWorkProxy()
	para.btnCallback = function (mType)
		--wwConfigData.REQUEST_IPS = {"192.168.10.53", }
		if mType == 1 then
			
			NetWorkProxy:connectServer()
		else
			--NetWorkProxy:fastLoin()
			NetWorkProxy:connectServer()
		end
		
		--self.systemInfoNode = nil
		LoadingManager:startLoading(0.0,LOADING_MODE.MODE_NORMAL,i18n:get('str_common','comm_net_connectding'))
		
	end

	local systemInfoNode = import(".SystemInfoDialog", "app.views.customwidget."):create( para )
	
	systemInfoNode:show()
		
end

function LoginInterceptor:getNetWorkProxy()
	return ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
end
--回收
function LoginInterceptor:finalizer()
	LoginInterceptor.super.finalizer(self)
end
return LoginInterceptor