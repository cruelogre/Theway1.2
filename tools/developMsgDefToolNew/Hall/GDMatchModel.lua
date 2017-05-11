-------------------------------------------------------------------------
-- Desc:    游戏比赛模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local GDMatchModel = class("GDMatchModel")

GDMatchModel.MSG_ID = {
    Msg_GDMatchData_Send            = 0x280301, -- 2622209, 比赛数据请求
    Msg_GDMatchList_Ret             = 0x280302, -- 2622210, 比赛列表
    Msg_GDMatchInfo_Ret             = 0x280303, -- 2622211, 比赛详情
    Msg_GDFoundMates_Ret            = 0x280304, -- 2622212, 玩家列表
    Msg_GDMatchEnter_Send           = 0x280305, -- 2622213, 比赛报名和退赛
    Msg_GDMatchNotifyUser_Ret       = 0x280306, -- 2622214, 比赛通知消息
    Msg_GDMatchGameStart_Ret        = 0x280307, -- 2622215, 比赛对局开局
    Msg_GDMatchGameOver_Ret         = 0x280308, -- 2622216, 比赛对局结束
    Msg_GDMatchResumeGame_Ret       = 0x280309, -- 2622217, 比赛恢复对局
    Msg_GDMatchAddBuddy_Ret         = 0x28030a, -- 2622218, 比赛添加好友接受
    Msg_GDMatchAddBuddy_Send        = 0x28030a, -- 2622218, 比赛添加好友发送
};

function GDMatchModel:ctor(target)
-- 0x280301 = 2622209 = Msg_GDMatchData_Send
-- 比赛数据请求
local Msg_GDMatchData_Send_write = function(sendTable)

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

-- 0x280302 = 2622210 = Msg_GDMatchList_Ret
-- 比赛列表
local Msg_GDMatchList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local MatchList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MatchID = netWWBuffer:readInt()
        t_row1.MatchName = netWWBuffer:readLengthAndString()
        t_row1.BeginType = netWWBuffer:readChar()
        t_row1.Flag = netWWBuffer:readLengthAndString()
        t_row1.Requirement = netWWBuffer:readLengthAndString()
        t_row1.MyEnterFlag = netWWBuffer:readChar()
        t_row1.EnterCount = netWWBuffer:readInt()
        t_row1.EnterType = netWWBuffer:readChar()
        t_row1.EnterData = netWWBuffer:readLengthAndString()
        t_row1.EnterEnough = netWWBuffer:readChar()
        t_row1.Countdown = netWWBuffer:readInt()
        t_row1.Interval = netWWBuffer:readInt()
        table.insert(MatchList, t_row1)
    end
    t_result["MatchList"] = MatchList

    local count = netWWBuffer:readShort()
    local PlayTypeList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.PlayType = netWWBuffer:readShort()
        table.insert(PlayTypeList, t_row1)
    end
    t_result["PlayTypeList"] = PlayTypeList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280302 = 2622210 = Msg_GDMatchList_Ret
-- 比赛列表线程函数解析关系注册
local Msg_GDMatchList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","MatchList"},
          {"int","MatchID"},
          {"string","MatchName"},
          {"char","BeginType"},
          {"string","Flag"},
          {"string","Requirement"},
          {"char","MyEnterFlag"},
          {"int","EnterCount"},
          {"char","EnterType"},
          {"string","EnterData"},
          {"char","EnterEnough"},
          {"int","Countdown"},
          {"int","Interval"},
    },
    {"loop",
          {"short","PlayTypeList"},
          {"short","PlayType"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x280303 = 2622211 = Msg_GDMatchInfo_Ret
-- 比赛详情
local Msg_GDMatchInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.MatchID = netWWBuffer:readInt()
    t_result.Name = netWWBuffer:readLengthAndString()
    t_result.BeginType = netWWBuffer:readChar()
    t_result.TeamWork = netWWBuffer:readChar()
    t_result.TeammateID = netWWBuffer:readInt()
    t_result.Requirement = netWWBuffer:readLengthAndString()
    t_result.MyEnterFlag = netWWBuffer:readChar()
    t_result.InstID = netWWBuffer:readInt()
    t_result.Countdown = netWWBuffer:readInt()
    t_result.Interval = netWWBuffer:readInt()
    t_result.EnterType = netWWBuffer:readChar()
    t_result.EnterData = netWWBuffer:readLengthAndString()
    t_result.EnterEnough = netWWBuffer:readChar()
    t_result.EnterCount = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.SignupTermDesc = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readShort()
    local awardList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.BeginRankNo = netWWBuffer:readShort()
        t_row1.EndRankNo = netWWBuffer:readShort()
        t_row1.Award = netWWBuffer:readLengthAndString()
        local count2 = netWWBuffer:readShort()
        local magicList = {}
        for i=1, count2 do
            local t_row2 = {}
            t_row2.MagicID = netWWBuffer:readInt()
            t_row2.FID = netWWBuffer:readInt()
            t_row2.MagicName = netWWBuffer:readLengthAndString()
            t_row2.MagicCount = netWWBuffer:readInt()
            table.insert(magicList, t_row2)
        end
        t_row1["magicList"] = magicList

        table.insert(awardList, t_row1)
    end
    t_result["awardList"] = awardList

    t_result.PlayType = netWWBuffer:readShort()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280303 = 2622211 = Msg_GDMatchInfo_Ret
-- 比赛详情线程函数解析关系注册
local Msg_GDMatchInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","MatchID"},
    {"string","Name"},
    {"char","BeginType"},
    {"char","TeamWork"},
    {"int","TeammateID"},
    {"string","Requirement"},
    {"char","MyEnterFlag"},
    {"int","InstID"},
    {"int","Countdown"},
    {"int","Interval"},
    {"char","EnterType"},
    {"string","EnterData"},
    {"char","EnterEnough"},
    {"int","EnterCount"},
    {"string","Desc"},
    {"string","SignupTermDesc"},
    {"loop",
          {"short","awardList"},
          {"short","BeginRankNo"},
          {"short","EndRankNo"},
          {"string","Award"},
    {"loop",
          {"short","magicList"},
          {"int","MagicID"},
          {"int","FID"},
          {"string","MagicName"},
          {"int","MagicCount"},
    },
    },
    {"short","PlayType"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280304 = 2622212 = Msg_GDFoundMates_Ret
-- 玩家列表
local Msg_GDFoundMates_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    local count = netWWBuffer:readShort()
    local mateList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Nickname = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.OnlineFlag = netWWBuffer:readChar()
        t_row1.Param1 = netWWBuffer:readInt()
        t_row1.Gender = netWWBuffer:readChar()
        table.insert(mateList, t_row1)
    end
    t_result["mateList"] = mateList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280304 = 2622212 = Msg_GDFoundMates_Ret
-- 玩家列表线程函数解析关系注册
local Msg_GDFoundMates_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"loop",
          {"short","mateList"},
          {"int","UserID"},
          {"string","Nickname"},
          {"int","IconID"},
          {"char","OnlineFlag"},
          {"int","Param1"},
          {"char","Gender"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x280305 = 2622213 = Msg_GDMatchEnter_Send
-- 比赛报名和退赛
local Msg_GDMatchEnter_Send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x280306 = 2622214 = Msg_GDMatchNotifyUser_Ret
-- 比赛通知消息
local Msg_GDMatchNotifyUser_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    t_result.MatchID = netWWBuffer:readInt()
    t_result.MatchName = netWWBuffer:readLengthAndString()
    t_result.InstMatchID = netWWBuffer:readInt()
    t_result.Param1 = netWWBuffer:readInt()
    t_result.RespInfo = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280306 = 2622214 = Msg_GDMatchNotifyUser_Ret
-- 比赛通知消息线程函数解析关系注册
local Msg_GDMatchNotifyUser_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"int","MatchID"},
    {"string","MatchName"},
    {"int","InstMatchID"},
    {"int","Param1"},
    {"string","RespInfo"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280307 = 2622215 = Msg_GDMatchGameStart_Ret
-- 比赛对局开局
local Msg_GDMatchGameStart_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.InstMatchID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readShort()
    t_result.ZoneWin = netWWBuffer:readChar()
    t_result.SetNo = netWWBuffer:readShort()
    t_result.PlayNo = netWWBuffer:readShort()
    t_result.ScoreBase = netWWBuffer:readInt()
    t_result.Trump = netWWBuffer:readChar()
    t_result.PlayTimeout = netWWBuffer:readShort()
    t_result.FHTimeout = netWWBuffer:readShort()
    local count = netWWBuffer:readChar()
    local playerList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.card = netWWBuffer:readLengthAndString()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.VIP = netWWBuffer:readShort()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.Score = netWWBuffer:readInt()
        t_row1.MRanking = netWWBuffer:readInt()
        table.insert(playerList, t_row1)
    end
    t_result["playerList"] = playerList

    t_result.NextPlayerID = netWWBuffer:readInt()
    t_result.TrumpCard = netWWBuffer:readChar()
    t_result.TCUserID1 = netWWBuffer:readInt()
    t_result.TCUserID2 = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280307 = 2622215 = Msg_GDMatchGameStart_Ret
-- 比赛对局开局线程函数解析关系注册
local Msg_GDMatchGameStart_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","InstMatchID"},
    {"short","PlayType"},
    {"char","ZoneWin"},
    {"short","SetNo"},
    {"short","PlayNo"},
    {"int","ScoreBase"},
    {"char","Trump"},
    {"short","PlayTimeout"},
    {"short","FHTimeout"},
    {"loop",
          {"char","playerList"},
          {"int","UserID"},
          {"string","card"},
          {"string","UserName"},
          {"int","IconID"},
          {"short","VIP"},
          {"char","Gender"},
          {"int","Score"},
          {"int","MRanking"},
    },
    {"int","NextPlayerID"},
    {"char","TrumpCard"},
    {"int","TCUserID1"},
    {"int","TCUserID2"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x280308 = 2622216 = Msg_GDMatchGameOver_Ret
-- 比赛对局结束
local Msg_GDMatchGameOver_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.InstMatchID = netWWBuffer:readInt()
    local count = netWWBuffer:readChar()
    local playerList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Ranking = netWWBuffer:readChar()
        t_row1.MRanking = netWWBuffer:readInt()
        t_row1.Card = netWWBuffer:readLengthAndString()
        t_row1.Score = netWWBuffer:readInt()
        t_row1.TScore = netWWBuffer:readInt()
        table.insert(playerList, t_row1)
    end
    t_result["playerList"] = playerList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280308 = 2622216 = Msg_GDMatchGameOver_Ret
-- 比赛对局结束线程函数解析关系注册
local Msg_GDMatchGameOver_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","InstMatchID"},
    {"loop",
          {"char","playerList"},
          {"int","UserID"},
          {"char","Ranking"},
          {"int","MRanking"},
          {"string","Card"},
          {"int","Score"},
          {"int","TScore"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x280309 = 2622217 = Msg_GDMatchResumeGame_Ret
-- 比赛恢复对局
local Msg_GDMatchResumeGame_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.MatchID = netWWBuffer:readInt()
    t_result.MatchName = netWWBuffer:readLengthAndString()
    t_result.InstMatchID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readShort()
    t_result.ZoneWin = netWWBuffer:readChar()
    t_result.SetNo = netWWBuffer:readShort()
    t_result.PlayNo = netWWBuffer:readShort()
    t_result.NeedPlayNo = netWWBuffer:readShort()
    t_result.WinCount = netWWBuffer:readInt()
    t_result.PlayerCount = netWWBuffer:readInt()
    t_result.ScoreBase = netWWBuffer:readInt()
    t_result.Trump = netWWBuffer:readChar()
    t_result.PlayTimeout = netWWBuffer:readShort()
    t_result.LastPlayUserID = netWWBuffer:readInt()
    t_result.LastPlayCards = netWWBuffer:readLengthAndString()
    t_result.NextPlayUseID = netWWBuffer:readInt()
    t_result.NextPlayTimeout = netWWBuffer:readShort()
    local count = netWWBuffer:readChar()
    local playerList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.UserType = netWWBuffer:readChar()
        t_row1.card = netWWBuffer:readLengthAndString()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.VIP = netWWBuffer:readShort()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.Score = netWWBuffer:readInt()
        t_row1.MRanking = netWWBuffer:readInt()
        table.insert(playerList, t_row1)
    end
    t_result["playerList"] = playerList

    t_result.BeginType = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x280309 = 2622217 = Msg_GDMatchResumeGame_Ret
-- 比赛恢复对局线程函数解析关系注册
local Msg_GDMatchResumeGame_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"int","MatchID"},
    {"string","MatchName"},
    {"int","InstMatchID"},
    {"short","PlayType"},
    {"char","ZoneWin"},
    {"short","SetNo"},
    {"short","PlayNo"},
    {"short","NeedPlayNo"},
    {"int","WinCount"},
    {"int","PlayerCount"},
    {"int","ScoreBase"},
    {"char","Trump"},
    {"short","PlayTimeout"},
    {"int","LastPlayUserID"},
    {"string","LastPlayCards"},
    {"int","NextPlayUseID"},
    {"short","NextPlayTimeout"},
    {"loop",
          {"char","playerList"},
          {"int","UserID"},
          {"char","UserType"},
          {"string","card"},
          {"string","UserName"},
          {"int","IconID"},
          {"short","VIP"},
          {"char","Gender"},
          {"int","Score"},
          {"int","MRanking"},
    },
    {"char","BeginType"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x28030a = 2622218 = Msg_GDMatchAddBuddy_Ret
-- 比赛添加好友接受
local Msg_GDMatchAddBuddy_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.type = netWWBuffer:readChar()
    t_result.toUserID = netWWBuffer:readInt()
    t_result.IconID = netWWBuffer:readInt()
    t_result.nickname = netWWBuffer:readLengthAndString()
    t_result.Param1 = netWWBuffer:readInt()
    t_result.Param2 = netWWBuffer:readInt()
    t_result.Gender = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x28030a = 2622218 = Msg_GDMatchAddBuddy_Ret
-- 比赛添加好友接受线程函数解析关系注册
local Msg_GDMatchAddBuddy_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","type"},
    {"int","toUserID"},
    {"int","IconID"},
    {"string","nickname"},
    {"int","Param1"},
    {"int","Param2"},
    {"char","Gender"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x28030a = 2622218 = Msg_GDMatchAddBuddy_Send
-- 比赛添加好友发送
local Msg_GDMatchAddBuddy_Send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDMatchData_Send, Msg_GDMatchData_Send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchList_Ret, Msg_GDMatchList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchList_Ret,Msg_GDMatchList_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchInfo_Ret, Msg_GDMatchInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchInfo_Ret,Msg_GDMatchInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDFoundMates_Ret, Msg_GDFoundMates_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDFoundMates_Ret,Msg_GDFoundMates_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDMatchEnter_Send, Msg_GDMatchEnter_Send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchNotifyUser_Ret, Msg_GDMatchNotifyUser_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchNotifyUser_Ret,Msg_GDMatchNotifyUser_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchGameStart_Ret, Msg_GDMatchGameStart_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchGameStart_Ret,Msg_GDMatchGameStart_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchGameOver_Ret, Msg_GDMatchGameOver_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchGameOver_Ret,Msg_GDMatchGameOver_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchResumeGame_Ret, Msg_GDMatchResumeGame_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchResumeGame_Ret,Msg_GDMatchResumeGame_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDMatchAddBuddy_Ret, Msg_GDMatchAddBuddy_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDMatchAddBuddy_Ret,Msg_GDMatchAddBuddy_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDMatchAddBuddy_Send, Msg_GDMatchAddBuddy_Send_write, target)


end

return GDMatchModel
