-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last:
-- Content:  大厅Mediator（View）组件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallSceneMediator = class("HallSceneMediator",require("packages.mvc.Mediator"))

local HallScene = import(".HallScene")

local HallProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)

local Noticecroll = require("hall.mediator.view.Noticecroll")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local Toast = require("app.views.common.Toast")

local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local HallCfg = require("hall.mediator.cfg.HallCfg")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

local ItemShowView = import(".ItemShowView", "app.views.customwidget.")
local JumpFilter = require("packages.statebase.filter.JumpFilter")

require("WhippedEgg.ConstType")
--在大厅进入后引用
require("hall.data.UIStateJumper")
--local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
-- local ENUM_HALLEVENT_HANDLE = CreatEnumTable(
--     {
--         "hall_handle_reflashinfo",  --切换个人信息
--     }, 1)

function HallSceneMediator:init()
	self.logTag = "HallSceneMediator.lua"
end
--进入的额外数据
function HallSceneMediator:onCreate(userdata)
	
	cclog("显示大厅背景")
	self.scene = HallScene:create(userdata)
	
	--播放背景音乐
	cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( delayTime )
		-- body
		ww.WWSoundManager:getInstance():SoundEffectControl(delayTime)
	end, 0, false)
	
	--playBackGroundMusic("sound/backMusic/hallBackGroundMusic",true)
	
	local bg = display.newSprite("hall/hallbg.jpg")
	bg:setPosition(display.center)
	bg:setScaleY(ww.scaleY)
	self.scene:addChild(bg)
	
	display.runScene(self.scene)
	
	self:installInnerEventListeners()
end

--装载组建消息事件
function HallSceneMediator:installInnerEventListeners()
	--个人信息刷新区域监听
	--self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
	--self:registerEventListener(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, handler(self, self.refreshHallList))
	self:registerEventListener(COMMON_EVENTS.C_EVENT_NOTICE, handler(self, self.showNotice))
	self:registerEventListener(COMMON_EVENTS.C_EVENT_BANKRUPT, handler(self, self.showBankrupt))
	--首充查询接口
	self:registerEventListener(COMMON_EVENTS.C_EVENT_FIRSTQUERY, handler(self, self.queryFirstCharge))
	--大厅中收到好友的邀请
	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED, handler(self, self.showGameInvited))
	
end

function HallSceneMediator:matchWillStart(userdata)
	--如果等待的是当前比赛则不用提示了
	--local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
	
	local eventTable = userdata._userdata[1]

	
	local leftTime = eventTable.Param1
	local matchid = eventTable.MatchID
	
	local para = {}
    para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
	--para.singleName = eventTable.MatchName --单一对话框Key
    --para.leftBtnCallback = handler(self, self.activityHandler)
    para.rightBtnCallback = function ()
		MatchProxy.isTimeToGo = true
		MatchProxy.timeMatchId = matchid
		MatchProxy:requestMatchDetail(matchid)

		if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_RecievedInvite")) then
			display.getRunningScene():getChildByName("MatchLayer_RecievedInvite"):close()
		end
--[[		MatchProxy:requestEnterOrNotGame(8,eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)--]]
		
	end
	para.leftBtnCallback = function ()
	
--[[		MatchProxy:requestEnterOrNotGame(9, eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)--]]
		
	end
    para.showclose = false  --是否显示关闭按钮
	
	local t = secondToTime(tonumber(eventTable.Param1))
	
    para.content = string.format(i18n:get('str_match','match_will_start'),eventTable.MatchName,
	secoundToTimeString2(tonumber(eventTable.Param1)))

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

--人数不足 比赛被取消
function HallSceneMediator:matchCancel(userdata)
	local eventTable = userdata._userdata[1]
	if not eventTable or eventTable.Type ~= MatchCfg.NotifyType.MATCH_CANCELED_NOT_ENOUGH then
		return
	end
	local backToHallFun = function ()
		print("FSRegistryManager.curFSMName",FSRegistryManager.curFSMName)
		if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG then
			--WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
			--比赛被取消，不跳转场景
		end
	end
	local para = {}
   -- para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
  --  para.leftBtnCallback = backToHallFun
    para.rightBtnCallback = backToHallFun
	para.showclose = false  --是否显示关闭按钮
	--eventTable.MatchName
	dump(eventTable)
	
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

function HallSceneMediator:refreshHallList(event)
	if self.hallContent then
		self.hallContent:refreshContent(unpack(event._userdata))
	end
end
--[[
handleType 为消息处理类型
--]]
function HallSceneMediator:refreshInfo(event)
	local handleType = unpack(event._userdata)
	if handleType == 1 then
		--刷新个人信息区域
		wwlog(self.logTag, "更新大厅信息")
		if self.bottomView then
			self.bottomView:valueHandle()
		end
	elseif handleType == 2 then
		--红点通知
	end
end
--这个处理和场景无关
function HallSceneMediator:showBankrupt(event)
	local data = unpack(event._userdata)
	local bandruptLayer = display.getRunningScene():getChildByName("BankruptLayer")
	if data.kResult==0 then
		--领取成功，加金币
		local addMoney = tonumber(data.kReason)
		local gameCashFid = 10170998
		updataGoods(gameCashFid,addMoney)
		local curCount = DataCenter:getUserdataInstance():getValueByKey("awardCount")
		curCount = math.max(curCount - 1,0)
		
		if curCount > 0 then
			--HallSceneProxy:requestIsBankrupt()
		end
		
		wwlog(self.logTag,"可以领取多少次%d",curCount)
		DataCenter:getUserdataInstance():setUserInfoByKey("awardCount",curCount)
		--DataCenter:getUserdataInstance():setUserInfoByKey("nextAwardTime",restTime)
		
		Toast:makeToast(string.format(i18n:get('str_bankrupt','bankrupt_get_success'),addMoney), 1.0):show()
		DataCenter:getUserdataInstance():setUserInfoByKey("bankrupt",false)
		if isLuaNodeValid(bandruptLayer) then
			bandruptLayer:close()
		end
	else
		--失败拉
		print("领取失败拉")
		Toast:makeToast(data.kReason, 1.0):show()
		
	end
end

--收到通知消息
function HallSceneMediator:showNotice(event)
	wwlog(self.logTag, "收到消息通知")
	--TODO 应该放到 控制类里面去
	if not isLuaNodeValid(self.scene) then
		return
	end
	local datas = unpack(event._userdata)


	local noticeNodeTime = os.date("*t",ww.WWGameData:getInstance():getIntegerForKey("noticeNode",0))
	local curTime = os.date("*t")

	if noticeNodeTime.day ~= curTime.day then
		ww.WWGameData:getInstance():setIntegerForKey("noticeNode",os.time())
		local noticeNode = import(".NoticeLayer", "hall.mediator.view.widget."):create(datas)
		self.scene:addChild(noticeNode, 4)
	end
end

--查询首充
function HallSceneMediator:queryFirstCharge( event )
	HallProxy:requestFirstChargeState()
end

--播放任务奖励动画
function HallSceneMediator:showTaskAwardUI(event)
	wwlog(self.logTag,"showTaskAwardUI")
	local datas = unpack(event._userdata)
	if not datas or not datas.awardList then
		return
	end
	local retData = {}
	for _,v in pairs(datas.awardList) do
		table.insert(retData,{fid = v.FID,num = v.AwardData})
	end
	if next(retData) then
		import(".ItemShowView", "app.views.customwidget."):create(retData,true):show()
	end
	--这里只是刷新，暂用分享成功的消息
	local dispatchId = TaskCfg.InnerEvents.TASK_EVENT_SHAREMESSAGE
	if dispatchId and HallCfg.innerEventComponent then
		HallCfg.innerEventComponent:dispatchEvent({
			name = dispatchId;
			
		})
	end
end
--展示游戏邀请界面  通过状态机的形式
function HallSceneMediator:showGameInvited(event)
	wwlog(self.logTag,"收到好友的游戏邀请")
	local invitedDatas = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED)
	if not invitedDatas or not next(invitedDatas) then
		--发送了一个空的消息
		return
	end
	local inviteData = invitedDatas[1]
	print("FSRegistryManager.curFSMName",FSRegistryManager.curFSMName)

	if inviteData.Param1 --房间号
		and inviteData.StrParam1 then --娃号
		if FSRegistryManager.curFSMName == FSMConfig.FSM_HALL then --在大厅中
			--触发私人房被邀请的状态机
			FSRegistryManager:currentFSM():trigger("sirenInvited",
			{ parentNode = display.getRunningScene(), 
				gameid = wwConfigData.GAME_ID,
				roomid = inviteData.Param1,
				zorder = ww.centerOrder,
				userid = inviteData.StrParam1 })
		else -- 在登录界面或者游戏中
			--游戏中就添加一个过滤器来实现
			local jumpFilter = JumpFilter:create(100,FSConst.FilterType.Filter_Enter,2)
			jumpFilter:setJumpData("sirenInvited",
				{ zorder=ww.centerOrder,
				gameid=wwConfigData.GAME_ID,
				roomid = inviteData.Param1,
				userid = inviteData.StrParam1
				} )
			FSRegistryManager:getFSM(FSMConfig.FSM_HALL):addFilter("UIRoot",jumpFilter)
		end

	end

end

function HallSceneMediator:onSceneEnter()
	self:registerEventListener(MatchCfg.InnerEvents.MATCH_EVENT_WILL_START, handler(self, self.matchWillStart))
	self:registerEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT, handler(self, self.matchCancel))
	self:registerEventListener(TaskCfg.InnerEvents.TASK_EVENT_AWARDNOTIFY, handler(self, self.showTaskAwardUI))

end
function HallSceneMediator:onSceneExit()
	print("HallSceneMediator  onSceneExit")
	wwlog(self.logTag, "HallSceneMediator:onSceneExit")


	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_WILL_START)
	self:unregisterEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT)
	self:unregisterEventListener(TaskCfg.InnerEvents.TASK_EVENT_AWARDNOTIFY)
	self:unregisterEventListener(COMMON_EVENTS.C_EVENT_NOTICE)
	--self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED)
	

end

return HallSceneMediator