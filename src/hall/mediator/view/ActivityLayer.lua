-------------------------------------------------------------------------
-- Title:       活动
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ActivityLayer = class("ActivityLayer", require("app.views.uibase.PopWindowBase"))

local Activity_Content = require("csb.hall.activity.Activity_Content")

local Activity_widget_Content =  require("hall.mediator.view.widget.task.Activity_widget_Content")

function ActivityLayer:ctor(param)
	ActivityLayer.super.ctor(self)	
	
	self.handlers = {}
	local node = Activity_Content:create().root
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

function ActivityLayer:init()
	local imgcontent = self.imgId:getChildByName("Image_content")
	local size = imgcontent:getContentSize()
	
	self.widgetActivity = Activity_widget_Content:create({width=size.width*0.95,height=size.height*0.95})
	self.widgetActivity:setPosition(cc.p(size.width/2,size.height/2))
	imgcontent:addChild(self.widgetActivity)
	self.widgetActivity:active()
	ccui.Helper:seekWidgetByName(self.imgId,"Button_back"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_webback"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_webrefresh"):addTouchEventListener(handler(self,self.touchListener))
end

function ActivityLayer:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		local btn = tolua.cast(ref,"ccui.Button")
		if not btn or btn:isBright() then
			playSoundEffect("sound/effect/anniu")
		end
		if name=="Button_back" then
			self:close()
		elseif name == "Button_webback" then
			if self.widgetActivity then
				self.widgetActivity:goBack()
			end
		elseif name == "Button_webrefresh" then
			if self.widgetActivity then
				self.widgetActivity:refresh()
			end
		end
	
	end
end
return ActivityLayer