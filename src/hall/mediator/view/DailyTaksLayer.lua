-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  房间聊天界面
-- v1.1 添加清空播放数据，经典房结算和私人房结算的时候关闭当前界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local DailyTaskLayer = class("DailyTaskLayer",require("app.views.uibase.PopWindowBase"))

local MatchChooseCard = require("hall.mediator.view.widget.MatchChooseCard")
local MatchChooseCardGroup = require("hall.mediator.view.widget.MatchChooseCardGroup")

local DailyTask_Content = require("csb.hall.dailyTask.DailyTask_Content")

local Task_widget_Content = require("hall.mediator.view.widget.task.Task_widget_Content")
--local Activity_widget_Content =  require("hall.mediator.view.widget.task.Activity_widget_Content")


local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")

--@key MatchID 比赛ID
--@key GamePlayID 对局ID
--@key InviteRoomID 私人房ID
function DailyTaskLayer:ctor(param)
	DailyTaskLayer.super.ctor(self)	
	
	self.openType = param.openType or 2 --没有默认任务
	if param.cancelAnim then
		self.canAnim = false
	else
		self.canAnim = true
	end
	--self.canAnim = (param.cancelAnim~=nil and false or true)
	self.handlers = {}
	local node = DailyTask_Content:create().root
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
function DailyTaskLayer:init()
	
	local imgheader = self.imgId:getChildByName("Image_header")
	
	local chooseTag = ccui.Helper:seekWidgetByName(imgheader,"Image_choosetag")
	

	local actPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_activiy")
	

	local taskPanel = ccui.Helper:seekWidgetByName(imgheader,"Panel_task")
	
	local imgcontent = self.imgId:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
--[[	local c1 = MatchChooseCard:create(actPanel,
		{textName="Text_activity",
		onTag = {size=52,color = cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetActivity = Activity_widget_Content:create({width=size.width*0.95,height=size.height*0.95})
	widgetActivity:setPosition(cc.p(size.width/2,size.height/2))
	--widgetActivity:setTaskData(RoomChatData.facialData)
	
	
	c1:bindView(imgcontent,widgetActivity)--]]
	
	local c2 = MatchChooseCard:create(taskPanel,
	{textName="Text_task",
		onTag = {size=52,color =cc.c3b(0xff,0xff,0xff)},
		offTag={size=48,color = cc.c3b(0x46,0x95,0x60)}})
	local widgetTask = Task_widget_Content:create(self.canAnim,{width=size.width,height=size.height*0.95})
	
	widgetTask:setPosition(cc.p(size.width/2,size.height/2))

	
	
	c2:bindView(imgcontent,widgetTask)
	
	self.chooseGp = MatchChooseCardGroup:create()
	self.chooseGp:setTagView(chooseTag)
--	self.chooseGp:addCard(c1)
	self.chooseGp:addCard(c2)
end

function DailyTaskLayer:onEnter()
	DailyTaskLayer.super.onEnter(self)
	wwlog(self.logTag,"DailyTaskLayer onEnter")
	
	
	--self.chooseGp:chooseCard(self.openType)
	self.chooseGp:chooseCard(1)
end


function DailyTaskLayer:onExit()
	wwlog(self.logTag,"DailyTaskLayer onExit")

	self:removeAllChildren()
	DailyTaskLayer.super.onExit(self)
	
end


return DailyTaskLayer