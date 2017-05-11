-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDGameoverWinLayer = class("GDGameoverWinLayer",require("WhippedEgg.mediator.view.GDSettleBaseLayer"))
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

function GDGameoverWinLayer:ctor(param)
	GDGameoverWinLayer.super.ctor(self)
	self:init(param)
	self:setDisCallback(function ( ... )
		-- body
		
		FSRegistryManager:currentFSM():trigger("back")
	end)
end

function GDGameoverWinLayer:init(param)
	--赢
	local Win = require("csb.guandan.GDGameover_win"):create()
	if not Win then
		return
	end
	self.Winroot = Win["root"]
	self.WinAni = Win["animation"]
	FixUIUtils.setRootNodewithFIXED(self.Winroot)
	self.Winroot:runAction(self.WinAni)


	self.WinTag = self.Winroot:getChildByName("Image_tag") --双下标志
	self.WinButtonQuit = self.Winroot:getChildByName("Button_quit")
	self.WinButtonHandover = self.Winroot:getChildByName("Button_handover")
	self.WinButtonContinue = self.Winroot:getChildByName("Button_continue")
  	self.WinButtonQuit:addClickEventListener(handler(self,self.btnClick))
  	self.WinButtonHandover:addClickEventListener(handler(self,self.btnClick))
  	self.WinButtonContinue:addClickEventListener(handler(self,self.btnClick))

  	self:addChild(self.Winroot)
	self:Win(param.info,param.gameOverUsersSeats,param.levelUpSettlementCallBack,param.PersonalEndCallBack)
end

--赢结算
function GDGameoverWinLayer:Win( info, gameOverUsersSeats,levelUpSettlementCallBack,PersonalEndCallBack )
	-- body
	self:unscheduleScript()
	
	playSoundEffect("sound/effect/ying")

	self.levelUpSettlementCallBack = levelUpSettlementCallBack
	self.PersonalEndCallBack = PersonalEndCallBack
	
	--设置信息

	self.WinImgGold = self.Winroot:getChildByName("Image_gold")
	self.WinGold = self.WinImgGold:getChildByName("AtlasLabel_gold") --金币
	local charMap = cc.Director:getInstance():getTextureCache():getTextureForKey("guandan/gameover/common/gd_cm_label1.png")
	self.WinGold:setProperty([[.2000]],"guandan/gameover/common/gd_cm_label1.png",charMap:getPixelsWide()/12,charMap:getPixelsHigh(),".")
	self.WinImageData = self.Winroot:getChildByName("Image_data")
	self.winImageIconG = self.WinImgGold:getChildByName("Image_icon_g") --金币
  	self.winImageIconG:ignoreContentAdaptWithSize(true)

	self.WinImageLeft = self.WinImageData:getChildByName("Image_left") --左边玩家
	self.PanelLeft1 = self.WinImageLeft:getChildByName("Panel_1") --左边玩家
	self.PanelLeft2 = self.WinImageLeft:getChildByName("Panel_2") --左边玩家
	self.LeftOneHead = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_head") --头像
	self.LeftOneName = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Text_username") --名字
	self.LeftOneRank = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_rank") --头油
	--self.LbankryptOne = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_bankrupt") --破产
	--self.LbankryptOne:setVisible(false)
	
	self.LeftTwoHead = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_head")
	self.LeftTwoName = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Text_username")
	self.LeftTwoRank = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_rank")
	--self.LbankryptTwo = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_bankrupt") --破产
	--self.LbankryptTwo:setVisible(false)
	
	self.WinImageRight = self.WinImageData:getChildByName("Image_right") --右边玩家
	self.PanelRight1 = self.WinImageRight:getChildByName("Panel_3") --左边玩家
	self.PanelRight2 = self.WinImageRight:getChildByName("Panel_4") --左边玩家
	self.RightOneHead = ccui.Helper:seekWidgetByName(self.PanelRight1,"Image_head") --头像
	self.RightOneName = ccui.Helper:seekWidgetByName(self.PanelRight1,"Text_username") --名字
	self.RightOneRank = ccui.Helper:seekWidgetByName(self.PanelRight1,"Image_rank") --头油
	self.RbankryptOne = ccui.Helper:seekWidgetByName(self.PanelRight1,"Image_bankrupt") --破产
	self.RbankryptOne:setVisible(false)
	self.RightTwoHead = ccui.Helper:seekWidgetByName(self.PanelRight2,"Image_head")
	self.RightTwoName = ccui.Helper:seekWidgetByName(self.PanelRight2,"Text_username")
	self.RightTwoRank = ccui.Helper:seekWidgetByName(self.PanelRight2,"Image_rank")
	self.RbankryptTwo = ccui.Helper:seekWidgetByName(self.PanelRight2,"Image_bankrupt") --破产
	self.RbankryptTwo:setVisible(false)
	local GamePlayID = info.GamePlayID --对局标识
	local FortuneTax = info.FortuneTax -- 桌子税收
	local Upgrade = info.Upgrade -- 本局上升了多少级

	local numberFortune  --财富或比分
	local doubleWin = true --是否双贡
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then --经典
		local myFortune = gameOverUsersSeats.side1[1].Fortune  --我的财富变化
		numberFortune = tonumber(myFortune)
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		local myFortune = gameOverUsersSeats.side1[1].Score  --我的财富变化
		numberFortune = tonumber(myFortune)
	end

	self.WinGold:setString(string.format("%s%d",numberFortune>=0 and "." or "/", math.abs(numberFortune)))

	for i,v in ipairs(gameOverUsersSeats.side1) do
		--我的信息
		local UserID = v.UserID
		local Ranking = v.Ranking
		local Card = v.Card
		-- local Fortune = v.Fortune
		-- local TFortune = v.TFortune  --本局后总财富
		local Fortune 
		local TFortune  --本局后总财富
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
			GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then --经典
			Fortune = v.Fortune
			TFortune = v.TFortune
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
				GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
				GameManageFactory.gameType == Game_Type.MatchRcircleCount or
				GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			Fortune = v.Score
			TFortune = v.TScore
		end
	
		local bankruptcy = tonumber(TFortune) <= 0 and true or false --是否破产
		local userSeatInfo = GameManageFactory:getCurGameManage():getCruSeatInfoByUserID(UserID)
		local IconID = userSeatInfo.IconID
		local Gender = userSeatInfo.Gender
		local NickName = subNickName(userSeatInfo.UserName)
		local rankImgPath = string.format("guandan/gameover/common/gd_cm_rank%d.png",Ranking)
		if i == 1 then
			if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
				GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
				GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
				DataCenter:getUserdataInstance():setUserInfoByKey("GameCash",tonumber(TFortune))
			end
			self.LeftOneName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.LeftOneRank:loadTexture(rankImgPath)
			end
			--设置头像
			self:addHead(self.LeftOneHead, Gender, IconID, userSeatInfo.UserID)
		else
			self.LeftTwoName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.LeftTwoRank:loadTexture(rankImgPath)
			end

			--设置头像
			self:addHead(self.LeftTwoHead, Gender, IconID, userSeatInfo.UserID)
		end

		if Ranking > 2 then
			doubleWin = false
		end
	end

	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		self.WinTag:setVisible(doubleWin)
		if doubleWin then
			self.WinTag:loadTexture("guandan/gameover/common/gd_cm_tag1.png")
		end
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.WinTag:setVisible(false)
	end

	--对边
	for i,v in ipairs(gameOverUsersSeats.side2) do

		local UserID = v.UserID
		local Ranking = v.Ranking
		local Card = v.Card
		-- local Fortune = v.Fortune
		-- local TFortune = v.TFortune  --本局后总财富
		local Fortune 
		local TFortune  --本局后总财富
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
			GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then --经典
			Fortune = v.Fortune
			TFortune = v.TFortune
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
				GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
				GameManageFactory.gameType == Game_Type.MatchRcircleCount or
				GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			Fortune = v.Score
			TFortune = v.TScore
		end

		local bankruptcy = tonumber(TFortune) <= 0 and true or false --是否破产

		local userSeatInfo = GameManageFactory:getCurGameManage():getCruSeatInfoByUserID(UserID)

		local IconID = userSeatInfo.IconID
		local Gender = userSeatInfo.Gender
		local NickName = subNickName(userSeatInfo.UserName)
		local rankImgPath = string.format("guandan/gameover/common/gd_cm_rank%d.png",Ranking)
		if bankruptcy  and (GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
							GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
							GameManageFactory.gameType == Game_Type.ClassicalRcircleGame)  then
			if i == 2 then
				self.RbankryptOne:setVisible(true)
			else
				self.RbankryptTwo:setVisible(true)
			end
		end
		if i == 2 then
			self.RightOneName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.RightOneRank:loadTexture(rankImgPath)
			end
			--设置头像
			self:addHead(self.RightOneHead, Gender, IconID, userSeatInfo.UserID)
		else
			self.RightTwoName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.RightTwoRank:loadTexture(rankImgPath)
			end
			--设置头像
			self:addHead(self.RightTwoHead, Gender, IconID, userSeatInfo.UserID)
		end

	end

	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
		--播放动画
		self.WinAni:play("animation1",false)
		self.WinAni:setAnimationEndCallFunc1("animation1",function ()
			self.WinAni:play("animation2",true)
		end)

		--倒计时
		self.endSec = SettlementClassicalSec
		self.WinButtonContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")

	  	self.ScriptFuncIdWin = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)

		self.winImageIconG:loadTexture("guandan/gameover/common/gd_cm_gold.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then --比赛
		--播放动画
		self.WinAni:play("animation3",false)
		self.WinAni:setAnimationEndCallFunc1("animation3",function ()
			self.WinAni:play("animation4",true)
		end)

		--倒计时
		self.endSec = SettlementMatchSec
	  	self.ScriptFuncIdWin = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)

		self.winImageIconG:loadTexture("guandan/match/fen.png")
	end	
end

--倒计时
function GDGameoverWinLayer:countDown( ... )
	-- body
	self.endSec = self.endSec - 1
	if self.endSec >= 0 then
  		self.WinButtonContinue:setTitleText(
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


--按钮响应
function GDGameoverWinLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref == self.WinButtonQuit then
		self:unscheduleScript()
		self:close()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.WinButtonHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(2,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.WinButtonContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(1,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	end
end

function GDGameoverWinLayer:onEnter()
	GDGameoverWinLayer.super.onEnter(self)
end

function GDGameoverWinLayer:onExit()
	print("GDGameoverWinLayer onExit")
	GDGameoverWinLayer.super.onExit(self)
end

function GDGameoverWinLayer:unscheduleScript( ... )
	-- body
	if self.ScriptFuncIdWin then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdWin)
		self.ScriptFuncIdWin = false
	end
end

return GDGameoverWinLayer