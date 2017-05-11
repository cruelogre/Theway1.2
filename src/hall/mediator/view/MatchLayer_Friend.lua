-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛牌友 添加好友 界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_Friend = class("MatchLayer_Friend",require("app.views.uibase.PopWindowBase"))

local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local MatchLayer_widget_addFriend = require("hall.mediator.view.widget.MatchLayer_widget_addFriend")
local MatchLayer_widget_friendList = require("hall.mediator.view.widget.MatchLayer_widget_friendList")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

function MatchLayer_Friend:ctor(matchid,InstMatchID)
	MatchLayer_Friend.super.ctor(self)
	self:init(matchid,InstMatchID)
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
end

function MatchLayer_Friend:init(matchid,InstMatchID)
	print("MatchLayer_Friend init")
	self.InstMatchID = InstMatchID
	self.matchid = matchid
	self.node = require("csb.hall.match.MatchLayer_friend"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	

	--testing
	
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	local imgContent = ccui.Helper:seekWidgetByName(self.imgId,"Image_content")
	local chooseTag = ccui.Helper:seekWidgetByName(self.imgId,"Image_choosetag")
	local PanelList = ccui.Helper:seekWidgetByName(self.imgId,"Panel_friend")
	local PanelAdd = ccui.Helper:seekWidgetByName(self.imgId,"Panel_add")
	self:popIn(self.imgId,Pop_Dir.Right)
	local size = imgContent:getContentSize()
	
	local c1 = MatchChooseCard:create(PanelList)
	local widgetlist = MatchLayer_widget_friendList:create({width=size.width,height=size.height},self.matchid,self.InstMatchID)
	widgetlist:setPosition(cc.p(size.width/2,size.height/2))
	widgetlist:bindChangeFun(function ()
		self.chooseGp:chooseCard(2)
	end)
	c1:bindView(imgContent,widgetlist)
	
	local c2 = MatchChooseCard:create(PanelAdd)
	local widgetadd = MatchLayer_widget_addFriend:create({width=size.width,height=size.height})
	widgetadd:bindChangeCard(handler(self,self.chooseCard))
	widgetadd:setPosition(cc.p(size.width/2,size.height/2))
	c2:bindView(imgContent,widgetadd)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
	
end

function MatchLayer_Friend:chooseCard(index)
	--这里切换的时候需要重新请求好友列表
	if index==1 then
		MatchProxy:requestFriend(4,self.InstMatchID)
	end
	
	self.chooseGp:chooseCard(index)
end

function MatchLayer_Friend:onEnter()
	-- body
	MatchLayer_Friend.super.onEnter(self)
	self:initViewData()
	self:initLocalText()
	self.chooseGp:chooseCard(1)
	if self:eventComponent() then
		local x4,handle4 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_AGREE_INVITE,handler(self,self.argreeMe))
		local x5,handle5 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS,handler(self,self.argreeMe))
		self.handle4 = handle4
		self.handle5 = handle5
			--组队成功 已经报名

	end
	
end
function MatchLayer_Friend:onExit()
	self:unregisterScriptHandler()
	self.super.onExit(self)
	if self:eventComponent() then
		self:eventComponent():removeEventListener(self.handle4)
		self:eventComponent():removeEventListener(self.handle5)
	end
end

function MatchLayer_Friend:eventComponent()
	return MatchCfg.innerEventComponent
end

--同意了我的邀请
function MatchLayer_Friend:argreeMe()
	self:close()
end

--设置关闭回调
function MatchLayer_Friend:bindCloseCB(closeCB)
	self._closeCB = closeCB
	
	if self._closeCB and type(self._closeCB)=="function" then
		
		self:setDisCallback(function ( ... )
		-- body
			
			self._closeCB()
			self._closeCB = nil
			
			self:removeFromParent()
			
			
		end)
	end
end

function MatchLayer_Friend:initViewData()
	 -- 我有没有朋友
	
end

function MatchLayer_Friend:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		if name == "Button_add" then
		--添加好友
		
		end
	end
	
	
	
end

function MatchLayer_Friend:initLocalText()
	
end

return MatchLayer_Friend