-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  关于
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SettingLayer_About = class("SettingLayer_About",require("app.views.uibase.PopWindowBase"))


local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local SettingCfg = require("hall.mediator.cfg.SettingCfg")

local SettingLayer_widget_About = require("hall.mediator.view.widget.SettingLayer_widget_About")
local SettingLayer_widget_protocol =  require("hall.mediator.view.widget.SettingLayer_widget_protocol")
function SettingLayer_About:ctor()
	SettingLayer_About.super.ctor(self)
	self:init()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
end

function SettingLayer_About:init()
		
	self.node = require("csb.hall.setting.SettingLayer_About"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	

	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	

	self:popIn(self.imgId,Pop_Dir.Right)
	
	local imgheader = self.imgId:getChildByName("Image_header")
	
	local chooseTag = ccui.Helper:seekWidgetByName(imgheader,"Image_choosetag")
	
	

	local policyPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_policy")
	

	local aboutPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_about")

	local protocolPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_protocol")
	local imgcontent = self.imgId:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
	--Image_content
	
	
	local c1 = MatchChooseCard:create(aboutPanel,
	{textName="Text_about",
		onTag = {size=46,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=42,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetabout = SettingLayer_widget_About:create({width=size.width,height=size.height})
	widgetabout:setPosition(cc.p(size.width/2,size.height/2))
	c1:bindView(imgcontent,widgetabout)
	
	local c2 = MatchChooseCard:create(policyPanel,
	{textName="Text_policy",
		onTag = {size=46,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=42,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetprivicy = SettingLayer_widget_protocol:create({width=size.width,height=size.height})
	widgetprivicy:setCid(SettingCfg.cids[1][1])
	widgetprivicy:setPosition(cc.p(size.width/2,size.height/2))
	c2:bindView(imgcontent,widgetprivicy)
	
	
	local c3 = MatchChooseCard:create(protocolPanel,
	{textName="Text_protocol",
		onTag = {size=46,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=42,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetprotocol = SettingLayer_widget_protocol:create({width=size.width,height=size.height})
	widgetprotocol:setCid(SettingCfg.cids[2][1])
	widgetprotocol:setPosition(cc.p(size.width/2,size.height/2))
	c3:bindView(imgcontent,widgetprotocol)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
	self.chooseGp:addCard(c3)
	
	
end

function SettingLayer_About:onEnter()
	-- body
	self.chooseGp:chooseCard(1)
	self:initLocalText()
end

function SettingLayer_About:initLocalText()
	--title
	local header = ccui.Helper:seekWidgetByName(self.imgId,"Image_header")
	ccui.Helper:seekWidgetByName(header,"Text_policy"):setString(i18n:get('str_setting','setting_privicy'))
	ccui.Helper:seekWidgetByName(header,"Text_about"):setString(i18n:get('str_setting','setting_about_us'))
	ccui.Helper:seekWidgetByName(header,"Text_protocol"):setString(i18n:get('str_setting','setting_service_protocol'))
	
end

function SettingLayer_About:onExit()
	self.chooseGp:removeCard(1)
	self.chooseGp:removeCard(1)
	self.chooseGp:removeCard(1)
	self.chooseGp = nil
	self.super.onExit(self)
end

return SettingLayer_About