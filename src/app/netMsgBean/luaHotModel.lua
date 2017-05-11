-------------------------------------------------------------------------
-- Desc:    lua热更新模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local luaHotModel = class("luaHotModel")

luaHotModel.MSG_ID = {
    Msg_LUAhotData_Ret              = 0x10148, -- 65864, 响应lua更新数据
    Msg_LUAhotData_send             = 0x10148, -- 65864, 请求lua更新数据
};

function luaHotModel:ctor(target)
-- 0x10148 = 65864 = Msg_LUAhotData_Ret
-- 响应lua更新数据
local Msg_LUAhotData_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.hallID = netWWBuffer:readInt()
    t_result.Op = netWWBuffer:readShort()
    t_result.Sp = netWWBuffer:readInt()
    t_result.Version = netWWBuffer:readLengthAndString()
    t_result.Subversion = netWWBuffer:readLengthAndString()
    t_result.LuaModel = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x10148 = 65864 = Msg_LUAhotData_Ret
-- 响应lua更新数据线程函数解析关系注册
local Msg_LUAhotData_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","hallID"},
    {"short","Op"},
    {"int","Sp"},
    {"string","Version"},
    {"string","Subversion"},
    {"string","LuaModel"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x10148 = 65864 = Msg_LUAhotData_send
-- 请求lua更新数据
local Msg_LUAhotData_send_write = function(sendTable)

    if nil == sendTable then
       flog("[Wawagame Error] sendTable must not nil")
       return nil
    end

    local nIndex = 0
    local autoPlus = function(nNum)
       nIndex = nIndex + 1
       return nIndex
    end

    local wb = ww.WWBuffer:create()
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_LUAhotData_Ret, Msg_LUAhotData_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_LUAhotData_Ret,Msg_LUAhotData_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_LUAhotData_send, Msg_LUAhotData_send_write, target)


end

return luaHotModel
