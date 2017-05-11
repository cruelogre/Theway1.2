-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  设置界面中的隐私政策，服务协议控件（共用，通过cid区分）
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingLayer_widget_protocol = class("SettingLayer_widget_protocol",
require("hall.mediator.view.widget.SettingLayer_widget_base"))

local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local SettingProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SETTING)
function SettingLayer_widget_protocol:ctor(size)
	SettingLayer_widget_protocol.super.ctor(self,size)
	
	self:init()
	
end

function SettingLayer_widget_protocol:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
	
	self.node = require("csb.hall.setting.SettingLayer_widget_protocol"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	self.scroll = self.node:getChildByName("ScrollView_content")
	self.size = self.scroll:getContentSize()
	--self:setInnerContainerSize(cc.size(900,1800))
	self.scroll:setClippingEnabled(true)
	
end 



function SettingLayer_widget_protocol:initView(...)
	local eventName = SettingCfg.getEventByCid(self.cid)
	local contenttable = DataCenter:getData(eventName)
	
	if not contenttable or not contenttable.content then
		return
	end

	self:freshContent(contenttable.content)
	
	
end

--刷新内容
function SettingLayer_widget_protocol:freshContent(content)
	self.scroll:removeAllChildren()
	
	local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 30, glyphs = "CUSTOM" }
	
	local ttf2 = cc.Label:createWithTTF(tmpCfg2,content, cc.TEXT_ALIGNMENT_LEFT, self.size.width*0.96)
	--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT
	self.scroll:setInnerContainerSize(cc.size(self.size.width,ttf2:getContentSize().height))
	ttf2:setName("text")
	ttf2:setColor(cc.c3b(91,97,94))
	ttf2:setAnchorPoint(cc.p(0.5,0.5))
	ttf2:setPosition(cc.p(self.size.width/2,ttf2:getContentSize().height/2))
    self.scroll:addChild(ttf2)
	self.scroll:jumpToTop()
	
end


function SettingLayer_widget_protocol:eventComponent()
	return SettingCfg.innerEventComponent
end

function SettingLayer_widget_protocol:onEnter()
	local eventName = SettingCfg.getEventByCid(self.cid)
	--注册cid响应回调
	self:eventComponent():addEventListener(eventName,handler(self,self.initView))
end

function SettingLayer_widget_protocol:onExit()
	local eventName = SettingCfg.getEventByCid(self.cid)
	self:eventComponent():removeEventListener(eventName)
	--退出的时候取消cid回调绑定
	SettingProxy:cancelProtocol(self.cid)
	
end


return SettingLayer_widget_protocol