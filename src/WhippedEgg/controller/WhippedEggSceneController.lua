local WhippedEggSceneController = class("WhippedEggSceneController", require("packages.mvc.Controller"))

import(".WhippedEggEvent", "WhippedEgg.event.")

import(".wwGameConst","app.config.")
import(".wwConst","app.config.")
import(".wwConfigData","app.config.")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
function WhippedEggSceneController:init()
	print("WhippedEggSceneController init")
	--注册大厅进入事件
	print(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY)
	self:registerEventListener(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY, handler(self, self.onSceneEntry))
end

--进入场景
function WhippedEggSceneController:onSceneEntry(event)

	self.Scenename = "HallScene"
	self.gameType = event._userdata[1] --比赛类型，经典 比赛（定人，定时） 高手
	self.gameZoneId = event._userdata[2]
	self.fortuneBase = event._userdata[3]
	self.MasterID = event._userdata[4] --房主
	self.MultipleData = string.split(event._userdata[5], ",")  --翻倍
	wwlog(self.Scenename, "进入游戏场景......")
	local ismutiple = false
	if self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then
		local matchall = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL) --比赛详情
		if matchall then
			local matchdata = matchall[self.gameZoneId]
			if matchdata then
				ismutiple = (matchdata.TeamWork == 1)
			end
		end
	end
	
	--初始化组件构造 游戏类型 
	self:getMainSceneMediator():onCreate(self.gameType,ismutiple)
	self:getMainSceneProxy().gamezoneid = self.gameZoneId
	if self.gameType == Game_Type.ClassicalPromotion or   
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then    --经典房
		GameManageFactory:getCurGameManage():setRoomPoint(self.fortuneBase)
	elseif 	self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
		GameManageFactory:getCurGameManage():setRoomPoint(1)
	end
	
	--比赛玩法的时候，这里传来的 gameZoneId = MatchID
	GameManageFactory:getCurGameManage():setRoomInfoByGameZoneID(self.gameType, self.gameZoneId)
end

function WhippedEggSceneController:getMainSceneProxy()
	return self:getProxy(self:getProxyRegistry().WHIPPEDEGG_SCENE)
end

function WhippedEggSceneController:getMainSceneMediator()

	return self:getMediator(self:getMediatorRegistry().WHIPPEDEGG_SCENE)
end

return WhippedEggSceneController
