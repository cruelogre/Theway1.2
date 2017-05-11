-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  任务页面控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Activity_widget_Content = class("Activity_widget_Content",function ()
	return ccui.Layout:create()
end)


local NodeTaskItem = require("csb.hall.dailyTask.NodeTaskItem")
local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local ActivityCfg = import(".ActivityCfg","hall.mediator.cfg.")

local Toast = require("app.views.common.Toast")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local JumpFilter = require("packages.statebase.filter.JumpFilter")
local CorFilter = require("packages.statebase.filter.CorFilter")

local LuaNativeBridge = require("app.utilities.LuaNativeBridge"):create()
local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()
function Activity_widget_Content:ctor(size)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.taskData = {}
	self.taskCount = 0
	
	self.logTag = self.__cname..".lua"
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Activity_widget_Content:init()
	
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
		or ((cc.PLATFORM_OS_IPAD == targetPlatform))
		or ((cc.PLATFORM_OS_MAC == targetPlatform))
		or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			
		
		self.actWevView = ccexp.WebView:create()
		
		local userid = ww.WWGameData:getInstance():getIntegerForKey("userid")
        local pwd = ww.WWGameData:getInstance():getStringForKey("pwd")
			
		self.actWevView:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self.actWevView:setContentSize(self.size)
		self.actWevView:loadURL(ToolCom:getActivityUrl(userid,pwd))
		self.actWevView:setScalesPageToFit(true)
		self.actWevView:setOnShouldStartLoading(handler(self,self.webViewShouldStartLoading))
		self.actWevView:setOnDidFinishLoading(handler(self,self.webViewFinishLoading))
		self.actWevView:setOnDidFailLoading(handler(self,self.webViewFailLoading))
		self:addChild(self.actWevView,1)
		LuaNativeBridge:addWebInterface(handler(self,self.jumpCallback))
	end
	
end
--跳转回调
function Activity_widget_Content:jumpCallback(arg)
	wwlog(self.logTag,"活动返回了")
	local ret, argArr = JsonDecorator:decode(arg)
	--local argArr = string.split(arg,"&")
	if ret then
		--local opendata = ActivityCfg.getOpenDataById(tonumber(argArr[1]))
		local UIJmperConfig = require("config.UIJmperConfig")
		if UIJmperConfig then
			local opendata = UIJmperConfig[tonumber(argArr.searchId)]
			if opendata then
				if tonumber(opendata.uopenType) == ActivityCfg.openType.STATEUI then

					self:jumpState(clone(opendata),unpack(argArr.param or {}))
				elseif tonumber(opendata.uopenType) == ActivityCfg.openType.SECONDUI then
					self:openUI(clone(opendata))
				elseif tonumber(opendata.uopenType) == ActivityCfg.openType.THIRDAPP then
					self:openAPP(clone(opendata))
				end
				
			end
		else
			wwlog(self.logTag,"跳转配置文件读取失败")
		end
	else
		wwlog(self.logTag,"参数解析异常:"..tostring(argArr))
		wwlog(self.logTag,"异常原始参数:"..tostring(arg))
	end
end

--跳转至指定的状态机
--@param eventName 跳转到状态机的事件名
--@param stateName 状态机名
--@crType 几个打牌的请求类型 1 经典 2 比赛 3 私人
function Activity_widget_Content:jumpState(opendata,...)
	--eventName,stateName,crType,externalData
	local jumpParam = { zorder = 3,}
	opendata.param = opendata.param or {}
	if opendata.param then
		table.merge(opendata.param,jumpParam)
	end

	UIStateJumper:JumpUI(opendata,...)
end
--直接打开界面 (非状态)
function Activity_widget_Content:openUI(opendata)
	FSRegistryManager:currentFSM():trigger("back")
	--display.getRunningScene():addChild(require(opendata.uipath):create(),ww.centerOrder)
	UIStateJumper:JumpUI(opendata)
end
--打开第三方app
function Activity_widget_Content:openAPP(opendata)
	wwlog(self.logTag,"打开第三方应用")
	UIStateJumper:JumpUI(opendata)
end
--刷新
function Activity_widget_Content:refresh()
	if isLuaNodeValid(self.actWevView) then
		wwlog(self.logTag,"刷新webview")
		self.actWevView:reload()
	end
end
--web 页面返回
function Activity_widget_Content:goBack()
	if isLuaNodeValid(self.actWevView) then
		wwlog(self.logTag,"后撤webview")
		if self.actWevView:canGoBack() then
			self.actWevView:goBack()
		end
	end
end

function Activity_widget_Content:webViewShouldStartLoading(pSender,url)
	
	return true
end


function Activity_widget_Content:webViewFinishLoading(pSender,url)
	
end

function Activity_widget_Content:webViewFailLoading(pSender,url)
	
end
function Activity_widget_Content:onEnter()
	
	wwlog(self.logTag,"Activity_widget_Content:onEnter")

end


function Activity_widget_Content:onExit()
	
	wwlog(self.logTag,"Activity_widget_Content:onExit")
	if isLuaNodeValid(self.actWevView) then
		self.actWevView:removeFromParent()
	end
	

end

function Activity_widget_Content:active()
	if not isLuaNodeValid(self.actWevView) then
		self:init()
	end
end

function Activity_widget_Content:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_go" then
			
			

		end
		
	end
	

end


function Activity_widget_Content:eventComponent()
	return TaskCfg.innerEventComponent
end



return Activity_widget_Content