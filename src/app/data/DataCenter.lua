-------------------------------------------------------------------------
-- Desc:    
-- Author:  
-- Date:    2016.08.13
-- Last:    
-- Content:  游戏中的数据管理，用户数据等
-- 20160826  用户信息管理  
-- 				DataCenter:getUserdataInstance():getValueByKey("nickname")  --获得用户昵称
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local DataCenter = class("DataCenter")
local UserDataCenter = import(".UserDataCenter","app.data."):create()

function DataCenter:ctor()
	self.cdataTable = {}
end

function DataCenter:setUserLoginData(userTable)

	UserDataCenter:initUserData()
	UserDataCenter:setUserInfoByTable(userTable)
	UserDataCenter:setGetUserInfo(true)

	-- wwdump(UserDataCenter:getUserInfo())
end

function DataCenter:cacheData(dataKey,dataTable)
	if self.cdataTable[dataKey] and type(self.cdataTable[dataKey])=="table" then
		removeAll(self.cdataTable[dataKey])
	end
	if dataTable and type(dataTable)=="table" then
		self.cdataTable[dataKey] = dataTable
	end
end

function DataCenter:updateData(dataKey,dataIndex,dataValue)
	if self.cdataTable[dataKey] and type(self.cdataTable[dataKey])=="table" then
		local cdata = self.cdataTable[dataKey]
		cdata[dataIndex] = dataValue
	end
end

function DataCenter:clearData(dataKey)
	if self.cdataTable and self.cdataTable[dataKey] then
		self.cdataTable[dataKey] = {}
	end	
end
function DataCenter:getData(dataKey)
	return self.cdataTable[dataKey]
end

--获取用户数据管理对象
function DataCenter:getUserdataInstance()
	return UserDataCenter
end

cc.exports.DataCenter = cc.exports.DataCenter or DataCenter:create()
return cc.exports.DataCenter