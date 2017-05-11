-------------------------------------------------------------------------
-- Desc:    游戏牌局模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local GDGameModel = class("GDGameModel")

GDGameModel.MSG_ID = {
    Msg_GDTrusteeship_Ret           = 0x6010f, -- 393487, 续托管消息回复
    Msg_GDTrusteeship_send          = 0x6010f, -- 393487, 托管消息请求
    Msg_GDUserInfo_send             = 0x60804, -- 395268, 请求玩家数据
    Msg_GDGamePlayerInfo_Ret        = 0x60805, -- 395269, 对局中玩家数据
    Msg_GDGameStart_Ret             = 0x28010d, -- 2621709, 开局消息返回
    Msg_GDTribute_Ret               = 0x28010e, -- 2621710, 进贡返回
    Msg_GDTribute_Send              = 0x28010e, -- 2621710, 进贡请求
    Msg_GDExchangerCard_Ret         = 0x28010f, -- 2621711, 交换牌
    Msg_GDPlayCard_Ret              = 0x280110, -- 2621712, 打牌返回
    Msg_GDPlayCard_Send             = 0x280110, -- 2621712, 打牌请求
    Msg_GDGameOver_Ret              = 0x280111, -- 2621713, 游戏结束
    Msg_GDResumeGame_Ret            = 0x280112, -- 2621714, 游戏恢复
    Msg_GDTableUserState_Ret        = 0x280113, -- 2621715, 续局桌子上玩家状态改变通知
    Msg_GDHoldAward_Ret             = 0x280114, -- 2621716, 打到结算分奖励
};

function GDGameModel:ctor(target)
-- 0x6010f = 393487 = Msg_GDTrusteeship_Ret
-- 续托管消息回复
local Msg_GDTrusteeship_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    t_result.gameZoneID = netWWBuffer:readInt()
    t_result.gameplayID = netWWBuffer:readInt()
    t_result.UserID = netWWBuffer:readInt()
    t_result.Type = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x6010f = 393487 = Msg_GDTrusteeship_Ret
-- 续托管消息回复线程函数解析关系注册
local Msg_GDTrusteeship_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"int","gameZoneID"},
    {"int","gameplayID"},
    {"int","UserID"},
    {"char","Type"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x6010f = 393487 = Msg_GDTrusteeship_send
-- 托管消息请求
local Msg_GDTrusteeship_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60804 = 395268 = Msg_GDUserInfo_send
-- 请求玩家数据
local Msg_GDUserInfo_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60805 = 395269 = Msg_GDGamePlayerInfo_Ret
-- 对局中玩家数据
local Msg_GDGamePlayerInfo_Ret_read = function(reciveMsgId, netWWBuffer)

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
    t_result.Gender = netWWBuffer:readChar()
    t_result.Victories = netWWBuffer:readLengthAndString()
    t_result.GamePoint = netWWBuffer:readInt()
    t_result.NextLevelPoint = netWWBuffer:readInt()
    t_result.GameLevel = netWWBuffer:readShort()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60805 = 395269 = Msg_GDGamePlayerInfo_Ret
-- 对局中玩家数据线程函数解析关系注册
local Msg_GDGamePlayerInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"string","Nickname"},
    {"int","IconID"},
    {"short","VIP"},
    {"char","Gender"},
    {"string","Victories"},
    {"int","GamePoint"},
    {"int","NextLevelPoint"},
    {"short","GameLevel"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x28010d = 2621709 = Msg_GDGameStart_Ret
-- 开局消息返回
local Msg_GDGameStart_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readShort()
    t_result.ZoneWin = netWWBuffer:readChar()
    t_result.FortuneBase = netWWBuffer:readInt()
    t_result.Trump = netWWBuffer:readChar()
    t_result.ContinueFlag = netWWBuffer:readChar()
    t_result.Upgrade = netWWBuffer:readChar()
    t_result.PlayTimeout = netWWBuffer:readShort()
    t_result.JGTimeout = netWWBuffer:readShort()
    t_result.FHTimeout = netWWBuffer:readShort()
    t_result.Jingong = netWWBuffer:readChar()
    local count = netWWBuffer:readChar()
    local playerArr = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.card = netWWBuffer:readLengthAndString()
        t_row1.PlayLevel = netWWBuffer:readChar()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.VIP = netWWBuffer:readShort()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.Fortune = netWWBuffer:readLengthAndString()
        t_row1.Ranking = netWWBuffer:readChar()
        table.insert(playerArr, t_row1)
    end
    t_result["playerArr"] = playerArr

    t_result.NextPlayerID = netWWBuffer:readInt()
    t_result.TrumpCard = netWWBuffer:readChar()
    t_result.TCUserID1 = netWWBuffer:readInt()
    t_result.TCUserID2 = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x28010d = 2621709 = Msg_GDGameStart_Ret
-- 开局消息返回线程函数解析关系注册
local Msg_GDGameStart_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"short","PlayType"},
    {"char","ZoneWin"},
    {"int","FortuneBase"},
    {"char","Trump"},
    {"char","ContinueFlag"},
    {"char","Upgrade"},
    {"short","PlayTimeout"},
    {"short","JGTimeout"},
    {"short","FHTimeout"},
    {"char","Jingong"},
    {"loop",
          {"char","playerArr"},
          {"int","UserID"},
          {"string","card"},
          {"char","PlayLevel"},
          {"string","UserName"},
          {"int","IconID"},
          {"short","VIP"},
          {"char","Gender"},
          {"string","Fortune"},
          {"char","Ranking"},
    },
    {"int","NextPlayerID"},
    {"char","TrumpCard"},
    {"int","TCUserID1"},
    {"int","TCUserID2"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x28010e = 2621710 = Msg_GDTribute_Ret
-- 进贡返回
local Msg_GDTribute_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.Type = netWWBuffer:readChar()
    t_result.UserID = netWWBuffer:readInt()
    t_result.Card = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x28010e = 2621710 = Msg_GDTribute_Ret
-- 进贡返回线程函数解析关系注册
local Msg_GDTribute_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"char","Type"},
    {"int","UserID"},
    {"char","Card"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x28010e = 2621710 = Msg_GDTribute_Send
-- 进贡请求
local Msg_GDTribute_Send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x28010f = 2621711 = Msg_GDExchangerCard_Ret
-- 交换牌
local Msg_GDExchangerCard_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    local count = netWWBuffer:readChar()
    local exchangeArr = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.card = netWWBuffer:readChar()
        t_row1.FromUserID = netWWBuffer:readInt()
        t_row1.toUserID = netWWBuffer:readInt()
        table.insert(exchangeArr, t_row1)
    end
    t_result["exchangeArr"] = exchangeArr

    t_result.NextPlayerID = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x28010f = 2621711 = Msg_GDExchangerCard_Ret
-- 交换牌线程函数解析关系注册
local Msg_GDExchangerCard_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"loop",
          {"char","exchangeArr"},
          {"char","card"},
          {"int","FromUserID"},
          {"int","toUserID"},
    },
    {"int","NextPlayerID"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280110 = 2621712 = Msg_GDPlayCard_Ret
-- 打牌返回
local Msg_GDPlayCard_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.UserID = netWWBuffer:readInt()
    t_result.Card = netWWBuffer:readLengthAndString()
    t_result.ReplaceCard = netWWBuffer:readLengthAndString()
    t_result.NextPlayUseID = netWWBuffer:readInt()
    t_result.Flag = netWWBuffer:readChar()
    t_result.ParnerCard = netWWBuffer:readLengthAndString()
    t_result.PlayCardType = netWWBuffer:readChar()
    t_result.PlayCardValue = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280110 = 2621712 = Msg_GDPlayCard_Ret
-- 打牌返回线程函数解析关系注册
local Msg_GDPlayCard_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","UserID"},
    {"string","Card"},
    {"string","ReplaceCard"},
    {"int","NextPlayUseID"},
    {"char","Flag"},
    {"string","ParnerCard"},
    {"char","PlayCardType"},
    {"char","PlayCardValue"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280110 = 2621712 = Msg_GDPlayCard_Send
-- 打牌请求
local Msg_GDPlayCard_Send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x280111 = 2621713 = Msg_GDGameOver_Ret
-- 游戏结束
local Msg_GDGameOver_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.FortuneTax = netWWBuffer:readInt()
    t_result.Upgrade = netWWBuffer:readChar()
    local count = netWWBuffer:readChar()
    local players = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Ranking = netWWBuffer:readChar()
        t_row1.Card = netWWBuffer:readLengthAndString()
        t_row1.Fortune = netWWBuffer:readLengthAndString()
        t_row1.TFortune = netWWBuffer:readLengthAndString()
        table.insert(players, t_row1)
    end
    t_result["players"] = players


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280111 = 2621713 = Msg_GDGameOver_Ret
-- 游戏结束线程函数解析关系注册
local Msg_GDGameOver_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","FortuneTax"},
    {"char","Upgrade"},
    {"loop",
          {"char","players"},
          {"int","UserID"},
          {"char","Ranking"},
          {"string","Card"},
          {"string","Fortune"},
          {"string","TFortune"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x280112 = 2621714 = Msg_GDResumeGame_Ret
-- 游戏恢复
local Msg_GDResumeGame_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.GameZoneID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readShort()
    t_result.ZoneWin = netWWBuffer:readChar()
    t_result.FortuneBase = netWWBuffer:readInt()
    t_result.Trump = netWWBuffer:readChar()
    t_result.ContinueFlag = netWWBuffer:readChar()
    t_result.Upgrade = netWWBuffer:readChar()
    t_result.PlayTimeout = netWWBuffer:readShort()
    t_result.JGTimeout = netWWBuffer:readShort()
    t_result.Jingong = netWWBuffer:readChar()
    t_result.Status = netWWBuffer:readChar()
    t_result.LastPlayUserID = netWWBuffer:readInt()
    t_result.LastPlayCards = netWWBuffer:readLengthAndString()
    t_result.NextPlayUseID = netWWBuffer:readInt()
    t_result.NextPlayTimeout = netWWBuffer:readShort()
    local count = netWWBuffer:readChar()
    local players = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.UserType = netWWBuffer:readChar()
        t_row1.Card = netWWBuffer:readLengthAndString()
        t_row1.PlayLevel = netWWBuffer:readChar()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.VIP = netWWBuffer:readShort()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.Fortune = netWWBuffer:readLengthAndString()
        t_row1.Ranking = netWWBuffer:readChar()
        t_row1.JGCard = netWWBuffer:readChar()
        t_row1.RecvCard = netWWBuffer:readChar()
        table.insert(players, t_row1)
    end
    t_result["players"] = players

    t_result.RoomMultiple = netWWBuffer:readInt()
    t_result.LastRank1User = netWWBuffer:readInt()
    t_result.RecordCard = netWWBuffer:readChar()
    t_result.RemainCard = netWWBuffer:readLengthAndData()
    t_result.GameZoneName = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280112 = 2621714 = Msg_GDResumeGame_Ret
-- 游戏恢复线程函数解析关系注册
local Msg_GDResumeGame_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","GameZoneID"},
    {"short","PlayType"},
    {"char","ZoneWin"},
    {"int","FortuneBase"},
    {"char","Trump"},
    {"char","ContinueFlag"},
    {"char","Upgrade"},
    {"short","PlayTimeout"},
    {"short","JGTimeout"},
    {"char","Jingong"},
    {"char","Status"},
    {"int","LastPlayUserID"},
    {"string","LastPlayCards"},
    {"int","NextPlayUseID"},
    {"short","NextPlayTimeout"},
    {"loop",
          {"char","players"},
          {"int","UserID"},
          {"char","UserType"},
          {"string","Card"},
          {"char","PlayLevel"},
          {"string","UserName"},
          {"int","IconID"},
          {"short","VIP"},
          {"char","Gender"},
          {"string","Fortune"},
          {"char","Ranking"},
          {"char","JGCard"},
          {"char","RecvCard"},
    },
    {"int","RoomMultiple"},
    {"int","LastRank1User"},
    {"char","RecordCard"},
    {"byteArray","RemainCard"},
    {"string","GameZoneName"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280113 = 2621715 = Msg_GDTableUserState_Ret
-- 续局桌子上玩家状态改变通知
local Msg_GDTableUserState_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.Type = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280113 = 2621715 = Msg_GDTableUserState_Ret
-- 续局桌子上玩家状态改变通知线程函数解析关系注册
local Msg_GDTableUserState_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"char","Type"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280114 = 2621716 = Msg_GDHoldAward_Ret
-- 打到结算分奖励
local Msg_GDHoldAward_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.gameZoneID = netWWBuffer:readInt()
    t_result.trump = netWWBuffer:readChar()
    t_result.result = netWWBuffer:readChar()
    local count = netWWBuffer:readShort()
    local magics = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MagicName = netWWBuffer:readLengthAndString()
        t_row1.MagicID = netWWBuffer:readInt()
        t_row1.MagicCount = netWWBuffer:readInt()
        t_row1.MagicFID = netWWBuffer:readInt()
        table.insert(magics, t_row1)
    end
    t_result["magics"] = magics


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280114 = 2621716 = Msg_GDHoldAward_Ret
-- 打到结算分奖励线程函数解析关系注册
local Msg_GDHoldAward_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"int","gameZoneID"},
    {"char","trump"},
    {"char","result"},
    {"loop",
          {"short","magics"},
          {"string","MagicName"},
          {"int","MagicID"},
          {"int","MagicCount"},
          {"int","MagicFID"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDTrusteeship_Ret, Msg_GDTrusteeship_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDTrusteeship_Ret,Msg_GDTrusteeship_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDTrusteeship_send, Msg_GDTrusteeship_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDUserInfo_send, Msg_GDUserInfo_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDGamePlayerInfo_Ret, Msg_GDGamePlayerInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDGamePlayerInfo_Ret,Msg_GDGamePlayerInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDGameStart_Ret, Msg_GDGameStart_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDGameStart_Ret,Msg_GDGameStart_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDTribute_Ret, Msg_GDTribute_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDTribute_Ret,Msg_GDTribute_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDTribute_Send, Msg_GDTribute_Send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDExchangerCard_Ret, Msg_GDExchangerCard_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDExchangerCard_Ret,Msg_GDExchangerCard_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDPlayCard_Ret, Msg_GDPlayCard_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDPlayCard_Ret,Msg_GDPlayCard_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDPlayCard_Send, Msg_GDPlayCard_Send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDGameOver_Ret, Msg_GDGameOver_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDGameOver_Ret,Msg_GDGameOver_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDResumeGame_Ret, Msg_GDResumeGame_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDResumeGame_Ret,Msg_GDResumeGame_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDTableUserState_Ret, Msg_GDTableUserState_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDTableUserState_Ret,Msg_GDTableUserState_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDHoldAward_Ret, Msg_GDHoldAward_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDHoldAward_Ret,Msg_GDHoldAward_Ret_Threadread())


end

return GDGameModel
