-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛定时赛界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_Face2Face = class("MatchLayer_Face2Face",require("app.views.uibase.PopWindowBase"))


local MatchLayer_widget_Face2Face1 = require("hall.mediator.view.widget.MatchLayer_widget_Face2Face1")
local MatchLayer_widget_Face2Face2 = require("hall.mediator.view.widget.MatchLayer_widget_Face2Face2")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

function MatchLayer_Face2Face:ctor()
	MatchLayer_Face2Face.super.ctor(self)
	self:init()
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
end

function MatchLayer_Face2Face:init()
	print("MatchLayer_Friend init")
	self.node = require("csb.hall.match.MatchLayer_face2face"):create().root
	
	--FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	
	self.numbers = MatchCfg.searchSendnumbers
	--testing
	
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	self.imgContent = ccui.Helper:seekWidgetByName(self.imgId,"Image_content")
	
	self:popIn(self.imgId,Pop_Dir.Right)
	--这里处理当前是否正在搜索，也就是上次数字的有效期
	
	self.searchingFriend = false --是否在搜索好友中  目前搜索好友条件判断是根据时间来的，30s内有效
end


function MatchLayer_Face2Face:onEnter()
	MatchLayer_Face2Face.super.onEnter(self)
	-- body
	--进来的时候，根据时间判断
	local diff = os.time() - MatchCfg.matchSendnumberTime
	if diff>0 and diff < MatchCfg.numberValidTime then
		self.searchingFriend = true
	else
		self.searchingFriend = false
	end
	
	self:initViewData()
	self:initLocalText()
	if self:eventComponent() then
		local x5,handle5 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS,handler(self,self.argreeMe))
		self.handle5 = handle5
	end

end
function MatchLayer_Face2Face:onExit()
	if isLuaNodeValid(self.panelNumber) then
		self.panelNumber:bindChangeFun(nil)
	end
	if isLuaNodeValid(self.searchFriend) then
		self.searchFriend:bindChangeFun(nil)
		self.searchFriend:bindTimeOutCB(nil)
	end
	MatchLayer_Face2Face.super.onExit(self)
	self:unregisterScriptHandler()
	self.imgContent = nil
	--self.super.onExit(self)
	if self:eventComponent() then
		self:eventComponent():removeEventListener(self.handle5)
	end
	
end

function MatchLayer_Face2Face:argreeMe()
	self:close()
end
function MatchLayer_Face2Face:initViewData()
	 -- 当前什么状态
	if self.imgContent then
		if isLuaNodeValid(self.panelNumber) then
			self.panelNumber:bindChangeFun(nil)
		end
		if isLuaNodeValid(self.searchFriend) then
			self.searchFriend:bindChangeFun(nil)
			self.searchFriend:bindTimeOutCB(nil)
		end
		self.imgContent:removeAllChildren()
		self.panelNumber = nil
		self.searchFriend = nil
	end
	local size = self.imgContent:getContentSize()
	if not self.searchingFriend then
		self.panelNumber = MatchLayer_widget_Face2Face1:create(size)
		self.panelNumber:setPosition(cc.p(size.width/2,size.height/2))
		self.panelNumber:bindChangeFun(function (numbers)
			self.searchingFriend = true
			self.numbers = numbers
			self:initViewData() --刷新
		end)
		self.imgContent:addChild(self.panelNumber,1)
	else
		self.searchFriend = MatchLayer_widget_Face2Face2:create(size,self.numbers)
		self.searchFriend:bindTimeOutCB(handler(self,self.timeOutHandle))
		self.searchFriend:bindChangeFun(handler(self,self.changeHandle))
		self.searchFriend:setPosition(cc.p(size.width/2,size.height/2))
		self.imgContent:addChild(self.searchFriend,1)
	end
	
end

function MatchLayer_Face2Face:bindChangeCard(cbFun)
	self.cbFun = cbFun
end
--搜索好友时间倒计时结束 搜到好友情况
function MatchLayer_Face2Face:timeOutHandle()
	self:close()
	if self.cbFun then
		self.cbFun()
	end
end

--搜索好友切换到数字界面
function MatchLayer_Face2Face:changeHandle()
		--进来的时候，根据时间判断
	local diff = os.time() - MatchCfg.matchSendnumberTime
	if diff>0 and diff < MatchCfg.numberValidTime then
		self.searchingFriend = true
	else
		self.searchingFriend = false
	end
	
	self:initViewData()
end


function MatchLayer_Face2Face:touchListener(ref,eventType)
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
function MatchLayer_Face2Face:eventComponent()
	return MatchCfg.innerEventComponent
end

function MatchLayer_Face2Face:initLocalText()
	
end

return MatchLayer_Face2Face