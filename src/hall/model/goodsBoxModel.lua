-------------------------------------------------------------------------
-- Desc:    游戏物品箱模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local goodsBoxModel = class("goodsBoxModel")

goodsBoxModel.MSG_ID = {
    Msg_EquipReq_send               = 0x110801, -- 1116161, 请求用户比赛物品箱的各种门票,门票碎片数据
    Msg_EquipList_Ret               = 0x110802, -- 1116162, 用户比赛物品箱的各种门票,门票碎片
    Msg_MatchEquipInfo_Ret          = 0x110803, -- 1116163, 比赛物品的说明信息
    Msg_GameEquipInfo_Ret           = 0x110804, -- 1116164, 游戏物品的详细说明信息
    Msg_GameEquipNumber_Ret         = 0x110805, -- 1116165, 游戏物品的数量信息
    Msg_GameEquipDesc_Ret           = 0x110807, -- 1116167, 游戏道具的详细信息
};

function goodsBoxModel:ctor(target)
-- 0x110801 = 1116161 = Msg_EquipReq_send
-- 请求用户比赛物品箱的各种门票,门票碎片数据
local Msg_EquipReq_send_write = function(sendTable)

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

    return wb
end

-- 0x110802 = 1116162 = Msg_EquipList_Ret
-- 用户比赛物品箱的各种门票,门票碎片
local Msg_EquipList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.GameID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local goodsInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserEquipID = netWWBuffer:readInt()
        t_row1.EquipID = netWWBuffer:readInt()
        t_row1.EquipCount = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.ExpireTime = netWWBuffer:readLengthAndString()
        t_row1.Fid = netWWBuffer:readInt()
        table.insert(goodsInfo, t_row1)
    end
    t_result["goodsInfo"] = goodsInfo

    local magicType = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MagicType = netWWBuffer:readChar()
        table.insert(magicType, t_row1)
    end
    t_result["magicType"] = magicType

    local status = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Status = netWWBuffer:readChar()
        table.insert(status, t_row1)
    end
    t_result["status"] = status


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110802 = 1116162 = Msg_EquipList_Ret
-- 用户比赛物品箱的各种门票,门票碎片线程函数解析关系注册
local Msg_EquipList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"int","GameID"},
    {"loop",
          {"short","goodsInfo"},
          {"int","UserEquipID"},
          {"int","EquipID"},
          {"int","EquipCount"},
          {"string","Name"},
          {"string","ExpireTime"},
          {"int","Fid"},
    },
    {"loop",
          {"none","magicType"},
          {"char","MagicType"},
    },
    {"loop",
          {"none","status"},
          {"char","Status"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110803 = 1116163 = Msg_MatchEquipInfo_Ret
-- 比赛物品的说明信息
local Msg_MatchEquipInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.EquipID = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.introduce = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110803 = 1116163 = Msg_MatchEquipInfo_Ret
-- 比赛物品的说明信息线程函数解析关系注册
local Msg_MatchEquipInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","EquipID"},
    {"string","Desc"},
    {"string","introduce"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x110804 = 1116164 = Msg_GameEquipInfo_Ret
-- 游戏物品的详细说明信息
local Msg_GameEquipInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.ObjectID = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.introduce = netWWBuffer:readLengthAndString()
    t_result.Name = netWWBuffer:readLengthAndString()
    t_result.totalCount = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local goodsInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.magicCount = netWWBuffer:readInt()
        t_row1.Expire = netWWBuffer:readLengthAndString()
        table.insert(goodsInfo, t_row1)
    end
    t_result["goodsInfo"] = goodsInfo

    t_result.type = netWWBuffer:readChar()
    local goodsInfo2 = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserEquipID = netWWBuffer:readInt()
        t_row1.magicID = netWWBuffer:readInt()
        t_row1.FID = netWWBuffer:readInt()
        t_row1.expireMinute = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        table.insert(goodsInfo2, t_row1)
    end
    t_result["goodsInfo2"] = goodsInfo2


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110804 = 1116164 = Msg_GameEquipInfo_Ret
-- 游戏物品的详细说明信息线程函数解析关系注册
local Msg_GameEquipInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","ObjectID"},
    {"string","Desc"},
    {"string","introduce"},
    {"string","Name"},
    {"int","totalCount"},
    {"loop",
          {"short","goodsInfo"},
          {"int","magicCount"},
          {"string","Expire"},
    },
    {"char","type"},
    {"loop",
          {"none","goodsInfo2"},
          {"int","UserEquipID"},
          {"int","magicID"},
          {"int","FID"},
          {"int","expireMinute"},
          {"string","Name"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110805 = 1116165 = Msg_GameEquipNumber_Ret
-- 游戏物品的数量信息
local Msg_GameEquipNumber_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.gameID = netWWBuffer:readInt()
    t_result.Fid = netWWBuffer:readInt()
    t_result.Count = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110805 = 1116165 = Msg_GameEquipNumber_Ret
-- 游戏物品的数量信息线程函数解析关系注册
local Msg_GameEquipNumber_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","gameID"},
    {"int","Fid"},
    {"int","Count"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x110807 = 1116167 = Msg_GameEquipDesc_Ret
-- 游戏道具的详细信息
local Msg_GameEquipDesc_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.gameID = netWWBuffer:readInt()
    t_result.magicID = netWWBuffer:readInt()
    t_result.FID = netWWBuffer:readInt()
    t_result.Name = netWWBuffer:readLengthAndString()
    t_result.introduce = netWWBuffer:readLengthAndString()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.magicType = netWWBuffer:readChar()
    t_result.ExpireType = netWWBuffer:readChar()
    t_result.Expire = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local goodsInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.magicID = netWWBuffer:readInt()
        t_row1.FID = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.introduce = netWWBuffer:readLengthAndString()
        t_row1.Desc = netWWBuffer:readLengthAndString()
        t_row1.magicType = netWWBuffer:readChar()
        t_row1.ExpireType = netWWBuffer:readChar()
        t_row1.Expire = netWWBuffer:readInt()
        t_row1.magicCount = netWWBuffer:readInt()
        table.insert(goodsInfo, t_row1)
    end
    t_result["goodsInfo"] = goodsInfo


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110807 = 1116167 = Msg_GameEquipDesc_Ret
-- 游戏道具的详细信息线程函数解析关系注册
local Msg_GameEquipDesc_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","gameID"},
    {"int","magicID"},
    {"int","FID"},
    {"string","Name"},
    {"string","introduce"},
    {"string","Desc"},
    {"char","magicType"},
    {"char","ExpireType"},
    {"int","Expire"},
    {"loop",
          {"short","goodsInfo"},
          {"int","magicID"},
          {"int","FID"},
          {"string","Name"},
          {"string","introduce"},
          {"string","Desc"},
          {"char","magicType"},
          {"char","ExpireType"},
          {"int","Expire"},
          {"int","magicCount"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_EquipReq_send, Msg_EquipReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_EquipList_Ret, Msg_EquipList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_EquipList_Ret,Msg_EquipList_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_MatchEquipInfo_Ret, Msg_MatchEquipInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_MatchEquipInfo_Ret,Msg_MatchEquipInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GameEquipInfo_Ret, Msg_GameEquipInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GameEquipInfo_Ret,Msg_GameEquipInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GameEquipNumber_Ret, Msg_GameEquipNumber_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GameEquipNumber_Ret,Msg_GameEquipNumber_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GameEquipDesc_Ret, Msg_GameEquipDesc_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GameEquipDesc_Ret,Msg_GameEquipDesc_Ret_Threadread())


end

return goodsBoxModel
