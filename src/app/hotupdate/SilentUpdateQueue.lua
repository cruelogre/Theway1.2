-------------------------------------------------------------------------
-- Desc:   静默下载队列
-- Author:  cruelogre
-- Date:    2016.11.10
-- Last:    
-- Content:   静默更新器
--			热更
-- 20161110  新建

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SilentUpdateQueue = class("SilentUpdateQueue")
local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local ThreadState = {
	UNKNOWN = 0,

	DOWNLOADING = 1,

	DOWNLOADED= 2,

	UNZIPING = 3,

	THREAD_END = 4,

	DOWNLOAD_ERROR = 5,
}

function SilentUpdateQueue:ctor()
	self.downloadingGameId = {} --正在下载的静默ID
	self.logTag = "SilentUpdateQueue.lua"
	self:registerUpgradeEvents()
	self:registerNetChangeEvents()
	wwlog(self.logTag,"静默下载器初始化")
	
end
function SilentUpdateQueue:getInnerComponent()
	return HotUpdateCfg.innerEventComponent
end

function SilentUpdateQueue:registerNetChangeEvents()
	self.netEventListener = cc.EventListenerCustom:create(COMMON_EVENTS.C_CHANGE_NETWORK_STATE, handler(self,self.netStateChangeEvent))
    eventDispatcher:addEventListenerWithFixedPriority(self.netEventListener, 1)
end
function SilentUpdateQueue:registerUpgradeEvents()
	self.handlers = self.handlers or {}
	if self:getInnerComponent() then
		for _, v in pairs(HotUpdateCfg.InnerEvents) do
			local x,handler1 = self:getInnerComponent():addEventListener(v,handler(self,self.upgradeEvent),"SilentUpdateQueue.upgradeEvent")
			table.insert(self.handlers,handler1)
		end
	end

end
function SilentUpdateQueue:setCurClientVersion(gameversion,subVersion)
	if gameversion and subVersion then
		local subVersionKey = nil
		local upgradeConfig = ww.WWConfigManager:getInstance():getModuleConfig(3)
		if upgradeConfig and upgradeConfig.items then
			for _,v in pairs(upgradeConfig.items) do
				
				if v.name=="key_hotupdate_subversion" then
					subVersionKey = string.format(v.values[1],gameversion)
				end
			
			end
		end
		if subVersionKey then
			local key = string.format(subVersionKey,gameversion)
			ww.WWGameData:getInstance():setIntegerForKey(key, tonumber(subVersion))
		end

	end
end

function SilentUpdateQueue:upgradeEvent(event)
	
	local msgId = event.name
	local data = event._userdata
	local mGameModuleID = data.gameId
	if not self:checkDownloadTask(mGameModuleID) then
		return
	end
	if msgId==HotUpdateCfg.InnerEvents.UPGRADE_GETREMOVE_FILEZIE then
		
		if data.isSuccess then
			--self.downloadText:setString(string.format("下载内容大小：%s",self:formateFileSize(data.fileSize)))
			--self:updateFileSize(data.fileSize)
		end
	
		local downloadModule = self:getDonwloadModule(mGameModuleID)
		local mgr = self:getUpgradeAssetMgr(mGameModuleID)
		local downlaodId = mgr:onGetDownloadID(mGameModuleID)
		local cfgVec = mgr:onGetDownloadCfgInfo(downloadModule)
		mgr:onStartSilenceDownloading(cfgVec,1,downlaodId)
		

	
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_DOWNLOAD_ERROR then --更新失败
	
		self.downloadingGameId[mGameModuleID] = nil
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_RESDOWNLOADADDR_MANUAL_CALLBACK then
		wwlog(self.logTag,"获取到了下载地址")
		--self.mgr = self:getUpgradeAssetMgr(self.mDownloadId)
		--data.resModule
		local mGameModuleID = data.gameId
		local units = self:onSetDownloadUnitsInfo(mGameModuleID)
		
		self:getUpgradeAssetMgr(mGameModuleID):onGetRemoteDownloadFileSize(units,mGameModuleID)
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_DOWNLOADING_PROGRESS then
		
		local curDownload = data.downloaded
		local totalDownload = data.totalToDownload
		local mGameModuleID = data.customId
		local percent = 100*curDownload/totalDownload
		print(curDownload,totalDownload)
		if percent>=0 then
			
		end
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_FINISH_DOWNLOAD then
		print(msgId)
		dump(data)
		print("下载完成.....")
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_UNZIPING_PROGRESS then
		print(msgId)
		dump(data)
		wwlog(self.logTag,"解压中.....")
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_FINISH_DOWNLOAD_UNZIP_TOLAYER then
		print(msgId)
		dump(data)
		wwlog(self.logTag,"解压完成.....")
		local loginMsg = DataCenter:getData(COMMON_TAG.C_CURRENT_VERSION)
		local version = wwConfigData.GAME_VERSION
		if loginMsg.Version and string.len(loginMsg.Version)>0 then
				version = loginMsg.Version
		end
		if mGameModuleID == wwConfigData.LUA_HOTUPDATE then
			local newSubVersion = 1
			local status, tempTable =  JsonDecorator:decode(loginMsg.LuaModel)
			
			if status and tempTable.subVersion then
				newSubVersion = tonumber(tempTable.subVersion)
			end
			HotUpdateProxy:setCurSuversion(version,newSubVersion)
		elseif mGameModuleID==wwConfigData.LUA_WHOLE_PACKAGE then
			HotUpdateProxy:setCurSuversion(version,1)
		end
		--解压完成 要判断是否为热更版本
		--COMMON_TAG.C_CURRENT_VERSION
		

		
	end
end
--判断是否在下载
function SilentUpdateQueue:checkDownloadTask(mGameModuleID)
	return self.downloadingGameId[mGameModuleID]
end


--下载推入到队列中
function SilentUpdateQueue:pushDownloadTask(mGameModuleID,param)
	local state = ww.DownloadThreadState:getInstance():onGetDownloadThreadState(mGameModuleID)
	if state==ThreadState.DOWNLOADING then
		wwlog(self.logTag,"下载ID %d 正在下载中....",mGameModuleID)
		return
	end
	wwlog(self.logTag,"开始下载ID %d....",mGameModuleID)
	local mgr = self:getUpgradeAssetMgr(mGameModuleID)
	
	if param.targetSubversion then
		mgr:onInitUserData("subVersion",tostring(param.targetSubversion))
	end
	if param.HotUpdate then
		mgr:onInitUserData("HotUpdate",tostring(param.HotUpdate))
	end
	
	local downlaodId = mgr:onGetDownloadID(mGameModuleID)
	
	--self.mgr:onFinishOtherLuaDownloadThread(self.mGameId)
	mgr:onFinishOtherLuaDownloadThread(mGameModuleID)
	local downloadUnits = self:onSetDownloadUnitsInfo(mGameModuleID)
	local isGetAllModuleHttpUrl = self:onCheckIsGetAllModuleHttpAddr(mGameModuleID,downloadUnits)
	
	if isGetAllModuleHttpUrl then
		local mRemoteFileSize = mgr:onGetRemoteDownloadFileSize(downloadUnits,downlaodId)
		local downloadModule = self:getDonwloadModule(mGameModuleID)
	
		local cfgVec = mgr:onGetDownloadCfgInfo(downloadModule)
		mgr:onStartSilenceDownloading(cfgVec,1,downlaodId)
		
		
		
	end
	self.downloadingGameId[mGameModuleID] = true

end

function SilentUpdateQueue:netStateChangeEvent()
	--网络改变了

	local netType = ww.IPhoneTool:getInstance():checkNetState()
	if netType=="wifi" then --wif的情况下 就显示下载
		wwlog(self.logTag,"当前是wifi状态，有下载的继续")
		local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
		--VerStatus 版本更新提示  
		--int1)客户端版本状态：
		--0 没有新版本可更新
		--1 有新版本，非必需更新
		--2 有新版本，必需更新
		if loginMsg and loginMsg.VerStatus then
			--拉取热更数据
			HotUpdateProxy:requestLuahotData(loginMsg.VerStatus~=2) --新版本 强制更新的才需要更新
		end
	else
		wwlog(self.logTag,"当前是流量状态，下载取消")
		self:stopAllDownloadTask()
	end	
	
end

--停止所有下载
function SilentUpdateQueue:stopAllDownloadTask()
	local tempTable = self.downloadingGameId
	for i,v in pairs(tempTable) do
		self:stopDownloadTask(i)
	end
end

--停止下载
function SilentUpdateQueue:stopDownloadTask(mGameModuleID)
	if self.downloadingGameId[mGameModuleID] then
		local units = self:onSetDownloadUnitsInfo(mGameModuleID)
		self:getUpgradeAssetMgr(mGameModuleID):onClearDownloadThread(mGameModuleID,units)
	end
	self.downloadingGameId[mGameModuleID] = nil
end

function SilentUpdateQueue:onSetDownloadUnitsInfo(mGameModuleID)
	local mgr = self:getUpgradeAssetMgr(mGameModuleID)
	local downloadModule = self:getDonwloadModule(mGameModuleID)
	
	local cfgVec = mgr:onGetDownloadCfgInfo(downloadModule)
	local downloadUnits = mgr:onGetDownloadUnits(cfgVec,1)

	
	dump(downloadUnits)
	return downloadUnits
end

function SilentUpdateQueue:getDonwloadModule(mGameModuleID)
	local mgr = self:getUpgradeAssetMgr(mGameModuleID)
	local downloadModule = {}

	table.insert(downloadModule,mGameModuleID)
	if mgr:isLuaRelateModule(mGameModuleID) then
		table.insert(downloadModule,wwConfigData.LUA_GAMEID)
	end
	
	return downloadModule
end


function SilentUpdateQueue:onCheckIsGetAllModuleHttpAddr(mGameModuleID,downloadUnits)
	local flag = true
	local mgr = self:getUpgradeAssetMgr(mGameModuleID)
	for i,unit in pairs(downloadUnits) do
		local moduleName = mgr:onGetModuleName(i)
		local addr = ww.DownloadThreadState:getInstance():onGetModuleHttpAddr(moduleName)
		print(moduleName)
		if not addr or string.len(addr)==0 then
			
			if unit.customId and tonumber(unit.customId)==wwConfigData.LUA_HOTUPDATE then --热更
				--  @param1 和wap定义的模块名字
				--  @param2 本地模块名字
				--  @param3 sourceType 请求资源类型，1 zip模块文件  2 资源的差分文件
				--  @param4 downtype 下载类型 0 静默更新  1 手动更新
				
				mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),wwConst.MODULE_CONST(),
					HotUpdateCfg.sourceType.ResDiff,HotUpdateCfg.downloadType.ManualDownload)
			elseif unit.customId and tonumber(unit.customId)==wwConfigData.LUA_WHOLE_PACKAGE then --整包
				mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),wwConst.MODULE_CONST(),
					HotUpdateCfg.sourceType.ResDiff,HotUpdateCfg.downloadType.ManualDownload)
			else --模块下载
				mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),moduleName, 
					HotUpdateCfg.sourceType.ModuleZip,HotUpdateCfg.downloadType.ManualDownload)
			end
			
			flag = false
		end
	end
	 
	return flag
end

function SilentUpdateQueue:finishDownload(mGameModuleID)
	self:getUpgradeAssetMgr(mGameModuleID):onFinishOtherLuaDownloadThread(mGameModuleID)
end


function SilentUpdateQueue:getUpgradeAssetMgr(gameModuleId)
	local mgr = ww.UpgradeAssetsMgrContainer:getInstance():onGetUpAssetMgr(gameModuleId)
	if not mgr then
		mgr = self:initUpgradeMgr(gameModuleId)
	end
	return mgr
	
end

--初始管理器
function SilentUpdateQueue:initUpgradeMgr(mGameModuleID)
	wwlog(self.logTag,"初始化下载管理器...")
	ww.UpgradeAssetsMgrContainer:getInstance():setDownloadURL("res_dl_url",wwURLConfig.PLATFORM_URL_TEST)
	ww.UpgradeAssetsMgrContainer:getInstance():setDownloadURL("lua_hotupdate_url",wwURLConfig.LUA_HOTUPDATE_URL_TEST)
	
	local msgManager = ww.WWMsgManager:getInstance()
	local upAssetMgr = ww.WWUpgradeAssetsMgr:create()
	upAssetMgr:onInitDownloadJsonInfo("XML/DownloadCfg.json")
	local storePath = cc.FileUtils:getInstance():getWritablePath().."Resources/"
	
	if not cc.FileUtils:getInstance():isDirectoryExist(storePath) then
		cc.FileUtils:getInstance():createDirectory(storePath)
	end
	
	upAssetMgr:onInitModuleInfo("XML/DownLoadModuleConfig.plist",storePath)
	upAssetMgr:onInitUserData("userid",tostring(DataCenter:getUserdataInstance():getValueByKey("userid")))
	upAssetMgr:onInitUserData("SP",tostring(wwConst.SP))
	upAssetMgr:onInitUserData("GAME_ID",tostring(wwConfigData.GAME_ID))
	upAssetMgr:onInitUserData("GAME_HALLID",tostring(wwConfigData.GAME_HALL_ID))
	upAssetMgr:onInitUserData("g_package_winsize","1")
	upAssetMgr:onInitUserData("GAME_VERSION",tostring(wwConfigData.GAME_VERSION))

	local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
	
	upAssetMgr:onInitUserData("subVersion",HotUpdateProxy:getCurSubversion(wwConfigData.GAME_VERSION))
	
	--self.upAssetMgr:onInitUserData("subVersion","1")
	upAssetMgr:onInitUserData("HotUpdate","0")
	upAssetMgr:setDelegate(msgManager)
	ww.UpgradeAssetsMgrContainer:getInstance():onSetUpAssetMgr(mGameModuleID, upAssetMgr)
	
	return upAssetMgr
end
--回收
function SilentUpdateQueue:finalizer()
	--删除所有注册
	if self:getInnerComponent() then
		for _,v in pairs(self.handlers) do
			self:getInnerComponent():removeEventListener(v)
		end
	end
	if self.netEventListener then
		eventDispatcher:removeEventListener(self.netEventListener)
	end
	
	--停止所有下载
	self:stopAllDownloadTask()
end

cc.exports.SilentUpdateQueue = cc.exports.SilentUpdateQueue or SilentUpdateQueue:create()
return SilentUpdateQueue