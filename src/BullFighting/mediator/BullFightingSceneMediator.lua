-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  
-- Date:    2016.08.29
-- Last: 
-- Content:  斗牛游戏mediator组件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullFightingSceneMediator = class("BullFightingSceneMediator",require("packages.mvc.Mediator"))
local BullFightingManage = require("BullFighting.mediator.scene.BullFightingManage")

local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)

function BullFightingSceneMediator:init()
	self.logTag = "BullFightingSceneMediator.lua"
end
--@param gameType 游戏类型
--@param ismutiple 是否组队
function BullFightingSceneMediator:onCreate(gameType, GameZoneID, fortuneBase)
	cclog("显示斗牛游戏界面")

	self.gameType = gameType
	self.GameZoneID = GameZoneID
	self.fortuneBase = fortuneBase

	local gameScene = BullFightingManage:createGame()
	display.runScene(gameScene)

	BullFightingManage.BullBackGrand:setScore(self.fortuneBase)
end

function BullFightingSceneMediator:initLogic( ... )
	-- body
	--经典打牌逻辑（TODO 不同的玩法）
	self.GameLogic = require("BullFighting.controller.logics.BullBaseLogic"):create()
end

function BullFightingSceneMediator:setGameStartEnd( ... )
	-- body
end

function BullFightingSceneMediator:onSceneEnter()
	wwlog(self.logTag, "BullFightingSceneMediator:onSceneEnter")

	BullFightingSceneProxy:requestLobbyActionHandle(self.GameZoneID, 13)  --请求进入随机、看牌场房间
end
function BullFightingSceneMediator:onSceneExit()
	wwlog(self.logTag, "BullFightingSceneMediator:onSceneExit")
	
	--回收  处理事件解绑 热更的时候回用到
	if self.GameLogic then
		self.GameLogic:recycle()
	end
	self.GameLogic = nil
end

function BullFightingSceneMediator:getLogic( ... )
	-- body
	return self.GameLogic
end

return BullFightingSceneMediator