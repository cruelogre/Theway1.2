---------------------------------------------
-- WWSQLiteManage.lua
-- module : SQLite数据库管理类
-- auther : diyal.yin
-- comment: 主要负责数据库资源的初始化,开启,
--      关闭,以及获得DatabaseHelper帮助类操作
---------------------------------------------
local WWSQLiteManager = class("WWSQLiteManager")

local dataBaseName = 'wawagame.db'
local mDatabase

function WWSQLiteManager:ctor()
	cclog('WWSQLiteManage:ctor()')
end

function WWSQLiteManager:closeDatabase()
	if (dbInstance ~= nil) and (dbInstance:isopen()) then
	    assert(dbInstance:close() == sqlite3.OK)
	end
end

function WWSQLiteManager:openDatabase()
	if not mDatabase then
		local dbFilePath = device.writablePath..dataBaseName
		local isExist = cc.FileUtils:getInstance():isFileExist(dbFilePath)

		if isExist then
		    -- cclog('[SQLite] DB File is exist')
		else
		    cclog('[SQLite] DB File is not exist, created it')
		end

		mDatabase = sqlite3.open(dbFilePath)
	end
	return mDatabase
end

function WWSQLiteManager:onTableCreate( dbInstance, dbName )

end

function WWSQLiteManager:onUpgrade( dbInstance, nOldVersion, nNewVersion )

end

function WWSQLiteManager:getDbName()
	cclog('DB Name %s', dataBaseName)
	return dataBaseName
end

cc.exports.WWSQLiteManager = cc.exports.WWSQLiteManager or WWSQLiteManager:create()
return WWSQLiteManage