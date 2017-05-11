-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.12.20
-- Last:
-- Content:  斗牛游戏场景管理器
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullFightingSceneController = class("BullFightingSceneController", require("packages.mvc.Controller"))

import(".BullFightingEvent", "BullFighting.event.")

function BullFightingSceneController:init()
	--注册进入斗牛事件
	self:registerEventListener(BULLFIGHTING_SCENE_EVENTS.MAIN_ENTRY, handler(self, self.onSceneEntry))
end

--进入场景
function BullFightingSceneController:onSceneEntry(event)
	self.Scenename = "BullFightingScene"
	self.gameType = event._userdata[1] --游戏类型，经典 比赛（定人，定时） 高手
	self.GameZoneID = event._userdata[2] --游戏区适配ID
	self.fortuneBase = event._userdata[3] --房间底分

	wwlog(self.Scenename, "进入斗牛游戏场景......")
	self:getMainSceneMediator():onCreate(self.gameType, self.GameZoneID, self.fortuneBase)
end

function BullFightingSceneController:getMainSceneProxy()
	return self:getProxy(self:getProxyRegistry().BULLFIGHTING_SCENE)
end

function BullFightingSceneController:getMainSceneMediator()

	return self:getMediator(self:getMediatorRegistry().BULLFIGHTING_SCENE)
end

return BullFightingSceneController
