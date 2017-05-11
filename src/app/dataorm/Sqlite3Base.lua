-------------------------------------------------------------------------
-- Desc:    Sqlite3Base.lua
-- Author:  diyal.yin
-- Content: Sqlite3基类  模板工具类
--   该类提供了数据库操作常用的CRUD，以及各种复杂条件匹配，分页，排序操作
-- Copyright (c) diyal.yin Entertainment All right reserved.
-------------------------------------------------------------------------

local Sqlite3Base = class("Sqlite3Base")

function Sqlite3Base:ctor()
	cclog('Sqlite3Base:ctor()')
end

function Sqlite3Base:getDbManager()
    return WWSQLiteManager
end

--[[表存在检查]]
function Sqlite3Base:_tableExist( tableName )

    assert( type(tableName) == 'string')

    local _db = WWSQLiteManager:openDatabase()

    local bTableIsExist = true

    local sqlStr = "SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ? "

    local stmt = _db:prepare(sqlStr)
    stmt:bind_values(tableName)
    stmt:step()

    local nCount = stmt:get_uvalues()
    if nCount == 0 then
    	bTableIsExist = false
    end
    stmt:finalize()

    WWSQLiteManager:closeDatabase()

    if DEBUG > 1 then 
        cclog('table %s is exist %s', tableName, bTableIsExist)
    end 

    return bTableIsExist
end

--[[运行SQL]]
function Sqlite3Base:_execSQL( sql )
    assert(type(sql) == 'string')
    local _db = WWSQLiteManager:openDatabase()
    assert(_db:exec(sql))
    WWSQLiteManager:closeDatabase()
end

--[[
stmt方式执行SQL
@param sql
@param tableParas 参数表
@param paramNums 参数对照表 
--]]
function Sqlite3Base:stmtExec( sql, tableParas, paramNums)
    local _db = WWSQLiteManager:openDatabase()
    if DEBUG > 1 then 
        cclog(sql)
    end 
    local stmt = _db:prepare(sql)
    assert(stmt, _db:errmsg())

    if tableParas then
        assert(stmt:bind_values(unpack(tableParas)) == sqlite3.OK)
    end
    if paramNums ~= nil then
        assert(stmt:bind_parameter_count() == paramNums)
    end

    local ret = stmt:step()
    WWSQLiteManager:closeDatabase()

    return ret
end

--[[
插入数据模板
注意参数个数一定要正确
@param sql 
@param tableParas 参数列表
@param paramNums 参数限制个数判断
@return ret 返回值 1：成功  0：失败
--]]
function Sqlite3Base:_insert( sql, tableParas, paramNums)

    --索引检查
    return self:stmtExec(sql, tableParas, paramNums)
end

--[[
删除数据
--]]
function Sqlite3Base:_delete( sql, tableParas, paramNums)
    return self:stmtExec(sql, tableParas, paramNums)
end

--[[
修改数据带参数
--]]
function Sqlite3Base:_update( sql, tableParas)
    return self:stmtExec(sql, tableParas, paramNums)
end

--[[
修改数据，不带参数
--]]
function Sqlite3Base:_updateUnParas( sql )
    return self:stmtExec(sql)
end

--[[
根据SQL查询，带泛型参数，支持填写参数
--]]
function Sqlite3Base:_select( sql, tableParas )

    local resultTable = {}

    local _db = WWSQLiteManager:openDatabase()
    if DEBUG > 1 then 
        cclog(sql)
    end 
    local stmt = _db:prepare(sql)
    assert(stmt, _db:errmsg())
    assert(stmt:bind_values(unpack(tableParas)) == sqlite3.OK)

    for row in stmt:nrows() do
        if DEBUG > 1 then 
            cclog(row.id, row.content)
        end 
        table.insert(resultTable, row)
    end

    WWSQLiteManager:closeDatabase()

    -- ccdump(resultTable, '[Sqlite Modelue] select result')

    return resultTable
end

--[[
根据SQL查询，不带指定参数
需要在外部直接拼接好SQL
--]]
function Sqlite3Base:_query( sql )

    local resultTable = {}

    local _db = WWSQLiteManager:openDatabase()

    for row in _db:nrows(sql) do
        -- ccdump(row, 'row')
        table.insert(resultTable, row)
    end

    WWSQLiteManager:closeDatabase()

    -- ccdump(resultTable, '[Sqlite Modelue] select result')

    return resultTable
end
return Sqlite3Base
