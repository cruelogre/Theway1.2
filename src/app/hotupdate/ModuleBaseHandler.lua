---------------------------------------------
-- module : 模块处理基类
-- auther : cruelogre
-- Date:    2016.11.3
-- comment: 模块处理器的基类 处理模块相关的流程，资源监测 进入等
--  		1. 每个模块ID mGameModuleID
--			2.实现 startExecute 进入模块
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local ModuleBaseHandler = class("ModuleBaseHandler",require("packages.statebase.Interceptor"))

local UpdateAssetLayer = import(".UpdateAssetLayer","app.views.common.")
require("app.config.wwConfigData")
require("app.config.wwConst")
require("app.data.DataCenter")
--@param dismisLayer 是否能够关闭
function ModuleBaseHandler:ctor(iID,priority)
	
	ModuleBaseHandler.super.ctor(self,iID,priority)
	self.mGameModuleID = 0 --模块的ID
	--self.logTag = self.__cname..".lua"
	self.upAssetMgr = nil --下载更新的控制器
	self.subVersionKey = nil
	
	local upgradeConfig = ww.WWConfigManager:getInstance():getModuleConfig(3)
	if upgradeConfig and upgradeConfig.items then
		for _,v in pairs(upgradeConfig.items) do
			
			if v.name=="key_hotupdate_subversion" then
				self.subVersionKey = string.format(v.values[1],wwConfigData.GAME_VERSION)
			elseif v.name == "g_LuaGameID" then
				wwConfigData.LUA_GAMEID = tonumber(v.values[1])
			elseif v.name == "g_HotUpdateBatchID" then
				wwConfigData.LUA_HOTUPDATE = tonumber(v.values[1])
			elseif v.name == "module_const" then
				--wwConfigData.MODULE_CONST = v.values[1]
			end
		
		end
	end
	
end
--是否能关闭升级框
function ModuleBaseHandler:canDismisLayer(dismisLayer)
	self.dismisLayer = dismisLayer
end
function ModuleBaseHandler:setCurClientVersion(gameversion,subVersion)
	if gameversion and subVersion then
		local key = string.format(self.subVersionKey,gameversion)
		ww.WWGameData:getInstance():setIntegerForKey(key, tonumber(subVersion))
	end
end

--初始管理器
function ModuleBaseHandler:initUpgradeMgr()
	wwlog(self.logTag,"初始化下载管理器...")
	ww.UpgradeAssetsMgrContainer:getInstance():setDownloadURL("res_dl_url",wwURLConfig.PLATFORM_URL_TEST)
	ww.UpgradeAssetsMgrContainer:getInstance():setDownloadURL("lua_hotupdate_url",wwURLConfig.LUA_HOTUPDATE_URL_TEST)
	
	self.upAssetMgr = ww.UpgradeAssetsMgrContainer:getInstance():onGetUpAssetMgr(self.mGameModuleID)
	if (self.upAssetMgr) then
		--
		--wwlog(self.logTag,"下载管理器已经存在...")
		return
	end
	local msgManager = ww.WWMsgManager:getInstance()
	self.upAssetMgr = ww.WWUpgradeAssetsMgr:create()
	self.upAssetMgr:onInitDownloadJsonInfo("XML/DownloadCfg.json")
	local storePath = cc.FileUtils:getInstance():getWritablePath().."Resources/"
	
	if not cc.FileUtils:getInstance():isDirectoryExist(storePath) then
		cc.FileUtils:getInstance():createDirectory(storePath)
	end
	
	self.upAssetMgr:onInitModuleInfo("XML/DownLoadModuleConfig.plist",storePath)
	self.upAssetMgr:onInitUserData("userid",tostring(DataCenter:getUserdataInstance():getValueByKey("userid")))
	self.upAssetMgr:onInitUserData("SP",tostring(wwConst.SP))
	self.upAssetMgr:onInitUserData("GAME_ID",tostring(wwConfigData.GAME_ID))
	self.upAssetMgr:onInitUserData("GAME_HALLID",tostring(wwConfigData.GAME_HALL_ID))
	self.upAssetMgr:onInitUserData("g_package_winsize","1")
	self.upAssetMgr:onInitUserData("GAME_VERSION",tostring(wwConfigData.GAME_VERSION))

	local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
	
	self.upAssetMgr:onInitUserData("subVersion",HotUpdateProxy:getCurSubversion(wwConfigData.GAME_VERSION))
	
	--self.upAssetMgr:onInitUserData("subVersion","1")
	self.upAssetMgr:onInitUserData("HotUpdate","0")
	self.upAssetMgr:setDelegate(msgManager)
	ww.UpgradeAssetsMgrContainer:getInstance():onSetUpAssetMgr(self.mGameModuleID, self.upAssetMgr)
end
--这里是一个空的实现 进入
function ModuleBaseHandler:startExecute(...)
	ModuleBaseHandler.super:startExecute(...)
	wwlog(self.logTag,"模块进入中...")
end
--监测更新  默认不需要
--@return true 不需要更新
--@return false 需要更新
function ModuleBaseHandler:intercept(...)
	
	return true --不需要更新
end
--监测模块的资源是否存在
function ModuleBaseHandler:isGameModuleResExisted()
	wwlog(self.logTag,"监测模块资源完整性...")
	if not isLuaNodeValid(self.upAssetMgr) then
		wwlog(self.logTag,"资源下载器未初始化...")
		return false
	end
	--判断是否和lua 相关 
	if self.upAssetMgr:isLuaRelateModule(self.mGameModuleID) then
		--监测本身模块和lua脚本模块
		return self.upAssetMgr:onCheckDownloadResExist(self.mGameModuleID) and self.upAssetMgr:onCheckDownloadResExist(wwConfigData.LUA_GAMEID)
	else
		--监测本身模块
		return self.upAssetMgr:onCheckDownloadResExist(self.mGameModuleID)
	end
end


--更新模块资源
function ModuleBaseHandler:stopEnter(...)
 --弹出更新的界面
	
	wwlog(self.logTag,"更新模块资源...")
	if not isLuaNodeValid(self.upAssetMgr) then
		wwlog(self.logTag,"资源下载器未初始化...")
		return
	end
	local param = {
		gameId = self.mGameModuleID, --模块ID
		moduleId = self.upAssetMgr:onGetDownloadID(self.mGameModuleID), -- 下载ID
		okCallBack = handler(self,self.setCurClientVersion), --更新完成的回调
		canDisMiss = self.dismisLayer --是否能关闭
	}
	if not isLuaNodeValid(display.getRunningScene():getChildByName("UpdateAssetLayer")) then
		local upLayer = UpdateAssetLayer:create(param)
		display.getRunningScene():addChild(upLayer,ww.topOrder-1)
	end
	
end

return ModuleBaseHandler