-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDBannerLayer = class("GDBannerLayer",require("WhippedEgg.mediator.view.GDSettleBaseLayer"))
local WWItemSprite = require("app.views.customwidget.WWItemSprite")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local BankruptLayer = require("app.views.customwidget.BankruptLayer")
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local request = require("hall.request.SiRenRoomRequest")
local HallCfg = require("hall.mediator.cfg.HallCfg")

function GDBannerLayer:ctor(param)
	GDBannerLayer.super.ctor(self)
	self:init(param.info)
	self:setDisCallback(function ( ... )
		-- body
		FSRegistryManager:currentFSM():trigger("back")
	end)
end

function GDBannerLayer:init(info)
    --旗帜
  	local banner = require("csb.guandan.GDGameover_banner"):create()
	if not banner then
		return
	end
	self.BanneRoot = banner["root"]
	self.BannerAni = banner["animation"]
	FixUIUtils.setRootNodewithFIXED(self.BanneRoot)
	self.BanneRoot:runAction(self.BannerAni)
  	self:addChild(self.BanneRoot)
  	self.PanelBanner = self.BanneRoot:getChildByName("Panel_banner")
  	self.TextShenji = ccui.Helper:seekWidgetByName(self.PanelBanner,"Text_title")
	self.TextShenji:setString("")
  	self.TextPrize = ccui.Helper:seekWidgetByName(self.PanelBanner,"Text_2")
  	self.Image_flagbg = ccui.Helper:seekWidgetByName(self.PanelBanner,"Image_flagbg")
  	self.Panel_prize = ccui.Helper:seekWidgetByName(self.PanelBanner,"Panel_prize")
  	self.BannerQuit = self.BanneRoot:getChildByName("Button_quit")
  	self.BannerHandover = self.BanneRoot:getChildByName("Button_handover")
  	self.BannerContinue = self.BanneRoot:getChildByName("Button_continue")
  	self.BannerQuit:addClickEventListener(handler(self,self.btnClick))
  	self.BannerHandover:addClickEventListener(handler(self,self.btnClick))
  	self.BannerContinue:addClickEventListener(handler(self,self.btnClick))
  	--倒计时
  	self.endSec = 0

  	--onEnter onExit
	self:Banner(info)
end

--锦旗
function GDBannerLayer:Banner( info )
	-- body
	self:unscheduleScript()
	self.BannerAni:play("animation0",false)
	self.BannerAni:setFrameEventCallFunc(function (frame)
  		self.Panel_prize:removeAllChildren()
		for k,v in pairs(info.magics) do
			local prize = WWItemSprite:createItem({id = v.MagicFID,count = v.MagicCount,})
			updataGoods(v.MagicFID,v.MagicCount)
			prize:setPosition(cc.p(prize:getContentSize().width*0.5 + (k-1)*prize:getContentSize().width,prize:getContentSize().height))
			self.Panel_prize:addChild(prize)
			self.Panel_prize:setContentSize(cc.size(k*prize:getContentSize().width,prize:getContentSize().height))
		end
		self.Panel_prize:setPosition((self.Image_flagbg:getContentSize().width - self.Panel_prize:getContentSize().width)/2,self.Panel_prize:getPositionY())
	end)

	playSoundEffect("sound/effect/jinqi")
	

	local function playNum( num )
		-- body
		if num <= 10 then
			return tostring(num)
		elseif num == 11 then
			return	"J"
		elseif num == 12 then
			return	"Q"
		elseif num == 13 then
			return	"K"
		elseif num == 14 then
			return	"A"
		end
	end

	local contentText = false
	if info.result == 1 then
		contentText = SimpleRichText:create(string.format(i18n:get("str_guandan", "guandan_setlayer_Banner"),
		DataCenter:getUserdataInstance():getValueByKey("nickname"),GameManageFactory:getCurGameManage():getRoomName(),playNum(info.trump)),
		self.TextShenji:getFontSize(),self.TextShenji:getTextColor())
	elseif info.result == 2 then 
		contentText = SimpleRichText:create(i18n:get("str_guandan", "guandan_setlayer_Banner_Fail"),self.TextShenji:getFontSize(),self.TextShenji:getTextColor())
	end

	if next(info.magics) then
		self.TextPrize:setVisible(true)
		else
		self.TextPrize:setVisible(false)
	end
		
	self.TextShenji:removeAllChildren()
	self.TextShenji:addChild(contentText)
	--倒计时
	self.endSec = SettlementClassicalSec
	self.BannerContinue:setTitleText(
		i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")
  	self.ScriptFuncIdBanner = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)
end

--按钮响应
function GDBannerLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref == self.BannerQuit then
		self:unscheduleScript()
		self:close()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.BannerHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(2,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.BannerContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(1,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	end
end


--倒计时
function GDBannerLayer:countDown( ... )
	-- body
	self.endSec = self.endSec - 1
	if self.endSec >= 0 then
		self.BannerContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")

		if self.levelUpSettlementCallBack and self.endSec == SettlementClassicalSec - SettlementMatchSec then
			--self:unscheduleScript()
	 		self.levelUpSettlementCallBack()
		end
  	else --超时
		self:unscheduleScript()
  		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
			--返回房间
			if wwConfigData.AUTO_CONTINUE_GAME then
				self:unscheduleScript()
				self:close()
				GameManageFactory:getCurGameManage():continueGame()
			else
				self:close()
	  			GameManageFactory:getCurGameManage():exitGame()
	  		end
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
				GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
				GameManageFactory.gameType == Game_Type.MatchRcircleCount or
				GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			self:unscheduleScript()
			self:close()
			GameManageFactory:getCurGameManage():settmentOverCallback()
		elseif 	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			self:unscheduleScript()
			if self.PersonalEndCallBack then
		 		self.PersonalEndCallBack()
			end
			
		end	
		
  	end
end

function GDBannerLayer:onEnter()
	GDBannerLayer.super.onEnter(self)
	
end

function GDBannerLayer:unscheduleScript( ... )
	-- body
	if self.ScriptFuncIdBanner then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdBanner)
		self.ScriptFuncIdBanner = false
	end
end
return GDBannerLayer