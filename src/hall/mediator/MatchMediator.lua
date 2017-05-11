-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last:
-- Content:  大厅Mediator（View）组件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchMediator = class("MatchMediator",require("packages.mvc.Mediator"))

local MatchLayer_RecievedInvite = import(".MatchLayer_RecievedInvite", "hall.mediator.view.")


local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local HallCfg = require("hall.mediator.cfg.HallCfg")

local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")
local Toast = require("app.views.common.Toast")

function MatchMediator:init()
	self.logTag = "MatchMediator.lua"
	self:installInnerEventListeners()
end
--装载组建消息事件
function MatchMediator:installInnerEventListeners()
	--个人信息刷新区域监听
	self:registerEventListener(
	COMMON_EVENTS.C_EVENT_INVITE, handler(self, self.showInviteOrRefuse))
	
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_DETAIL, handler(self, self.refreshDetail))
	
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT, handler(self, self.matchHashBeginOrCancel))
	
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_START_DATA, handler(self, self.matchHashBeginOrCancel))
	
	--组队成功 已经报名
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS, handler(self, self.matchSignOk))
	--组队成功 未报名
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER, handler(self, self.matchSignOk))
	--MatchCfg.InnerEvents.MATCH_EVENT_SIGN_FAILED
	--报名失败
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_SIGN_FAILED, handler(self, self.matchFaild))
	--组队失败
	self:registerEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FAILED, handler(self, self.matchFaild))
	
	
end
function MatchMediator:onSceneEnter()
	--self:installInnerEventListeners()
end
function MatchMediator:onSceneExit()
	print("MatchMediator  onSceneExit")
	wwlog(self.logTag, "MatchMediator:onSceneExit")

--[[	self:unregisterEventListener(COMMON_EVENTS.C_EVENT_INVITE)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_START_DATA)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_SIGN_FAILED)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FAILED)--]]
	

end

function MatchMediator:showInviteOrRefuse(event)
	--如果已经组队了
	wwlog(self.logTag,"MatchMediator:showInviteOrRefuse")
	local msgTable = event._userdata[1]
	
	local instanceId = msgTable.Param1
	dump(msgTable)
	print("msgTable.Param1",msgTable.Param1)
	print("instanceId",instanceId)
	if msgTable and msgTable.Param2 then --在比赛详情里边 有好友了
		local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
		if allMtchData then
			local matchData =allMtchData[msgTable.Param2]
			if matchData and tonumber(matchData.TeammateID)~=0 then
				print("我已经有组队的好友了")
				return --有组队的好友了
			end
		end
		
	end
--[[	local hasMatchOthers = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_AGREE_INVITE)
	if hasMatchOthers and next(hasMatchOthers) then
		wwdump(hasMatchOthers)
		print("我已经有组队的好友了")
		
		return 
	end--]]
	--判断当前的位置
	if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG then
		--在游戏里边
		--设置进来的时候就跳转的状态机
		HallCfg.enterView = MatchLayer_RecievedInvite
		HallCfg.enterViewOrder = 5
		HallCfg.enterViewData = msgTable.Param1
		local nickname = msgTable.nickname
		if not nickname or string.len(nickname)==0 then
			nickname = ""
		end
		local matchName = i18n:get("str_match", "match_text")
		local matchdata = MatchProxy:getMatchDetailDataByID(msgTable.Param2 or 0)
		if matchdata then
			matchName = matchdata.Name
		end
		Toast:makeToast(string.format(i18n:get("str_match", "match_invite_in_game"),nickname,matchName),1.0):show()
--[[		FSRegistryManager:setJumpState("match")
		local invitedFriends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND)
		
		MatchCfg.enterMatchId = invitedFriends[1].Param2--]]
		
	elseif FSRegistryManager.curFSMName == FSMConfig.FSM_HALL then
		--在大厅
		local runningScene = cc.Director:getInstance():getRunningScene()
		if not isLuaNodeValid(runningScene:getChildByName("MatchLayer_RecievedInvite")) then --顶层没有显示
			
			local recvView = MatchLayer_RecievedInvite:create(instanceId)
			runningScene:addChild(recvView,5) --加入进去 在界面里边自己通过这个列表去处理
		end
	end
end
--刷新比赛详情
function MatchMediator:refreshDetail()
	local runningScene = cc.Director:getInstance():getRunningScene()
	if isLuaNodeValid(runningScene:getChildByName("MatchLayer_RecievedInvite")) and --顶层没有显示
		not MatchCfg.innerEventComponent then --并且比赛界面没有初始化
	
		runningScene:getChildByName("MatchLayer_RecievedInvite"):reloadData()
	end
end

function MatchMediator:matchHashBeginOrCancel()
	local runningScene = cc.Director:getInstance():getRunningScene()
	if isLuaNodeValid(runningScene:getChildByName("MatchLayer_RecievedInvite")) and --顶层没有显示
		not MatchCfg.innerEventComponent then --并且比赛界面没有初始化
		
		runningScene:getChildByName("MatchLayer_RecievedInvite"):matchHashBeginOrCancel()
		
	end
end
--组队报名成功
function MatchMediator:matchSignOk()
	local runningScene = cc.Director:getInstance():getRunningScene()
	if isLuaNodeValid(runningScene:getChildByName("MatchLayer_RecievedInvite")) --顶层没有显示
		then --并且比赛界面没有初始化
		
		runningScene:getChildByName("MatchLayer_RecievedInvite"):matchSignOk()
		
	end
end
--组队报名失败
function MatchMediator:matchFaild(event)
	local msgTable = event._userdata[1]
	local runningScene = cc.Director:getInstance():getRunningScene()
	if isLuaNodeValid(runningScene:getChildByName("MatchLayer_RecievedInvite")) --顶层没有显示
		then --并且比赛界面没有初始化
		runningScene:getChildByName("MatchLayer_RecievedInvite"):reloadOrCLose(msgTable.Type or 0)
		
	end
end
return MatchMediator