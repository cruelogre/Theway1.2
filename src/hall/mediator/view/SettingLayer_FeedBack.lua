-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  问题反馈
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SettingLayer_FeedBack = class("SettingLayer_FeedBack",require("app.views.uibase.PopWindowBase"))
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local SettingProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SETTING)
local Toast = require("app.views.common.Toast")
local LuaNativeBridge = require('app.utilities.LuaNativeBridge'):create();

function SettingLayer_FeedBack:ctor()
	SettingLayer_FeedBack.super.ctor(self)
	self:init()
	self.handlers = {}
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
end

function SettingLayer_FeedBack:init()
		
	self.node = require("csb.hall.setting.SettingLayer_FeedBack"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	
	self:setDisCallback(function ( ... )
		-- body
		self:unregisterListener()
		self:removeFromParent()
	end)
	--testing

	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	

	self:popIn(self.imgId,Pop_Dir.Right)

	--TextField_msg
	self.textmsg = ccui.Helper:seekWidgetByName(self.imgId,"TextField_msg")
	self.textmsg:setTextColor(ConvertHex2RGBTab('999A9A')) --设置字体颜色
	self.textmsg:addEventListener(handler(self,self.textFieldListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_submit"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_service_tel"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_online_service"):addTouchEventListener(handler(self,self.touchListener))
end

function SettingLayer_FeedBack:textFieldListener(ref,eventType)
	if not ref then
		return
	end
	
	if eventType==ccui.TextFiledEventType.attach_with_ime then
		self.touchActive = false
	elseif eventType==ccui.TextFiledEventType.detach_with_ime then
		self.touchActive = true
	elseif eventType==ccui.TextFiledEventType.insert_text then
		local count = self.textmsg:getStringLength()
		if count > SettingCfg.maxContentLength then
			Toast:makeToast(string.format(i18n:get('str_setting','setting_feedback_toomuch'),SettingCfg.maxContentLength),1.0):show()
		end
	elseif eventType==ccui.TextFiledEventType.delete_backward then
	end
end

function SettingLayer_FeedBack:touchListener(psender,eventType)
	if not psender then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local name = psender:getName()
		if name=="Button_submit" then
			local textString = self.textmsg:getString()
			local textCount  = self.textmsg:getStringLength()
			if string.len(textString)==0 or textCount==0 then
				Toast:makeToast(i18n:get('str_setting','setting_feedback_empty'),1.0):show()
				
			elseif string.trim(textString) == "" then
				Toast:makeToast(string.format(i18n:get('str_setting','setting_feedback_empty'),SettingCfg.maxContentLength),1.0):show()
			elseif textCount > SettingCfg.maxContentLength then
				--Toast:makeToast("内容不能超过200字",1.0):show()
				Toast:makeToast(string.format(i18n:get('str_setting','setting_feedback_toomuch'),SettingCfg.maxContentLength),1.0):show()
			else
				self.textmsg:setString("") --提交的时候立马滞空
				SettingProxy:requestFeedBack(textString)
			end
		elseif name == "Button_service_tel" then
				--call tel
				self:callService()
		elseif name == "Button_online_service" then
				--先请求用户信息？
				self:onLineServer()
		end
	end
end
--在线客服
function SettingLayer_FeedBack:onLineServer()
	local url = wwURLConfig.LIVE800_URL
	LuaNativeBridge:openLive800(url)
end
--拨打电话，先弹出对话框
function SettingLayer_FeedBack:callService()
	local phonecall = i18n:get("str_common", "comm_telNum")
	LuaNativeBridge:makePhoneCall(phonecall)
	
end
function SettingLayer_FeedBack:onEnter()
	-- body
	if SettingCfg.innerEventComponent then
		local _ = nil
		_,self.handlers[#self.handlers+1] = SettingCfg.innerEventComponent:addEventListener(SettingCfg.InnerEvents.SETTING_EVENT_FEEDBACK,handler(self,self.feedBackResp))
	end
	self:initLocalText()
end
function SettingLayer_FeedBack:feedBackResp(event)
	print("SettingLayer_FeedBack feedBackResp")
	if isLuaNodeValid(self.textmsg) then
		self.textmsg:setString("")
	end
end

function SettingLayer_FeedBack:onExit()
	self.textmsg = nil
	self.super.onExit(self)
end

--本地化
function SettingLayer_FeedBack:initLocalText()
	--title
	ccui.Helper:seekWidgetByName(self.imgId,"Text_feedback_title"):setString(i18n:get('str_setting','setting_feedback'))
	ccui.Helper:seekWidgetByName(self.imgId,"TextField_msg"):setPlaceHolder(i18n:get('str_setting','setting_feedback_placeholder'))
end

function SettingLayer_FeedBack:unregisterListener()
	if SettingCfg.innerEventComponent then
		for _,v in pairs(self.handlers) do
			SettingCfg.innerEventComponent:removeEventListener(v)
		end
	end
	
end

return SettingLayer_FeedBack