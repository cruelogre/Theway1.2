-------------------------------------------------------------------------
-- Desc:    orm_demo.lua
-- Author:  diyal.yin
-- Content: ORM映射 demo表
-- Copyright (c) diyal.yin Entertainment All right reserved.
-------------------------------------------------------------------------
local orm_demo = class('orm_demo', require('app.dataorm.Sqlite3Base'))

local T_SQL = {
  ['CREATE'] = 'CREATE TABLE orm_demo (id INTEGER PRIMARY KEY, content);', --创建

}

function orm_demo:ctor()
    cclog('orm_demo:ctor()')
    self:_tableExist('test')
end

--[[增加数据]]
function orm_demo:addData()

end
--[[删除数据]]
--[[修改数据]]
--[[查询数据]]
--[[查询总数据行]]

return orm_demo
