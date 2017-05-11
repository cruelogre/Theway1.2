-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.23
-- Last: 
-- Content:  牌友邀请游戏界面 包括可邀请牌友 和添加牌友
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Cardpartner_Invite_Friend = class("Cardpartner_Invite_Friend",require("app.views.uibase.PopWindowBase"))

local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local Add_widget_Content =  require("hall.mediator.view.widget.partner.Add_widget_Content")
local Cardpartner_widget_InviteFriendList = require("hall.mediator.view.widget.partner.Cardpartner_widget_InviteFriendList")

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
function Cardpartner_Invite_Friend:ctor(inviteType,paramId,userOrder)
	Cardpartner_Invite_Friend.super.ctor(self)
	self.inviteType = inviteType or 4 --邀请的类型 4 私人房 3 比赛
	self.paramId = paramId --参数的ID 如果是私人房就是roomID 如果是比赛就是比赛实例ID
	self.userOrder = userOrder or 8
	self.handlers = {}
	self:init()
	
end

function Cardpartner_Invite_Friend:init()
	print("Cardpartner_Invite_Friend init")

	self.node = require("csb.hall.cardpartner.Cardpartner_Invite_Friend"):create().root
	
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
	local widgetlist = Cardpartner_widget_InviteFriendList:create({width=size.width,height=size.height},self.inviteType,self.paramId)
	widgetlist:setPosition(cc.p(size.width/2,size.height/2))
	widgetlist:bindChangeFun(handler(self,self.chooseCard))
	c1:bindView(imgContent,widgetlist)
	
	local c2 = MatchChooseCard:create(PanelAdd)
	local widgetadd = Add_widget_Content:create({width=size.width,height=size.height},{userOrder = self.userOrder,jumpIndex = 1})
	widgetadd:bindChangeCard(handler(self,self.chooseCard))
	widgetadd:setPosition(cc.p(size.width/2,size.height/2))
	c2:bindView(imgContent,widgetadd)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
	
end

function Cardpartner_Invite_Friend:chooseCard(index)
	--这里切换的时候需要重新请求好友列表
	print("chooseCard",index)
	if index==1 then
		--MatchProxy:requestFriend(4,self.InstMatchID)
	end
	
	self.chooseGp:chooseCard(index)
end

function Cardpartner_Invite_Friend:onEnter()
	-- body
	Cardpartner_Invite_Friend.super.onEnter(self)
	self:initViewData()
	self:initLocalText()
	self.chooseGp:chooseCard(1)
	if self:eventComponent() then
		
	end
	
end
function Cardpartner_Invite_Friend:onExit()
	self:unregisterScriptHandler()
	self.super.onExit(self)
	if self:eventComponent() and self.handlers then
		for _,v in pairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
	end
end

function Cardpartner_Invite_Friend:eventComponent()
	return CardPartnerCfg.innerEventComponent
end

--同意了我的邀请
function Cardpartner_Invite_Friend:argreeMe()
	self:close()
end

--设置关闭回调
function Cardpartner_Invite_Friend:bindCloseCB(closeCB)
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

function Cardpartner_Invite_Friend:initViewData()
	 -- 我有没有朋友
	
end


function Cardpartner_Invite_Friend:initLocalText()
	
end

return Cardpartner_Invite_Friend