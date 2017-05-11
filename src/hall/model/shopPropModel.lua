-------------------------------------------------------------------------
-- Desc:    道具商城协议
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local shopPropModel = class("shopPropModel")

shopPropModel.MSG_ID = {
    Msg_BuyMagicReq_send            = 0x110301, -- 1114881, 购买道具请求
    Msg_BuyMagicResp_Ret            = 0x110302, -- 1114882, 购买道具回复
    Msg_UseMagicResp_Ret            = 0x110305, -- 1114885, 道具使用情况
    Msg_MagicStoreReq_send          = 0x110b01, -- 1116929, 请求游戏道具商店数据
    Msg_StoreMagicList_Ret          = 0x110b02, -- 1116930, 游戏商店商品列表
};

function shopPropModel:ctor(target)
-- 0x110301 = 1114881 = Msg_BuyMagicReq_send
-- 购买道具请求
local Msg_BuyMagicReq_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x110302 = 1114882 = Msg_BuyMagicResp_Ret
-- 购买道具回复
local Msg_BuyMagicResp_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.MagicID = netWWBuffer:readInt()
    t_result.DestUserID = netWWBuffer:readInt()
    t_result.BuyPrice = netWWBuffer:readInt()
    t_result.result = netWWBuffer:readChar()
    t_result.SpareTime = netWWBuffer:readInt()
    t_result.UseCash = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.CashType = netWWBuffer:readChar()
    t_result.Count = netWWBuffer:readShort()
    t_result.bankID = netWWBuffer:readInt()
    t_result.gameCash = netWWBuffer:readLongLong()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110302 = 1114882 = Msg_BuyMagicResp_Ret
-- 购买道具回复线程函数解析关系注册
local Msg_BuyMagicResp_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","MagicID"},
    {"int","DestUserID"},
    {"int","BuyPrice"},
    {"char","result"},
    {"int","SpareTime"},
    {"int","UseCash"},
    {"string","Desc"},
    {"char","CashType"},
    {"short","Count"},
    {"int","bankID"},
    {"long long","gameCash"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x110305 = 1114885 = Msg_UseMagicResp_Ret
-- 道具使用情况
local Msg_UseMagicResp_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.MagicID = netWWBuffer:readInt()
    t_result.FromUserID = netWWBuffer:readInt()
    t_result.ToUserID = netWWBuffer:readInt()
    t_result.Param = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110305 = 1114885 = Msg_UseMagicResp_Ret
-- 道具使用情况线程函数解析关系注册
local Msg_UseMagicResp_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","MagicID"},
    {"int","FromUserID"},
    {"int","ToUserID"},
    {"string","Param"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x110b01 = 1116929 = Msg_MagicStoreReq_send
-- 请求游戏道具商店数据
local Msg_MagicStoreReq_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x110b02 = 1116930 = Msg_StoreMagicList_Ret
-- 游戏商店商品列表
local Msg_StoreMagicList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    t_result.StoreID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local StoreMagicInfos = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.StoreMagicID = netWWBuffer:readInt()
        t_row1.MagicID = netWWBuffer:readInt()
        t_row1.Money = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.Description = netWWBuffer:readLengthAndString()
        t_row1.Introduce = netWWBuffer:readLengthAndString()
        table.insert(StoreMagicInfos, t_row1)
    end
    t_result["StoreMagicInfos"] = StoreMagicInfos

    local fids = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.magicCount = netWWBuffer:readInt()
        t_row1.fid = netWWBuffer:readInt()
        table.insert(fids, t_row1)
    end
    t_result["fids"] = fids

    local Expires = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Expire = netWWBuffer:readLengthAndString()
        table.insert(Expires, t_row1)
    end
    t_result["Expires"] = Expires

    t_result.bankID = netWWBuffer:readInt()
    local marketMoneys = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.marketMoney = netWWBuffer:readInt()
        table.insert(marketMoneys, t_row1)
    end
    t_result["marketMoneys"] = marketMoneys

    local dayLimits = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.dayLimit = netWWBuffer:readInt()
        t_row1.monthLimit = netWWBuffer:readInt()
        t_row1.buystatus = netWWBuffer:readChar()
        table.insert(dayLimits, t_row1)
    end
    t_result["dayLimits"] = dayLimits


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110b02 = 1116930 = Msg_StoreMagicList_Ret
-- 游戏商店商品列表线程函数解析关系注册
local Msg_StoreMagicList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"int","StoreID"},
    {"loop",
          {"short","StoreMagicInfos"},
          {"int","StoreMagicID"},
          {"int","MagicID"},
          {"int","Money"},
          {"string","Name"},
          {"string","Description"},
          {"string","Introduce"},
    },
    {"loop",
          {"none","fids"},
          {"int","magicCount"},
          {"int","fid"},
    },
    {"loop",
          {"none","Expires"},
          {"string","Expire"},
    },
    {"int","bankID"},
    {"loop",
          {"none","marketMoneys"},
          {"int","marketMoney"},
    },
    {"loop",
          {"none","dayLimits"},
          {"int","dayLimit"},
          {"int","monthLimit"},
          {"char","buystatus"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_BuyMagicReq_send, Msg_BuyMagicReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_BuyMagicResp_Ret, Msg_BuyMagicResp_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_BuyMagicResp_Ret,Msg_BuyMagicResp_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_UseMagicResp_Ret, Msg_UseMagicResp_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_UseMagicResp_Ret,Msg_UseMagicResp_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_MagicStoreReq_send, Msg_MagicStoreReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_StoreMagicList_Ret, Msg_StoreMagicList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_StoreMagicList_Ret,Msg_StoreMagicList_Ret_Threadread())


end

return shopPropModel
