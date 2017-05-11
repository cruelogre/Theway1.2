-------------------------------------------------------------------------
-- Desc:    ChatLogDao.lua
-- Author:  cruleogre
-- Content: ORM映射 聊天记录
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ChatLogDao = class("ChatLogDao",require('app.dataorm.Sqlite3Base'))

local TableName = [[chat_log]] --日志记录表名字
local T_SQL = {
  ['CREATE'] = [[CREATE TABLE ]]..TableName..  --创建牌友数据表
								[[ (logid INTEGER PRIMARY KEY AUTOINCREMENT,
									senderid INTEGER NOT NULL DEFAULT 0,
									receiverid INTEGER NOT NULL DEFAULT 0,
									sendtime DATETIME DEFAULT CURRENT_TIMESTAMP,
									sendcontent VARCHAR,
									remark VARCHAR);]], 
 ['INSERT'] = [[insert into ]]..TableName..[[ VALUES (null,?,?,datetime('now','localtime'),?,?);]],
 ['INSERT_TIME'] = [[insert into ]]..TableName..[[ VALUES (null,?,?,?,?,?);]],
 ['DELETE_FRIEND'] = [[delete from ]]..TableName..[[ WHERE senderid in (?,?) and receiverid in (?,?);]], --删除和好友的聊天记录
 ['DELETE_FRIEND_BEFORE_TIME'] = [[delete from ]]..TableName..[[ WHERE senderid in (?,?) and receiverid in (?,?) and sendtime <= ?;]], --删除和好友的聊天记录 早于给定时间的
 ['COUNT'] = [[select count(*) as num from ]]..TableName..[[;]], --获取总条数
 ['COUNT_FIRNED'] = [[select count(*) as num from ]]..TableName..[[ WHERE senderid in (?,?) and receiverid in (?,?);]], --获取和好友聊天总条数
--select * from chat_log WHERE senderid in (1000,100305703) and receiverid in (1000,100305703) ORDER BY sendtime desc LIMIT 50 OFFSET 0
 ['SELECT_LIMIT'] = [[select * from (
					select * from ]]..TableName..[[ where senderid = %d and receiverid = %d union 
					select * from ]]..TableName..[[ where senderid = %d and receiverid = %d) 
					ORDER BY sendtime desc LIMIT ? OFFSET ?;]] --查询固定条数的数据
}

local Default_limit = 50 --默认显示数量
local Default_offset = 0 --默认间隔
function ChatLogDao:ctor()
	self.logTag = self.__cname..".lua"
	self:tableExistCheck()
end

function ChatLogDao:tableExistCheck()
	local tableExist = self:_tableExist(TableName)
	if not tableExist then
		--创建表
		wwlog(self.logTag,"创建数据表"..TableName)
		self:_execSQL(T_SQL.CREATE)
	end

end
--添加日志
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
--@key sendcontent 内容
--@key remark
function ChatLogDao:addLog(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"addLog 表不能为空")
		return false
	end
	if not dataStructParams.sendcontent or string.len(dataStructParams.sendcontent)<=0 then
		wwlog(self.logTag,"addLog 聊天记录不能为空")
		return false
	end
	local paraTable = {}
	table.insert(paraTable, dataStructParams.senderid or 0) 
	table.insert(paraTable, dataStructParams.receiverid or 0) 
	--如果有时间 这里只有未读消息插入才有 INSERT_TIME
	if dataStructParams.sendtime and string.len(dataStructParams.sendtime)>0  then
		table.insert(paraTable, dataStructParams.sendtime) 
	end
	table.insert(paraTable, dataStructParams.sendcontent)
	table.insert(paraTable, dataStructParams.remark or "")
	if dataStructParams.sendtime and string.len(dataStructParams.sendtime)>0 then
		return self:_insert(T_SQL.INSERT_TIME,paraTable)
	else
		return self:_insert(T_SQL.INSERT,paraTable)
	end
	
end
--获取日志 发送者id和接受者
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
--@key limitCount 限制取条数的长度
--@key offsetLen 从多少条开始
function ChatLogDao:getLog(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"getLog 表不能为空")
		return false
	end	
	local paraTable = {} 
	table.insert(paraTable, dataStructParams.limitCount or Default_limit)   --limit
	table.insert(paraTable, dataStructParams.offsetLen or Default_offset)   --offset
	local sql = string.format(T_SQL.SELECT_LIMIT,
				dataStructParams.receiverid or 0,
				dataStructParams.senderid or 0,
				dataStructParams.senderid or 0,
				dataStructParams.receiverid or 0)
	return self:_select(sql, paraTable)
	
end
--删除数据
--@param dataStructParams 数据封装
--@key senderid 发送id
--@key receiverid 接受者id
--@key datetime 时间 如果有时间  那么就删除时间早于给定时间的日志 否则直接删除两个人的料条记录
function ChatLogDao:removeLog(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"removeLog 表不能为空")
		return false
	end	
	local paraTable = {}
	table.insert(paraTable, dataStructParams.senderid or 0) 
	table.insert(paraTable, dataStructParams.receiverid or 0)
	table.insert(paraTable, dataStructParams.senderid or 0)  
	table.insert(paraTable, dataStructParams.receiverid or 0)
	if dataStructParams.datetime then
	--DELETE_FRIEND_BEFORE_TIME
		table.insert(paraTable, dataStructParams.datetime or 0)
		self:_delete(T_SQL.DELETE_FRIEND_BEFORE_TIME, paraTable)
	else
		self:_delete(T_SQL.DELETE_FRIEND, paraTable)
	end

end

--当前数据表的条数
function ChatLogDao:countAll()
	local temp = self:_query(T_SQL.COUNT)
	return tonumber(temp[1])
end
--查询和好友聊天的数量
--@param dataStructParams 数据封装
--@key senderid 发送者
--@key receiverid 接受者
function ChatLogDao:countFriendChat(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"countFriendChat 表不能为空")
		return false
	end	
	local paraTable = {}
	table.insert(paraTable, dataStructParams.senderid or 0) 
	table.insert(paraTable, dataStructParams.receiverid or 0)
	table.insert(paraTable, dataStructParams.senderid or 0)  
	table.insert(paraTable, dataStructParams.receiverid or 0)   
	local temp = self:_select(T_SQL.COUNT_FIRNED,paraTable)
	return tonumber(temp[1].num)
end

return ChatLogDao