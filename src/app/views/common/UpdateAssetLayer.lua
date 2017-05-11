-------------------------------------------------------------------------
-- Desc:   更新界面
-- Author:  cruelogre
-- Date:    2016.11.10
-- Last:    
-- Content:  更新界面
--			1.模块下载
--			2.热更
--			3.整包下载
-- 20161110  新建

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UpdateAssetLayer = class("UpdateAssetLayer",require("app.views.uibase.PopWindowBase"))

require("app.config.wwModuleConfig")
require("app.netMsgCfg.UpgradeEventId")
import(".wwDownloadCfg","app.config.")
local UpdateLayer = require("csb.hall.hotupdate.UpdateLayer")

local NodeUpdateDesc = require("csb.hall.hotupdate.Node_UpdateDesc")
local Node_UpdateGrogress = require("csb.hall.hotupdate.Node_UpdateGrogress")

local Toast = require("app.views.common.Toast")
local SimpleRichText = require("app.views.uibase.SimpleRichText")

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

local UpdateLayerState = {
	EMPTY_STATUS = 0,
	UNDOWNLOADED_STATUS = 1,
	DOWNLOADING_STATUS = 2,
	DOWNLOAD_CANCEL_STATUS = 3,
	DOWNLOAD_FAILED_STATUS = 4,
}

local ThreadState = {
	UNKNOWN = 0,

	DOWNLOADING = 1,

	DOWNLOADED= 2,

	UNZIPING = 3,

	THREAD_END = 4,

	DOWNLOAD_ERROR = 5,
}
function UpdateAssetLayer:ctor(param)
	UpdateAssetLayer.super.ctor(self)
	self.mGameId = param.gameId
	self.mDownloadId = param.moduleId
	self.finishCB = param.okCallBack
	self.canDisMiss = param.canDisMiss
	self.misComingToDownload = false
	self.uistate = UpdateLayerState.EMPTY_STATUS
	self:setName("UpdateAssetLayer")
	self.curDownloadWidget = nil
	self.fileNodePos = cc.p(0,0)
	self.starCenterPos = cc.p(0,0) --中心点
	self.starRaduis  = 0 --半径
	self.showContents = {}
	self:initView()
	self:initAssetMgr()
	self:registerUpgradeEvents()
	--WWNetAdapter:registerUpgradeEventMsg(UpgradeEventId.Event_Upgrade_Download_Error,handler(self,UpdateAssetLayer.upgradeEvent),"UpdateAssetLayer.upgradeEvent",self)
	self.canCancel = self.canDisMiss
end
--不能返回关闭的回调
function UpdateAssetLayer:cantCloseOnBack()
	Toast:makeToast(i18n:get('str_hotupdate','hot_update_canot_close'),1):show()
end

function UpdateAssetLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        --忽略
		if self.mGameId==wwConfigData.LUA_HOTUPDATE or self.mGameId==wwConfigData.LUA_WHOLE_PACKAGE then
			--热更和整包更新的时候
			if self.canDisMiss then
				self:close()
			else
				Toast:makeToast(i18n:get('str_hotupdate','hot_update_canot_close'),1):show()
			end
		else --模块下载  
			
		end
		
		
    end
end
--这忽略弹出的关闭当前界面的动画
function UpdateAssetLayer:onEnter()

end
function UpdateAssetLayer:getInnerComponent()
	return HotUpdateCfg.innerEventComponent
end
function UpdateAssetLayer:registerUpgradeEvents()
	self.handlers = self.handlers or {}
	if self:getInnerComponent() then
		for _, v in pairs(HotUpdateCfg.InnerEvents) do
			local x,handler1 = self:getInnerComponent():addEventListener(v,handler(self,self.upgradeEvent),"HotUpdateProxy.upgradeEvent")
			table.insert(self.handlers,handler1)
		end
	end

end

function UpdateAssetLayer:formateFileSize(fileSize)
	local sizeStr = ""
	if math.ceil(fileSize/(1024*1024))>1 then --大于1M
		sizeStr = string.format("%.2f M",fileSize/1024/1024)
	elseif (fileSize/1024)>1 then --大于1KB
		sizeStr = string.format("%.2f KB",fileSize/1024)
	else --很小了 <1K
		sizeStr = string.format("%d B",fileSize)
	end
	
	return sizeStr
end
function UpdateAssetLayer:upgradeEvent(event)
	
	local msgId = event.name
	local data = event._userdata

	
	if msgId==HotUpdateCfg.InnerEvents.UPGRADE_GETREMOVE_FILEZIE then
		wwdump(data,"热更资源文件大小")
		if data.isSuccess then
			--self.downloadText:setString(string.format("下载内容大小：%s",self:formateFileSize(data.fileSize)))
			self:updateFileSize(data.fileSize)
		end
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_DOWNLOAD_ERROR then --更新失败
	
		self:changeUIState(UpdateLayerState.DOWNLOAD_FAILED_STATUS)
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_RESDOWNLOADADDR_MANUAL_CALLBACK then
		print("获取到了下载地址")
		--self.mgr = self:getUpgradeAssetMgr(self.mDownloadId)
		local content = data.resDesc
		local gameId = data.gameId
		self.mgr:onGetRemoteDownloadFileSize(self.units,self.mDownloadId)
		dump(data)
		self:updateDescription(gameId,content)
		
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_DOWNLOADING_PROGRESS then
		
		local curDownload = data.downloaded
		local totalDownload = data.totalToDownload
		local percent = 100*curDownload/totalDownload
		percent = percent*0.99 --下载最高到99%

		self:updateProgress(percent)
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_FINISH_DOWNLOAD then
		print(msgId)
		dump(data)
		print("下载完成.....")
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_UNZIPING_PROGRESS then
		print(msgId)
		dump(data)
		print("解压中.....")
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_FINISH_DOWNLOAD_UNZIP_TOLAYER then
		print(msgId)
		dump(data)
		print("解压完成.....")
		local percent = 100 --下载最高到99%
		self:updateProgress(percent)

		if self.finishCB then
			self.finishCB()
		end
		self.finishCB = nil
		self:close()
		
		Toast:makeToast(i18n:get('str_hotupdate','hot_update_success'),1):show(function ()
			
			FSRegistryManager:clearFSM()
			local modules = {"hall","login","app","packages","WhippedEgg"}
			reStartGame(modules)
		end)
		--self:changeUIState(UpdateLayerState.DOWNLOAD_FAILED_STATUS)

		
	end
end

function UpdateAssetLayer:initView()
	local node = UpdateLayer:create().root
	
	FixUIUtils.setRootNodewithFIXED(node)
	self.img = node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.img)
	
	self:addChild(node)
	local title
	if self.mGameId==wwConfigData.LUA_HOTUPDATE or self.mGameId==wwConfigData.LUA_WHOLE_PACKAGE then
		title = i18n:get('str_hotupdate','hot_title_update')
	else
		title = i18n:get('str_hotupdate','hot_title_download')
	end
	ccui.Helper:seekWidgetByName(self.img,"Text_title"):setString(title)

	self:changeUIState(UpdateLayerState.UNDOWNLOADED_STATUS)
	
	self.scroll = ccui.Helper:seekWidgetByName(self.img,"ScrollView_content")
	self.size = self.scroll:getContentSize()
	--self:setInnerContainerSize(cc.size(900,1800))
	self.scroll:setClippingEnabled(true)
	self.scroll:setScrollBarEnabled(false)

	local scSize = self.scroll:getContentSize()
	local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 32, glyphs = "CUSTOM" }
	self.updateDescRichView = cc.Label:createWithTTF(tmpCfg2,"", cc.TEXT_ALIGNMENT_LEFT, scSize.width)
	--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT

	self.updateDescRichView:setColor(cc.c3b(0x99,0x9A,0x9A))
	self.updateDescRichView:setAnchorPoint(cc.p(0.0,1.0))
	self.updateDescRichView:setPosition(cc.p(0,scSize.height))
	
	self.scroll:addChild(self.updateDescRichView)
	
	
	--self.updateDescRichView:setContentSize(renderSize)
	self:popIn(self.img,Pop_Dir.Right)
	
end


function UpdateAssetLayer:touchListener(ref,eventType)
	if not ref then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		if not ref:isBright() then
			return
		end
		if name=="Button_update" then
			--更新 下载

		
			self:changeUIState(UpdateLayerState.DOWNLOADING_STATUS)
			self:onStartDownloadHandle()
		elseif name == "Text_redownload"  then
			--重新下载
			self:changeUIState(UpdateLayerState.DOWNLOADING_STATUS)
			self:onStartDownloadHandle()
		end
	end
end

function UpdateAssetLayer:initAssetMgr()
	self.mgr = self:getUpgradeAssetMgr(self.mDownloadId)
	self.mgr:onFinishOtherLuaDownloadThread(self.mGameId)
	self:onSetDownloadUnitsInfo(self.mGameId)
	self.isGetAllModuleHttpUrl = self:onCheckIsGetAllModuleHttpAddr()
	
	if self.isGetAllModuleHttpUrl then
		self.mRemoteFileSize = self.mgr:onGetRemoteDownloadFileSize(self.units,self.mDownloadId)
		local data = DataCenter:getData(HotUpdateCfg.InnerEvents.UPGRADE_RESDOWNLOADADDR_MANUAL_CALLBACK)
		if data and data[self.mGameId] then
			self:updateDescription(self.mGameId,data[self.mGameId].resDesc)
		end	
	end
end

function UpdateAssetLayer:onEnter()
	UpdateAssetLayer.super.onEnter(self)
	
	
	print("UpdateAssetLayer:onEnter")
	local state = ww.DownloadThreadState:getInstance():onGetDownloadThreadState(self.mDownloadId)
	print("onGetDownloadThreadState",state)
	if state==ThreadState.DOWNLOADING or state==ThreadState.DOWNLOADED or state==ThreadState.UNZIPING then
		
		self:changeUIState(UpdateLayerState.DOWNLOADING_STATUS)
	elseif state == ThreadState.DOWNLOAD_ERROR then
		ww.DownloadThreadState:getInstance():onSetLocalFileSize(self.mDownloadId,self.mRemoteFileSize)
		local isWIFI = true
		if isWIFI then
			self.misComingToDownload = true
			--self:onInitDownloadingUI()
			self:changeUIState(UpdateLayerState.DOWNLOADING_STATUS)
			self:onStartDownloadHandle()
			
		else
			--self:onInitDownloadUI()
			self:changeUIState(UpdateLayerState.UNDOWNLOADED_STATUS)
		end
	end
end

function UpdateAssetLayer:onExit()
	UpdateAssetLayer.super.onExit(self)
	if self:getInnerComponent() then
		for _,v in pairs(self.handlers) do
			self:getInnerComponent():removeEventListener(v)
		end
	end

end

function UpdateAssetLayer:getDownloadWidget(NodeWidget)
	local imgContent = ccui.Helper:seekWidgetByName(self.img,"Image_content")
	local fnode = imgContent:getChildByName("FileNode_1")
	if self.curDownloadWidget~=NodeWidget then
		self.curDownloadWidget = NodeWidget
		if fnode then
			self.fileNodePos.x = fnode:getPositionX()
			self.fileNodePos.y = fnode:getPositionY()
		end
		fnode:removeFromParent()
		
		fnode = NodeWidget:create().root
		fnode:setName("FileNode_1")
		imgContent:addChild(fnode)
		fnode:setPosition(self.fileNodePos)
	
	end

	return fnode
end
--初始化下载UI
function UpdateAssetLayer:onInitDownloadUI()
	--self.updateBtn:setBright(true)
	local fnode = self:getDownloadWidget(NodeUpdateDesc)

	local imgbg = fnode:getChildByName("Image_bg")
	self.updateBtn = ccui.Helper:seekWidgetByName(imgbg,"Button_update")
	self.updateBtn:addTouchEventListener(handler(self,self.touchListener))
	--
	local text1 = ccui.Helper:seekWidgetByName(imgbg,"Text_1")
	local Image_desc = ccui.Helper:seekWidgetByName(imgbg,"Image_desc")
	--local content = i18n:get('str_hotupdate','hot_content_file') --
	self.updateBtn:setBright(false)
	--text1:getContentSize()
	self.downloadRichView = SimpleRichText:create("",32,cc.c3b(0x99,0x9A,0x9A))
	self.downloadRichView:ignoreContentAdaptWithSize(false)
	local topY = 480
	local bottomY = 190
	self.downloadRichView:setAnchorPoint(text1:getAnchorPoint())
	self.downloadRichView:setPosition(cc.p(text1:getPositionX(),270))
	self.downloadRichView:setContentSize(text1:getContentSize())
	self.downloadRichView:setWrapMode(1)
	Image_desc:addChild(self.downloadRichView)
	
	text1:removeFromParent()
	
	if self.mGameId==wwConfigData.LUA_HOTUPDATE or self.mGameId==wwConfigData.LUA_WHOLE_PACKAGE then
		
	else
		
	end
		
	
	
end
--初始化下载中UI
function UpdateAssetLayer:onInitDownloadingUI()
	
	local fnode = self:getDownloadWidget(Node_UpdateGrogress)
	
	local imgbg = fnode:getChildByName("Image_bg")
	--
	ccui.Helper:seekWidgetByName(imgbg,"Panel_1"):setVisible(true)
	ccui.Helper:seekWidgetByName(imgbg,"Panel_2"):setVisible(false)
	
	local progressbg = ccui.Helper:seekWidgetByName(imgbg,"Image_progressbg")
	local bgSize = progressbg:getContentSize()
	local progressSp = display.newSprite("#hotud_progress_1.png")
	self.progressbar = cc.ProgressTimer:create(progressSp)
	self.progressbar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	progressbg:addChild(self.progressbar)
	self.progressbar:setPosition(cc.p(bgSize.width/2,bgSize.height/2))
	--hotud_progress__star
	self.progressStar = display.newSprite("#hotud_progress__star.png")
	progressbg:addChild(self.progressStar)
	self.starCenterPos = cc.p(bgSize.width/2,bgSize.height/2) --中心点
	self.starRaduis = progressSp:getContentSize().width/2 --半径
	self.starRaduis = 187
	
	local rotateAction = cc.RotateBy:create(1.5,360)
	local faedAction1 = cc.FadeTo:create(1.0,255)
	local faedAction2 = cc.FadeTo:create(1.0,150)
	local seqFade = cc.Sequence:create(faedAction1,faedAction2)

	self.progressStar:runAction(cc.RepeatForever:create(rotateAction))
	self.progressStar:runAction(cc.RepeatForever:create(seqFade))
	--self.progressStar:setPosition(cc.p(bgSize.width/2,bgSize.height/2))
	self.progressStar:setVisible(false)
	self.textPercent = ccui.Helper:seekWidgetByName(imgbg,"Text_percent")
	
	
	
	--local to2 = cc.ProgressTo:create(2, 100)
	--progressSp:setSpriteFrame("hotud_progress_2.png")

	--getSprite
end
function UpdateAssetLayer:onInitDownloadFailUI()
	self.canDisMiss = true --下载失败可以返回去
	local fnode = self:getDownloadWidget(Node_UpdateGrogress)
	local imgbg = fnode:getChildByName("Image_bg")
	--
	ccui.Helper:seekWidgetByName(imgbg,"Panel_1"):setVisible(false)
	ccui.Helper:seekWidgetByName(imgbg,"Panel_2"):setVisible(true)
	
	local progressbg = ccui.Helper:seekWidgetByName(imgbg,"Image_progressbg")
	if isLuaNodeValid(self.progressbar) then
		local progressSp = display.newSprite("#hotud_progress_2.png")
		self.progressbar:setSprite(progressSp)
	else
		local bgSize = progressbg:getContentSize()
		local progressSp = display.newSprite("#hotud_progress_2.png")
		self.progressbar = cc.ProgressTimer:create(progressSp)
		self.progressbar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
		progressbg:addChild(self.progressbar)
		self.progressbar:setPosition(cc.p(bgSize.width/2,bgSize.height/2))
	end
	
	if isLuaNodeValid(self.progressStar) then
		self.progressStar:removeFromParent()
	end
	--
	ccui.Helper:seekWidgetByName(imgbg,"Text_redownload"):addTouchEventListener(handler(self,self.touchListener))
end
--初始化取消下载UI
function UpdateAssetLayer:onInitCancelUI()
	
end
--更新进度
function UpdateAssetLayer:updateProgress(percent)
	if isLuaNodeValid(self.progressbar) then
		self.progressbar:setPercentage(percent)
	end
	if isLuaNodeValid(self.textPercent) then
		self.textPercent:setString(string.format("%d",percent).."%")
	end
	if isLuaNodeValid(self.progressStar) then
		if percent>0 and percent<100 then
			self.progressStar:setVisible(true)
		else
			self.progressStar:setVisible(false)
		end
		local angle = percent*360/100
		angle = math.angle2radian(angle)
		self.progressStar:setPosition(cc.p(self.starCenterPos.x+self.starRaduis*math.sin(angle),
		self.starCenterPos.y+self.starRaduis*math.cos(angle)))
	end
	--self.starCenterPos
	--self.starRaduis

end

function UpdateAssetLayer:updateFileSize(fileSize)
	local fsize = self:formateFileSize(fileSize)
	local content = string.format(i18n:get('str_hotupdate','hot_content_file'),self:formateFileSize(fileSize))
	
	if isLuaNodeValid(self.downloadRichView) then		
		self.downloadRichView:setString(content)
	
	end
	if isLuaNodeValid(self.updateBtn) then
		self.updateBtn:setBright(true)
	end
end

function UpdateAssetLayer:updateDescription(gameId,content)
	content = string.urldecode(content)
	print(content)
	if self.showContents[gameId] then
		return --不重复显示
	end
	self.showContents[gameId] = true --保存显示的内容ID
	local scSize = self.scroll:getContentSize()

	--content = content.."\n〖0〗-操作成功完成。\n〖1〗-功能错误。\n〖2〗-系统找不到指定的文件。\n〖3〗-系统找不到指定的路径。\n〖4〗-系统无法打开文件。\n〖5〗-拒绝访问。\n〖6〗-句柄无效。\n〖7〗-存储控制块被损坏。"
	--content = content.."\n〖8〗-存储空间不足，无法处理此命令。\n〖9〗-存储控制块地址无效。\n〖10〗-环境错误。\n〖11〗-试图加载格式错误的程序。\n〖12〗-访问码无效。"
	
	self.updateDescRichView:setString(content)
	self.scroll:setInnerContainerSize(self.updateDescRichView:getContentSize())
	if self.updateDescRichView:getContentSize().height>self.scroll:getContentSize().height then
		self.updateDescRichView:setPositionY(self.updateDescRichView:getContentSize().height)
	end
	--self.updateDescRichView:setPositionY(self.updateDescRichView:getContentSize().height)
end

function UpdateAssetLayer:changeUIState(newState)
	cclog("UpdateAssetLayer changeUIState:%d",newState)
	if self.uistate==newState then return end
	self.uistate = newState
	if self.uistate == UpdateLayerState.UNDOWNLOADED_STATUS then
		self:onInitDownloadUI()
		
	elseif self.uistate == UpdateLayerState.DOWNLOADING_STATUS then
		self:onInitDownloadingUI()
	elseif self.uistate == UpdateLayerState.DOWNLOAD_CANCEL_STATUS then
		self:onInitCancelUI()
	elseif self.uistate == UpdateLayerState.DOWNLOAD_FAILED_STATUS then
		self:onInitDownloadFailUI()
	end
	
end


function UpdateAssetLayer:onStartDownloadHandle()
	--self.updateBtn:setTouchEnabled(false)
	
	local downloadModule = self:getDonwloadModule(self.mGameId)
	
	local cfgVec = self.mgr:onGetDownloadCfgInfo(downloadModule)
	self.mgr:onStartSilenceDownloading(cfgVec,1,self.mDownloadId)
end

function UpdateAssetLayer:getDonwloadModule(moduleId)
	local downloadModule = {}

	table.insert(downloadModule,moduleId)
	if self.mgr:isLuaRelateModule(moduleId) then
		table.insert(downloadModule,wwConfigData.LUA_GAMEID)
	end
	
	return downloadModule
end

function UpdateAssetLayer:onSetDownloadUnitsInfo(moduleId)
	local downloadModule = self:getDonwloadModule(moduleId)
	
	local cfgVec = self.mgr:onGetDownloadCfgInfo(downloadModule)
	self.units = self.mgr:onGetDownloadUnits(cfgVec,1)

	
	dump(self.units)
end

function UpdateAssetLayer:onCheckIsGetAllModuleHttpAddr()
	local flag = true
	for i,unit in pairs(self.units) do
		local moduleName = self.mgr:onGetModuleName(i)
		local addr = ww.DownloadThreadState:getInstance():onGetModuleHttpAddr(moduleName)
		print(moduleName)
		if not addr or string.len(addr)==0 then
			
			if unit.customId and tonumber(unit.customId)==wwConfigData.LUA_HOTUPDATE then --热更
				--  @param1 和wap定义的模块名字
				--  @param2 本地模块名字
				--  @param3 sourceType 请求资源类型，1 zip模块文件  2 资源的差分文件
				--  @param4 downtype 下载类型 0 静默更新  1 手动更新
				
				self.mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),wwConst.MODULE_CONST(),
					HotUpdateCfg.sourceType.ResDiff,HotUpdateCfg.downloadType.ManualDownload)
			elseif unit.customId and tonumber(unit.customId)==wwConfigData.LUA_WHOLE_PACKAGE then --整包
				self.mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),wwConst.MODULE_CONST(),
					HotUpdateCfg.sourceType.ResDiff,HotUpdateCfg.downloadType.ManualDownload)
			else --模块下载
				self.mgr:onHttpRequestDownloadAddress(unit.customId,wwConst.MODULE_CONST(),moduleName, 
					HotUpdateCfg.sourceType.ModuleZip,HotUpdateCfg.downloadType.ManualDownload)
			end
			
			flag = false
		end
	end
	 
	return flag
end

function UpdateAssetLayer:getUpgradeAssetMgr(gameModuleId)
	local mgr = ww.UpgradeAssetsMgrContainer:getInstance():onGetUpAssetMgr(gameModuleId)

	return mgr
	
end

return UpdateAssetLayer