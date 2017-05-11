-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛收到组队邀请界面
-- Modify :  2016-11-03 diyal 修改被好友邀请失败Bug 修改了self.enterType从比赛详情拿到
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_RecievedInvite = class("MatchLayer_RecievedInvite",require("hall.mediator.view.MatchLayer_WindowBase"))

local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local MatchLayer_widget_detail = require("hall.mediator.view.widget.MatchLayer_widget_detail")

local JumpFilter = require("packages.statebase.filter.JumpFilter")
local CorFilter = require("packages.statebase.filter.CorFilter")

function MatchLayer_RecievedInvite:ctor(instanceID)
	local allinvitedFriends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND)
	local invitedFriends = allinvitedFriends[instanceID]
	wwdump(invitedFriends)
	--self.inviteData = invitedFriends[1]
	self.inviteData = {}
	copyTable(invitedFriends[1],self.inviteData)
	--table.remove(invitedFriends,1)
	self:setName("MatchLayer_RecievedInvite")
	self.instanceID = instanceID
	MatchLayer_RecievedInvite.super.ctor(self,self.inviteData.Param2)
	self.logTag = "MatchLayer_RecievedInvite.lua"
end

function MatchLayer_RecievedInvite:init(matchid)
	MatchLayer_RecievedInvite.super.init(self,matchid)
	self.matchid = matchid
	--self:setOpacity(156)
	self.qualification = true --默认满足报名资格
	print("MatchLayer_RecievedInvite init")
	self.node = require("csb.hall.match.MatchLayer_recvInvite"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	self.hasValid = true

	--testing
	self.clickItem = false
	self.signType = 0 --请求的类型
	self.signData = 0 --请求的数据
	self.qualification = false
	self.timeCount = 0
	self.refreshToGame = false --是否进入游戏的刷新
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	self.hasDeal = false --是否处理了

	self:popIn(self.imgId,Pop_Dir.Right)
	
	self:bindCloseCB(function ()
		local invitedFriends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND)
		if invitedFriends and next(invitedFriends) then
			wwlog(self.logTag,"删除这个请求 %d",tonumber(self.inviteData.toUserID))
			invitedFriends[self.instanceID] = nil
			--table.remove(invitedFriends[self.instanceID],1)
		
			for instanceID,inviteData in pairs(invitedFriends) do
				cc.Director:getInstance():getRunningScene():addChild(MatchLayer_RecievedInvite:create(instanceID),5)
				break
			end
--[[			if #invitedFriends[self.instanceID]>0 then
				--删了 还有
				cc.Director:getInstance():getRunningScene():addChild(MatchLayer_RecievedInvite:create(self.instanceID),5)
			else
				print("没拉")
			end--]]
		end
		
	end)
	
end

function MatchLayer_RecievedInvite:reloadOrCLose(eventType)
	--组队失败，如果当前比赛还有继续的
	if eventType == MatchCfg.NotifyType.MATCH_FRIEND_FAILED then
			print("MatchLayer_RecievedInvite 组队失败 但是比赛有下一场 跳转到游戏详情")
			self:jumpToMatchDetail()
	end

	self:close()
end

function MatchLayer_RecievedInvite:onEnter()
	-- body
	print("MatchLayer_RecievedInvite onEnter")
	MatchLayer_RecievedInvite.super.onEnter(self)
	
	self:initViewData()
	self:initLocalText()

	if self.matchData then
		self:reloadData()
	else
		MatchProxy:requestMatchDetail(self.matchid)
	end
	--MatchProxy:requestMatchDetail(self.matchid)
	
end

function MatchLayer_RecievedInvite:onExit()
	--是否处理了，没处理 当成拒绝
	if self.hasDeal == false then
		self:refuse()
	end
	local invitedFriends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND)
	if invitedFriends and next(invitedFriends) then
		invitedFriends[self.instanceID] = nil
	end
	
	MatchLayer_RecievedInvite.super.onExit(self)
	
	
end

function MatchLayer_RecievedInvite:refreshContent()
	--print("MatchLayer_RecievedInvite refreshContent",self.timeCount)
	if not self.matchData then
		return
	end
	self.titleText:setString(tostring(self.matchData.Name))
	self:refreshTime(self.matchData,self.timeText)
	self:refreshIcon()
	self:refreshCost()
end

--倒计时时间到
function MatchLayer_RecievedInvite:timeout()
	self:stopAllActions()
	self.timeCount = 0
	MatchProxy:requestMatchDetail(self.matchid)
end

function MatchLayer_RecievedInvite:matchHashBeginOrCancel()
	self:stopAllActions()
	self.timeCount = 0
	self.hasValid = false
end

function MatchLayer_RecievedInvite:matchSignOk()
	self:matchHashBeginOrCancel()
	--报名成功
	print("MatchLayer_RecievedInvite 组队报名成功 跳转到游戏详情")
	self:jumpToMatchDetail()
	self:close()
end
--跳转到比赛详情界面
function MatchLayer_RecievedInvite:jumpToMatchDetail()
	local curFsm = FSRegistryManager:currentFSM()
	--curFsm:currentState().mStateName ~= "UIMatchState"
	if curFsm:currentState().mStateName == "UIMatchState" then
		print("我本来就在比赛界面")
	else
		self:gotoTask("match","UIMatchState",1,self.inviteData.Param2)
--[[		while curFsm:currentState().mStateName~=curFsm.fsm.mEntryPoint do
			print("mStateName",curFsm:currentState().mStateName)
			print("mEntryPoint",curFsm.fsm.mEntryPoint)
			curFsm:trigger("back")
		end
		FSRegistryManager:currentFSM():trigger("match",{parentNode=display.getRunningScene(), zorder=3,crType = 1 })--]]
	end
	
--[[	local invitedFriends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND)
	
	MatchCfg.enterMatchId = invitedFriends[self.instanceID][1].Param2--]]
	--立即刷新
	print("立刻刷新")
	MatchProxy:requstMatchList(false)
	
end

--任务跳转 跳转至指定的状态机
--@param eventName 跳转到状态机的事件名
--@param stateName 状态机名
--@crType 几个打牌的请求类型 1 经典 2 比赛 3 私人
function MatchLayer_RecievedInvite:gotoTask(eventName,stateName,crType,externalData)
	local UIJmperConfig = require("config.UIJmperConfig")
	if UIJmperConfig then
		local opendata = clone(UIJmperConfig[0x012]) --跳转到比赛
		local jumpParam = { zorder = 3,}
		opendata.param = opendata.param or {}
		if opendata.param then
			table.merge(opendata.param,jumpParam)
		end
		UIStateJumper:JumpUI(opendata,externalData)
	end
		
--[[	local curStateName = FSRegistryManager:currentFSM():currentState().mStateName
	if curStateName=="UIRoot" then
		FSRegistryManager:currentFSM():trigger(eventName,{parentNode=display.getRunningScene(), zorder=3,crType = crType,enterMatchId=externalData })
	else
		local jumpFilter = JumpFilter:create(1,bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume),1)
		jumpFilter:setJumpData(eventName, { zorder = 3, crType = crType,enterMatchId = externalData })
		FSRegistryManager:currentFSM():addFilter("UIRoot",jumpFilter)
		
		--如果这个state就在堆栈中
		local cor = CorFilter:create(2,FSConst.FilterType.Filter_Resume,1)
		cor:setCorData(function ()
			wwlog( self.__cname..".lua","删除过滤器")
			FSRegistryManager:currentFSM():removeFilter("UIRoot",1)
			
		end)
		FSRegistryManager:currentFSM():addFilter(stateName,jumpFilter)

		while curStateName~="UIRoot" and curStateName~=stateName do
			wwlog( self.__cname..".lua","当前状态名字:%s，需要跳转的状态:%s",curStateName,stateName)
			FSRegistryManager:currentFSM():trigger("back")
			curStateName = FSRegistryManager:currentFSM():currentState().mStateName
		end
	end
--]]
	

end

function MatchLayer_RecievedInvite:matchNotify(event)
	local msgTable = event._userdata
	if not msgTable then
		return
	end
	if event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER or
	event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT then --报名成功
		--改变按钮状态
		--报名成功，退赛成功
		self:timeout()
		if msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS or
		msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS_HAS_STARTED or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_ING or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_NOT_EXISTS then
			self.clickItem = false
		end
--[[		if msgTable.Type==7 or msgTable.Type==2 or msgTable.Type==3 then
			MatchProxy:requestMatchDetail(self.matchid)
		end--]]
		
	end
end
function MatchLayer_RecievedInvite:reloadData(event)
	
	print("MatchLayer_RecievedInvite:reloadData")
	
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	self.matchData =allMtchData[self.matchid]
	if not self.matchData then
		return
	end
	self.hasDataOnce = true
	--dump(self.matchData)
	self:stopAllActions()
	self.signType = 0 --请求的类型
	self.signData = 0 --请求的数据
	self.timeCount = 0
--	self:refreshTime(self.matchData,self.timeText)
	self:refreshContent()
	if self.refreshToGame then
		--MatchProxy:requestSign(self.matchid,self.signType,self.signData)
	end

end

--刷新图标
function MatchLayer_RecievedInvite:refreshIcon()
	--BeginType
	
	if tonumber(self.matchData.BeginType)==1 then
	--人数
		self.alarmImg:loadTexture("match_desc_person.png",1)
	else
	--时间
		self.alarmImg:loadTexture("match_desc_alarm.png",1)
	end
	local num = self:getMaxAwardCount(self.matchid)
	if tonumber(self.matchData.TeamWork)==1 then
		--num = num / 2
	end
	ccui.Helper:seekWidgetByName(self.imgId,"Text_condition"):setString(
	string.format(i18n:get('str_match','match_award_count'),num))
end
--刷新消耗
function MatchLayer_RecievedInvite:refreshCost()
	
	self.signText:removeAllElements()
	local showStr = ""
	local showNum = nil
	local needImg = false
	-- wwdump(self.matchData)
	self.qualification = (self.matchData.EnterEnough==1)
	
	local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
	local fid 
	local nNum
	if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
		local splArrs = Split(self.matchData.EnterData, "/")
		nNum = splArrs[3]
	else
		nNum = self.matchData.EnterData
	end
	
	self.signType = tonumber(self.matchData.EnterType)
	
	self.signData = tonumber(nNum)
	
	if tonumber(self.matchData.MyEnterFlag)==0 then --未报名
		--self.signImg:loadTexture("hall/match/match_mate_btn_yellow.png")
		if tonumber(self.matchData.EnterType)==0 then --免费报名
			showStr = i18n:get('str_match','match_sure_invite') --显示确认组队
		else
			--报名资格是否足够
			self.qualification = false
		
			--local slist = self.matchData.signList
			--		for _,signData in ipairs(slist) do
					
						
									
						fid = ed.fid

						local goods = getGoodsByFid(fid)
				
						if goods then
							-- local value = DataCenter:getUserdataInstance():getValueByKey(goods.dataKey)
							local value = DataCenter:getUserdataInstance():getGoodsAttr(goods.fid,"count")

							wwlog("diyal 道具数量", value)
							if tonumber(value or 0)>=tonumber(nNum) then
							--满足
								--if self.signType == 0 then
									
								--end
							
								self.qualification = true
							
							end
						end
				--	end
		
			--local enterData = self.matchData.signList[1]
			--print("qualification",self.qualification)
			self.qualification = (self.matchData.EnterEnough==1)
			if self.qualification then
				-- 满足的情况下 本地再判断一次
				local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
				local fid  = ed.fid
				local nNum
				local value = 0
				if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
					local splArrs = Split(self.matchData.EnterData, "/")
					nNum = splArrs[3]
					value = DataCenter:getUserdataInstance():getGoodsAttr(fid,"count")
				else
					nNum = self.matchData.EnterData
					local goods = getGoodsByFid(fid)
					if goods then
						value = DataCenter:getUserdataInstance():getValueByKey(goods.dataKey)
					end
					
					
				end
				--fid = ed.fid

				--wwdump(self.matchData, nNum)

				--wwlog("diyal", goods.dataKey)
				if value and tonumber(value)<tonumber(nNum) then
				--满足
	--[[				if self.signType == 0 then
						self.signType = tonumber(self.matchData.EnterType)
						self.signData = tonumber(self.matchData.EnterData)
					end--]]
					
					self.qualification = false
					
				end
			end			
			local nNum
			if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
				local splArrs = Split(self.matchData.EnterData, "/")
				nNum = splArrs[3]
			else
				nNum = self.matchData.EnterData
			end

			if self.qualification then
				

				--TODO 显示比赛消耗
				showStr = string.format(i18n:get('str_match','match_sign_fee_s'))
				if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
					showNum  = string.format("x%s",ToolCom.splitNumFix(tonumber(nNum)))
				else
					showNum  = string.format("%s",ToolCom.splitNumFix(tonumber(nNum)))
				end
				print(showNum)
				needImg = true
				
			else
				--match_sign_not_enough
				if string.len(self.matchData.SignupTermDesc) >0 then
					showStr = i18n:get('str_match','match_sign_not_enough')

				else
					showStr = string.format(i18n:get('str_match','match_sign_fee_s'))
					if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
						showNum  = string.format("x%s",ToolCom.splitNumFix(tonumber(nNum)))
					else
						showNum  = string.format("%s",ToolCom.splitNumFix(tonumber(nNum)))
					end
					needImg = true
				end
				
			end
		
		
		
		end
		
		local showColor = cc.c3b(0xff, 0xff, 0xff)
		if not self.qualification and string.len(self.matchData.SignupTermDesc) == 0 then
			showColor = cc.c3b(0xff,0x00,0x00)
		end
		
		local re1 = ccui.RichElementText:create(1, showColor,0xff, showStr, "FZZhengHeiS-B-GB.ttf", 40)
		self.signText:pushBackElement(re1)
		if showNum then 
			local re11 = ccui.RichElementText:create(1, showColor,0xff, showNum, "FZZhengHeiS-B-GB.ttf", self.textFontSize)
			self.signText:pushBackElement(re11)
		end
		if needImg then
			
			local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
			if ed and cc.FileUtils:getInstance():isFileExist(ed.spfile) then
				local re2 = ccui.RichElementImage:create(2,cc.c3b(0xff,0xff,0xff),0xff,ed.spfile)
				self.signText:pushBackElement(re2)
			end
		end
	else --已经报名了 显示退赛
		--self.signImg:loadTexture("hall/match/match_mate_btn_green.png")
		local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
		local fid 
		local nNum
		if self.matchData and (self.matchData.EnterType == 3) then --如果是比赛门票
			local splArrs = Split(self.matchData.EnterData, "/")
			nNum = splArrs[3]
		else
			nNum = self.matchData.EnterData
		end
		
		self.signType = tonumber(self.matchData.EnterType)
		self.signData = tonumber(nNum)
		showStr = i18n:get('str_match','match_sure_invite')
		local re1 = ccui.RichElementText:create(1,  cc.c3b(0xff, 0xff, 0xff),0xff, showStr, "FZZhengHeiS-B-GB.ttf", 42)
		self.signText:pushBackElement(re1)
	end
	
end


function MatchLayer_RecievedInvite:initViewData()
	 

	ccui.Helper:seekWidgetByName(self.imgId,"Image_refuse"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Image_sure"):addTouchEventListener(handler(self,self.touchListener))
	
	self.titleText = ccui.Helper:seekWidgetByName(self.imgId,"Text_title")
	self.titleText:setString("")
	self.timeText = ccui.Helper:seekWidgetByName(self.imgId,"Text_time")
	self.alarmImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_alarm")
	--头像
	self.headImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_head1")
	
	local param = {
		headFile=DataCenter:getUserdataInstance():getHeadIconByGender(self.inviteData.Gender and tonumber(self.inviteData.Gender) or 1),
		maskFile="#match_mate_bg_header2.png",
		frameFile = "common/common_userheader_frame_userinfo.png",
		headType=1,
		radius=104,
	    headIconType = self.inviteData.IconID,--DataCenter:getUserdataInstance():getValueByKey("IconID"),
	    userID = self.inviteData.toUserID--DataCenter:getUserdataInstance():getValueByKey("userid") 
	}
		--
	local HeadSprite = WWHeadSprite:create(param)
	HeadSprite:setPosition(cc.p(104,104))
	self.headImg:addChild(HeadSprite)
	--名字
	local nameText = ccui.Helper:seekWidgetByName(self.imgId,"Text_name1")
	if self.inviteData.nickname and string.len(self.inviteData.nickname)>0 then
		nameText:setString(self.inviteData.nickname)
	else
		nameText:setString(tostring(self.inviteData.toUserID))
	end
	
	self.signText = ccui.Helper:seekWidgetByName(self.imgId,"Text_sure")
	--这里用富文本来替换
	local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:addTo(self.signText:getParent())
	richText:setName("Text_sure")
	richText:setPosition(self.signText:getPositionX(),self.signText:getPositionY())
	self.textFontSize = 42
	self.textFontColor = cc.c3b(0x91,0x1F,0x1F)
	self.signText:removeFromParent()
	self.signText = richText
	
	ccui.Helper:seekWidgetByName(self.imgId,"Image_condition"):addTouchEventListener(handler(self,self.touchListener))
end
function MatchLayer_RecievedInvite:refuse()
	if self.matchData and self.hasValid then
		self.hasDeal = true --是否处理了
		local mynickname = DataCenter:getUserdataInstance():getValueByKey("nickname")
		local myuserid = DataCenter:getUserdataInstance():getValueByKey("userid")
		local myIconID = DataCenter:getUserdataInstance():getValueByKey("IconID")
				
		local nickname = tostring(myuserid)
		if mynickname and string.len(mynickname)>0 then
			nickname = mynickname
		end
				
		MatchProxy:requestInviteOrRefuse(5,self.inviteData.toUserID,tonumber(myIconID),nickname,
		self.inviteData.Param1,self.inviteData.Param2,self.inviteData.Gender)
	end
end
function MatchLayer_RecievedInvite:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		wwlog(self.logTag,"别TM瞎点了00000%s,%s",tostring(self.clickItem),tostring(LoadingManager:isShowing()))
		if self.clickItem or LoadingManager:isShowing() then
			wwlog(self.logTag,"别TM瞎点了")
			return
		end
		self.clickItem = true
		
		local name = ref:getName()
		if name == "Image_refuse" then
		--添加好友
			self.isTopLayer = false
			--传入比赛实例ID
			print("拒绝")
			self:refuse()
			--直接退出当前界面
			self:close()
			
		elseif name == "Image_sure" then
			
			print("确认")
			self.isTopLayer = false
			--self.qualification
			--tonumber(self.matchData.MyEnterFlag)==1
			if self.qualification or tonumber(self.matchData.MyEnterFlag)==1 then --满足报名条件
				if self.matchData and self.hasValid then
					self.hasDeal = true --是否处理了
	--[[				if tonumber(self.matchData.TeammateID) then
					
					end--]]

					local cost = {signType = self.signType,signData = self.signData}
					DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_COST,cost)
						
					--Modify Start 20161103 diyal  修改被邀请报名比赛失败 
					MatchProxy:requestSign(self.matchid,self.signType,self.signData,self.inviteData.toUserID)
					-- MatchProxy:requestSign(self.matchid, self.matchData.EnterType,self.signData,self.inviteData.toUserID)
					--Modify End 20161103  修改被邀请报名比赛失败 
					
					--display.getRunningScene():removeChildByName("MatchLayer_Single")
				else
					--数据还没获取到
				end
			else
				--不满足条件
								--先判断是否破产 并且是金币
				local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey('GameCash'))
				if DataCenter:getUserdataInstance():getValueByKey("bankrupt") 
				and self.matchData.EnterType==1 then
					self:showBankRupt(self.signData - myCash)
				else
					
					--判断是否配置了报名条件
					if self.matchData.SignupTermDesc and string.len(self.matchData.SignupTermDesc)>0 then
						self.isTopLayer = false
						local reward = MatchLayer_widget_detail:create(self.matchData.SignupTermDesc)
						reward:setCid(1)
						reward:bindCloseCB(handler(self,self.frontClosed))
						cc.Director:getInstance():getRunningScene():addChild(reward,5)
					else
						self.clickItem = false
						self.isTopLayer = true
						local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
						if ed then
							
							local storeOpenType = ed.storeOpenType
							FSRegistryManager:currentFSM():trigger("store", 
							{parentNode=display.getRunningScene(), zorder=5, store_openType=storeOpenType, sceneIDKey = "MatchRoom"})
						else
							print("本地未配置当前道具",self.matchData.EnterType)
						end
						
						

					end
				end
			end
			

		elseif name == "Image_condition" then
		--显示奖励列表
			self.isTopLayer = false
			local awardStr = self:formatAward(self.matchData.MatchID)
			print(awardStr,"==================")
			local condition = MatchLayer_widget_detail:create(self:formatAward(self.matchData.MatchID))
			condition:setCid(2)
			condition:bindCloseCB(handler(self,self.frontClosed))
			cc.Director:getInstance():getRunningScene():addChild(condition,self:getLocalZOrder()+1)
		end
	end
	
	
	
end

--顶层关闭的回调
function MatchLayer_RecievedInvite:frontClosed(force)
	print("MatchLayer_RecievedInvite frontClosed",self.needFresh)
	self.isTopLayer = true
	self.clickItem = false
	
end

function MatchLayer_RecievedInvite:initLocalText()
	
end

return MatchLayer_RecievedInvite