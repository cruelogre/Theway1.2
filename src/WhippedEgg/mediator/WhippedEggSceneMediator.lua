-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  
-- Date:    2016.08.29
-- Last: 
-- Content:  惯蛋游戏mediator组件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local WhippedEggSceneMediator = class("WhippedEggSceneMediator",require("packages.mvc.Mediator"))
local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local GameManageFactory = require("WhippedEgg.GameManageRoot.GameManageFactory")
local Toast = require("app.views.common.Toast")
local WhippedEggCfg = import(".WhippedEggCfg", "WhippedEgg.mediator.cfg.")

function WhippedEggSceneMediator:init()
	self.logTag = "WhippedEggSceneMediator.lua"
end
--@param gameType 游戏类型
--@param ismutiple 是否组队
function WhippedEggSceneMediator:onCreate(gameType,ismutiple)
	cclog("显示惯蛋游戏界面")
	if self.GameLogic and (self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle) then --私人房
		local request = require("hall.request.SiRenRoomRequest")
		local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
  		local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
		if WhippedEggSceneController.MasterID == DataCenter:getUserdataInstance():getValueByKey("userid") then --房主
			wwlog("房主解散房间")
	    	request.releaseRoom(proxy, WhippedEggSceneController.gameZoneId)
		else
			wwlog("不是房主离开房间")
	    	request.quitRoom(proxy, WhippedEggSceneController.gameZoneId)
		end
	end

	self.gameType = gameType
	local gameScene = GameManageFactory:createGame(gameType,ismutiple)
	display.runScene(gameScene)
end

function WhippedEggSceneMediator:initLogic( ... )
	-- body
	--经典打牌逻辑（TODO 不同的玩法）
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then
		self.GameLogic = require("WhippedEgg.logics.Classical"):create()
	elseif self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then --比赛
		self.GameLogic = require("WhippedEgg.logics.Match"):create()
	elseif self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then    --私人房
		self.GameLogic = require("WhippedEgg.logics.Personal"):create()
	end

	if self.GameLogic then
		self.GameLogic:createCardRecorder()
		--这里要判断一下信息是否已经进来了 最后一个人进来的时候 数据最先过来
		local start = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_GAMESTART)
		if start and next(start) then
			self.GameLogic:baseStartGame(start)
		else
		 	local resume = DataCenter:getData(WhippedEggCfg.InnerEvents.GD_EVENT_RESUMEGAME)
		 	if resume and next(resume) then
		 		self.GameLogic:baseResumeGameGame(resume)
		 	end
		end
	end
end

function WhippedEggSceneMediator:setGameStartEnd( ... )
	-- body
	--经典打牌逻辑（TODO 不同的玩法）
	if self.GameLogic then
		self.GameLogic.StartGame = false
	end
end

function WhippedEggSceneMediator:refreshDetail( ... )
	-- body
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	if allMtchData and 
		next(allMtchData) and 
		WhippedEggSceneProxy.gamezoneid and 
		allMtchData[WhippedEggSceneProxy.gamezoneid] and
		allMtchData[WhippedEggSceneProxy.gamezoneid].Name then
		GameManageFactory:getCurGameManage():setRoomName(allMtchData[WhippedEggSceneProxy.gamezoneid].Name)
	end
end

function WhippedEggSceneMediator:setGameLogicSeatInfos( seatInfos )
	-- body
	if self.GameLogic then
		self.GameLogic:setSeatInfos(seatInfos)
	end 
end

function WhippedEggSceneMediator:matchWillStart(userdata)
	local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
	local eventTable = userdata._userdata[1]
	wwlog(self.logTag,"在游戏界面收到游戏即将开始的消息")
	if WhippedEggSceneProxy.gamezoneid==eventTable.MatchID then
		--当前比赛 不用提示了
		wwlog(self.logTag,"就是当前比赛的等待界面，不用做任何提示了")
		return
	end
	local leftTime = eventTable.Param1
	local matchid = eventTable.MatchID
	local matchdata = MatchProxy:getMatchDetailDataByID(matchid)
	if not matchdata then
		MatchProxy:requestMatchDetail(matchid)
	end
	if tonumber(eventTable.RespInfo) == 1 then
		--最后一场通知
		self:handleLastWillStart(eventTable,gamedata)
	else
		--通用通知
		self:handleNormalWillStart(eventTable)
	end

end

function WhippedEggSceneMediator:handleLastWillStart(eventTable,gamedata)
	local para = {}
    para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
	local curTime = os.time()
	local diffSec = tonumber(eventTable.Param1)

	local canChangeMatch = function ( curTime,diffSec )
		-- body
		local nowTime = os.time()
		local diff = nowTime - curTime
		if tonumber(diff) >= diffSec then --比赛已经开始了，不用点击了
			Toast:makeToast(i18n:get('str_match','match_has_start'),1.0):show()
			return false
		else
			--是否是组队赛
			return true
		end
	end

	local changeMatchFun = function ( eventTable,gamedata )
		-- body
		--是否是组队赛
		local matchdata = MatchProxy:getMatchDetailDataByID(eventTable.MatchID)
		local ismutiple = false
		if matchdata then
			ismutiple = (tonumber(matchdata.TeamWork)==1)
		end
		MatchProxy:requestEnterOrNotGame(8,eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)
		--等待
		WhippedEggSceneProxy.gamezoneid = eventTable.MatchID
		
		GameManageFactory:switchGame(Game_Type.MatchRamdomTime,ismutiple)
		self.gameType = Game_Type.MatchRamdomTime
		self:setGameStartEnd()
		
		--经典打牌逻辑（TODO 不同的玩法）
		if self.GameLogic then
			self.GameLogic:recycle()
			self.GameLogic = nil
		end
		wwlog("成功切换到比赛")
	end

    para.rightBtnCallback = function ()
		--时间是否过了
		if self.gameType == Game_Type.PersonalPromotion or 
			self.gameType == Game_Type.PersonalRandom or 
			self.gameType == Game_Type.PersonalRcircle then --私人房
			local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
			
			local para = {}
		    para.leftBtnlabel = i18n:get('str_common','comm_no')
		    para.rightBtnlabel = i18n:get('str_common','comm_yes')
			para.rightBtnCallback = function ( ... )
				-- body
				if canChangeMatch(curTime,diffSec) then
					local request = require("hall.request.SiRenRoomRequest")
					local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
			  		local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
					if WhippedEggSceneController.MasterID == DataCenter:getUserdataInstance():getValueByKey("userid") then --房主
						wwlog("房主解散房间")
				    	request.releaseRoom(proxy, WhippedEggSceneController.gameZoneId)
					else
						wwlog("不是房主离开房间")
				    	request.quitRoom(proxy, WhippedEggSceneController.gameZoneId)
					end

					changeMatchFun(eventTable,gamedata)
				end
			end
			para.leftBtnCallback = function ( ... )
				-- body
				wwlog("继续留在私人房")
				MatchProxy:requestEnterOrNotGame(9,eventTable.InstMatchID,
				gamedata and gamedata.GamePlayID or 0,
				gamedata and gamedata.InstMatchID or 0)
			end
			para.showclose = false  --是否显示关闭按钮
			if WhippedEggSceneController.MasterID == DataCenter:getUserdataInstance():getValueByKey("userid") then --房主
		    	para.content = i18n:get('str_guandan','guandan_Master')
			else
		    	para.content = i18n:get('str_guandan','guandan_NoMaster')
			end

		    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
		else
			if canChangeMatch(curTime,diffSec) then
				changeMatchFun(eventTable,gamedata)
			end
		end
	end
	para.leftBtnCallback = function ()
		wwlog("不切换到比赛去")
		MatchProxy:requestEnterOrNotGame(9,eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)
	end
    para.showclose = false  --是否显示关闭按钮
	
	local t = secondToTime(tonumber(eventTable.Param1))
	local i18Text = ""
	if self.gameType == Game_Type.ClassicalPromotion or 
		self.gameType == Game_Type.ClassicalRandomGame or 
		self.gameType == Game_Type.ClassicalRcircleGame then
		i18Text = i18n:get('str_match','match_will_start_3') --普通牌局
	elseif self.gameType == Game_Type.MatchRamdomCount or 
		self.gameType == Game_Type.MatchRamdomTime or 
		self.gameType == Game_Type.MatchRcircleCount or
		self.gameType == Game_Type.MatchRcircleTime then --比赛
		i18Text = i18n:get('str_match','match_will_start_2') --比赛
	elseif self.gameType == Game_Type.PersonalPromotion or 
		self.gameType == Game_Type.PersonalRandom or 
		self.gameType == Game_Type.PersonalRcircle then --私人房
		i18Text = i18n:get('str_match','match_will_start_2') --比赛
	end
    para.content = string.format(i18Text,eventTable.MatchName,
	secoundToTimeString2(tonumber(eventTable.Param1)),eventTable.MatchName)

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
	
end


--处理普通比赛即将开赛的情况
function WhippedEggSceneMediator:handleNormalWillStart(eventTable)
	local para = {}

    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
	--para.singleName = eventTable.MatchName --单一对话框Key
    --para.leftBtnCallback = handler(self, self.activityHandler)
    para.rightBtnCallback = function ()
		
	end
    para.showclose = false  --是否显示关闭按钮
	
	local t = secondToTime(tonumber(eventTable.Param1))
	
    para.content = string.format(i18n:get('str_match','match_will_start_1'),eventTable.MatchName,
	secoundToTimeString2(tonumber(eventTable.Param1)))

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

--人数不足 比赛被取消
function WhippedEggSceneMediator:matchCancel(userdata)
	local eventTable = userdata._userdata[1]
	if not eventTable or eventTable.Type ~= MatchCfg.NotifyType.MATCH_CANCELED_NOT_ENOUGH then
		return
	end
	local backToHallFun = function ()
		print("FSRegistryManager.curFSMName",FSRegistryManager.curFSMName)
		if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG --在比赛界面
		and WhippedEggSceneProxy.gamezoneid==eventTable.MatchID then --并且是等待的比赛
			--WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
			--比赛被取消  没有玩经典的时候 退出去
			if self.gameType == Game_Type.MatchRamdomCount or 
				self.gameType == Game_Type.MatchRamdomTime or 
				self.gameType == Game_Type.MatchRcircleCount or
				self.gameType == Game_Type.MatchRcircleTime then --是定时 或者定人
				WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
			end
		end
	end
	local para = {}
  --  para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
  --  para.leftBtnCallback = backToHallFun
    para.rightBtnCallback = backToHallFun
	para.showclose = false  --是否显示关闭按钮
	--eventTable.MatchName
   	local ed = MatchCfg.enterTypes[tonumber(eventTable.Param1)]
	local nNum = nil
	if ed and ed.fid then
		if (tonumber(eventTable.Param1) == 3) then --如果是比赛门票
			local splArrs = Split(eventTable.RespInfo, "/")
			nNum = tonumber(splArrs[3])
		else
			nNum = tonumber(eventTable.RespInfo)
		end
						
		local goods = getGoodsByFid(ed.fid)
		if goods then
		 	local value = DataCenter:getUserdataInstance():getValueByKey(goods.dataKey)
		 	if value and tonumber(eventTable.RespInfo)>0 then
				nNum = tonumber(eventTable.RespInfo) - tonumber(value)
		 		
		 	end
		end
		local cost = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_COST)
		
		
	end
	local showStr = string.format(i18n:get('str_match','match_cancel'),eventTable.MatchName)
	if ed and nNum then --退赛 并且返还了报名费
		showStr = string.format(i18n:get('str_match','match_cancel_getaward'),eventTable.MatchName)
	end
	
    para.content = showStr

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
	
end
function WhippedEggSceneMediator:onSceneEnter()
	print("WhippedEggSceneMediator  onSceneEnter")
	self:registerEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT, handler(self, self.matchCancel))
	self:registerEventListener(MatchCfg.InnerEvents.MATCH_EVENT_WILL_START, handler(self, self.matchWillStart))
	self:registerEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL, handler(self, self.refreshDetail))
end
function WhippedEggSceneMediator:onSceneExit()
	print("WhippedEggSceneMediator  onSceneExit")
	wwlog(self.logTag, "WhippedEggSceneMediator:onSceneExit")
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_WILL_START)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	--回收  处理事件解绑 热更的时候回用到
	if self.GameLogic then
		self.GameLogic:recycle()
	end
	self.GameLogic = nil
	WWAsynResLoader:unloadTexture("WWLoadingSceneBase")
end
return WhippedEggSceneMediator