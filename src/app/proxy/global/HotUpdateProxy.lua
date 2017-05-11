-------------------------------------------------------------------------
-- Desc:   热更代理
-- Author:  cruelogre
-- Date:    2016.11.10
-- Last:    
-- 20161110  新建
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HotUpdateProxy = class("HotUpdateProxy", require("packages.mvc.Proxy"))
require("app.netMsgCfg.UpgradeEventId")
require("app.netMsgCfg.HotUpdateCfg")

local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()

local LuaHotRequest = require("app.request.LuaHotRequest")

local HotUpdateHandler = require("app.hotupdate.HotUpdateHandler")
local PackageUpdateHandler = require("app.hotupdate.PackageUpdateHandler")

function HotUpdateProxy:ctor()
	self._innerEventComponent = { }
    self._innerEventComponent.isBind = false
	
	self._luahotModel = require("app.netMsgBean.luaHotModel"):create(self)
	
	self:bindInnerEventComponent()
	self:registUpdateListener()
	
	self.logTag = "HotUpdateProxy.lua"
		
end

--请求lua热更数据
--@param candismis 能否关闭升级框
--@param showUpdateView 是否显示升级界面 强制
function HotUpdateProxy:requestLuahotData(candismis,showUpdateView)
	wwlog(self.logTag,"请求lua更新")
	self.candismiss = candismis --是否可以关闭升级弹窗
	self.showUpdateView = showUpdateView
	--获取本地的小版本号
		--std::string key = StringUtils::format(UpGradeConst::key_hotupdate_subversion.c_str(), wwConfigData.GAME_VERSION)
	--int vcurrent = WWGameData::getInstance()->getIntegerForKey(key.c_str(), 1); //当前正在应用的版本号(lua内部版本号，约定为数值类型)
	local subVersionKey = "key_hotupdate_subversion_%s"
	local upgradeConfig = ww.WWConfigManager:getInstance():getModuleConfig(3)
	if upgradeConfig and upgradeConfig.items then
		for _,v in pairs(upgradeConfig.items) do
			if v.name=="key_hotupdate_subversion" then
				subVersionKey = string.format(v.values[1],wwConfigData.GAME_VERSION)
				break
			end
		end
	end
	
	local subVersion = ww.WWGameData:getInstance():getIntegerForKey(string.format(subVersionKey,wwConfigData.GAME_VERSION),1)
	local version = wwConfigData.GAME_VERSION
	local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
	if loginMsg and loginMsg.hallversion and string.len(loginMsg.hallversion) > 0 then
		version = loginMsg.hallversion
	end
	local luarequest = LuaHotRequest:create()
	luarequest:formatRequest(version,tostring(subVersion))
	luarequest:send(self)
end

function HotUpdateProxy:registUpdateListener()
    for _, v in pairs(UpgradeEventId) do
       self:registerUpdateId(v,handler(self,self.upgradeEvent),"HotUpdateProxy.upgradeEvent")
    end
	
		--注册lua热更数据返回
	self:registerMsgId(self._luahotModel.MSG_ID.Msg_LUAhotData_Ret,handler(self,self.response))
	
end

function HotUpdateProxy:bindInnerEventComponent()
    -- body
    self:unbindInnerEventComponent()

    cc.bind(self._innerEventComponent, "event")
    self._innerEventComponent.isBind = true
    HotUpdateCfg.innerEventComponent = self._innerEventComponent
end
function HotUpdateProxy:unbindInnerEventComponent()
    -- body
    if self._innerEventComponent.isBind then
        cc.unbind(self._innerEventComponent, "event")
        self._innerEventComponent.isBind = false
        HotUpdateCfg.innerEventComponent = nil
    end
end
function HotUpdateProxy:upgradeEvent(msgId, msgTable)

	local eventName = HotUpdateCfg.getEventById(msgId)
	
	if eventName==HotUpdateCfg.InnerEvents.UPGRADE_FINISH_DOWNLOAD_UNZIP_TOLAYER then
		
		if tonumber(msgTable.customId)==wwConfigData.LUA_HOTUPDATE then--如果是热更的那么更新 本地小版本
		
		else --  下载资源
			
		end
	end
	
	if eventName and msgTable and type(msgTable)=="table" then
		local temp = {}
		copyTable(msgTable,temp)
		local old = DataCenter:getData(eventName)
		if not old or next(old) then
			local temp2 = {}
			temp2[temp.gameId] = temp
			DataCenter:cacheData(eventName,temp2)
		else
			DataCenter:updateData(eventName,temp.gameId,temp)
		end
	end
		
		
	if eventName and HotUpdateCfg.innerEventComponent then
		  HotUpdateCfg.innerEventComponent:dispatchEvent( {
            name = eventName;
            _userdata = msgTable
        } )
	end
	
end

function HotUpdateProxy:response(msgId, msgTable)
	local dispatchEventId = nil
	local dispatchData = nil
	LoadingManager:endLoading()
	if msgId == self._luahotModel.MSG_ID.Msg_LUAhotData_Ret then --lua 热更数据回复
		dump(msgTable,"热更数据")
		dispatchEventId = COMMON_TAG.C_CURRENT_VERSION
		dispatchData = {}
		copyTable(msgTable,dispatchData)
		--保存最新的版本号
		--dispatchData.LuaModel = "{\"subVersion\": 3}"
		if string.len(dispatchData.Version)==0 then
			
			local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
			if loginMsg and loginMsg.hallversion and string.len(dispatchData.Version)==0 then
				dispatchData.Version = loginMsg.hallversion
			else
				dispatchData.Version = wwConfigData.GAME_VERSION
			end
			
		end
		
		dispatchEventId,dispatchData = self:handleUpdate(dispatchData)
		
    end
	
	if dispatchEventId and dispatchData and type(dispatchData)=="table" then
		--DataCenter:clearData(dispatchEventId)
		local temp = {}
		copyTable(dispatchData,temp)
		DataCenter:cacheData(dispatchEventId,temp)
		
	end
	
		--发送消息
	if dispatchEventId and HotUpdateCfg.innerEventComponent then
		HotUpdateCfg.innerEventComponent:dispatchEvent({
					name = dispatchEventId;
					_userdata = dispatchData;
					
				})
	end
	
end
--处理热更逻辑
--如果大版本号变化 则整包更新
--如果小版本号变化  则热更
function HotUpdateProxy:handleUpdate(msgTable)
	local dispatchEventId = COMMON_TAG.C_CURRENT_VERSION
	local dispatchData = msgTable
	local newVersion = string.len(msgTable.Version or "")>0 and msgTable.Version or wwConfigData.GAME_VERSION
	local newSubVersion = 1
	local status, tempTable =  JsonDecorator:decode(msgTable.LuaModel)
	
	if status and tempTable.subVersion then
		newSubVersion = tonumber(tempTable.subVersion)
	end
	--第一次安装，并且这个时候服务器有新版本，我们这个安装的版本就是最新的
	--客户端和服务器大版本一致，而且小版本移植的情况 这个时候就不管是不是当前首次安装
	if (self:getCurSubversion(newVersion) == 1 or newVersion==wwConfigData.GAME_VERSION)
		and wwConfigData.GAME_SUBVERSION>1 and wwConfigData.GAME_SUBVERSION==newSubVersion then
		wwlog(self.logTag,"当前安装的版本是最新版本")
		self:setCurSuversion(newVersion,wwConfigData.GAME_SUBVERSION)
	else
		self:setCurSuversion(wwConfigData.GAME_VERSION,wwConfigData.GAME_SUBVERSION)
	end
	
	--这里先处理一下当前的
	--GAME_SUBVERSION
	
	--先监测整包更新
	if not self._PackageUpdateHandler then
		self._PackageUpdateHandler = PackageUpdateHandler:create()
	end
	if not self._HotUpdateHandler then
		self._HotUpdateHandler = HotUpdateHandler:create()
	end
	
	self._PackageUpdateHandler:canDismisLayer(self.candismiss)
	self._HotUpdateHandler:canDismisLayer(self.candismiss)
	self._HotUpdateHandler:setShowUpdateView(self.showUpdateView)
	
	self.candismiss = nil
	self.showUpdateView = false
	
	--require("app.hotupdate.SilentUpdateQueue")
	if self._PackageUpdateHandler:intercept(newVersion,tonumber(newSubVersion)) then
		
		if self._HotUpdateHandler:intercept(tonumber(newSubVersion)) then
			--当前是最新版本
			dispatchEventId = HotUpdateCfg.InnerEvents.UPGRADE_NO_HOTUPDATE
		end
	else
		dispatchEventId = HotUpdateCfg.InnerEvents.UPGRADE_PACKAGE_UPDATE
	end
	return dispatchEventId,dispatchData
end

--获取当前小版本
--@param clientVersion 客户端版本号
function HotUpdateProxy:getCurSubversion(clientVersion)
	local subVersionKey = self:getSubVersionKey(clientVersion)
	--wwConfigData.GAME_VERSION
	local localSub = ww.WWGameData:getInstance():getIntegerForKey(string.format(subVersionKey),wwConfigData.GAME_SUBVERSION)
	wwlog(self.logTag,"获取当前版本号%s--> %d",clientVersion,localSub)
	return localSub
	
end
--设置当前小版本
--@param clientVersion 客户端版本号
--@param subVersion 客户端小版本号
-- 如果客户端版本号和本地的版本号不一样 则设置新版本号为1
function HotUpdateProxy:setCurSuversion(clientVersion,subVersion)
	local subVersionKey = self:getSubVersionKey(clientVersion)
	--wwConfigData.GAME_VERSION
	wwlog(self.logTag,"设置当前版本号%s|%s--> %d",wwConfigData.GAME_VERSION,clientVersion,subVersion)
	if clientVersion==wwConfigData.GAME_VERSION then
		ww.WWGameData:getInstance():setIntegerForKey(string.format(subVersionKey),tonumber(subVersion))
	else
		ww.WWGameData:getInstance():setIntegerForKey(string.format(subVersionKey),wwConfigData.GAME_SUBVERSION)
	end
end

function HotUpdateProxy:getSubVersionKey(clientVersion)
	local subVersionKey = "key_hotupdate_subversion_%s"
	local upgradeConfig = ww.WWConfigManager:getInstance():getModuleConfig(3)
	if upgradeConfig and upgradeConfig.items then
		for _,v in pairs(upgradeConfig.items) do
			if v.name=="key_hotupdate_subversion" then
				subVersionKey = string.format(v.values[1],clientVersion)
				break
			end
		end
	end
	return subVersionKey
end

function HotUpdateProxy:finalizer()
	self:unbindInnerEventComponent()
	self:unregisterAllUpdateId()
	self:unregisterRootMsgId()
	self:unregisterNetId()
	self:unregisterMsgId()
	self._HotUpdateHandler = nil
	self._PackageUpdateHandler = nil
	
end
return HotUpdateProxy