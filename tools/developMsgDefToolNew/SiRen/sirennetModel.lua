-------------------------------------------------------------------------
-- Desc:    私人房模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local sirennetModel = class("sirennetModel")

sirennetModel.MSG_ID = {
    Msg_GDRoomSet_Ret               = 0x60815, -- 395285, 玩法局数配置
    Msg_GDCreateRoomReq_send        = 0x60816, -- 395286, 创建房间
    Msg_GDRoomInfo_Ret              = 0x60817, -- 395287, 返回房间信息
    Msg_GDRoomAct_send              = 0x60818, -- 395288, 房间操作
    Msg_GDRoomResult_Ret            = 0x60819, -- 395289, 私人房最终结算
    Msg_GDRoomHistory_Ret           = 0x6081a, -- 395290, 私人房历史记录
    Msg_GDRoomNotify_Ret            = 0x6081b, -- 395291, 房间通知消息
};

function sirennetModel:ctor(target)
-- 0x60815 = 395285 = Msg_GDRoomSet_Ret
-- 玩法局数配置
local Msg_GDRoomSet_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local roomConf = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.PlayType = netWWBuffer:readShort()
        t_row1.PlayData = netWWBuffer:readLengthAndString()
        t_row1.RoomCard = netWWBuffer:readLengthAndString()
        table.insert(roomConf, t_row1)
    end
    t_result["roomConf"] = roomConf


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60815 = 395285 = Msg_GDRoomSet_Ret
-- 玩法局数配置线程函数解析关系注册
local Msg_GDRoomSet_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"loop",
          {"short","roomConf"},
          {"short","PlayType"},
          {"string","PlayData"},
          {"string","RoomCard"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x60816 = 395286 = Msg_GDCreateRoomReq_send
-- 创建房间
local Msg_GDCreateRoomReq_send_write = function(sendTable)

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
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60817 = 395287 = Msg_GDRoomInfo_Ret
-- 返回房间信息
local Msg_GDRoomInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    t_result.GameID = netWWBuffer:readInt()
    t_result.RoomID = netWWBuffer:readInt()
    t_result.MasterID = netWWBuffer:readInt()
    t_result.Playtype = netWWBuffer:readShort()
    t_result.PlayData = netWWBuffer:readShort()
    t_result.DWinPoint = netWWBuffer:readChar()
    t_result.MultipleData = netWWBuffer:readLengthAndString()
    t_result.RoomCardCount = netWWBuffer:readShort()
    local count = netWWBuffer:readShort()
    local userInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.Nickname = netWWBuffer:readLengthAndString()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.Status = netWWBuffer:readChar()
        table.insert(userInfo, t_row1)
    end
    t_result["userInfo"] = userInfo


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60817 = 395287 = Msg_GDRoomInfo_Ret
-- 返回房间信息线程函数解析关系注册
local Msg_GDRoomInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"int","GameID"},
    {"int","RoomID"},
    {"int","MasterID"},
    {"short","Playtype"},
    {"short","PlayData"},
    {"char","DWinPoint"},
    {"string","MultipleData"},
    {"short","RoomCardCount"},
    {"loop",
          {"short","userInfo"},
          {"int","UserID"},
          {"int","IconID"},
          {"string","Nickname"},
          {"char","Gender"},
          {"char","Status"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x60818 = 395288 = Msg_GDRoomAct_send
-- 房间操作
local Msg_GDRoomAct_send_write = function(sendTable)

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
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60819 = 395289 = Msg_GDRoomResult_Ret
-- 私人房最终结算
local Msg_GDRoomResult_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    t_result.RoomID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local result = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Nickname = netWWBuffer:readLengthAndString()
        t_row1.Play = netWWBuffer:readShort()
        t_row1.Winp = netWWBuffer:readLengthAndString()
        t_row1.Rank1 = netWWBuffer:readShort()
        t_row1.Boom = netWWBuffer:readShort()
        t_row1.StrFlush = netWWBuffer:readShort()
        t_row1.Score = netWWBuffer:readInt()
        table.insert(result, t_row1)
    end
    t_result["result"] = result


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60819 = 395289 = Msg_GDRoomResult_Ret
-- 私人房最终结算线程函数解析关系注册
local Msg_GDRoomResult_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"int","RoomID"},
    {"loop",
          {"short","result"},
          {"int","UserID"},
          {"string","Nickname"},
          {"short","Play"},
          {"string","Winp"},
          {"short","Rank1"},
          {"short","Boom"},
          {"short","StrFlush"},
          {"int","Score"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x6081a = 395290 = Msg_GDRoomHistory_Ret
-- 私人房历史记录
local Msg_GDRoomHistory_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local history = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.RoomID = netWWBuffer:readInt()
        t_row1.DateStr = netWWBuffer:readLengthAndString()
        t_row1.Playtype = netWWBuffer:readShort()
        t_row1.PlayData = netWWBuffer:readShort()
        t_row1.MultipleData = netWWBuffer:readLengthAndString()
        local count2 = netWWBuffer:readShort()
        local playerInfo = {}
        for i=1, count2 do
            local t_row2 = {}
            t_row2.UserID = netWWBuffer:readInt()
            t_row2.Nickname = netWWBuffer:readLengthAndString()
            t_row2.Play = netWWBuffer:readShort()
            t_row2.Winp = netWWBuffer:readLengthAndString()
            t_row2.Rank1 = netWWBuffer:readShort()
            t_row2.Boom = netWWBuffer:readShort()
            t_row2.StrFlush = netWWBuffer:readShort()
            t_row2.Score = netWWBuffer:readInt()
            table.insert(playerInfo, t_row2)
        end
        t_row1["playerInfo"] = playerInfo

        table.insert(history, t_row1)
    end
    t_result["history"] = history


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x6081a = 395290 = Msg_GDRoomHistory_Ret
-- 私人房历史记录线程函数解析关系注册
local Msg_GDRoomHistory_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"loop",
          {"short","history"},
          {"int","RoomID"},
          {"string","DateStr"},
          {"short","Playtype"},
          {"short","PlayData"},
          {"string","MultipleData"},
    {"loop",
          {"short","playerInfo"},
          {"int","UserID"},
          {"string","Nickname"},
          {"short","Play"},
          {"string","Winp"},
          {"short","Rank1"},
          {"short","Boom"},
          {"short","StrFlush"},
          {"int","Score"},
    },
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x6081b = 395291 = Msg_GDRoomNotify_Ret
-- 房间通知消息
local Msg_GDRoomNotify_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    t_result.RoomID = netWWBuffer:readInt()
    t_result.Param1 = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.GameID = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x6081b = 395291 = Msg_GDRoomNotify_Ret
-- 房间通知消息线程函数解析关系注册
local Msg_GDRoomNotify_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"int","RoomID"},
    {"int","Param1"},
    {"string","Desc"},
    {"int","GameID"},

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDRoomSet_Ret, Msg_GDRoomSet_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDRoomSet_Ret,Msg_GDRoomSet_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDCreateRoomReq_send, Msg_GDCreateRoomReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDRoomInfo_Ret, Msg_GDRoomInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDRoomInfo_Ret,Msg_GDRoomInfo_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDRoomAct_send, Msg_GDRoomAct_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDRoomResult_Ret, Msg_GDRoomResult_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDRoomResult_Ret,Msg_GDRoomResult_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDRoomHistory_Ret, Msg_GDRoomHistory_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDRoomHistory_Ret,Msg_GDRoomHistory_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDRoomNotify_Ret, Msg_GDRoomNotify_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDRoomNotify_Ret,Msg_GDRoomNotify_Ret_Threadread())


end

return sirennetModel
