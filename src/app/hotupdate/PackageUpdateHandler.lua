---------------------------------------------
-- module : 整包更新
-- auther : cruelogre
-- Date:    2016.11.3
-- comment: 
--  		1. 每个模块ID mGameModuleID
--			2.实现 startExecute 进入模块
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------

local PackageUpdateHandler = class("PackageUpdateHandler",require("app.hotupdate.ModuleBaseHandler"))

local moduleId = 10000 --整包的模块ID
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function PackageUpdateHandler:ctor(iID,priority)
	PackageUpdateHandler.super.ctor(self,iID,priority)
	self.mGameModuleID = moduleId --模块的ID
	
	self:initUpgradeMgr()
	
end

function PackageUpdateHandler:initUpgradeMgr()
	PackageUpdateHandler.super.initUpgradeMgr(self)
	
	self.upAssetMgr:onInitUserData("HotUpdate","1")
end

function PackageUpdateHandler:setCurClientVersion()
	
	PackageUpdateHandler.super.setCurClientVersion(self,self.targetVersion,self.targetSubVersion )
end
--监测更新  默认不需要
--@return true 不需要更新
--@return false 需要更新
--@param targetClientVersion 目标客户端版本 
function PackageUpdateHandler:intercept(targetClientVersion,targetSubversion)
	wwlog(self.logTag,"整包更新比较大版本号")
	self.targetVersion = targetClientVersion
	self.targetSubVersion = targetSubversion

	local localClientVersion = wwConfigData.GAME_VERSION

	self.upAssetMgr:onInitUserData("subVersion",tostring(targetSubversion))
	self.upAssetMgr:onInitUserData("GAME_VERSION",tostring(targetClientVersion))
	
	--对于小版本
	if self:compareVersion(localClientVersion,targetClientVersion) then
		self:stopEnter()
	else 
		self:startExecute()
		return true
	end
	--弹出更新界面
	return false --需要更新
end
--比较版本号
--retun true 本地版本号比目标版本号小
--return false 
function PackageUpdateHandler:compareVersion(localClientVersion,targetClientVersion)
	wwlog(self.logTag,"local version %s  target version %s",localClientVersion,targetClientVersion)
	if localClientVersion and targetClientVersion then
		
		local localVArr = string.split(localClientVersion,".")
		local targetVArr = string.split(targetClientVersion,".")
		if localVArr and targetVArr and table.nums(localVArr)==table.nums(targetVArr) then
			local isBigger = false
			for i=1,table.nums(targetVArr) do
				if tonumber(targetVArr[i]) > tonumber(localVArr[i]) then
					isBigger = true
					break 
				end
			end
			return isBigger
		end
	else
		return false
	end
	
	return false
end

--这里是一个空的实现 进入
function PackageUpdateHandler:startExecute()
	PackageUpdateHandler.super.startExecute(self)
end
function PackageUpdateHandler:isGameModuleResExisted()
	return PackageUpdateHandler.super.isGameModuleResExisted(self)
end

--更新模块资源
function PackageUpdateHandler:stopEnter(...)
	--self.super.updateModuleRes(self)
	--self.super.stopEnter(self,...)
	wwlog(self.logTag,"整包资源更新中")
	--目前的处理方式是 android 走卓盟更新这里不需要关心 IOS跳转到下载地址 win32 不管
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform)) 
	or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or not self.dismisLayer then --或者强制更新的
		local para = {}
		
		if self.dismisLayer then
			wwlog(self.logTag,"可以关闭按钮")
			para.leftBtnlabel = i18n:get('str_common','comm_cancel')
		else
			wwlog(self.logTag,"不能关闭按钮")
			para.rightStayOnClick = true --点击了不关闭
			para.keyBackClose = false --返回键不关闭
		end
		para.rightBtnlabel = i18n:get('str_common','comm_sure')
		
		para.rightBtnCallback = function ()
			local url = wwURLConfig.LUA_PACKAGE_WIN_URL
			if (cc.PLATFORM_OS_WINDOWS ~= targetPlatform) then
				local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
				if loginMsg and loginMsg.DownloadURL then
					url = loginMsg.DownloadURL
				end
				
			end
		
			if (cc.PLATFORM_OS_ANDROID == targetPlatform)  then
				url = wwURLConfig.LUA_PACKAGE_ANDROID_URL
			end
				wwlog(self.logTag,"打开更新连接:%s",url)
				cc.Application:getInstance():openURL(url)
		end
		para.showclose = false  --是否显示关闭按钮
		--eventTable.MatchName
		para.content = i18n:get('str_hotupdate','packge_update')

		local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
	end

			
--[[	local storePath = cc.FileUtils:getInstance():getWritablePath()..self.targetVersion..".apk"
	local headers= {}--]]
	--self.upAssetMgr:onStartAPKDownload("http://a4.pc6.com/lxf2/majiangtuidaohu.pc6.apk",storePath,headers)
end

return PackageUpdateHandler