-------------------------------------------------------------------------
-- Desc:    sqlite3test.lua
-- Author:  sqlite3测试
-- Copyright (c) wawagame Entertainment All right reserved.
   -- local sqlite3 = require("app.dataorm.sqlite3test")
    -- sqlite3:getDBVersion()
    -- sqlite3:openDB()
    -- sqlite3:insert('numbers', {10086, 10086,"diyal"})
    -- sqlite3:test()
    -- sqlite3:test2()
    -- sqlite3:test3()
    -- sqlite3:aggregate()
    -- sqlite3:crudTest()
    -- sqlite3:statement()
    -- sqlite3:tracing()
    -- sqlite3:batchsql()
    -- sqlite3:updateHook()
-------------------------------------------------------------------------
local sqlite3 = require("sqlite3")

local sqlite3test = class('sqlite3test')

local _db, _vm  --数据库句柄， 数据库状态

--[[获取版本号]]
function sqlite3test:getDBVersion()
    cclog("[SQLite] DB version : "..sqlite3.version())
end

function sqlite3test:openDB()
    local dbFilePath = device.writablePath..'test.db'
    local isExist = cc.FileUtils:getInstance():isFileExist(dbFilePath)

    _db = sqlite3.open(dbFilePath)
    if isExist then
        cclog('[SQLite] DB File is exist')
    else
        cclog('[SQLite] DB File is not exist, created it')
        --初始化表结构
        self:initDB()
    end
end

function sqlite3test:initDB()
    -- Demo表DDL语句
    local t_demo_sql=
    [=[
        CREATE TABLE numbers(num1,num2,str);
        INSERT INTO numbers VALUES(1,11,"ABC");
        INSERT INTO numbers VALUES(2,22,"DEF");
        INSERT INTO numbers VALUES(3,33,"UVW");
        INSERT INTO numbers VALUES(4,44,"XYZ");
        SELECT * FROM numbers;
    ]=]

    local showrow = function(udata,cols,values,names)
        assert(udata == 't_demo_create')

        -- for i=1,cols do
        --    cclog('%s |-> %s',names[i],values[i]) 
        -- end
        cclog('[SQLite] %s rows %s', udata,table.concat( values, "-"))

        return 0
    end
    _db:exec(t_demo_sql, showrow, 't_demo_create')
end

function sqlite3test:insert( tableName, tableParas)

    local t_demo_sql=
    [=[
        INSERT INTO tableName VALUES(tableParas);
        SELECT * FROM numbers;
    ]=]

    local showrow = function(udata,cols,values,names)
        assert(udata == 't_demo_create')

        -- for i=1,cols do
        --    cclog('%s |-> %s',names[i],values[i]) 
        -- end
        cclog('[SQLite] %s rows %s', udata,table.concat( values, "-"))

        return 0
    end
    local ret = _db:exec(t_demo_sql, showrow, 't_demo_create')
    if ret ~= sqlite3.OK then
        cclog('error')
    end
end

--[[test]]
function sqlite3test:test()
    local sqlite3 = require('sqlite3')

    local width = 78
    local function line(pref, suff)  --格式化函数
        pref = pref or ''
        suff = suff or ''
        local len = width - 2 - string.len(pref) - string.len(suff)
        cclog(pref .. string.rep('_', len) .. suff)
    end

    local db, vm
    local assert_, assert = assert, function (test)
        if (not test) then
            error(db:errmsg(), 2)
        end
    end

    -- os.remove('test.db')
    db = sqlite3.open('test.db')

    line(nil, 'db:exec')
    db:exec('CREATE TABLE t(a, b)')

    line(nil, 'prepare')
    vm = db:prepare('insert into t values(?, :bork)')
    assert(vm, db:errmsg())
    assert(vm:bind_parameter_count() == 2)
    assert(vm:bind_values(2, 4) == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ 'pork', bork = 'nono' } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ bork = 'sisi' } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ 1 } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:finalize() == sqlite3.OK)

    line("select * from t", 'db:exec')

    -- assert(db:exec('select * from t', function (ud, ncols, values, names)
    --     cclog(table.unpack(values))
    --     return sqlite3.OK
    -- end) == sqlite3.OK)

    db:exec('select * from t', function (ud, ncols, values, names)
        cclog(
            table.concat(
                  { unpack(values)}
                )
        )

        return sqlite3.OK
    end)

    line("select * from t", 'db:prepare')

    vm = db:prepare('select * from t')
    assert(vm, db:errmsg())
    cclog(vm:get_unames())
    while (vm:step() == sqlite3.ROW) do
        cclog(vm:get_uvalues())
    end
    assert(vm:finalize() == sqlite3.OK)

    line('udf', 'scalar')

    local function do_query(sql)
        local r
        local vm = db:prepare(sql)
        assert(vm, db:errmsg())
        cclog('====================================')
        cclog(vm:get_unames())
        cclog('------------------------------------')
        r = vm:step()
        while (r == sqlite3.ROW) do
            cclog(vm:get_uvalues())
            r = vm:step()
        end
        assert(r == sqlite3.DONE)
        assert(vm:finalize() == sqlite3.OK)
        cclog('====================================')
    end

    local function udf1_scalar(ctx, v)
        local ud = ctx:user_data()
        ud.r = (ud.r or '') .. tostring(v)
        ctx:result_text(ud.r)
    end

    db:create_function('udf1', 1, udf1_scalar, { })
    do_query('select udf1(a) from t')


    line('udf', 'aggregate')

    local function udf2_aggregate(ctx, ...)
        local ud = ctx:get_aggregate_data()
        if (not ud) then
            ud = {}
            ctx:set_aggregate_data(ud)
        end
        ud.r = (ud.r or 0) + 2
    end

    local function udf2_aggregate_finalize(ctx, v)
        local ud = ctx:get_aggregate_data()
        ctx:result_number(ud and ud.r or 0)
    end

    db:create_aggregate('udf2', 1, udf2_aggregate, udf2_aggregate_finalize, { })
    do_query('select udf2(a) from t')

    -- if (true) then
    --     line(nil, '100 insert exec')
    --     db:exec('delete from t')
    --     local t = os.time()
    --     for i = 1, 100 do
    --         db:exec('insert into t values('..i..', '..(i * 2 * -1^i)..')')
    --     end
    --     print('elapsed: '..(os.time() - t))
    --     do_query('select count(*) from t')

    --     line(nil, '100000 insert exec T')
    --     db:exec('delete from t')
    --     local t = os.time()
    --     db:exec('begin')
    --     for i = 1, 100000 do
    --         db:exec('insert into t values('..i..', '..(i * 2 * -1^i)..')')
    --     end
    --     db:exec('commit')
    --     print('elapsed: '..(os.time() - t))
    --     do_query('select count(*) from t')

    --     line(nil, '100000 insert prepare/bind T')
    --     db:exec('delete from t')
    --     local t = os.time()
    --     local vm = db:prepare('insert into t values(?, ?)')
    --     db:exec('begin')
    --     for i = 1, 100000 do
    --         vm:bind_values(i, i * 2 * -1^i)
    --         vm:step()
    --         vm:reset()
    --     end
    --     vm:finalize()
    --     db:exec('commit')
    --     print('elapsed: '..(os.time() - t))
    --     do_query('select count(*) from t')

    -- end

    line(nil, "db:close")

    local filePath = cc.FileUtils:getInstance():fullPathForFilename('test.db')
    cclog('path: '..filePath)

    assert(db:close() == sqlite3.OK)
end

function sqlite3test:test2()
    _db = sqlite3.open('test.db')
    cclog('[SQLite] db:exec')
    _db:exec('CREATE TABLE t(a, b)')

    cclog('[SQLite] prepare')
    _vm = _db:prepare('insert into t values(?, :bork)')
    assert(_vm, _db:errmsg())
    assert(_vm:bind_parameter_count() == 2)
    assert(_vm:bind_values(2, 4) == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ 'pork', bork = 'nono' } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ bork = 'sisi' } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ 1 } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:finalize() == sqlite3.OK)

    cclog("[SQLite] select * from t")

    -- assert(_db:exec('select * from t', 
    --     function (ud, ncols, values, names)
    --         cclog(table.unpack(values))
    --         return sqlite3.OK
    --     end) == sqlite3.OK
    -- )

    local ret = _db:exec('select * from t', 
            function (ud, ncols, values, names)
                cclog('[SQLite] ' .. table.unpack(values))
                return sqlite3.OK
            end)

end

--[[test 3]]
function sqlite3test:test3()

end

--[[聚合函数]]
function sqlite3test:aggregate()
    assert( _db:exec "CREATE TABLE test (col1, col2)" )
    assert( _db:exec "INSERT INTO test VALUES (1, 2)" )
    assert( _db:exec "INSERT INTO test VALUES (2, 4)" )
    assert( _db:exec "INSERT INTO test VALUES (3, 6)" )
    assert( _db:exec "INSERT INTO test VALUES (4, 8)" )
    assert( _db:exec "INSERT INTO test VALUES (5, 10)" )

    do
        local square_error_sum = 0

        local function step(ctx, a, b)
          local error        = a - b
          local square_error = error * error
          square_error_sum   = square_error_sum + square_error
        end

        local function final(ctx)
          ctx:result_number( square_error_sum / ctx:aggregate_count() )
        end

        assert( _db:create_aggregate("my_stats", 2, step, final) )
    end

    for my_stats in _db:urows("SELECT my_stats(col1, col2) FROM test")
    do 
        cclog("my_stats:%d", my_stats) 
    end
end

--[[CRUD]]
function sqlite3test:crudTest()
   local sqlite3 = require("sqlite3") --加载模块

   local db = sqlite3.open_memory() --开辟内存数据库

   db:exec[[ CREATE TABLE test (id INTEGER PRIMARY KEY, content) ]] --执行DDL语句

   local stmt = db:prepare[[ INSERT INTO test VALUES (:key, :value) ]] --前导声明

   stmt:bind_names({  
                        key = 1,
                        value = "Hello World"    
                   }) --参数绑定

   -- step()
   -- This is the top-level implementation of sqlite3_step().  Call
   -- sqlite3Step() to do most of the work.  If a schema error occurs,
   -- call sqlite3Reprepare() and try again.
   stmt:step()  --执行
   stmt:reset()  --重置
   stmt:bind_names({  key = 2,  value = "Hello Lua"      } ) 
   stmt:step()
   stmt:reset()
   stmt:bind_names({  key = 3,  value = "Hello Sqlite3"  })
   stmt:step()
   stmt:finalize()

   for row in db:nrows("SELECT * FROM test") do
      cclog("%d, %s", row.id, row.content)
   end 
end

--[[statement]]
function sqlite3test:statement()
    local sqlite3 = require("sqlite3")

    local db = sqlite3.open_memory()

    db:exec[[
      CREATE TABLE test (
        id        INTEGER PRIMARY KEY,
        content   VARCHAR
      );
    ]]

    local insert_stmt = assert( db:prepare("INSERT INTO test VALUES (NULL, ?)") )

    local function insert(data)  --封装一个insert函数
      insert_stmt:bind_values(data)
      insert_stmt:step()
      insert_stmt:reset()
    end

    local select_stmt = assert( db:prepare("SELECT * FROM test") )

    local function select()  --封装一个查询函数
      for row in select_stmt:nrows() do
        cclog("%d, %s",row.id, row.content)
      end
    end

    insert("Hello World")
    cclog("First:")
    select()

    insert("Hello Lua")
    cclog("Second:")
    select()

    insert("Hello Sqlite3")
    cclog("Third:")
    select()
end

--[[tracing]]
function sqlite3test:tracing()
    local sqlite3 = require("sqlite3")

    local db = sqlite3.open_memory()

    db:trace( function(ud, sql)
      cclog("[Sqlite Trace]: %s", sql)
    end )

    db:exec[=[
      CREATE TABLE test ( id INTEGER PRIMARY KEY, content VARCHAR );

      INSERT INTO test VALUES (NULL, 'Hello World');
      INSERT INTO test VALUES (NULL, 'Hello Lua');
      INSERT INTO test VALUES (NULL, 'Hello Sqlite3');
    ]=]

    for row in db:rows("SELECT * FROM test") do
      cclog(row.content)
    end
end

--[[batch sql str]]
--批处理
function sqlite3test:batchsql()

    local sqlite3 = require("sqlite3")

    local db = sqlite3.open_memory()

    local sql=[=[
          CREATE TABLE numbers(num1,num2,str);
          INSERT INTO numbers VALUES(1,11,"ABC");
          INSERT INTO numbers VALUES(2,22,"DEF");
          INSERT INTO numbers VALUES(3,33,"UVW");
          INSERT INTO numbers VALUES(4,44,"XYZ");
          SELECT * FROM numbers;
        ]=]
    local showrow = function(udata,cols,values,names)
        assert(udata=='test_udata')

        for i=1,cols do
           cclog('%s |-> %s',names[i],values[i]) 
        end

        return 0
    end
    db:exec(sql,showrow,'test_udata')
end

--[[update hook]]
--表事件监听   eg:有在一张表插入数据，则读取更新数据
function sqlite3test:updateHook()
    local sqlite3 = require("sqlite3")

    local db = sqlite3.open_memory()

    local optbl = { 
                [sqlite3.UPDATE] = "UPDATE";
                [sqlite3.INSERT] = "INSERT";
                [sqlite3.DELETE] = "DELETE"
            }

    setmetatable(optbl,
        {
            __index=function(t,n) 
                return string.format("Unknown op %d",n) 
            end
        })

    local udtbl = {0, 0, 0}

    db:update_hook( function(ud, op, dname, tname, rowid)
      cclog("Sqlite Update Hook: %s,%s,%s,%d", optbl[op], dname, tname, rowid)
    end, udtbl)

    db:exec[[
      CREATE TABLE test ( id INTEGER PRIMARY KEY, content VARCHAR );

      INSERT INTO test VALUES (NULL, 'Hello World');
      INSERT INTO test VALUES (NULL, 'Hello Lua');
      INSERT INTO test VALUES (NULL, 'Hello Sqlite3');
      UPDATE test SET content = 'Hello Again World' WHERE id = 1;
      DELETE FROM test WHERE id = 2;
    ]]

    for row in db:nrows("SELECT * FROM test") do
       cclog('%d %s', row.id, row.content)
    end
end

return sqlite3test
