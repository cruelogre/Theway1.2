-------------------------------------------------------------------------
-- Desc:    HallChatService
-- Author:  cruleogre
-- Content: 大厅中聊天的控制器
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local HallChatService = class("HallChatService", require("packages.mvc.Controller"))

local ChatSessionDao = require("hall.dborm.ChatSessionDao")
local ChatLogDao = require("hall.dborm.ChatLogDao")
local FriendListDao = require("hall.dborm.FriendListDao")
local LOG_CHECK_Threshold = 200 --监测删除日志时的阈值
local LOG_REMAIN_Threshold = 50 --保存的日志最大阈值
function HallChatService:ctor()
	self.logTag = self.__cname..".lua"
	self.sessionDao = nil
	self.logDao = nil
	self:initDao()
end
function HallChatService:initDao()
	self.sessionDao = ChatSessionDao:create()
	self.logDao = ChatLogDao:create()
	self.friendDao = FriendListDao:create()
end
--添加日志
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
--@key sendcontent 内容
function HallChatService:addLog(dataStructParams)
	if not self.logDao then
		wwlog(self.logDao,"添加日志异常，DAO未初始化")
		return
	end
	--先查询
	local queryParams = {}
	queryParams.senderid = dataStructParams.senderid
	queryParams.receiverid = dataStructParams.receiverid
	queryParams.limitCount = 1
	queryParams.offsetLen = LOG_CHECK_Threshold --
	local fixData = self.logDao:getLog(queryParams) --查看是否有超过存储阈值的
	if fixData and next(fixData) then
		queryParams.offsetLen = LOG_REMAIN_Threshold --查询超过删除阈值的
		fixData = self.logDao:getLog(queryParams)
		if fixData and next(fixData) then
			--删除数据
			local removeParams = {}
			removeParams.senderid = dataStructParams.senderid
			removeParams.receiverid = dataStructParams.receiverid
			removeParams.datetime = fixData[1].sendtime --删除时间早于删除阈值点的日志
			self.logDao:removeLog(removeParams)
		end

	end
	self.logDao:addLog(dataStructParams)
end
--删除了某人的聊天记录 这个在后边添加了删除好友的时候，删除好友会话和记录
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
function HallChatService:removeLog(dataStructParams)
	if not self.logDao then
		wwlog(self.logDao,"删除日志异常，DAO未初始化")
		return
	end
	self.logDao:removeLog(dataStructParams)
end

--获取日志 发送者id和接受者
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
--@key limitCount 限制取条数的长度 默认50
--@key offsetLen 从多少条开始 默认 0
function HallChatService:getLog(dataStructParams)
	if not self.logDao then
		wwlog(self.logDao,"获取日志异常，DAO未初始化")
		return nil
	end
	return self.logDao:getLog(dataStructParams)
end
--获取和好友的聊天数量
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
function HallChatService:countLog(dataStructParams)

	if not self.logDao then
		wwlog(self.logDao,"获取和好友的聊天数量异常，DAO未初始化")
		return nil
	end
	return self.logDao:countFriendChat(dataStructParams)
end

--安全添加会话
--@param dataStructParams 数据封装
--@key senderid 会话对象ID
--@key title 标题
--@key sendcontent 内容
--@key isread 是否已经阅读
--@key sessionType 会话类型
function HallChatService:addSession(dataStructParams)
	if not self.sessionDao then
		wwlog(self.sessionDao,"安全添加会话异常，DAO未初始化")
		return
	end
	self.sessionDao:safeAddSession(dataStructParams)
end
--获取会话长度
--@param senderid 会话的用户ID
--@param sessionType 会话类型
function HallChatService:getSessionCount(senderid,sessionType)
	if not self.sessionDao then
		wwlog(self.sessionDao,"安全添加会话异常，DAO未初始化")
		return -1 --异常
	end
	return self.sessionDao:countSession(senderid,sessionType)
end
--读取是否有未读消息
function HallChatService:hasUnreadMsg()
	if not self.sessionDao then
		wwlog(self.sessionDao,"读取未读消息异常，DAO未初始化")
		return false --异常
	end
	return self.sessionDao:hasUnreadMsg()
end

--更新会话
--@param dataStructParams 数据封装
--@key sendcontent 内容
--@key isread 是否已经阅读
function HallChatService:updateSession(dataStructParams)
	if not self.sessionDao then
		wwlog(self.sessionDao,"更新会话异常，DAO未初始化")
		return
	end
	self.sessionDao:safeAddSession(dataStructParams)
end
--删除某个会话
--@param senderid 会话对象ID
--@param sessionType 会话类型
function HallChatService:removeSession(senderid,sessionType)
	if not self.sessionDao then
		wwlog(self.sessionDao,"安全添加会话异常，DAO未初始化")
		return
	end
	self.sessionDao:removeSession(senderid,sessionType)
end
--查询所有会话
--@param dataStructParams 数据封装
--@key limitCount 限制取条数的长度
--@key offsetLen 从多少条开始
function HallChatService:getSession(dataStructParams)
	if not self.sessionDao then
		wwlog(self.sessionDao,"获取会话异常，DAO未初始化")
		return nil
	end
	return self.sessionDao:querySession(dataStructParams)
end

--添加好友关系
--@param dataStructParams 数据封装
--@key userid 好友ID
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function HallChatService:addOneFriend(dataStructParams)
	if not self.friendDao then
		wwlog(self.friendDao,"添加好友异常，DAO未初始化")
		return nil
	end
	return self.friendDao:addFriend(dataStructParams)
end
--批量添加好友关系
--@param dataStructParams 数据封装
function HallChatService:addBundleFriends(dataStructParams)
	if not self.friendDao then
		wwlog(self.friendDao,"批量添加好友异常，DAO未初始化")
		return nil
	end
	return self.friendDao:bundleAddFriend(dataStructParams)
end
--删除数据
--@param dataStructParams 数据封装
--@key userid 好友ID 如果好友ID是nil 则表示清空好友
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function HallChatService:removeFriend(dataStructParams)
	if not self.friendDao then
		wwlog(self.friendDao,"删除友异常，DAO未初始化")
		return nil
	end
	if dataStructParams.userid ~= nil then
		return self.friendDao:removeFriend(dataStructParams)
	else
		return self.friendDao:clearFriend(dataStructParams.owerid)
	end
	
end


--判断是否为好友
--@param dataStructParams 数据封装
--@key userid 好友ID
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function HallChatService:checkFriend(dataStructParams)
	if not self.friendDao then
		wwlog(self.friendDao,"判断好友异常，DAO未初始化")
		return nil
	end
	return self.friendDao:checkFriend(dataStructParams)
end

--查询我有多少好友
--@param owerid 拥有者ID 一般为当前登录的玩家ID
function HallChatService:countFriend(owerid)
	if not self.friendDao then
		wwlog(self.friendDao,"好友数量异常，DAO未初始化")
		return 0
	end
	return self.friendDao:countFriend(owerid)
end
function HallChatService:finalizer()
	self.sessionDao = nil
	self.logDao = nil
	self.friendDao = nil
end
return HallChatService