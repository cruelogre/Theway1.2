-------------------------------------------------------------------------
-- Desc:    FriendListDao.lua
-- Author:  cruleogre
-- Content: ORM映射 好友列表消息
-- Desc: 该表在登录游戏的时候请求，其他情况下，只有删除和添加操作，查询是否为好友关系
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local FriendListDao = class("FriendListDao",require('app.dataorm.Sqlite3Base'))

local TableName = [[friend_list]] --好友列表表名字
local T_SQL = {
  ['CREATE'] = [[CREATE TABLE ]]..TableName..  --创建好友数据表
								[[ (friendid INTEGER PRIMARY KEY AUTOINCREMENT,
									userid INTEGER NOT NULL DEFAULT 0,
									owerid INTEGER NOT NULL DEFAULT 0,
									UNIQUE(userid,owerid));]], 
 ['INSERT'] = [[insert into ]]..TableName..[[ VALUES (null,?,?);]],

 ['DELETE_FRIEND'] = [[delete from ]]..TableName..[[ WHERE userid = ? and owerid = ?;]], --删除和好友关系
 ['CLEAR_FRIEND'] = [[delete from ]]..TableName..[[ WHERE owerid = ?;]], --清除好友关系
 ['COUNT_FIRNED'] = [[select count(*) as num from ]]..TableName..[[ where owerid = ?;]], --获取总条数
 ['CHECK_FRIEND'] = [[select count(*) as num from ]]..TableName..[[ WHERE userid = ? and owerid = ?;]], --判断是否为好友
}

function FriendListDao:ctor()
	self.logTag = self.__cname..".lua"
	self:tableExistCheck()
end

function FriendListDao:tableExistCheck()
	local tableExist = self:_tableExist(TableName)
	if not tableExist then
		--创建表
		wwlog(self.logTag,"创建数据表"..TableName)
		self:_execSQL(T_SQL.CREATE)
	end

end
--插入多个好友 插入的这些好友之前不能有重复的
--@param dataStructParams 好友们的集合
function FriendListDao:bundleAddFriend(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"bundleAddFriend 表不能为空")
		return false
	end
	local sqlStr = [[insert into ]]..TableName..[[ VALUES ]]
	local values = ""
	local len = table.nums(dataStructParams)
	for i,v in ipairs(dataStructParams) do
		--v.userid
		--v.owerid
		values = values..string.format("(null,%d,%d)",tonumber(v.userid),v.owerid)
		if i~=len then
			values = values..","
		else
			values = values..";"
			
		end
	end
	sqlStr = sqlStr..values
	self:_execSQL(sqlStr)
end

--添加好友关系
--@param dataStructParams 数据封装
--@key userid 好友ID
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function FriendListDao:addFriend(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"addFriend 表不能为空")
		return false
	end
	if not dataStructParams.userid  then
		wwlog(self.logTag,"userid 不能为空")
		return false
	end
	if not dataStructParams.owerid  then
		wwlog(self.logTag,"owerid 不能为空")
		return false
	end
	local paraTable = {}
	table.insert(paraTable, dataStructParams.userid ) 
	table.insert(paraTable, dataStructParams.owerid ) 
	return self:_insert(T_SQL.INSERT,paraTable)
end
--判断是否为好友
--@param dataStructParams 数据封装
--@key userid 好友ID
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function FriendListDao:checkFriend(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"checkFriend 表不能为空")
		return false
	end	
	local paraTable = {} 
	table.insert(paraTable, dataStructParams.userid )   --
	table.insert(paraTable, dataStructParams.owerid )   --
	local temp = self:_select(T_SQL.CHECK_FRIEND,paraTable)
	return tonumber(temp[1].num) > 0
	
end
--删除数据
--@param dataStructParams 数据封装
--@key userid 好友ID
--@key owerid 拥有者ID 一般为当前登录的玩家ID
function FriendListDao:removeFriend(dataStructParams)
	if type(dataStructParams) ~= 'table' or not next(dataStructParams) then
		wwlog(self.logTag,"removeLog 表不能为空")
		return false
	end	
	local paraTable = {}
	table.insert(paraTable, dataStructParams.userid ) 
	table.insert(paraTable, dataStructParams.owerid )

	self:_delete(T_SQL.DELETE_FRIEND, paraTable)
end

--清空数据
--@param owerid 拥有者ID 一般为当前登录的玩家ID
function FriendListDao:clearFriend(owerid)
	if not owerid then
		wwlog(self.logTag,"owerid 不能为空")
		return false
	end	
	local paraTable = {}
	table.insert(paraTable, owerid )

	self:_delete(T_SQL.CLEAR_FRIEND, paraTable)
end

--查询好友数量
--@param owerid 拥有者
function FriendListDao:countFriend(owerid)
	if not owerid then
		wwlog(self.logTag,"owerid 不能为空")
		return false
	end	
	local paraTable = {}
	table.insert(paraTable, owerid) 
	local temp = self:_select(T_SQL.COUNT_FIRNED,paraTable)
	return tonumber(temp[1].num)
end

return FriendListDao