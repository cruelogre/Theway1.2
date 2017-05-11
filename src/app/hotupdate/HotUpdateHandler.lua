---------------------------------------------
-- module : 热更处理
-- auther : cruelogre
-- Date:    2016.11.3
-- comment: 
--  		1. 每个模块ID mGameModuleID
--			2.实现 startExecute 进入模块
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------

local HotUpdateHandler = class("HotUpdateHandler",require("app.hotupdate.ModuleBaseHandler"))

local moduleId = 9999 --热更的模块ID
function HotUpdateHandler:ctor()
	HotUpdateHandler.super.ctor(self)
	self.mGameModuleID = moduleId --模块的ID
	
	self:initUpgradeMgr()

end
--设置显示更新界面
function HotUpdateHandler:setShowUpdateView(isShow)
	self.showUpdateView = isShow
end
function HotUpdateHandler:initUpgradeMgr()
	HotUpdateHandler.super.initUpgradeMgr(self)
	self.upAssetMgr:onInitUserData("HotUpdate","1")

end
function HotUpdateHandler:setCurClientVersion()
	
	HotUpdateHandler.super.setCurClientVersion(self,wwConfigData.GAME_VERSION,self.targetSubVersion )
end
--监测更新  默认不需要
--@param targetSubversion 目标子版本号

--@return true 不需要更新
--@return false 需要更新
function HotUpdateHandler:intercept(targetSubversion)
	wwlog(self.logTag,"热更新比较小版本号")
	local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
	local localSub = HotUpdateProxy:getCurSubversion(wwConfigData.GAME_VERSION) --本地小版本号
--[[	self.targetSubVersion = 1
	self:setCurClientVersion()--]]
	self.upAssetMgr:onInitUserData("subVersion",tostring(targetSubversion))
	self.targetSubVersion = targetSubversion
	
	--对于小版本
	wwlog(self.logTag,"local subversion %d  target subversion %d",localSub,targetSubversion)
	
	if targetSubversion>localSub then
		--红点显示
		WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "set", true)
		self:stopEnter()
	else 
		WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "set", false)
		self:startExecute()
		return true
	end
	--弹出更新界面
	return false --需要更新
end

--这里是一个空的实现 进入
function HotUpdateHandler:startExecute()
	HotUpdateHandler.super.startExecute(self)
end
function HotUpdateHandler:isGameModuleResExisted()
	return HotUpdateHandler.super.isGameModuleResExisted(self)
end

--更新模块资源
function HotUpdateHandler:stopEnter()
	--根据什么条件 判断是静默还是显示
	--默认是显示更新，就是弹出更新界面
	local flag = false --静默标志
	local netType = ww.IPhoneTool:getInstance():checkNetState()
	if netType=="wifi" then --wif的情况下 就显示下载
		flag = true
	end
	if self.showUpdateView then
		HotUpdateHandler.super.stopEnter(self)
	else
		
		if flag then
			local param = {
				subVersion = self.targetSubVersion
			}
			if not SilentUpdateQueue:checkDownloadTask(self.mGameModuleID) then
				wwlog(self.logTag,"开始静默下载中")
				SilentUpdateQueue:pushDownloadTask(self.mGameModuleID,param)
			else
				wwlog(self.logTag,"已经在静默下载中了")
			end
			
			
		else
			wwlog(self.logTag,"当前是非流量状态，限制更新")
			HotUpdateHandler.super.stopEnter(self)
		end
	end

	
end

return HotUpdateHandler