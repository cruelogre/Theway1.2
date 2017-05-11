-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  背景层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BackGrand = class("BackGrand",cc.Layer)

function BackGrand:ctor()
	-- body
	self:init(roomId,double)
end

function BackGrand:init()
	-- body
	local bgUi = require("csb.guandan.GamePlayBGLayer"):create()
	if not bgUi then
		return
	end
	local root = bgUi["root"]
	root:setScaleY(ww.scaleY)
	self:addChild(root)

	self.Image_bg_house = root:getChildByName("Image_bg_house")
	self.Image_bg_desk = root:getChildByName("Image_bg_desk")
	local roomWediget = self.Image_bg_house:getChildByName("roomIdImg")
	self.roomIdImg = roomWediget:clone()
	self.roomId = self.roomIdImg:getChildByName("roomId")
	self.double = self.roomIdImg:getChildByName("double")
	self.doubleCount = 1
	self.canDoubleCount = false
	self.roomIdImg:setVisible(false)
	self.roomIdImg:setPosition(cc.p(roomWediget:getPositionX(),screenSize.height - roomWediget:getContentSize().height/2))
	self:addChild(self.roomIdImg)

	self.Image_bg_desk:setAnchorPoint(0.5, 0.5)
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
		self.Image_bg_house:loadTexture("guandan/guandan_bg_bg1.jpg")
  		self.Image_bg_desk:loadTexture("guandan/guandan_bg_desk1.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
  		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
  		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
  		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
  		self.Image_bg_house:loadTexture("guandan/match/back1.jpg")
  		self.Image_bg_desk:loadTexture("guandan/match/desk.png")
	elseif	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
  		GameManageFactory.gameType == Game_Type.PersonalRandom or
  		GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
  		self.Image_bg_house:loadTexture("guandan/personal/personal_back.jpg")
  		self.Image_bg_desk:loadTexture("guandan/personal/personal_desk.png")
  		self.roomIdImg:setVisible(true)

  		local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
  		self.roomId:setString(WhippedEggSceneController.gameZoneId.."")
  		self.double:setString("x"..self.doubleCount)
	end
end

function BackGrand:resetDouble( count )
	-- body
	self.canDoubleCount = true
	self.doubleCount = count
  	self.double:setString("x"..self.doubleCount)
end

function BackGrand:addDouble(PlayerType)
	-- body
	if self.canDoubleCount then
	  	local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
	    if PlayerType >= CARD_TYPE.SIX_BOMB and tonumber(WhippedEggSceneController.MultipleData[1]) == 1 then --炸弹
	      self.doubleCount = self.doubleCount*2
	      self.double:setString("x"..self.doubleCount)
	    elseif PlayerType == CARD_TYPE.FLUSH_BOMB and tonumber(WhippedEggSceneController.MultipleData[2]) == 1 then --同花
	  		self.doubleCount = self.doubleCount*2
	  		self.double:setString("x"..self.doubleCount)
	  	end
	end
end

return BackGrand