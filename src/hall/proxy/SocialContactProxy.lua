-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.24
-- Last: 
-- Content:  每日任务的代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SocialContactProxy = class("SocialContactProxy",require("packages.mvc.Proxy"))
local SocialTalkRequest = require("hall.request.SocialTalkRequest")
local SocialDataRequest = require("hall.request.SocialDataRequest")

local UserDataCenter = DataCenter:getUserdataInstance()

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

local Toast = require("app.views.common.Toast")

function SocialContactProxy:init()
	print("SocialContactProxy init")
	self.logTag = self.__cname..".lua"
	self._socialContactModel = require("hall.model.SocialContactModel"):create(self)
	self:registerMsg()
end
function SocialContactProxy:registerMsg()
	--每日任务列表
	self:registerMsgId(self._socialContactModel.MSG_ID.Msg_RSCBuddyList_Ret,handler(self,self.response))
	self:registerMsgId(self._socialContactModel.MSG_ID.Msg_RSCBuddyTalk_Ret,handler(self,self.response))
	self:registerMsgId(self._socialContactModel.MSG_ID.Msg_RSCBuddyTalkList_Ret,handler(self,self.response))
	self:registerMsgId(self._socialContactModel.MSG_ID.Msg_RSCData_Ret,handler(self,self.response))
	
	self:registerRootMsgId(self._socialContactModel.MSG_ID.Msg_RSCData_Req,handler(self,self.rootResponse))
	self:registerRootMsgId(self._socialContactModel.MSG_ID.Msg_RSCBuddyTalk_Req,handler(self,self.rootResponse))
end
--请求牌友列表
--@param offset 开始的位置
--@param count 数量
function SocialContactProxy:requestCardPartner(offset,count)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(2,0,offset,count)
	sreq:send(self)
end

--请求所有牌友列表
function SocialContactProxy:requestAllCardPartner()
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(12,0)
	sreq:send(self)
end

--请求游戏可邀请好友列表
--@param inviteType 邀请的类型 3 比赛  4 私人房
--@param paramId 邀请类型是比赛是 matchInstID 比赛实例ID ;邀请是私人房时  roomID 私人房ID 
--@param start  
--@param count 长度
function SocialContactProxy:requestInvitePartner(inviteType,paramId,start,count)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(inviteType,paramId,start,count)
	sreq:send(self)
end

--搜索牌友
--@param userid 搜索的好友ID
function SocialContactProxy:searchBuddy(userid)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(5,tonumber(userid))
	sreq:send(self)
end
--请求添加牌友
--@param userid 添加的好友ID
function SocialContactProxy:requestAddBuddy(userid,gameid,gamePlayId,roomId) --添加了三个字段 //by sonic
	local sreq = SocialDataRequest:create()
	local strparam2 = string.format("%d,%d,%d",gameid or 0,gamePlayId or 0,roomId or 0)
	sreq:formatRequest(6,tonumber(userid),0,0,UserDataCenter:getValueByKey("nickname"),strparam2)
	sreq:send(self)
end

--请求未读聊天消息
--@param userid 添加的好友ID
function SocialContactProxy:requestUnreadMsg()
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(7,tonumber(UserDataCenter:getValueByKey("userid")),1,100,UserDataCenter:getValueByKey("nickname"))
	sreq:send(self)
end

--请求面对面好友
function SocialContactProxy:requestFaceBuddy(number)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(1,tonumber(number))
	sreq:send(self)
end
--邀请进入私人房
--@param roomId 房间ID
--@param userid 对方的蛙号
function SocialContactProxy:inviteIntoSiren(roomId,userid)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(8,tonumber(roomId),0,0,tostring(userid))
	sreq:send(self)
end

--拒绝私人房邀请
--@param roomId 房间ID
--@param userid 对方的蛙号
function SocialContactProxy:refuseSiren(roomId,userid)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(10,tonumber(roomId),0,0,tostring(userid))
	sreq:send(self)
end
--拒绝私人房邀请
--@param roomId 房间ID
--@param userid 对方的蛙号
function SocialContactProxy:agreeSiren(roomId,gameid)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(9,tonumber(roomId),0,0,tostring(gameid))
	sreq:send(self)
end

--删除好友
--@param userid 对方的蛙号
function SocialContactProxy:deleteFriend(userid)
	local sreq = SocialDataRequest:create()
	sreq:formatRequest(11,tonumber(userid))
	sreq:send(self)
end

--请求聊天
--@param toUserID 聊天的好友ID
--@param 聊天内容
function SocialContactProxy:requestChat(toUserID,content)
	local streq = SocialTalkRequest:create()
	streq:formatRequest(0,UserDataCenter:getValueByKey("userid"),tonumber(toUserID),tostring(content))
	streq:send(self)
end

--拒绝添加好友
--@param userid 被拒绝的好友ID
--@param talkMsgID 添加好友的对话ID
function SocialContactProxy:refuseAddBuddy(userid,talkMsgID)
	local streq = SocialTalkRequest:create()
	streq:formatRequest(3,UserDataCenter:getValueByKey("userid"),tonumber(userid),nil,tostring(talkMsgID))
	streq:send(self)
end
--同意添加好友
--@param userid 同意的好友ID
--@param talkMsgID 添加好友的对话ID
function SocialContactProxy:agreeAddBuddy(userid,talkMsgID)
	local streq = SocialTalkRequest:create()
	streq:formatRequest(2,UserDataCenter:getValueByKey("userid"),tonumber(userid),nil,tostring(talkMsgID))
	streq:send(self)
end
function SocialContactProxy:rootResponse(msgId,msgTable)
	dump(msgTable)
	local dispatchId = nil
	local dispatchData = nil
	LoadingManager:endLoading()
	if msgTable.kResult==1 and string.len(tostring(msgTable.kReason)) >0 then  --请求失败
		Toast:makeToast(tostring(msgTable.kReason),1.0):show()
	end
	if msgId == self._socialContactModel.MSG_ID.Msg_RSCData_Req then
		if msgTable.kReasonType == 5 and msgTable.kResult == 0 then --搜索指定用户  操作成功
			dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_SEARCH_OK
			dispatchData = msgTable
		elseif msgTable.kReasonType == 11 then --删除指定好友
			wwdump(msgTable,"好友已经删除，不管成功与否")
			dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED
			dispatchData = msgTable
			local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
			
			
			if msgTable.kResult == 0 and string.len(tostring(msgTable.kReason)) >0 then --删除成功
				local HallChatService = self:getHallChatService()
				local deleteUserId = (myuserid == tonumber(msgTable.kUserId) and msgTable.kReason or msgTable.kUserId )
				HallChatService:removeFriend({userid = tonumber(deleteUserId),owerid=tonumber(myuserid)})
			else
				--算了，还是自己重新请求吧
				self:requestAllCardPartner()
			end

		
		elseif msgTable.kReasonType == 12 and msgTable.kResult == 0 then --获取到了完整好友列表
			--写到数据库
			if tonumber(UserDataCenter:getValueByKey("userid"))>0 then
				local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
				if msgTable.kReason and string.len(tostring(msgTable.kReason))>0 then
					local friendIds = string.split(msgTable.kReason,",")
					if friendIds and next(friendIds) then
						local dataStrcts = {}
						table.walk(friendIds,function (userid,k)
							if isdigit(userid) then
								table.insert(dataStrcts,{userid = tonumber(userid),owerid=tonumber(myuserid)})
							end
						end)
						if next(dataStrcts) then
							local HallChatService = self:getHallChatService()
							HallChatService:removeFriend({owerid=tonumber(myuserid)}) --批量前先删除
							HallChatService:addBundleFriends(dataStrcts)
						end

					else
						wwlog(self.logTag,"我还没添加任何好友哦1")
					end
				else
					wwlog(self.logTag,"我还没添加任何好友哦2")
				end

			else
				wwlog(self.logTag,"我都还没有登录")
			end

		end
			
	elseif msgId == self._socialContactModel.MSG_ID.Msg_RSCBuddyTalk_Ret then
		if msgTable.kResult == 0 then --操作成功

			if msgTable.kReasonType == 2 and string.len(tostring(msgTable.kReason)) >0 then --同意加好友(上下行)
				
				dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED_ROOT
				dispatchData = msgTable
				--msgTable.kReason 由 内容和对方ID组成 这里解析
				local kReason = string.split(msgTable.kReason,"/")
				if kReason and table.nums(kReason)==2 then
					Toast:makeToast(tostring(kReason[1]),1.0):show()
					
					local HallChatService = self:getHallChatService()
					local senderid = tonumber(kReason[2])
					wwlog(self.logTag,"同意后，删除请求添加好友的会话ID:"..tostring(senderid))
					HallChatService:removeSession(senderid,1) --好友请求的类型是1
					local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
					HallChatService:addOneFriend({userid = tonumber(senderid),owerid=tonumber(myuserid)})
				end

			elseif msgTable.kReasonType == 3 then --拒绝加好友(上下行)
				--本地拒绝添加好友，就直接删除这个会话即可
				dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_REFUSE_FRINED_ROOT
				dispatchData = msgTable
				--这里操作数据库，删除之前请求好友的
				local kReason = string.split(msgTable.kReason,"/")
				if kReason and table.nums(kReason)==2 then --拒绝添加好友的不需要我这边提示了
					local HallChatService = self:getHallChatService()
					local senderid = tonumber(kReason[2])
					wwlog(self.logTag,"拒绝后，删除请求添加好友的会话ID:"..tostring(senderid))
					HallChatService:removeSession(senderid,1)
				end
			end
		elseif msgTable.kResult == 1 then --操作失败 直接删除
			dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_REFUSE_FRINED_ROOT
			dispatchData = msgTable
			Toast:makeToast("操作异常",1.0):show()
			local kReason = string.split(msgTable.kReason,"/")
			if kReason then --拒绝添加好友的不需要我这边提示了
				local HallChatService = self:getHallChatService()
				local senderid = tonumber(kReason[table.nums(kReason)])
				wwlog(self.logTag,"操作异常的时候 删除请求添加好友的会话ID:"..tostring(senderid))
				HallChatService:removeSession(senderid,1)
			end
		end
		
	end
--[[	if msgTable.kReason and string.len(msgTable.kReason)>0 and msgTable.kResult ==0 then
		Toast:makeToast(msgTable.kReason,1.0):show()
	end--]]
	if dispatchId then --全局的广播
		self:dispatchEvent(dispatchId,dispatchData)
	end
    if dispatchId and dispatchData and CardPartnerCfg.innerEventComponent then
        CardPartnerCfg.innerEventComponent:dispatchEvent( {
            name = dispatchId;
            _userdata = dispatchData;
        } )
    end
end
function SocialContactProxy:response(msgId,msgTable)
	print("SocialContactProxy response")
	--LoadingManager:endLoading()
	local dispatchId = nil
	local dispatchData = nil
	LoadingManager:endLoading()
	if msgId == self._socialContactModel.MSG_ID.Msg_RSCBuddyList_Ret then --好友列表
		dispatchId,dispatchData = self:handleBuddyList(msgTable)
	elseif msgId == self._socialContactModel.MSG_ID.Msg_RSCBuddyTalk_Ret then --好友聊天
		dump(msgTable)
		dispatchId,dispatchData = self:handleBuddyTalk(msgTable)
	elseif msgId == self._socialContactModel.MSG_ID.Msg_RSCBuddyTalkList_Ret then --未读消息列表
		dispatchId,dispatchData = self:handleBuddyTalkList(msgTable)
	elseif msgId == self._socialContactModel.MSG_ID.Msg_RSCData_Ret then --请求社交数据返回
		dispatchId,dispatchData = self:handleSocialData(msgTable)
	end
	
    if dispatchId and dispatchData and CardPartnerCfg.innerEventComponent then
        CardPartnerCfg.innerEventComponent:dispatchEvent( {
            name = dispatchId;
            _userdata = dispatchData;
        } )
    end
end
--处理好友聊天返回
--type 类型
--	0=好友聊天(上下行)
--	1=好友申请（系统消息下行）
--	2=同意加好友(上下行)
--	3=拒绝加好友(上下行)
function SocialContactProxy:handleBuddyTalk(msgTable)
	local dispatchId = nil
	local dispachData = nil
	
	if msgTable.type == 1 or msgTable.type == 0 then --好友申请  好友聊天
		dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST --会话消息
		dispachData = msgTable
		
		--写入数据库
		local HallChatService = self:getHallChatService()
		--先删除
		if msgTable.type == 1 then --好友申请的时候先删除之前的
			--HallChatService:removeSession(tonumber(msgTable.FromUserID))
		end
		
		
		local dataparams = {}
		dataparams.senderid = tonumber(msgTable.FromUserID)
		--这里固定写我的
		dataparams.receiverid =  tonumber(UserDataCenter:getValueByKey("userid"))
		dataparams.title = tostring(msgTable.FromUserID) --标题先用用户ID来标识
		dataparams.sendcontent = tostring(msgTable.Content)
		dataparams.isread = 1 --默认未读
		dataparams.sessionType = tonumber(msgTable.type) --会话类型
		dataparams.extraData = tostring(msgTable.TalkMsgID) --聊天消息ID
		if dataparams.senderid~=dataparams.receiverid and dataparams.receiverid ==tonumber(msgTable.ToUserID) then --发送和接受一样，那么就是自己加自己了
			HallChatService:addSession(dataparams)
		end
		
		
		if msgTable.type == 0 then --如果是好友聊天 那么还需要添加到聊天记录中去
			local dataparams2 = {}
			dataparams2.senderid = tonumber(msgTable.FromUserID)
			dataparams2.receiverid = tostring(msgTable.ToUserID)
			dataparams2.sendcontent = tostring(msgTable.Content)
			HallChatService:addLog(dataparams2)
			--这里聊天内容单独发送事件
			local unreadMsgs = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT)
			if not unreadMsgs then
				unreadMsgs = {}
				DataCenter:cacheData(CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT,unreadMsgs)
			end
			unreadMsgs[tonumber(msgTable.FromUserID)] = unreadMsgs[tonumber(msgTable.FromUserID)] or {}
			table.insert(unreadMsgs[tonumber(msgTable.FromUserID)],clone(msgTable))
			
			if CardPartnerCfg.innerEventComponent then
				CardPartnerCfg.innerEventComponent:dispatchEvent( {
					name = CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT;
				} )
			end
		end
		self:dispatchEvent(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST,msgTable)
	elseif msgTable.type == 2 or msgTable.type == 3 then --2=同意加好友(上下行) 3=拒绝加好友(上下行)
		dispatchId = msgTable.type == 2 and  CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED
			or CardPartnerCfg.InnerEvents.CP_EVENT_REFUSE_FRINED --会话消息
		dispachData = msgTable
		if msgTable.Content and string.len(msgTable.Content)>0 then
			Toast:makeToast(tostring(msgTable.Content),1.0):show()
		end
		wwdump(msgTable)
		--如果这个时候对方同时也加了我，删除加好友会话
		local HallChatService = self:getHallChatService()
		local senderid = tonumber(msgTable.FromUserID)
		wwlog(self.logTag,"删除请求添加好友的会话ID:"..tostring(senderid))
		HallChatService:removeSession(senderid,1)
		local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
		HallChatService:addOneFriend({userid = tonumber(senderid),owerid=tonumber(myuserid)})
		self:dispatchEvent(dispatchId,msgTable)
	end
	return dispatchId,dispachData
end
--处理好友列表
--1=面对面扫描结果
--2=牌友列表
--3=比赛可邀请好友列表
--4=私人房可邀请好友列表
function SocialContactProxy:handleBuddyList(msgTable)
	local dispatchId = nil
	local dispachData = nil
	if not msgTable then
		wwlog(self.logTag,"error in handle buddy list,table empty")
		return
	end
	if msgTable.Type == 2 then --牌友结果
		dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_PARTNERLIST
		DataCenter:clearData(dispatchId)
		dispachData = {}
		table.merge(dispachData,msgTable.friendList)
		DataCenter:cacheData(dispatchId,dispachData)
	elseif msgTable.Type == 1 then --面对面扫描结果
		local function hasMate(allFriends,friend)
			if not allFriends or not next(allFriends.friendList) then
				return false
			end
			local hasTheFriend = false
			for _,m in pairs(allFriends.friendList) do
				if m.UserID==friend.UserID then
					hasTheFriend = true
					break
				end
			end
			return hasTheFriend
		end
	
		dispatchId =  CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE --这里只是作为消息通知而已 所有的内容都存储在CP_EVENT_FOUNDMATES_FACE_ALL中
		--面对面扫结果的情况下，扫到的好友，添加到内存中去，代表当前匹配到的好友
		local searchFriend = false
		local friends = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE_ALL)
		if not friends then
			friends = {}
			friends.friendList = {}
			DataCenter:cacheData(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE_ALL,friends)
		end
		
		friends.friendList = friends.friendList or {}
		local myuserid = DataCenter:getUserdataInstance():getValueByKey("userid")
		if msgTable.friendList then
			for _,mate in pairs(msgTable.friendList) do
				if mate.UserID~=tonumber(myuserid)  --是我就不用添加
				and not hasMate(friends,mate) then --这个好友在里边没有的
					table.insert(friends.friendList,mate)
					print("add mate",mate.UserID)
					
					local HallChatService = self:getHallChatService()
					local senderid = tonumber(mate.UserID)
					local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
					local paramStruct = {userid = tonumber(senderid),owerid=tonumber(myuserid)}
					if not HallChatService:checkFriend(paramStruct) then --如果不是好友，那么添加到好友列表去
						HallChatService:addOneFriend(paramStruct)
					end
					
					searchFriend = true
				end
			end
		end
		self:dispatchEvent(dispatchId,msgTable)
		dispatchId = nil --外边不用发送了
	
	elseif msgTable.Type == 3 or msgTable.Type == 4 then --3=比赛可邀请好友列表 4=私人房可邀请好友列表
		dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITE_FRIENDLIST
		dispachData = msgTable
		local gameFriends = DataCenter:getData(dispatchId)
		if not gameFriends then
			gameFriends = {}
			DataCenter:cacheData(dispatchId,gameFriends)
		end
		removeAll(gameFriends[msgTable.Type])
		gameFriends[msgTable.Type] = clone(msgTable)
		self:dispatchEvent(dispatchId)
	end

	return dispatchId,dispachData
end
--处理未读消息
function SocialContactProxy:handleBuddyTalkList(msgTable)
	wwdump(msgTable,"未读消息")
	
	if msgTable and next(msgTable.msgList) then
		self:dispatchEvent(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST) --现发送会话消息
		--写入数据库
		local hasChatMsg = false
		local HallChatService = self:getHallChatService()
		local unreadMsgs = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT)
		if not unreadMsgs then
			unreadMsgs = {}
			DataCenter:cacheData(CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT,unreadMsgs)
		end
		for _,v in pairs(msgTable.msgList) do
			local dataparams = {}
			dataparams.senderid = tonumber(v.FromUserID)
			dataparams.receiverid =  tonumber(UserDataCenter:getValueByKey("userid"))
			dataparams.title = tostring(v.FromUserID) --标题先用用户ID来标识
			dataparams.sendcontent = tostring(v.Content)
			dataparams.isread = 1 --默认未读
			dataparams.sessionType = tonumber(v.TalkType) --会话类型
			dataparams.extraData = tostring(v.TalkMsgID) --聊天消息ID
			HallChatService:addSession(dataparams)
		
			if v.TalkType == 0 then --0=好友聊天 1=好友申请（系统消息）
				--如果是好友聊天 那么还需要添加到聊天记录中去
				hasChatMsg = true
				local dataparams2 = {}
				dataparams2.senderid = tonumber(v.FromUserID)
				dataparams2.receiverid = tostring(UserDataCenter:getValueByKey("userid")) --接受者这里肯定是我拉
				dataparams2.sendcontent = tostring(v.Content)
				dataparams2.sendtime = tostring(v.CreateTime)
				HallChatService:addLog(dataparams2)
				unreadMsgs[tonumber(v.FromUserID)] = unreadMsgs[tonumber(v.FromUserID)] or {}
				table.insert(unreadMsgs[tonumber(v.FromUserID)],clone(v))
			end
		end
		if hasChatMsg then
			--这里聊天内容单独发送事件
			if CardPartnerCfg.innerEventComponent then
				CardPartnerCfg.innerEventComponent:dispatchEvent( {
					name = CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT;
				} )
			end
		end
	end
	
	
end
--处理社交请求返回
--[[	
	1=面对面加好友
	2=请求牌友列表
	3=比赛可邀请好友列表
	4=私人房可邀请好友列表
	5=搜索指定用户
	6=搜索后请求加好友
	7=请求未读聊天消息
	8=邀请好友进入私人房
	9=好友同意进入私人房
	10=好友拒绝进入私人房
--]]
function SocialContactProxy:handleSocialData(msgTable)
	local dispatchId = nil
	local dispachData = nil
	if msgTable.type == 8 then -- 收到 邀请进入私人房
		--这个时候要判断是在大厅还是牌局
		dispatchId = CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED
		local data = DataCenter:getData(dispatchId)
		if not data then
			data = {}
			DataCenter:cacheData(dispatchId,data)
		end
		if msgTable.StrParam1 and string.len(tonumber(msgTable.StrParam1))>0 then --msgTable.StrParam1 请求方用户ID
			--同样的ID不用重复添加
		--是否有重复的邀请
			local function hasSameGameInvited(dall,d1)
				local sameUser = false
				if dall then
					for _,v in pairs(dall) do
						if v and d1 and v.StrParam1 == d1.StrParam1 then
							sameUser = true
						end
					end
				end
				return sameUser
			end
			if not hasSameGameInvited(data,msgTable) then --没有重复邀请才回插入并且通知
				table.insert(data,clone(msgTable))
				self:dispatchEvent(dispatchId)
			end
		end
	elseif msgTable.type == 10 then -- 收到 拒绝邀请进入私人房
		wwlog(self.logTag,"谁谁谁拒绝了您的邀请："..tostring(msgTable.StrParam1))
		local friendInfo  = self:getFriendInfo(tostring(msgTable.StrParam1))
		local showName = tostring(msgTable.StrParam1)
		if friendInfo then
			showName = friendInfo.Nickname
		end
		local showStr = string.format(i18n:get('str_cardpartner','partner_invite_refuse'),showName)
		
		Toast:makeToast(showStr,1.0):show()
	elseif msgTable.Type == 9 then --收到 同意邀请进入私人房
		wwlog(self.logTag,"谁谁谁同意了您的邀请："..tostring(msgTable.StrParam1))
	end
	return dispatchId,dispachData
end

--获取好友信息
--@param friendId 好友的用户ID (不包括自己)
--@return 返回好友数据table 如果没有找到 返回null
function SocialContactProxy:getFriendInfo(friendId)
	local friendInfo = nil
	local friendLists = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_PARTNERLIST)
	if friendLists then
		for _,v in pairs(friendLists) do
			if v.UserID == tonumber(friendId) then
				friendInfo = v
				break
			end
		end
	end
	return friendInfo
end
function SocialContactProxy:getHallChatService()
	return ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
end
return SocialContactProxy