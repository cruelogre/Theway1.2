-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  房间聊天界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local CardPartnerLayer = class("CardPartnerLayer",require("app.views.uibase.PopWindowBase"))

local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local Cardpartner_Content = require("csb.hall.cardpartner.Cardpartner_Content")

local Session_widget_Content =  require("hall.mediator.view.widget.partner.Session_widget_Content")
local Friend_widget_Content =  require("hall.mediator.view.widget.partner.Friend_widget_Content")
local Add_widget_Content =  require("hall.mediator.view.widget.partner.Add_widget_Content")


--@key MatchID 比赛ID
--@key GamePlayID 对局ID
--@key InviteRoomID 私人房ID
function CardPartnerLayer:ctor(param)
	CardPartnerLayer.super.ctor(self)	
	
	self.openType = param.openType or 2 --没有默认任务
	self.handlers = {}
	local node = Cardpartner_Content:create().root
	FixUIUtils.setRootNodewithFIXED(node)
	
	self:addChild(node)
	
	self.imgId = node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	self:init()
	
	
	self:setDisCallback(function ( ... )
		-- body
		FSRegistryManager:currentFSM():trigger("back")
	end)
	
	self:popIn(self.imgId,Pop_Dir.Right)
	
end
function CardPartnerLayer:init()
	
	local imgheader = self.imgId:getChildByName("Image_header")
	
	local chooseTag = ccui.Helper:seekWidgetByName(imgheader,"Image_choosetag")
	
	local sessionPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_session")
	local friendPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_friend")
	local addPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_add")
	
	local imgcontent = self.imgId:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
	local c1 = MatchChooseCard:create(sessionPanel,
		{textName="Text_session",
		onTag = {size=52,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetSession = Session_widget_Content:create({width=size.width,height=size.height*0.95})
	widgetSession:setPosition(cc.p(size.width/2,size.height/2))
	--widgetActivity:setTaskData(RoomChatData.facialData)
	c1:bindView(imgcontent,widgetSession)
	
	local c2 = MatchChooseCard:create(friendPanel,
	{textName="Text_friend",
		onTag = {size=52,color =cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetFriend = Friend_widget_Content:create({width=size.width,height=size.height*0.95})
	widgetFriend:bindChangeCard(handler(self,self.chooseCard))
	widgetFriend:setPosition(cc.p(size.width/2,size.height/2))
	c2:bindView(imgcontent,widgetFriend)
	
	local c3 = MatchChooseCard:create(addPanel,
	{textName="Text_add",
		onTag = {size=52,color =cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetAdd = Add_widget_Content:create({width=size.width,height=size.height*0.95},{jumpIndex = 2})
	widgetAdd:bindChangeCard(handler(self,self.chooseCard))
	widgetAdd:setPosition(cc.p(size.width/2,size.height/2))
	c3:bindView(imgcontent,widgetAdd)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
	self.chooseGp:addCard(c3)
end

function CardPartnerLayer:onEnter()
	CardPartnerLayer.super.onEnter(self)
	wwlog(self.logTag,"CardPartnerLayer onEnter")
	
	self:chooseCard(self.openType)
end


function CardPartnerLayer:onExit()
	wwlog(self.logTag,"CardPartnerLayer onExit")
	self.chooseGp:removeCard(1)
	self.chooseGp:removeCard(1)
	self.chooseGp:removeCard(1)
	
	self:removeAllChildren()
	CardPartnerLayer.super.onExit(self)

end
function CardPartnerLayer:chooseCard(index)
	--这里切换的时候需要重新请求好友列表
	if index==2 then
		--MatchProxy:requestFriend(4,self.InstMatchID)
	end
	
	self.chooseGp:chooseCard(index)
end

return CardPartnerLayer