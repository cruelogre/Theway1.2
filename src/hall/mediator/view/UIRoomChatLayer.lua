-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  房间聊天界面
-- v1.1 添加清空播放数据，经典房结算和私人房结算的时候关闭当前界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIRoomChatLayer = class("UIRoomChatLayer",require("app.views.uibase.PopWindowBase"))

local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local RoomChat_Content = require("csb.hall.roomchat.RoomChat_Content")

local RoomChat_widget_Facial = require("hall.mediator.view.widget.roomchat.RoomChat_widget_Facial")
local RoomChat_widget_Character =  require("hall.mediator.view.widget.roomchat.RoomChat_widget_Character")

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

--@key MatchID 比赛ID
--@key GamePlayID 对局ID
--@key InviteRoomID 私人房ID
function UIRoomChatLayer:ctor(param)
	wwlog("UIRoomChatLayer 创建")
	self.super.ctor(self)	
	self.MatchID = param.MatchID
	self.GamePlayID = param.GamePlayID
	self.InviteRoomID = param.InviteRoomID
	
	self.handlers = {}
	local node = RoomChat_Content:create().root
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
function UIRoomChatLayer:init()
	
	local imgheader = self.imgId:getChildByName("Image_header")
	
	local chooseTag = ccui.Helper:seekWidgetByName(imgheader,"Image_choosetag")
	

	local expPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_expression")
	

	local charPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_character")
	
	local imgcontent = self.imgId:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
	local c1 = MatchChooseCard:create(expPanel,
		{textName="Text_expression",
		onTag = {size=52,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetFacial = RoomChat_widget_Facial:create({width=size.width,height=size.height*0.95})
	widgetFacial:setPosition(cc.p(size.width/2,size.height/2))
	widgetFacial:setFacialData(RoomChatManager.facialData)
	widgetFacial:setGameData(self.MatchID,self.GamePlayID,self.InviteRoomID)
	
	c1:bindView(imgcontent,widgetFacial)
	
	local c2 = MatchChooseCard:create(charPanel,
	{textName="Text_character",
		onTag = {size=52,color =cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetChar = RoomChat_widget_Character:create({width=size.width,height=size.height*0.95})
	
	widgetChar:setPosition(cc.p(size.width/2,size.height/2))
	widgetChar:setCharData(RoomChatManager.charecterData)
	widgetChar:setGameData(self.MatchID,self.GamePlayID,self.InviteRoomID)
	
	c2:bindView(imgcontent,widgetChar)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
end

function UIRoomChatLayer:closeUIHandler(event)
	if event._eventName==RoomChatCfg.InnerEvents.RMCHAT_EVENT_CLOSEUI then
		RoomChatManager:clearCharPlayData()
		RoomChatManager:clearFacialPlayData()
		self:close()
	end

end

function UIRoomChatLayer:onEnter()
	self.super.onEnter(self)
	wwlog(self.logTag,"UIRoomChatLayer onEnter")
	if self.chooseGp then
		self.chooseGp:chooseCard(1)
	end
	
	self.closeHandler = WWFacade:addCustomEventListener(RoomChatCfg.InnerEvents.RMCHAT_EVENT_CLOSEUI, handler(self, self.closeUIHandler))
end


function UIRoomChatLayer:onExit()
	wwlog(self.logTag,"UIRoomChatLayer onExit")
	
	if self.closeHandler then
		WWFacade:removeEventListener(self.closeHandler)
	end
	self:removeAllChildren()
	if self.chooseGp then
		self.chooseGp:removeCard(1)
		self.chooseGp:removeCard(1)
	end
	self.chooseGp = nil

	self.super.onExit(self)
	self.MatchID = nil
	self.GamePlayID = nil
	self.InviteRoomID = nil
end


return UIRoomChatLayer