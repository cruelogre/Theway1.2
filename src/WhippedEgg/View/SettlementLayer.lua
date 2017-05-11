-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  结算
-- 2016-09-21 diyal 将init函数里面的控件解析去掉
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SettlementLayer = class("SettlementLayer",cc.LayerColor)
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

function SettlementLayer:ctor( ... )
	-- body
	self:init()
end

function SettlementLayer:init( ... )
	-- body
    --旗帜
  	local banner = require("csb.guandan.GDGameover_banner"):create()
	if not banner then
		return
	end
	self.BanneRoot = banner["root"]
	self.BannerAni = banner["animation"]
	FixUIUtils.setRootNodewithFIXED(self.BanneRoot)
	self.BanneRoot:runAction(self.BannerAni)
	self.BanneRoot:setVisible(false)
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
	
	local personSettleLayer = require("csb.guandan.GDPersonSettleLayer"):create()
	if not personSettleLayer then
		return
	end
	self.personSettleLayerRoot = personSettleLayer["root"]
	self.personSettleLayerAni = personSettleLayer["animation"]
	FixUIUtils.setRootNodewithFIXED(self.personSettleLayerRoot)
	self.personSettleLayerRoot:runAction(self.personSettleLayerAni)
	self.personSettleLayerRoot:setVisible(false)
  	self:addChild(self.personSettleLayerRoot)
	local Image_listbg = self.personSettleLayerRoot:getChildByName("Image_listbg")
	self.listViewPersonal = Image_listbg:getChildByName("ListView_content")
	self.personalBtnBack = self.personSettleLayerRoot:getChildByName("Button_back")
	self.personalBtnShare = self.personSettleLayerRoot:getChildByName("Button_share")
	self.personalBtnContinue = self.personSettleLayerRoot:getChildByName("Button_continue")
	self.personalBtnBack:addClickEventListener(handler(self,self.btnClick))
  	self.personalBtnShare:addClickEventListener(handler(self,self.btnClick))
	self.personalBtnContinue:addClickEventListener(handler(self,self.btnClick))


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
  	self.Winroot:setVisible(false)

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

  	self.Lostroot:setVisible(false)
  	self:addChild(self.Lostroot)

  	--倒计时
  	self.endSec = 0

  	--onEnter onExit
	self:registerScriptHandler(handler(self,self.onNodeEvent))
end
----------------------------------------------------
--触摸事件
----------------------------------------------------
function SettlementLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
       
    end
end

--onEnter onExit
function SettlementLayer:onNodeEvent( event )
	-- body
	if event == "enter" then
    elseif event == "exit" then
		self:unscheduleScript()
    end
end

--赢结算
function SettlementLayer:Win( info, gameOverUsersSeats,levelUpSettlementCallBack,PersonalEndCallBack )
	-- body
	self:Cancellation()
	
	playSoundEffect("sound/effect/ying")
	self.Winroot:setVisible(true)
	self.Lostroot:setVisible(false)
	self.BanneRoot:setVisible(false)
	self.levelUpSettlementCallBack = levelUpSettlementCallBack
	self.PersonalEndCallBack = PersonalEndCallBack
	self:addTouchListener()
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
		self.LostButtonContinue:setTitleText(
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

--输结算
function SettlementLayer:Lost( info, gameOverUsersSeats,levelUpSettlementCallBack,PersonalEndCallBack )
	-- body
	self:Cancellation()

	playSoundEffect("sound/effect/shu")
	self.Winroot:setVisible(false)
	self.Lostroot:setVisible(true)
	self.BanneRoot:setVisible(false)
	self.levelUpSettlementCallBack = levelUpSettlementCallBack
	self.PersonalEndCallBack = PersonalEndCallBack
	self:addTouchListener()

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
		self.WinButtonContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")
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

function SettlementLayer:showBankrupt( butType,leftTime )
	-- body
	wwlog("SettlementLayer.lua","检测是否破产")
	local enterTime = os.time()
	local layerType = false
	local roomData = ChooseRoomProxy:getRoomData(WhippedEggSceneProxy.gamezoneid)
	local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash"))
	if  DataCenter:getUserdataInstance():getValueByKey("bankrupt") and myCash < HallCfg.bankRuptLimit then
		wwlog("SettlementLayer.lua","有破产标志")
		layerType = 2
	elseif roomData and roomData.FortuneMin > tonumber(myCash) then
		wwlog("SettlementLayer.lua","金币不足弹出的破产界面 房间的最低金币：%d，我的金币数量：%d",roomData.FortuneMin,tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")))
		layerType = 1
	end
	if not layerType then
		return false
	end
	local para = {}		
	para.layerType = layerType  --界面类型  1金币不足 2 破产
	if roomData then
		para.money = tonumber(roomData.FortuneMin) - tonumber(myCash)
	end
	para.sceneTag = 2 --在哪个场景
	para.upCloseOnClick = false
	para.upCallback = function ()
		--购买金币  打开商城
		self.isTopLayer = false

		local sIDKey 
		if para.layerType == 1 then --金币不足
			sIDKey = "GoldEnough"
		elseif para.layerType == 2 then --破产 then --破产
			sIDKey = "Bankrupt"
		end
		
		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=zorderLayer.BankruptLayer,store_openType=2, sceneIDKey = sIDKey})
			
	end --上面按钮响应
	para.downCloseOnClick = false --下边的按钮点击不自动关闭
    para.downCallback = function ()
		
		if para.layerType==2 then
			HallSceneProxy:requestBankruptAward()
		elseif para.layerType==1 then
			GameManageFactory:getCurGameManage():exitGame()
		end
	end --下面按钮响应
	
	local bankrupt = BankruptLayer:create(para)
	bankrupt:setOpacity(156)
	bankrupt:bindCloseFun(function ()
		self.isTopLayer = false
		if roomData and roomData.FortuneMin <= tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")) then
			local curTime = os.time() 
			if butType == 1 and curTime - enterTime <= leftTime then
				GameManageFactory:getCurGameManage():continueGame()
			else
				GameManageFactory:getCurGameManage():changeDesk()
			end
		else
			GameManageFactory:getCurGameManage():exitGame()
		end
	end)
	bankrupt:show(zorderLayer.BankruptLayer)

	return true
end

--锦旗
function SettlementLayer:Banner( info )
	-- body
	self:Cancellation()

	self.Winroot:setVisible(false)
	self.Lostroot:setVisible(false)
	self.BanneRoot:setVisible(true)
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
	self:addTouchListener()

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

--私人房打完结算
function SettlementLayer:personalEnd( info )
	-- body
	self:addTouchListener()
	self.personSettleLayerRoot:setVisible(true)
	self.personSettleLayerAni:play("animation0",false)
	self.listViewPersonal:removeAllItems()
	local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)

	for k,v in pairs(info) do	
		local itemNode = require("csb.guandan.GDPersonListItem"):create()
		local custom_head = itemNode.root
		local Image_master = custom_head:getChildByName("Image_master")--是否房主
		local Text_username = custom_head:getChildByName("Text_username") --名字
		local Image_wintag = custom_head:getChildByName("Image_wintag") --输赢
		local Text_count = custom_head:getChildByName("Text_count") --局数
		local Text_winrate = custom_head:getChildByName("Text_winrate")--胜率
		local Text_fist = custom_head:getChildByName("Text_fist")--头油
		local Text_sixbomb = custom_head:getChildByName("Text_sixbomb")--6炸
		local Text_ths = custom_head:getChildByName("Text_ths")--同花顺
		local Text_score = custom_head:getChildByName("Text_score")--积分

		if WhippedEggSceneController.MasterID == v.UserID then --房主
			Image_master:setVisible(true)
		else
			Image_master:setVisible(false)
		end
		Text_username:setString(subNickName(v.Nickname))
		if v.Score > 0 then
		 	Image_wintag:setVisible(true)
		else
		 	Image_wintag:setVisible(false)
		end
		Text_count:setString(v.Play.."")
		Text_winrate:setString(v.Winp.."")
		Text_fist:setString(v.Rank1.."")
		Text_sixbomb:setString(v.Boom.."")
		Text_ths:setString(v.StrFlush.."")
		Text_score:setString(v.Score.."")

        custom_head:setContentSize(cc.size(1200,100))
       	local custom_item = ccui.Layout:create()
        custom_item:setContentSize(custom_head:getContentSize())
        custom_head:setPosition(cc.p(0, custom_item:getContentSize().height-60 ))
        custom_item:addChild(custom_head)
		self.listViewPersonal:pushBackCustomItem(custom_item)
	end
end
 
--倒计时
function SettlementLayer:countDown( ... )
	-- body
	self.endSec = self.endSec - 1
	if self.endSec >= 0 then
  		self.WinButtonContinue:setTitleText(
  			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")
		self.LostButtonContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")
		self.BannerContinue:setTitleText(
			i18n:get("str_guandan", "guandan_continue").."("..tostring(self.endSec)..")")

		if self.levelUpSettlementCallBack and self.endSec == SettlementClassicalSec - SettlementMatchSec then
	 		self.levelUpSettlementCallBack()
		end
  	else --超时
  		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
			--返回房间
			if wwConfigData.AUTO_CONTINUE_GAME then
				self:Cancellation()
				GameManageFactory:getCurGameManage():continueGame()
			else
	  			GameManageFactory:getCurGameManage():exitGame()
	  		end
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
				GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
				GameManageFactory.gameType == Game_Type.MatchRcircleCount or
				GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			self:Cancellation()
			GameManageFactory:getCurGameManage():settmentOverCallback()
		elseif 	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			self:Cancellation()

			if self.PersonalEndCallBack then
		 		self.PersonalEndCallBack()
			end
		end	

		self:unscheduleScript()
  	end
end

function SettlementLayer:unscheduleScript( ... )
	-- body
	if self.ScriptFuncIdWin then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdWin)
		self.ScriptFuncIdWin = false
	end

	if self.ScriptFuncIdLost then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdLost)
		self.ScriptFuncIdLost = false
	end

	if self.ScriptFuncIdBanner then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncIdBanner)
		self.ScriptFuncIdBanner = false
	end
end

--人为注销倒计时
function SettlementLayer:Cancellation( ... )
	-- body
	self.BanneRoot:setVisible(false)
  	self.Winroot:setVisible(false)
  	self.Lostroot:setVisible(false)
	self:unscheduleScript()
	
	self:removeTouchListener()
end

--按钮响应
function SettlementLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref == self.WinButtonQuit then
		self:unscheduleScript()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.WinButtonHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(2,self.endSec) then
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.WinButtonContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(1,self.endSec) then
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	elseif ref == self.LostButtonQuit then
		self:unscheduleScript()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.LostButtonHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(2,self.endSec) then
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.LostButtonContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(1,self.endSec) then
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	elseif ref == self.BannerQuit then
		self:unscheduleScript()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref == self.BannerHandover then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(2,self.endSec) then
				GameManageFactory:getCurGameManage():changeDesk()
			end
		end
	elseif ref == self.BannerContinue then
		if not GameManageFactory:getCurGameManage().haveLevelUpSettlement then
			self:Cancellation()
			if not self:showBankrupt(1,self.endSec) then
				GameManageFactory:getCurGameManage():continueGame()
			end
		end
	elseif ref == self.personalBtnBack then --私人返回
		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	elseif ref == self.personalBtnShare then --私人分享
		self.personalBtnBack:setVisible(false)
		self.personalBtnShare:setVisible(false)
		self.personalBtnContinue:setVisible(false)
		--截屏回调方法  
		 local function afterCaptured(succeed, outputFile)  
		    if succeed then  
		     	wwlog(self.logTag,"截屏分享成功%s",outputFile)
		     	LuaWxShareNativeBridge:create():callNativeShareByPhotos(outputFile,1)
		     	self.personalBtnBack:setVisible(true)
				self.personalBtnShare:setVisible(true)
				self.personalBtnContinue:setVisible(true)
		    else  
		        wwlog(self.logTag,"截屏分享失败")  
		    end  
		 end  
	  
	    local fileName = "SirenCaptureScreenTest.png"  
		fileName = ww.IPhoneTool:getInstance():getExternalFilesDir()..fileName
	    -- 截屏  
	    cc.utils:captureScreen(afterCaptured, fileName)  
	elseif ref == self.personalBtnContinue then --私人继续
    	local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")
		local sirenData = DataCenter:getData(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)
		FSRegistryManager:setJumpState("siren",{ zorder=3,crType = 3 })
		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
		request.createRoom(proxy, sirenData.Playtype, sirenData.PlayData, sirenData.RoomCardCount, sirenData.DWinPoint, sirenData.MultipleData)
	end
end

function SettlementLayer:addHead(headNode,Gender, iconid, userid)
	-- body
	local fileName = DataCenter:getUserdataInstance():getHeadIconByGender(Gender)
	if headNode:getChildByName("WWHeadSprite") then
		headNode:removeChildByName("WWHeadSprite")
	end

	local param = {
		headFile=fileName,
		maskFile="",
		headType=2,
		radius=60,
		width = headNode:getContentSize().width,
		height = headNode:getContentSize().height,
		headIconType = iconid,
		userID = userid
	}
	local HeadSprite = WWHeadSprite:create(param)
	local clippingNode = createClippingNode("guandan_head_robot.png",HeadSprite,
		cc.p(headNode:getContentSize().width/2,headNode:getContentSize().height/2))
	clippingNode:setName("WWHeadSprite")
	headNode:addChild(clippingNode,1)
end

function SettlementLayer:addTouchListener( ... )
	-- body
	self:setOpacity(200)
	self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:setSwallowTouches(true)
    self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
end

function SettlementLayer:removeTouchListener( ... )
	-- body
	self:setOpacity(0)
	if self.listener then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
	self.listener = nil
end

function SettlementLayer:isHaveSettmentLayer( ... )
	-- body
	if  not self.Winroot:isVisible() and not self.Lostroot:isVisible() and not self.BanneRoot:isVisible() then
		return false
	else
		return true
	end 
end
return SettlementLayer