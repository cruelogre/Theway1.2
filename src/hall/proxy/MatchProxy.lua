-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.11
-- Last: 
-- Content:  比赛代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchProxy = class("MatchProxy",require("packages.mvc.Proxy"))

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")
local HallCfg = require("hall.mediator.cfg.HallCfg")

local Toast = require("app.views.common.Toast")

local GDMatchDataRequest = import(".GDMatchDataRequest","hall.request.")
local GDMatchEnterRequest = import(".GDMatchEnterRequest","hall.request.")
local GDInviteRequest = import(".GDInviteRequest","hall.request.")

local ChooseRoomRequest = require("hall.request.ChooseRoomRequest")

local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")



function MatchProxy:init()
	print("MatchProxy init")
	self._gdmatchModel = require("hall.model.GDMatchModel"):create(self)
	self.hallMsgModel = import(".HallNetModel", "hall.model."):create(self)
	self._hallNetModel2 = require("hall.model.HallNetModel2"):create(self)
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchList_Ret,handler(self,self.response), MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST)
	
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchNotifyUser_Ret,handler(self,self.response))
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchInfo_Ret,handler(self,self.response))
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDFoundMates_Ret,handler(self,self.response))
	self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchAddBuddy_Ret,handler(self,self.response))
	--self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchGameStart_Ret,handler(self,self.response))
	--self:registerMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchGameOver_Ret,handler(self,self.response))
	
	self:registerRootMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchData_Send,handler(self,self.normalResponse))	
	self:registerRootMsgId(self._gdmatchModel.MSG_ID.Msg_GDMatchEnter_Send,handler(self,self.normalResponse))
	
	self.isTimeToGo = false --是否定时赛开始的标志
	self.timeMatchId = 0 --定时赛开赛的ID
	self.restoreMatchId  = 0 --恢复对局的matchid
	self.logTag = "MatchProxy.lua"
	--self.matchSendnumberTime = 0 --发送四个数字的时间
end

function MatchProxy:normalResponse(msgId,msgTable)
	print(msgTable)
	dump(msgTable)
	if msgTable.msgId and msgTable.kReason and string.len(msgTable.kReason)>0 then
		Toast:makeToast(tostring(msgTable.kReason),1.0):show()
	end
end
--进入比赛列表事件发送
function MatchProxy:enterMatchList(param1)
	
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(1,param1)
	crquest:send2(self)
	
end

--请求比赛列表
function MatchProxy:requstMatchList(loading)
	if loading then
		LoadingManager:startLoading(0.8,LOADING_MODE.MODE_TOUCH_CLOSE)
	end
	local msgIds = self._gdmatchModel.MSG_ID
	DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST,nil)
	
	
	local mdquest = GDMatchDataRequest:create()
	mdquest:formatRequest(1)
	mdquest:send(self)
	
end
--比赛报名
--@param matchId 比赛ID
--@param enterType 进入类型
--@param enterData  进入条件
--@param friendid  好友ID
--@param sure 是否取消之前报名
function MatchProxy:requestSign(matchId,enterType,enterData,friendid,sure)
	local msgIds = self._gdmatchModel.MSG_ID
	DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER,nil)
	
	local mdquest = GDMatchEnterRequest:create()

	wwlog("MatchProxy 报名比赛", enterType)
	
	mdquest:formatRequest(friendid and 3 or 1,matchId,enterType,enterData,friendid or 0,sure==nil and 0 or sure)
	mdquest:send(self)
end

--请求添加好友
--@param retType 请求类型 3=面对面加好友 4=邀请比赛配对的好友列表 5=邀请好友组队
--@pram1 retType=3时，4位数字密码  retType=4，5时，Param1=InstMatchID,比赛实例ID
--@pram1 retType=5时，Param2=好友ID
function MatchProxy:requestFriend(retType,param1,param2)
	local mdquest = GDMatchDataRequest:create()
	mdquest:formatRequest(retType,param1,param2)
	mdquest:send(self)
end
--邀请好友或者拒绝
--@param reqType 请求类型 4=邀请好友组队 5=拒绝组队
--@param toUserID 对方蛙号
--@param IconID 我的头像
--@param nickname 我的昵称
--@param Param1 InstMatchID 比赛实例ID
--@param Param2 MatchID 比赛ID
function MatchProxy:requestInviteOrRefuse(reqType,toUserID,IconID,nickname,InstMatchID,MatchID,gender)
	local invite = GDInviteRequest:create()
	
	invite:formatRequest(reqType,toUserID,IconID,nickname,InstMatchID,MatchID,gender)
	invite:send(self)
end
--退赛
function MatchProxy:quitSign(matchId)
	local mdquest = GDMatchEnterRequest:create()
	
	mdquest:formatRequest(2,matchId,0,0,0,0)
	mdquest:send(self)
end
--请求比赛详情
function MatchProxy:requestMatchDetail(matchId)
	--LoadingManager:startLoading(0.8)
	local mdquest = GDMatchDataRequest:create()
	mdquest:formatRequest(2,matchId)
	mdquest:send(self)
end
--比赛即将开始的时候处理是否进入游戏
function MatchProxy:requestEnterOrNotGame(retType,targetInstMatchID,curGamePlayID,curInstMatchID)
	wwlog(self.logTag,"比赛即将开始的时候处理是否进入游戏%d %d %d %d",retType,targetInstMatchID,curGamePlayID,curInstMatchID)
	local crquest = ChooseRoomRequest:create()
	crquest:formatRequest(retType, targetInstMatchID,
	curGamePlayID,
	curInstMatchID)
	crquest:send(self)
		
end
function MatchProxy:response(msgId,msgTable)
	LoadingManager:endLoading()
	--dump(msgTable)
	local eventTag = nil
	local eventData = msgTable
	if msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchList_Ret then --比赛列表
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchNotifyUser_Ret then
		eventTag,eventData = self:handleMatchNotify(msgTable)
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchInfo_Ret then --比赛详情
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_DETAIL
		eventData = nil
		self:handleMatchDetail(msgTable)
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDFoundMates_Ret then --好友列表
		eventTag,eventData = self:handleFoundMates(msgTable)
	elseif msgId == self._gdmatchModel.MSG_ID.Msg_GDMatchAddBuddy_Ret then
		eventTag,eventData = self:handleAddBuddy(msgTable)
	end
	if eventTag and eventData and type(eventData)=="table" and next(eventData) then
		local temp2 = {}
		copyTable(eventData,temp2)
		DataCenter:cacheData(eventTag,temp2)
	end
	
		--发送消息
	if eventTag and MatchCfg.innerEventComponent then
		MatchCfg.innerEventComponent:dispatchEvent({
					name = eventTag;
					_userdata = eventData;
					msgId = eventTag;
					
				})
	end

	wwlog(self.logTag,eventTag)
	if eventData then
		--self:unregisterMsgId(msgId,eventTag)
		--removeAll(eventData)
	end
	
end

function MatchProxy:getMatchAward(mid,rankNo)
	local awardlist = {}
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	if tempmatchData and tempmatchData.awardList then
		for _,awardata in pairs(tempmatchData.awardList) do
			if rankNo>=awardata.BeginRankNo and rankNo<=awardata.EndRankNo then
				if awardata.magicList and type(awardata.magicList)=="table" then
					for _,v in ipairs(awardata.magicList) do
						if v.FID~=0 then
							table.insert(awardlist,v)
						end
					end
					--copyTable(awardata.magicList,awardlist)
					break
				end
				
				break
			end
			
		end
	end
	
	return awardlist
end

--处理比赛详情  这里自己存储
function MatchProxy:handleMatchDetail(msgTable)
	--msgTable.MatchID
	--缓存中通过比赛ID来存储
	local msgId = MatchCfg.InnerEvents.MATCH_EVENT_DETAIL
	local t1 = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	if not t1 then
		t1 = {}
	end
	t1[msgTable.MatchID] = msgTable --通过matchID来存储数据
	local t2 = {}
	copyTable(t1,t2)
	DataCenter:cacheData(msgId,t2)
	
	--MatchID
	if self.timeMatchId== msgTable.MatchID and self.isTimeToGo then
		--
		wwlog(self.logTag,"开赛获取提前进入房间 玩法类型%d",msgTable.BeginType)
		local jumpType = nil
		if msgTable.PlayType == Play_Type.RandomGame then
			local btype = tonumber(msgTable.BeginType)
			if btype == 1 then --定人赛
				jumpType = Game_Type.MatchRamdomCount
			elseif btype == 2 then --定时赛
				jumpType = Game_Type.MatchRamdomTime
			end
		elseif msgTable.PlayType == Play_Type.RcircleGame then
			local btype = tonumber(msgTable.BeginType)
			if btype == 1 then --定人赛
				jumpType = Game_Type.MatchRcircleCount
			elseif btype == 2 then --定时赛
				jumpType = Game_Type.MatchRcircleTime
			end
		end
		if jumpType then
			--如果已经在游戏里边了，就不进去了
			if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_Single")) then
				display.getRunningScene():getChildByName("MatchLayer_Single"):close()
			end
			if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_Multiple")) then
				display.getRunningScene():getChildByName("MatchLayer_Multiple"):close()
			end
			if FSRegistryManager.curFSMName ~= FSMConfig.FSM_WHIPPEDEGG then
				WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,jumpType,self.timeMatchId,0)
				wwlog(self.logTag,"发送进入游戏大厅事件%d",jumpType)
			end
			
			self.timeMatchId = 0
			self.isTimeToGo = false
		else
			wwlog(self.logTag,"服务器发送的玩法类型有问题啊！！！")
		end
	elseif self.restoreMatchId == msgTable.MatchID then
		
		--恢复对局的时候，正好是等待
		self.restoreMatchId = 0
		--发送消息
		local dispatchEventId = MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS
		local temp = {}
		copyTable(msgTable,temp)
		DataCenter:cacheData(dispatchEventId,temp)
		
		if dispatchEventId and WhippedEggCfg.innerEventComponent then
			WhippedEggCfg.innerEventComponent:dispatchEvent({
						name = dispatchEventId;
						_userdata = temp;
						
					})
		end
	
	end
	self:dispatchEvent(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	
	--这个地方全局广播一次
	if NetWorkCfg.innerEventComponent then
		NetWorkCfg.innerEventComponent:dispatchEvent({
						name = MatchCfg.InnerEvents.MATCH_EVENT_DETAIL;
						_userdata = msgTable;
						
					})
	end
	t1 = nil
end

--处理好友列表
function MatchProxy:handleFoundMates(msgTable)
	local eventTag  = nil
	local eventData = {}
	local msgType = msgTable.Type 
	--dump(msgTable)
	local function hasMate(allFriends,friend)
		if not allFriends or not next(allFriends.mateList) then
			return false
		end
		local hasTheFriend = false
		for _,m in pairs(allFriends.mateList) do
			if m.UserID==friend.UserID then
				hasTheFriend = true
				break
			end
		end
		return hasTheFriend
	end
	if msgType==1 then --面对面扫描结果
		eventTag =  MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE
		--面对面扫结果的情况下，扫到的好友，添加到内存中去，代表当前匹配到的好友
		
		local searchFriend = false
		local friends = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE_ALL)
		friends = friends or {}
		friends.mateList = friends.mateList or {}
		local myuserid = DataCenter:getUserdataInstance():getValueByKey("userid")
		if msgTable.mateList then
			for _,mate in pairs(msgTable.mateList) do
				if mate.UserID~=tonumber(myuserid)  --是我就不用添加
				and not hasMate(friends,mate) then --这个好友在里边没有的
					table.insert(friends.mateList,mate)
					print("add mate",mate.UserID)
					table.insert(eventData,mate)
					searchFriend = true
				end
			end
		end
		if searchFriend then
			--存到所有的好友中去
			--copyTable(msgTable,eventData)
			local tempFriend = {}
			tempFriend.mateList = {}
			
			copyTable(friends.mateList,tempFriend.mateList)
			--wwdump(friends.mateList)
			DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE_ALL,tempFriend)
		else
			eventTag = nil --外边不用再缓存了
		end
		--dump(msgTable)
		--dump(DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE))
		
	elseif msgType == 2 then --比赛邀请好友列表
		eventTag =  MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND
		copyTable(msgTable,eventData)
	end
	
	return eventTag,eventData
end


--[[
--Type 通知类型

1-开赛预通知
2-退赛成功
3-退赛成功，比赛已开始，不返回门票
4-正在开赛中，不允许退赛
5-不在比赛中，不允许退赛
6-人数不足，比赛被取消
7-报名成功
8-报名失败
9-好友退赛
11-开赛
12-晋级下一轮
13-被淘汰
14-比赛结束
15-等待其他桌完成对局
16-恢复现场--]]
--处理比赛通知消息
function MatchProxy:handleMatchNotify(msgTable)
	
	local function getMateInfo(uid)
		local mateinfo = nil --是否有这个好友
		local friendLists = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND)
		if friendLists and friendLists.mateList and next(friendLists.mateList) then
			for _,mate in pairs(friendLists.mateList) do
				if mate.UserID== uid then
					mateinfo = mate
					
					break
				end
			end
		end
		
		return mateinfo
	end
	
	local eventTag  = nil
	local eventData = nil
	local msgType = msgTable.Type  
	if msgType == MatchCfg.NotifyType.MATCH_WILL_START then --开赛预通知
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_WILL_START
		eventData = msgTable
		--self:handleGameWillStart(msgTable)
	elseif msgType == MatchCfg.NotifyType.MATCH_QUIT_SUCCESS then  --退赛成功
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT
		if tonumber(msgTable.Param1)==0 then --免费报名的
			self:handleToast(i18n:get('str_match','match_quit_ok'))
		end
		eventData = {}
		self:handleQuitSign(msgTable)
	elseif msgType == MatchCfg.NotifyType.MATCH_QUIT_SUCCESS_HAS_STARTED then  --退赛成功，比赛已开始，不返回门票
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT
		self:handleToast(i18n:get('str_match','match_quit_ok_2'))
		eventData = {}
		self:handleQuitSign(msgTable)
	elseif msgType == MatchCfg.NotifyType.MATCH_QUIT_FAILED_ING then  --正在开赛中，不允许退赛
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT
		self:handleToast(i18n:get('str_match','match_cant_quit_1'))
		eventData = {}
	elseif msgType == MatchCfg.NotifyType.MATCH_QUIT_FAILED_NOT_EXISTS then  --不在比赛中，不允许退赛
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT
		self:handleToast(i18n:get('str_match','match_cant_quit_2'))
		eventData = {}
	elseif msgType == MatchCfg.NotifyType.MATCH_CANCELED_NOT_ENOUGH then  --人数不足，比赛被取消
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT
		--self:handleGameCancel(msgTable)
		eventData = msgTable
		self:handleQuitSign(msgTable)
	elseif msgType == MatchCfg.NotifyType.MATCH_SIGN_SUCCESS then  --报名成功
		
		--进入游戏中
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER
		eventData = msgTable
		self:handleGameSignOk(msgTable)
		
	elseif msgType == MatchCfg.NotifyType.MATCH_SIGN_FAILED then  --报名失败
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_SIGN_FAILED
		eventData = msgTable
		local showStr = i18n:get('str_match','match_sign_failed')
		if msgTable.RespInfo and string.len(msgTable.RespInfo)>0 then
			showStr = msgTable.RespInfo
		end
		self:handleToast(showStr)
	elseif msgType == MatchCfg.NotifyType.MATCH_FRIEND_QUIT then  --好友退赛
		self:handleToast(string.format(i18n:get('str_match','match_friend_cancel'),msgTable.Param1))
	elseif msgType == MatchCfg.NotifyType.MATCH_INVITE_FRIEND_QUIT then --组队好友退赛
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_FRIEND_QUIT
		eventData = msgTable
		local mateinfo = getMateInfo(msgTable.Param1) --是否有这个好友
		
		self:handleToast(string.format(i18n:get('str_match','match_invite_friend_cancel'),mateinfo and tostring(mateinfo.Nickname) or tostring(msgTable.Param1)))
	elseif msgType == MatchCfg.NotifyType.MATCH_START then  --开赛
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_START_DATA
		eventData = {}
		eventData.data =  msgTable.RespInfo --轮次/局数/每轮晋级人数
		eventData.data2 =  msgTable.Param1 --晋级条件
		copyTable(msgTable,eventData)
		--比赛开赛，请求一下比赛详情
		self.isTimeToGo = true
		self.timeMatchId = msgTable.MatchID
		self:requestMatchDetail(msgTable.MatchID)
	elseif msgType == MatchCfg.NotifyType.MATCH_UPGRADE then  --晋级下一轮
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_UPGRADE
		--eventData = {}
		--eventData.data =  msgTable.RespInfo --晋级人数
		--copyTable(msgTable,eventData)
	elseif msgType == MatchCfg.NotifyType.MATCH_OBSOLESCENCE then  --被淘汰
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED
		--eventData = { MRanking = msgTable.Param1,matchid = msgTable.MatchID ,matchname = msgTable.MatchName }
	elseif msgType == MatchCfg.NotifyType.MATCH_OVER then  --比赛结束
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_OBSOLETED
		--eventData =  { MRanking = msgTable.Param1,matchid = msgTable.MatchID ,matchname = msgTable.MatchName }
	elseif msgType == MatchCfg.NotifyType.MATCH_WAITING_OTHERS then  --等待其他桌完成对局
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_WAITOTHERS
		--eventData = {}
		--copyTable(msgTable,eventData)
	elseif msgType == MatchCfg.NotifyType.MATCH_RESUME_GAME then  --恢复现场
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_RESTORE_SCENE
		--eventData = {}
		--copyTable(msgTable,eventData)
	elseif msgType == MatchCfg.NotifyType.MATCH_RANK_CHANGE then  --玩家名次变化
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_RANK_CHANGE
		--eventData = {}
		--eventData.data =  msgTable.RespInfo --自己名次/比赛人数
	elseif msgType == MatchCfg.NotifyType.MATCH_COUNT_RESTORE then --定人赛恢复
		self.isTimeToGo = true
		self.timeMatchId = msgTable.MatchID
		self:requestMatchDetail(msgTable.MatchID)
	elseif msgType == MatchCfg.NotifyType.MATCH_FRIEND_AGREE then --好友同意
		--msgTable.Param1
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_AGREE_INVITE
		
		local mateinfo = getMateInfo(msgTable.Param1) --是否有这个好友
	
		--dump(mateinfo)
		self:handleToast(string.format(i18n:get('str_match','match_invited_team_ok'),mateinfo and tostring(mateinfo.Nickname) or tostring(msgTable.Param1)))
		--组队成功，重新刷新请求
		self:requestFriend(4,msgTable.InstMatchID)
		eventData = {}
		copyTable(msgTable,eventData)
	elseif msgType == MatchCfg.NotifyType.MATCH_FRIEND_SUCCESS then --组队成功
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS
		eventData = {}
		copyTable(msgTable,eventData)
		self:handleToast(i18n:get('str_match','match_invite_success'))
	elseif msgType == MatchCfg.NotifyType.MATCH_FRIEND_FAILED then --组队失败 好友已经组队了
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FAILED
		eventData = {}
		copyTable(msgTable,eventData)
		local showStr = i18n:get('str_match','match_invite_failed')
		if msgTable.RespInfo and string.len(msgTable.RespInfo)>0 then
			showStr = msgTable.RespInfo
		end
		self:handleToast(showStr)
	end
	if string.len(msgTable.RespInfo)>0 then
		--Toast:makeToast(tostring(msgTable.RespInfo),1.0):show()
	end

	wwdump(msgTable,"MatchProxy:handleMatchNotify")
	
	--退赛或者开赛了
	if eventTag==MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT --退赛
	or eventTag== MatchCfg.InnerEvents.MATCH_EVENT_START_DATA --开赛
	or eventTag == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER  --报名成功
	or eventTag == MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS --组队成功
	or eventTag == MatchCfg.InnerEvents.MATCH_EVENT_SIGN_FAILED --报名失败
	or eventTag == MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FAILED --组队失败
	or eventTag == MatchCfg.InnerEvents.MATCH_EVENT_WILL_START then --比赛即将开赛
		self:dispatchEvent(eventTag,eventData)
	end
	
	return eventTag,eventData
end
--邀请或者拒绝好友通知
function MatchProxy:handleAddBuddy(msgTable)
	local eventTag  = nil
	local eventData = nil
	
	if msgTable.type==4 then --邀请好友组队
	
		--如果已经和别人组队了，就忽略这个请求
		
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_INVITE_FRIEND
		local eventInviteData = DataCenter:getData(eventTag)
		if not eventInviteData then
			eventInviteData = {}
			--eventInviteData[msgTable.Param1] = {}
		end
		if not eventInviteData[msgTable.Param1] then
			eventInviteData[msgTable.Param1] = {}
		end
		--是否有重复的邀请
		local function hasSameUser(dall,d1)
			local sameUser = false
			if dall then
				for _,v in pairs(dall) do
					if v and d1 and v.toUserID == d1.toUserID then
						sameUser = true
					end
				end
			end
			return sameUser
		end
		
		if not hasSameUser(eventInviteData[msgTable.Param1],msgTable) then
			table.insert(eventInviteData[msgTable.Param1],msgTable) --有数据
			local tempData = {}
			copyTable(eventInviteData,tempData)
			DataCenter:cacheData(eventTag,tempData)

			self:requstMatchList()
			local tempMsg = {}
			copyTable(msgTable,tempMsg)
			self:dispatchEvent(COMMON_EVENTS.C_EVENT_INVITE,tempMsg)
		else
			wwlog(self.logTag,"重复邀请了啊")
		end
	elseif msgTable.type == 5 then --拒绝组队
		eventTag = MatchCfg.InnerEvents.MATCH_EVENT_REFUSE_INVITE
		--忽略
		--拒绝后重新请求好友列表
		eventData = msgTable
	end
	
	return eventTag,eventData
end

--通过matchID 查找缓存中的数据
function MatchProxy:getMatchDataByID(matchId)
	local roomdata = nil
	local roomlist = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST)
	if roomlist and roomlist.MatchList then
		for _,v in pairs(roomlist.MatchList) do
			if v.MatchID == matchId then
				roomdata = v
				break
			end
		end
	end
	
	return roomdata
end

--通过matchID 查找缓存中的数据
function MatchProxy:getMatchDetailDataByID(matchId)
	local matchData = nil
	local allmatch = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	if allmatch then
		for _,v in pairs(allmatch) do
			if v.MatchID == matchId then
				matchData = v
				break
			end
		end
	end

	return matchData
end

--处理退赛成功
function MatchProxy:handleQuitSign(msgTable)
	local ed = MatchCfg.enterTypes[tonumber(msgTable.Param1)]
	local nNum = nil
	local cost = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_COST)
	if ed and ed.fid then
		if string.len(msgTable.RespInfo)>0 then
			local newValue = tostring(msgTable.RespInfo)
			if (tonumber(msgTable.Param1) == 3) then --如果是比赛门票
				local splArrs = Split(msgTable.RespInfo, "/")
				newValue = splArrs[3]
			else
				newValue = msgTable.RespInfo
			end
			wwlog(self.logTag, "更新信息中心数据newValue %s, %s", ed.fid, newValue)
			updataGoods(ed.fid, newValue, true)
		end
	end

	if msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS 
		and ed and cost and cost.signData then --退赛 并且返还了报名费
		local returnStr = string.format("%s*%d",ed.name,tonumber(cost.signData))
		self:handleToast(string.format(i18n:get('str_match','match_quit_ok_with'),returnStr))
		
		--这里请求我是否破产
		local cash = DataCenter:getUserdataInstance():getValueByKey("GameCash")
		if cash and tonumber(cash) < HallCfg.bankRuptLimit then
			-- 不要频繁发送 本地先判断我的金币
			wwlog(self.logTag, "请求破产标志")
			local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
			HallSceneProxy:requestIsBankrupt()
		end
			
	end
	dump(msgTable)
	local matchData = self:getMatchDetailDataByID(msgTable.MatchID)
	if not matchData then
		wwlog(self.logTag,"matchData空的，没有比赛数据")
		return
	end
	if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_Multiple")) and tonumber(matchData.TeamWork)==1 then
		display.getRunningScene():getChildByName("MatchLayer_Multiple"):close()
		--打开加好友的界面
		MatchCfg.enterMatchId = msgTable.MatchID
		self:requstMatchList()
	end
	
end
--处理报名成功
function MatchProxy:handleGameSignOk(msgTable)
	local matchData = self:getMatchDetailDataByID(msgTable.MatchID)
	if not matchData then
		wwlog(self.logTag,"matchData空的，没有比赛数据")
		return
	end
	local ed = MatchCfg.enterTypes[tonumber(matchData.EnterType)]
	local cost = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_COST)
	if ed and ed.fid then
		local goods = getGoodsByFid(ed.fid)
		local value = DataCenter:getUserdataInstance():getValueByKey(goods.dataKey)
		local newValue = nil
		if value then
			newValue = tostring( tonumber(value) - tonumber(cost.signData))
		else
			value = DataCenter:getUserdataInstance():getGoodsAttr(ed.fid,"count")
			if value then
				value = value - cost.signData
				newValue = math.max(value,0)
				-- DataCenter:getUserdataInstance():updateGoodsAttr(ed.fid,"count",value)
			end
			
		end
		
		wwlog(self.logTag, "更新信息中心数据SignOk newValue %s, %s", ed.fid, newValue)

		updataGoods(ed.fid, newValue, true)
		--这里请求我是否破产
		local cash = DataCenter:getUserdataInstance():getValueByKey("GameCash")
		if cash and tonumber(cash) < HallCfg.bankRuptLimit then
			-- 不要频繁发送 本地先判断我的金币
			wwlog(self.logTag, "请求破产标志")
			local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
			HallSceneProxy:requestIsBankrupt()
		end
	end
	
			
	local cbFun = nil
	if matchData and tonumber(matchData.BeginType) == 1 then
		--定人赛
		wwlog(self.logTag,"定人赛报名成功，跳转到跳转到比赛界面等待")
		local matchId = msgTable.MatchID
		cbFun = function ()
			performFunction(function ()
				if FSRegistryManager.curFSMName ~= FSMConfig.FSM_WHIPPEDEGG then
					wwlog(self.logTag,"处理报名成功进入房间 玩法类型%d",matchData.PlayType)
					local jumpType = nil
					if matchData.PlayType == Play_Type.RandomGame then
						jumpType = Game_Type.MatchRamdomCount
					elseif matchData.PlayType == Play_Type.RcircleGame then
						jumpType = Game_Type.MatchRcircleCount
					end

					if jumpType then
						--开赛后，删除比赛详情UI
						if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_Single")) then
							display.getRunningScene():getChildByName("MatchLayer_Single"):close()
						end
						if isLuaNodeValid(display.getRunningScene():getChildByName("MatchLayer_Multiple")) then
							display.getRunningScene():getChildByName("MatchLayer_Multiple"):close()
						end
	
						WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,jumpType,matchId,0)
						wwlog(self.logTag,"发送进入游戏大厅事件%d",matchId)
					else
						wwlog(self.logTag,"服务器发送的玩法类型有问题啊！！！")
					end
				end
			end,0.2)
		end
	else
		--定时赛
	wwlog(self.logTag,"定时赛报名成功")
	local singleLayer = display.getRunningScene():getChildByName("MatchLayer_Single")
	if isLuaNodeValid(singleLayer) and tonumber(matchData.TeamWork)==1 then
				--定时赛报名成功 关闭
			singleLayer:close()
			--打开加好友的界面
			MatchCfg.enterMatchId = msgTable.MatchID
			self:requstMatchList()
		end
	end
	
	local cost = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_COST)
	local ed = MatchCfg.enterTypes[cost.signType]
	if ed then
		--刷新个人财产信息
		local str = string.format("%s%s*%d",i18n:get('str_match','match_sign_ok_with_pay'),ed.name,cost.signData)
		Toast:makeToast(str,1.0):show(cbFun)
	else
		Toast:makeToast(i18n:get('str_match','match_sign_ok'),1.0):show(cbFun)
	end
end

--开赛预通知
function MatchProxy:handleGameWillStart(eventTable)
	if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG then
		wwlog(self.logTag,"已经在游戏里边了，不用通知了")
		return
	end

	local leftTime = eventTable.Param1
	local matchid = eventTable.MatchID
	
	local para = {}
    para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
    para.rightBtnCallback = function ()
		self.isTimeToGo = true
		self.timeMatchId = matchid
		self:requestMatchDetail(matchid)
		local crquest = ChooseRoomRequest:create()
		local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
		crquest:formatRequest(8, eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)
		crquest:send(self)
		
	end
	para.leftBtnCallback = function ()
		local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
		local crquest = ChooseRoomRequest:create()
		crquest:formatRequest(9, eventTable.InstMatchID,
		gamedata and gamedata.GamePlayID or 0,
		gamedata and gamedata.InstMatchID or 0)
		crquest:send(self)
	end
    para.showclose = false  --是否显示关闭按钮
	
	local t = secondToTime(tonumber(eventTable.Param1))
	
    para.content = string.format(i18n:get('str_match','match_will_start'),eventTable.MatchName,
	secoundToTimeString(tonumber(eventTable.Param1)))

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

function MatchProxy:handleGameCancel(eventTable)
	local backToHallFun = function ()
		print("FSRegistryManager.curFSMName",FSRegistryManager.curFSMName)
		if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG then
			--WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
			--比赛被取消，不跳转场景
		end
	end
	local para = {}
    para.leftBtnlabel = i18n:get('str_common','comm_cancel')
    para.rightBtnlabel = i18n:get('str_common','comm_sure')
	para.singleName = tostring(eventTable.MatchID)
    para.leftBtnCallback = backToHallFun
    para.rightBtnCallback = backToHallFun
	para.showclose = false  --是否显示关闭按钮
    para.content = string.format(i18n:get('str_match','match_cancel'),eventTable.MatchName)

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

function MatchProxy:handleToast(str,delayTime)
	local deltime = delayTime or 1.0
	if str and string.len(str)>0 then
		Toast:makeToast(str,deltime):show()
	end
end
return MatchProxy