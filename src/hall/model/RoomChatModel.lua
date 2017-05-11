-------------------------------------------------------------------------
-- Desc:    牌局聊天模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local RoomChatModel = class("RoomChatModel")

RoomChatModel.MSG_ID = {
    Msg_RoomChat_Ret                = 0x60809, -- 395273, 聊天返回
    Msg_RoomChat_send               = 0x60809, -- 395273, 聊天请求
};

function RoomChatModel:ctor(target)
-- 0x60809 = 395273 = Msg_RoomChat_Ret
-- 聊天返回
local Msg_RoomChat_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.GameID = netWWBuffer:readShort()
    t_result.RoomID = netWWBuffer:readInt()
    t_result.UserID = netWWBuffer:readInt()
    t_result.Content = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60809 = 395273 = Msg_RoomChat_Ret
-- 聊天返回线程函数解析关系注册
local Msg_RoomChat_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"short","GameID"},
    {"int","RoomID"},
    {"int","UserID"},
    {"string","Content"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x60809 = 395273 = Msg_RoomChat_send
-- 聊天请求
local Msg_RoomChat_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RoomChat_Ret, Msg_RoomChat_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RoomChat_Ret,Msg_RoomChat_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_RoomChat_send, Msg_RoomChat_send_write, target)


end

return RoomChatModel
