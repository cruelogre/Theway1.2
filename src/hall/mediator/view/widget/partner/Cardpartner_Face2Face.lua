-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛面对面加好友界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Cardpartner_Face2Face = class("Cardpartner_Face2Face",require("app.views.uibase.PopWindowBase"))


local Cardpartner_widget_Face2Face1 = require("hall.mediator.view.widget.partner.Cardpartner_widget_Face2Face1")
local Cardpartner_widget_Face2Face2 = require("hall.mediator.view.widget.partner.Cardpartner_widget_Face2Face2")

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

function Cardpartner_Face2Face:ctor()
	Cardpartner_Face2Face.super.ctor(self)
	self.handles = {}
	self:init()

end

function Cardpartner_Face2Face:init()
	print("Cardpartner_Face2Face init")
	self.node = require("csb.hall.match.MatchLayer_face2face"):create().root
	
	--FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)

	self.numbers = CardPartnerCfg.searchSendnumbers
	
	--testing
	
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	self.imgContent = ccui.Helper:seekWidgetByName(self.imgId,"Image_content")
	
	self:popIn(self.imgId,Pop_Dir.Right)
	--这里处理当前是否正在搜索，也就是上次数字的有效期
	
	self.searchingFriend = false --是否在搜索好友中  目前搜索好友条件判断是根据时间来的，30s内有效
end


function Cardpartner_Face2Face:onEnter()
	Cardpartner_Face2Face.super.onEnter(self)
	-- body
	--进来的时候，根据时间判断


	local diff = os.time() -  CardPartnerCfg.matchSendnumberTime
	local numberValidTime = CardPartnerCfg.numberValidTime
	
	if diff>0 and diff < numberValidTime then
		self.searchingFriend = true
	else
		self.searchingFriend = false
	end
	
	self:initViewData()
	self:initLocalText()
	if self:eventComponent() then
		
	end

end
function Cardpartner_Face2Face:onExit()
	if isLuaNodeValid(self.panelNumber) then
		self.panelNumber:bindChangeFun(nil)
	end
	if isLuaNodeValid(self.searchFriend) then
		self.searchFriend:bindChangeFun(nil)
		self.searchFriend:bindTimeOutCB(nil)
	end
	Cardpartner_Face2Face.super.onExit(self)
	self:unregisterScriptHandler()
	self.imgContent = nil
	--self.super.onExit(self)
	if self.handles and self:eventComponent() then
		for _,v in pairs(self.handles) do
			self:eventComponent():removeEventListener(v)
		end
		removeAll(self.handles)
	end

	
end

function Cardpartner_Face2Face:argreeMe()
	self:close()
end
function Cardpartner_Face2Face:initViewData()
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
		self.panelNumber = Cardpartner_widget_Face2Face1:create(size,self.openType)
		self.panelNumber:setPosition(cc.p(size.width/2,size.height/2))
		self.panelNumber:bindChangeFun(function (numbers)
			self.searchingFriend = true
			self.numbers = numbers
			self:initViewData() --刷新
		end)
		self.imgContent:addChild(self.panelNumber,1)
	else
		self.searchFriend = Cardpartner_widget_Face2Face2:create(size,self.numbers,self.openType)
		self.searchFriend:bindTimeOutCB(handler(self,self.timeOutHandle))
		self.searchFriend:bindChangeFun(handler(self,self.changeHandle))
		self.searchFriend:setPosition(cc.p(size.width/2,size.height/2))
		self.imgContent:addChild(self.searchFriend,1)
	end
	
end

function Cardpartner_Face2Face:bindChangeCard(cbFun)
	self.cbFun = cbFun
end
--搜索好友时间倒计时结束 搜到好友情况
function Cardpartner_Face2Face:timeOutHandle()
	self:close()
	if self.cbFun then
		self.cbFun()
	end
end

--搜索好友切换到数字界面
function Cardpartner_Face2Face:changeHandle()
		--进来的时候，根据时间判断
	local diff = os.time() -  MatchCfg.matchSendnumberTime
	local numberValidTime = MatchCfg.numberValidTime
	if self.openType==1 then
		
	elseif self.openType == 2 then
		diff = os.time() -  CardPartnerCfg.matchSendnumberTime
		numberValidTime = CardPartnerCfg.numberValidTime
	end
	
	if diff>0 and diff < numberValidTime then
		self.searchingFriend = true
	else
		self.searchingFriend = false
	end
	
	self:initViewData()
end


function Cardpartner_Face2Face:touchListener(ref,eventType)
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
function Cardpartner_Face2Face:eventComponent()
	return CardPartnerCfg.innerEventComponent
end

function Cardpartner_Face2Face:initLocalText()
	
end

return Cardpartner_Face2Face