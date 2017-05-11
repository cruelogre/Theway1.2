-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDGameoverLoseLayer = class("GDGameoverLoseLayer",require("WhippedEgg.mediator.view.GDSettleBaseLayer"))
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

function GDGameoverLoseLayer:ctor(param)
	GDGameoverLoseLayer.super.ctor(self)
	self:init(param)
	self:setDisCallback(function ( ... )
		-- body
		
		FSRegistryManager:currentFSM():trigger("back")
	end)
end
function GDGameoverLoseLayer:init(param)
  	--输
  	local Lost = require("csb.guandan.GDGameover_lose"):create()
	if not Lost then
		return
	end
	self.Lostroot = Lost["root"]
	self.LostAni = Lost["animation"]
	FixUIUtils.setRootNodewithFIXED(self.Lostroot)
	self.Lostroot:runAction(self.LostAni)

	self.LostTag = self.Lostroot:getChildByName("Image_tag") --双下标志
	self.LostButtonQuit = self.Lostroot:getChildByName("Button_quit")
	self.LostButtonHandover = self.Lostroot:getChildByName("Button_handover")
	self.LostButtonContinue = self.Lostroot:getChildByName("Button_continue")
	self.LostButtonQuit:addClickEventListener(handler(self,self.btnClick))
  	self.LostButtonHandover:addClickEventListener(handler(self,self.btnClick))
  	self.LostButtonContinue:addClickEventListener(handler(self,self.btnClick))

  	self:addChild(self.Lostroot)
	
	self:Lost(param.info,param.gameOverUsersSeats,param.levelUpSettlementCallBack,param.PersonalEndCallBack)
end

--输结算
function GDGameoverLoseLayer:Lost( info, gameOverUsersSeats,levelUpSettlementCallBack,PersonalEndCallBack )
	-- body
	self:unscheduleScript()

	playSoundEffect("sound/effect/shu")

	self.levelUpSettlementCallBack = levelUpSettlementCallBack
	self.PersonalEndCallBack = PersonalEndCallBack

	--设置信息
	self.LostImgGold = self.Lostroot:getChildByName("Image_gold")
	self.LostGold = self.LostImgGold:getChildByName("AtlasLabel_gold") --金币
	local charMap = cc.Director:getInstance():getTextureCache():getTextureForKey("guandan/gameover/common/gd_cm_label2.png")
	self.LostGold:setProperty([[/2000]],"guandan/gameover/common/gd_cm_label2.png",charMap:getPixelsWide()/12,charMap:getPixelsHigh(),".")
	self.LostImageData = self.Lostroot:getChildByName("Image_data")
	self.LostImageIconG = self.LostImgGold:getChildByName("Image_icon_g") --金币
  	self.LostImageIconG:ignoreContentAdaptWithSize(true)

	self.LostImageLeft = self.LostImageData:getChildByName("Image_left") --左边玩家
	self.PanelLeft1 = self.LostImageLeft:getChildByName("Panel_1") --左边玩家
	self.PanelLeft2 = self.LostImageLeft:getChildByName("Panel_2") --左边玩家
	self.LeftOneHead = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_head") --头像
	self.LeftOneName = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Text_username") --名字
	self.LeftOneRank = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_rank") --头油
	
	self.LbankryptOne = ccui.Helper:seekWidgetByName(self.PanelLeft1,"Image_bankrupt") --破产
	self.LbankryptOne:setVisible(false)
	
	self.LeftTwoHead = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_head")
	self.LeftTwoName = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Text_username")
	self.LeftTwoRank = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_rank")
	self.LbankryptTwo = ccui.Helper:seekWidgetByName(self.PanelLeft2,"Image_bankrupt") --破产
	self.LbankryptTwo:setVisible(false)
	
	self.LostImageRight = self.LostImageData:getChildByName("Image_right") --右边玩家
	self.PanelRight1 = self.LostImageRight:getChildByName("Panel_3") --左边玩家
	self.PanelRight2 = self.LostImageRight:getChildByName("Panel_4") --左边玩家
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
	-- local myFortune = gameOverUsersSeats.side1[1].Fortune  --我的财富变化
	-- local numberFortune = tonumber(myFortune)

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

	self.LostGold:setString(string.format("%s%d",numberFortune>=0 and "." or "/", math.abs(numberFortune)))
	
	local doubleLost = true --是否双下	
	for i,v in ipairs(gameOverUsersSeats.side1) do
		--我的信息
		local UserID = v.UserID
		local Ranking = v.Ranking
		local Card = v.Card
		local Fortune 
		local TFortune  --本局后总财富
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
			GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then --经典 私人房都用财富值参数
			Fortune = v.Fortune
			TFortune = v.TFortune
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
				GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
				GameManageFactory.gameType == Game_Type.MatchRcircleCount or
				GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			Fortune = v.Score
			TFortune = v.TScore
		end

		local userSeatInfo = GameManageFactory:getCurGameManage():getCruSeatInfoByUserID(UserID)
		local IconID = userSeatInfo.IconID
		local Gender = userSeatInfo.Gender
		local NickName = subNickName(userSeatInfo.UserName)

		local bankruptcy = tonumber(TFortune) <= 0 and true or false --是否破产
		local rankImgPath = string.format("guandan/gameover/common/gd_cm_rank%d.png",Ranking)
		if i == 1 then
			self.LeftOneName:setString(NickName)
			if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
				GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
				GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
				DataCenter:getUserdataInstance():setUserInfoByKey("GameCash",tonumber(TFortune))
			end
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.LeftOneRank:loadTexture(rankImgPath)
			end

			self:addHead(self.LeftOneHead, Gender, IconID, userSeatInfo.UserID)
		else
			self.LeftTwoName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.LeftTwoRank:loadTexture(rankImgPath)
			end
			self:addHead(self.LeftTwoHead, Gender, IconID, userSeatInfo.UserID)
		end
		if bankruptcy and (GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
							GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
							GameManageFactory.gameType == Game_Type.ClassicalRcircleGame) then
			if i == 1 then
				self.LbankryptOne:setVisible(true)
			else
				self.LbankryptTwo:setVisible(true)
			end
		end
		
		if Ranking <= 2 then
			doubleLost = false
		end
	end


	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		self.LostTag:setVisible(doubleLost)
		if doubleLost then
			self.LostTag:loadTexture("guandan/gameover/common/gd_cm_tag2.png")
		end
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.LostTag:setVisible(false)
	end
	
	for i,v in ipairs(gameOverUsersSeats.side2) do
		--对边
		local UserID = v.UserID
		local Ranking = v.Ranking
		local Card = v.Card
		local Fortune 
		local TFortune  --本局后总财富
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
			GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle	then --经典 私人房都用财富值参数
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
		if i == 2 then		
			self.RightOneName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.RightOneRank:loadTexture(rankImgPath)
			end

			self:addHead(self.RightOneHead, Gender, IconID, userSeatInfo.UserID)
		else
			self.RightTwoName:setString(NickName)
			if cc.FileUtils:getInstance():isFileExist(rankImgPath) then
				self.RightTwoRank:loadTexture(rankImgPath)
			end

			self:addHead(self.RightTwoHead, Gender, IconID, userSeatInfo.UserID)
		end
	end

	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典 
		--播放动画
		self.LostAni:play("animation1",false)
		self.LostAni:setAnimationEndCallFunc1("animation1",function ()
			self.LostAni:play("animation2",true)
		end)

		--倒计时
		self.endSec = SettlementClassicalSec
		self.LostButtonContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")
	  	self.ScriptFuncIdLost = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)

	  	self.LostImageIconG:loadTexture("guandan/gameover/common/gd_cm_gold.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		--播放动画
		self.LostAni:play("animation3",false)
		self.LostAni:setAnimationEndCallFunc1("animation3",function ()
			self.LostAni:play("animation4",true)
		end)

		--倒计时
		self.endSec = SettlementMatchSec
	  	self.ScriptFuncIdLost = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)

	  	self.LostImageIconG:loadTexture("guandan/match/fen.png")
	end	
end


--倒计时
function GDGameoverLoseLayer:countDown( ... )
	-- body
	self.endSec = self.endSec - 1
	if self.endSec >= 0 then
		self.LostButtonContinue:setTitleText(
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
function GDGameoverLoseLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref == self.LostButtonQuit then
		self:unscheduleScript()
		self:close()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.LostButtonHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(2,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.LostButtonContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:unscheduleScript()
			if not self:showBankrupt(1,self.endSec) then
				self:close()
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	end
end

function GDGameoverLoseLayer:onEnter()
	GDGameoverLoseLayer.super.onEnter(self)
end

function GDGameoverLoseLayer:onExit()
	print("GDGameoverLoseLayer onExit")
	GDGameoverLoseLayer.super.onExit(self)
	
end
function GDGameoverLoseLayer:unscheduleScript( ... )
	-- body
	if self.ScriptFuncIdLost then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdLost)
		self.ScriptFuncIdLost = false
	end
end

return GDGameoverLoseLayer