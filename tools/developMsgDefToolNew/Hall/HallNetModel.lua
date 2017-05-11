-------------------------------------------------------------------------
-- Desc:    大厅消息
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local HallNetModel = class("HallNetModel")

HallNetModel.MSG_ID = {
    Msg_GDBriefUserInfo_ret         = 0x60801, -- 395265, 简要玩家信息
    Msg_GDGameZoneList_Ret          = 0x60803, -- 395267, 游戏区列表
    Msg_GDHallAction_send           = 0x28010b, -- 2621707, 玩家游戏大厅操作
};

function HallNetModel:ctor(target)
-- 0x60801 = 395265 = Msg_GDBriefUserInfo_ret
-- 简要玩家信息
local Msg_GDBriefUserInfo_ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.Nickname = netWWBuffer:readLengthAndString()
    t_result.IconID = netWWBuffer:readInt()
    t_result.VIP = netWWBuffer:readShort()
    t_result.GameCash = netWWBuffer:readLengthAndString()
    t_result.Diamond = netWWBuffer:readLengthAndString()
    t_result.BindPhone = netWWBuffer:readLengthAndString()
    t_result.Region = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60801 = 395265 = Msg_GDBriefUserInfo_ret
-- 简要玩家信息线程函数解析关系注册
local Msg_GDBriefUserInfo_ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"string","Nickname"},
    {"int","IconID"},
    {"short","VIP"},
    {"string","GameCash"},
    {"string","Diamond"},
    {"string","BindPhone"},
    {"string","Region"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x60803 = 395267 = Msg_GDGameZoneList_Ret
-- 游戏区列表
local Msg_GDGameZoneList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.type = netWWBuffer:readInt()
    t_result.GameID = netWWBuffer:readShort()
    local count = netWWBuffer:readShort()
    local looptab1 = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.GameZoneID = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.ZoneWin = netWWBuffer:readChar()
        t_row1.Description = netWWBuffer:readLengthAndString()
        t_row1.Account = netWWBuffer:readInt()
        t_row1.fortuneBase = netWWBuffer:readInt()
        t_row1.FortuneMin = netWWBuffer:readInt()
        t_row1.FortuneMax = netWWBuffer:readInt()
        t_row1.PlayType = netWWBuffer:readShort()
        table.insert(looptab1, t_row1)
    end
    t_result["looptab1"] = looptab1


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60803 = 395267 = Msg_GDGameZoneList_Ret
-- 游戏区列表线程函数解析关系注册
local Msg_GDGameZoneList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","type"},
    {"short","GameID"},
    {"loop",
          {"short","looptab1"},
          {"int","GameZoneID"},
          {"string","Name"},
          {"char","ZoneWin"},
          {"string","Description"},
          {"int","Account"},
          {"int","fortuneBase"},
          {"int","FortuneMin"},
          {"int","FortuneMax"},
          {"short","PlayType"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x28010b = 2621707 = Msg_GDHallAction_send
-- 玩家游戏大厅操作
local Msg_GDHallAction_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDBriefUserInfo_ret, Msg_GDBriefUserInfo_ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDBriefUserInfo_ret,Msg_GDBriefUserInfo_ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDGameZoneList_Ret, Msg_GDGameZoneList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDGameZoneList_Ret,Msg_GDGameZoneList_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDHallAction_send, Msg_GDHallAction_send_write, target)


end

return HallNetModel
