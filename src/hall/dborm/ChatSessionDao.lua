-------------------------------------------------------------------------
-- Desc:    ChatSessionDao.lua
-- Author:  cruleogre
-- Content: ORM映射 会话表
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ChatSessionDao = class("ChatSessionDao",require('app.dataorm.Sqlite3Base'))

local TableName = [[chat_session]] -- 会话表

local T_SQL = {
	['CREATE'] = [[CREATE TABLE ]]..TableName..  --创建会话表（会话ID，最近更新时间，标题【暂定存昵称或者ID】，内容，是否已经读取标志）
								[[ ( sessionid INTEGER PRIMARY KEY, 
									recenttime DATETIME DEFAULT CURRENT_TIMESTAMP,
									senderid INTEGER NOT NULL DEFAULT 0,
									receiverid INTEGER NOT NULL DEFAULT 0,
									title VARCHAR,
									content VARCHAR,
									isread INTEGER,
									sessionType INTEGER,
									extraData VARCHAR DEFAULT "");]], 
	['INSERT'] = [[insert INTO ]]..TableName..[[ VALUES (null,datetime('now','localtime'),?,?,?,?,?,?,?);]],
	['UPDATE'] = [[update ]]..TableName..[[ SET isread = ? WHERE senderid = ?;]], --修改
	
	['UPDATE_CONTENT'] = [[update ]]..TableName..[[ SET isread = ?,recenttime =datetime('now','localtime'),content=? WHERE senderid = ?;]], --修改
	['UPDATE_CONTENT_ADD_READCOUNT'] = [[update ]]..TableName..[[ SET isread = isread+ 1,recenttime =datetime('now','localtime'),content=?,extraData=? WHERE senderid = ?;]], --修改
	['COUNT_SESSION'] = [[select count(*) as num from ]]..TableName..[[ WHERE senderid = ? and sessionType = ?;]], 
	['HAS_UNREAD_SESSION'] = [[select count(*) as num from ]]..TableName..[[ WHERE isread > 0;]], 
	['REMOVE_SESSION'] = [[delete from ]]..TableName..[[ WHERE senderid = ? and sessionType = ?;]], --删除和某人的对话
	['REMOVE_SESSION_TIME'] = [[delete from ]]..TableName..[[ WHERE senderid != ? and recenttime < ?;]], --删除时间小于某个值的对话(暂时不开放)
	['SELECT_LIMIT'] = [[select * from ]]..TableName..[[ WHERE receiverid = ? ORDER BY recenttime DESC LIMIT ? OFFSET ?;]], --查询
}
local Default_limit = 10000 --默认显示数量
local Default_offset = 0 --默认间隔
function ChatSessionDao:ctor()
	self.logTag = self.__cname..".lua"
	self:tableExistCheck()
end

function ChatSessionDao:tableExistCheck()
	
	local tableExist = self:_tableExist(TableName)
	if not tableExist then
		--创建表
		wwlog(self.logTag,"创建数据表"..TableName)
		self:_execSQL(T_SQL.CREATE)
	end
end
--安全添加会话
--@param dataStructParams 数据封装
--@key senderid 会话对象ID
--@key title 标题
--@key sendcontent 内容
--@key isread 是否已经阅读
--@key sessionType 会话类型  0=好友聊天 1=好友申请 2=同意加好友 3=拒绝加好友
function ChatSessionDao:safeAddSession(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"safeAddSession 表不能为空")
		return false
	end
	local sessionCount = self:countSession(dataStructParams.senderid,dataStructParams.sessionType)
	if sessionCount and sessionCount > 0 then
		self:updateSession(dataStructParams)
	else
		self:addSession(dataStructParams)
	end
end

--添加会话
--@param dataStructParams 数据封装
--@key senderid 会话对象ID
--@key receiverid 会话接受的ID  一般情况下是自己
--@key title 标题
--@key sendcontent 内容
--@key isread 是否已经阅读
--@key sessionType 会话类型  0=好友聊天 1=好友申请 2=同意加好友 3=拒绝加好友
--@key extraData 额外数据 sessionType=1 好友申请 的时候表示 TalkMsgID
function ChatSessionDao:addSession(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"addSession 表不能为空")
		return false
	end
	local paraTable = {}
	table.insert(paraTable, dataStructParams.senderid or 0) 
	table.insert(paraTable, dataStructParams.receiverid or 0) 
	table.insert(paraTable, dataStructParams.title or "")   
	table.insert(paraTable, dataStructParams.sendcontent or "")  
	table.insert(paraTable, dataStructParams.isread or 0)   
	table.insert(paraTable, dataStructParams.sessionType or -1)
	table.insert(paraTable, dataStructParams.extraData or "")  
	self:_insert(T_SQL.INSERT,paraTable)
end
--查询所有会话
--@param dataStructParams 数据封装
--@key receiverid 接受者的ID 这里主要考虑切换帐号的问题
--@key limitCount 限制取条数的长度
--@key offsetLen 从多少条开始
function ChatSessionDao:querySession(dataStructParams)
	local paraTable = {}
	
	table.insert(paraTable, dataStructParams and (tonumber(dataStructParams.receiverid) or 0) or 0)   --limit
	table.insert(paraTable, dataStructParams and (dataStructParams.limitCount or Default_limit) or Default_limit)   --limit
	table.insert(paraTable, dataStructParams and (dataStructParams.offsetLen or Default_offset) or Default_offset)   --offset
	return self:_select(T_SQL.SELECT_LIMIT, paraTable)
end
--更新会话
--@param dataStructParams 数据封装
--@key title 标题
--@key sendcontent 内容
--@key extraData 额外数据
--@key isread 是否已经阅读
function ChatSessionDao:updateSession(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"updateSession 表不能为空")
		return false
	end
	local paraTable = {}
	
	table.insert(paraTable, dataStructParams.isread or 0)
	if dataStructParams.sendcontent then
		table.insert(paraTable, dataStructParams.sendcontent)
		table.insert(paraTable, dataStructParams.extraData)  
	end
	table.insert(paraTable, dataStructParams.senderid or 0) 
	if dataStructParams.sendcontent then
		if tonumber(dataStructParams.isread)> 0 then
			table.remove(paraTable,1) --第一个是isread 增长的时候不需要了
			self:_update(T_SQL.UPDATE_CONTENT_ADD_READCOUNT, paraTable)
		else
			self:_update(T_SQL.UPDATE_CONTENT, paraTable)
		end
		
	else

		self:_update(T_SQL.UPDATE, paraTable)
		
	end
	
end
--是否有会话
--@param senderid会话对象ID
--@param sessionType 会话类型  0 好友聊天 1 好友申请
function ChatSessionDao:countSession(senderid,sessionType)
	local paraTable = {}
	table.insert(paraTable, senderid or 0)
	table.insert(paraTable, sessionType or 0)
	local temp = self:_select(T_SQL.COUNT_SESSION,paraTable)
	return temp[1] and tonumber(temp[1].num) or 0
end
--是否有未读消息
function ChatSessionDao:hasUnreadMsg()
	local temp = self:_select(T_SQL.HAS_UNREAD_SESSION,{})
	return temp[1] and tonumber(temp[1].num)>0 or false
end

--删除某个会话
--@param senderid会话对象ID
--@param sessionType 会话类型  0 好友聊天 1 好友申请
function ChatSessionDao:removeSession(senderid,sessionType)
	local paraTable = {}
	table.insert(paraTable, senderid or 0)
	table.insert(paraTable, sessionType or 0)
	self:_delete(T_SQL.REMOVE_SESSION, paraTable)
end

return ChatSessionDao