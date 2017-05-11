-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  掼蛋总管理器基类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GameManageFactory = class("GameManageFactory")
local PromotionGameManage = require("WhippedEgg.GameManageRoot.PromotionGameManage")
local RandomGameManage = require("WhippedEgg.GameManageRoot.RandomGameManage")
local RcirclesGameManage = require("WhippedEgg.GameManageRoot.RcirclesGameManage")

--初始化界面
--@param gameType 游戏类型
--@param ismutiple 组队还是单人
function GameManageFactory:createGame( gameType,ismutiple )
	self.gameType = gameType
	
	local gameScene = false
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.PersonalPromotion then --升级玩法
		gameScene = PromotionGameManage:createGame(gameType,ismutiple)
	elseif self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or
		self.gameType == Game_Type.PersonalRandom then --逢人配玩法
		gameScene = RandomGameManage:createGame(gameType,ismutiple)
	elseif self.gameType == Game_Type.ClassicalRcircleGame or 
		self.gameType == Game_Type.MatchRcircleCount or 
		self.gameType == Game_Type.MatchRcircleTime or
		self.gameType == Game_Type.PersonalRcircle then --团团转玩法
		gameScene = RcirclesGameManage:createGame(gameType,ismutiple)
	end

	return gameScene
end

function GameManageFactory:getCurGameManage( ... )
	-- body
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.PersonalPromotion then --升级玩法
		return PromotionGameManage
	elseif self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or
		self.gameType == Game_Type.PersonalRandom then --逢人配玩法
		return RandomGameManage
	elseif self.gameType == Game_Type.ClassicalRcircleGame or 
		self.gameType == Game_Type.MatchRcircleCount or 
		self.gameType == Game_Type.MatchRcircleTime or
		self.gameType == Game_Type.PersonalRcircle then --团团转玩法
		return RcirclesGameManage
	end
end

function GameManageFactory:switchGame( gameType,ismutiple )
	-- body
	self:getCurGameManage():clearGameData()
	self:getCurGameManage():onExit()

	local gameScene = self:createGame(gameType,ismutiple)
	display.runScene(gameScene)
end


cc.exports.GameManageFactory = cc.exports.GameManageFactory or GameManageFactory:create()
return cc.exports.GameManageFactory
