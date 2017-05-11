local SettingLayer_widget_About = class("SettingLayer_widget_About",
require("hall.mediator.view.widget.SettingLayer_widget_base"))
local SettingCfg = require("hall.mediator.cfg.SettingCfg")

function SettingLayer_widget_About:ctor(size)
	SettingLayer_widget_About.super.ctor(self,size)
	self:init()
	
end

function SettingLayer_widget_About:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
end



function SettingLayer_widget_About:initView()
	self.node = require("csb.hall.setting.SettingLayer_widget_about"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	
	--testing
	self.node:getChildByName("Text_versionnumber"):setString(
	tostring(wwConfigData.GAME_VERSION).."."..tostring(wwConfigData.GAME_SUBVERSION))
	
	
	
end

function SettingLayer_widget_About:eventComponent()
	return SettingCfg.innerEventComponent
end

function SettingLayer_widget_About:onEnter()
	--self:eventComponent():addEventListener(SettingCfg.InnerEvents.SETTING_EVENT_FAQ,handler(self,self.freshFAQ))
	self:initView()
	self:initLocalText()
end

function SettingLayer_widget_About:onExit()
	--self:eventComponent():removeEventListener(SettingCfg.InnerEvents.SETTING_EVENT_FAQ)
end
--±¾µØ»¯
function SettingLayer_widget_About:initLocalText()
	--title
	
	self.node:getChildByName("Text_versioncode"):setString(i18n:get('str_setting','setting_version_id'))
	self.node:getChildByName("Text_desc"):setString(i18n:get('str_setting','setting_copyright'))
end

return SettingLayer_widget_About