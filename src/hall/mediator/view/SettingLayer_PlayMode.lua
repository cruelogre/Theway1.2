-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.22
-- Last: 
-- Content:  设置界面中的玩法
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingLayer_PlayMode = class("SettingLayer_PlayMode",require("app.views.uibase.PopWindowBase"))


local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")
local SettingLayer_widget_FAQ = require ("hall.mediator.view.widget.SettingLayer_widget_FAQ")
local SettingLayer_widget_Guandan = require("hall.mediator.view.widget.SettingLayer_widget_Guandan")

local SettingCfg = require("hall.mediator.cfg.SettingCfg")

function SettingLayer_PlayMode:ctor()
	SettingLayer_PlayMode.super.ctor(self)
	print("SettingLayer_PlayMode:ctor")
	self:init()

end

function SettingLayer_PlayMode:init()
	
	print("SettingLayer_PlayMode:init")
	local setting_bg = require("csb.hall.setting.SettingLayer_PlayMode"):create()
	if not setting_bg then
		return
	end
	self:setDisCallback(function ()
		self:removeFromParent()
	end)
	self.node = setting_bg["root"]
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	local imgid = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(imgid)
	
	self:addChild(self.node)
	self:popIn(imgid,Pop_Dir.Right)
	
	
	local imgheader = imgid:getChildByName("Image_header")
	self.imgheader = imgheader
	local chooseTag = ccui.Helper:seekWidgetByName(imgheader,"Image_choosetag")
	

	local faqPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_FAQ")
	

	local guandanPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_Guandan")
	
	local imgcontent = imgid:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
	local c1 = MatchChooseCard:create(faqPanel,
		{textName="Text_FAQ",
		onTag = {size=52,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetfaq = SettingLayer_widget_FAQ:create({width=size.width,height=size.height})
	widgetfaq:setPosition(cc.p(size.width/2,size.height/2))
	widgetfaq:setCid(SettingCfg.cids[3][1])
	c1:bindView(imgcontent,widgetfaq)
	
	local c2 = MatchChooseCard:create(guandanPanel,
	{textName="Text_Guandan",
		onTag = {size=52,color =cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetguandan = SettingLayer_widget_FAQ:create({width=size.width,height=size.height})
	widgetguandan:setCid(SettingCfg.cids[4][1])
	widgetguandan:setPosition(cc.p(size.width/2,size.height/2))
	c2:bindView(imgcontent,widgetguandan)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
	
	
end
function SettingLayer_PlayMode:onEnter()
	-- body
	
	--这儿之前有个大bug，放在init中会导致，而第二次启动的时候，界面还没创建完成，而这个时候取的是内存中缓存的数据，就直接进行操作子界面的内容，然而这个时候子界面可能还没有创建完成
	self.chooseGp:chooseCard(1)
	self:initLocalText()
end
function SettingLayer_PlayMode:onExit()
	
	self.chooseGp:removeCard(1)
	self.chooseGp:removeCard(1)
	self.chooseGp = nil
	self:unregisterScriptHandler()
	self.super.onExit(self)
end

--本地化
function SettingLayer_PlayMode:initLocalText()
	--title

	ccui.Helper:seekWidgetByName(self.imgheader,"Text_FAQ"):setString(i18n:get('str_setting','setting_faq'))
	ccui.Helper:seekWidgetByName(self.imgheader,"Text_Guandan"):setString(i18n:get('str_setting','setting_guandan'))
end

return SettingLayer_PlayMode