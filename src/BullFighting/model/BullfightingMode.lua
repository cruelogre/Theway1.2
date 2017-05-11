-------------------------------------------------------------------------
-- Desc:    地方棋牌斗牛
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local BullfightingMode = class("BullfightingMode")

BullfightingMode.MSG_ID = {
    Msg_NMessage_DNGameStart        = 0x2d0101, -- 2949377, 2.1.1.  游戏开局
    Msg_NMessage_DNShowPokerReq_send = 0x2d0102, -- 2949378, 2.1.2.  请求玩家亮牌
    Msg_NMessage_DNShowPokerRes_ret = 0x2d0103, -- 2949379, 2.1.3.  响应玩家亮牌
    Msg_NMessage_DNStartBetShowRes  = 0x2d0106, -- 2949382, 2.1.6.  通知下注/ 亮牌
    Msg_NMessage_DNBetReq_send      = 0x2d0107, -- 2949383, 2.1.7.  请求玩家下注
    Msg_NMessage_DNBetRes_ret       = 0x2d0108, -- 2949384, 2.1.8.  响应玩家下注
    Msg_NMessage_DNGameOver         = 0x2d0109, -- 2949385, 2.1.9.  牌局结束
    Msg_NMessage_DNLobbyActionReq_send = 0x2d011a, -- 2949402, 请求大厅操作(响应进入房间（随机看牌）)
    Msg_NMessage_DNInNorRoomRes     = 0x2d0143, -- 2949443, 2.1.67. 响应进入房间
    Msg_NMessage_DNNoticeInOutRes   = 0x2d0144, -- 2949444, 2.1.68.通知进/出房间(随机、看牌新玩法)
};

function BullfightingMode:ctor(target)
-- 0x2d0101 = 2949377 = Msg_NMessage_DNGameStart
-- 2.1.1.  游戏开局
local Msg_NMessage_DNGameStart_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GameID = netWWBuffer:readInt()
    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.Revenue = netWWBuffer:readLengthAndString()
    t_result.BankUserID = netWWBuffer:readInt()
    t_result.MyUserId = netWWBuffer:readInt()
    t_result.MyCard = netWWBuffer:readLengthAndString()
    t_result.MyBullNum = netWWBuffer:readShort()
    t_result.MyRobScore = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readChar()
    local PlayTable = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserId = netWWBuffer:readInt()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.Icon = netWWBuffer:readLengthAndString()
        t_row1.Grade = netWWBuffer:readShort()
        t_row1.Chip = netWWBuffer:readLengthAndString()
        table.insert(PlayTable, t_row1)
    end
    t_result["PlayTable"] = PlayTable

    t_result.MyBoxSwitch = netWWBuffer:readChar()
    t_result.MyHavedBox = netWWBuffer:readChar()
    t_result.MyOpenBoxTime = netWWBuffer:readInt()
    t_result.HandleTime = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0101 = 2949377 = Msg_NMessage_DNGameStart
-- 2.1.1.  游戏开局线程函数解析关系注册
local Msg_NMessage_DNGameStart_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GameID"},
    {"int","GamePlayID"},
    {"char","PlayType"},
    {"string","Revenue"},
    {"int","BankUserID"},
    {"int","MyUserId"},
    {"string","MyCard"},
    {"short","MyBullNum"},
    {"string","MyRobScore"},
    {"loop",
          {"char","PlayTable"},
          {"int","UserId"},
          {"string","UserName"},
          {"string","Icon"},
          {"short","Grade"},
          {"string","Chip"},
    },
    {"char","MyBoxSwitch"},
    {"char","MyHavedBox"},
    {"int","MyOpenBoxTime"},
    {"char","HandleTime"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d0102 = 2949378 = Msg_NMessage_DNShowPokerReq_send
-- 2.1.2.  请求玩家亮牌
local Msg_NMessage_DNShowPokerReq_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x2d0103 = 2949379 = Msg_NMessage_DNShowPokerRes_ret
-- 2.1.3.  响应玩家亮牌
local Msg_NMessage_DNShowPokerRes_ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.ReturnCode = netWWBuffer:readChar()
    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.UserID = netWWBuffer:readInt()
    t_result.Card = netWWBuffer:readLengthAndString()
    t_result.BullNum = netWWBuffer:readShort()
    t_result.showPokerTime = netWWBuffer:readShort()
    t_result.type = netWWBuffer:readChar()
    t_result.helpCash = netWWBuffer:readInt()
    t_result.handlerCash = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0103 = 2949379 = Msg_NMessage_DNShowPokerRes_ret
-- 2.1.3.  响应玩家亮牌线程函数解析关系注册
local Msg_NMessage_DNShowPokerRes_ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","ReturnCode"},
    {"int","GamePlayID"},
    {"char","PlayType"},
    {"int","UserID"},
    {"string","Card"},
    {"short","BullNum"},
    {"short","showPokerTime"},
    {"char","type"},
    {"int","helpCash"},
    {"string","handlerCash"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d0106 = 2949382 = Msg_NMessage_DNStartBetShowRes
-- 2.1.6.  通知下注/ 亮牌
local Msg_NMessage_DNStartBetShowRes_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.Type = netWWBuffer:readChar()
    t_result.BankUserID = netWWBuffer:readInt()
    t_result.LastPoker = netWWBuffer:readChar()
    t_result.MyBetScore = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readChar()
    local ScoreInfos = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserId = netWWBuffer:readInt()
        t_row1.Score = netWWBuffer:readShort()
        table.insert(ScoreInfos, t_row1)
    end
    t_result["ScoreInfos"] = ScoreInfos

    t_result.BetTime = netWWBuffer:readChar()
    t_result.GamePlayID2 = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0106 = 2949382 = Msg_NMessage_DNStartBetShowRes
-- 2.1.6.  通知下注/ 亮牌线程函数解析关系注册
local Msg_NMessage_DNStartBetShowRes_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"char","PlayType"},
    {"char","Type"},
    {"int","BankUserID"},
    {"char","LastPoker"},
    {"string","MyBetScore"},
    {"loop",
          {"char","ScoreInfos"},
          {"int","UserId"},
          {"short","Score"},
    },
    {"char","BetTime"},
    {"int","GamePlayID2"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d0107 = 2949383 = Msg_NMessage_DNBetReq_send
-- 2.1.7.  请求玩家下注
local Msg_NMessage_DNBetReq_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x2d0108 = 2949384 = Msg_NMessage_DNBetRes_ret
-- 2.1.8.  响应玩家下注
local Msg_NMessage_DNBetRes_ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.ReturnCode = netWWBuffer:readChar()
    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.UserId = netWWBuffer:readInt()
    t_result.SeatId = netWWBuffer:readChar()
    t_result.Chip = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0108 = 2949384 = Msg_NMessage_DNBetRes_ret
-- 2.1.8.  响应玩家下注线程函数解析关系注册
local Msg_NMessage_DNBetRes_ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","ReturnCode"},
    {"int","GamePlayID"},
    {"char","PlayType"},
    {"int","UserId"},
    {"char","SeatId"},
    {"string","Chip"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d0109 = 2949385 = Msg_NMessage_DNGameOver
-- 2.1.9.  牌局结束
local Msg_NMessage_DNGameOver_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.isAllKill = netWWBuffer:readChar()
    local count = netWWBuffer:readChar()
    local PlayTable = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.IsShow = netWWBuffer:readChar()
        t_row1.Card = netWWBuffer:readLengthAndString()
        t_row1.BullNum = netWWBuffer:readShort()
        t_row1.WinLoseFlag = netWWBuffer:readChar()
        t_row1.InCome = netWWBuffer:readLengthAndString()
        t_row1.ShowPokerTime = netWWBuffer:readShort()
        t_row1.Extra = netWWBuffer:readShort()
        t_row1.FinalChip = netWWBuffer:readLengthAndString()
        table.insert(PlayTable, t_row1)
    end
    t_result["PlayTable"] = PlayTable

    local HelpCashs = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.HelpCash = netWWBuffer:readInt()
        table.insert(HelpCashs, t_row1)
    end
    t_result["HelpCashs"] = HelpCashs

    t_result.CreateGameTimeOut = netWWBuffer:readChar()
    t_result.isEnough = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0109 = 2949385 = Msg_NMessage_DNGameOver
-- 2.1.9.  牌局结束线程函数解析关系注册
local Msg_NMessage_DNGameOver_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","GamePlayID"},
    {"char","PlayType"},
    {"char","isAllKill"},
    {"loop",
          {"char","PlayTable"},
          {"int","UserID"},
          {"string","UserName"},
          {"char","IsShow"},
          {"string","Card"},
          {"short","BullNum"},
          {"char","WinLoseFlag"},
          {"string","InCome"},
          {"short","ShowPokerTime"},
          {"short","Extra"},
          {"string","FinalChip"},
    },
    {"loop",
          {"none","HelpCashs"},
          {"int","HelpCash"},
    },
    {"char","CreateGameTimeOut"},
    {"char","isEnough"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d011a = 2949402 = Msg_NMessage_DNLobbyActionReq_send
-- 请求大厅操作(响应进入房间（随机看牌）)
local Msg_NMessage_DNLobbyActionReq_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x2d0143 = 2949443 = Msg_NMessage_DNInNorRoomRes
-- 2.1.67. 响应进入房间
local Msg_NMessage_DNInNorRoomRes_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.ReturnCode = netWWBuffer:readChar()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.RoomId = netWWBuffer:readInt()
    t_result.GameStatus = netWWBuffer:readChar()
    t_result.BankerId = netWWBuffer:readInt()
    t_result.RemainTime = netWWBuffer:readChar()
    t_result.UserId = netWWBuffer:readInt()
    t_result.MySeatId = netWWBuffer:readChar()
    t_result.MyRobScore = netWWBuffer:readLengthAndString()
    t_result.MyBetScore = netWWBuffer:readLengthAndString()
    t_result.MyBoxSwitch = netWWBuffer:readChar()
    t_result.MyHavedBox = netWWBuffer:readChar()
    t_result.MyOpenBoxTime = netWWBuffer:readInt()
    t_result.FastestShow = netWWBuffer:readInt()
    local count = netWWBuffer:readChar()
    local UserTable = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserId = netWWBuffer:readInt()
        t_row1.UserName = netWWBuffer:readLengthAndString()
        t_row1.Icon = netWWBuffer:readLengthAndString()
        t_row1.Grade = netWWBuffer:readShort()
        t_row1.Chip = netWWBuffer:readLengthAndString()
        t_row1.Status = netWWBuffer:readChar()
        t_row1.RobRate = netWWBuffer:readChar()
        t_row1.BetRate = netWWBuffer:readChar()
        t_row1.CardStatus = netWWBuffer:readChar()
        t_row1.Card = netWWBuffer:readLengthAndString()
        t_row1.BullNum = netWWBuffer:readShort()
        t_row1.ShowPokerTime = netWWBuffer:readChar()
        t_row1.isShow = netWWBuffer:readChar()
        t_row1.SeatId = netWWBuffer:readChar()
        table.insert(UserTable, t_row1)
    end
    t_result["UserTable"] = UserTable

    t_result.GamePlayID = netWWBuffer:readInt()
    t_result.GameZoneId = netWWBuffer:readInt()
    t_result.GameZoneAdaptId = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0143 = 2949443 = Msg_NMessage_DNInNorRoomRes
-- 2.1.67. 响应进入房间线程函数解析关系注册
local Msg_NMessage_DNInNorRoomRes_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","ReturnCode"},
    {"char","PlayType"},
    {"int","RoomId"},
    {"char","GameStatus"},
    {"int","BankerId"},
    {"char","RemainTime"},
    {"int","UserId"},
    {"char","MySeatId"},
    {"string","MyRobScore"},
    {"string","MyBetScore"},
    {"char","MyBoxSwitch"},
    {"char","MyHavedBox"},
    {"int","MyOpenBoxTime"},
    {"int","FastestShow"},
    {"loop",
          {"char","UserTable"},
          {"int","UserId"},
          {"string","UserName"},
          {"string","Icon"},
          {"short","Grade"},
          {"string","Chip"},
          {"char","Status"},
          {"char","RobRate"},
          {"char","BetRate"},
          {"char","CardStatus"},
          {"string","Card"},
          {"short","BullNum"},
          {"char","ShowPokerTime"},
          {"char","isShow"},
          {"char","SeatId"},
    },
    {"int","GamePlayID"},
    {"int","GameZoneId"},
    {"int","GameZoneAdaptId"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x2d0144 = 2949444 = Msg_NMessage_DNNoticeInOutRes
-- 2.1.68.通知进/出房间(随机、看牌新玩法)
local Msg_NMessage_DNNoticeInOutRes_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    t_result.PlayType = netWWBuffer:readChar()
    t_result.UserId = netWWBuffer:readInt()
    t_result.UserName = netWWBuffer:readLengthAndString()
    t_result.Grade = netWWBuffer:readShort()
    t_result.Icon = netWWBuffer:readLengthAndString()
    t_result.Chip = netWWBuffer:readLengthAndString()
    t_result.SeatId = netWWBuffer:readChar()
    t_result.GameStatus = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x2d0144 = 2949444 = Msg_NMessage_DNNoticeInOutRes
-- 2.1.68.通知进/出房间(随机、看牌新玩法)线程函数解析关系注册
local Msg_NMessage_DNNoticeInOutRes_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"char","PlayType"},
    {"int","UserId"},
    {"string","UserName"},
    {"short","Grade"},
    {"string","Icon"},
    {"string","Chip"},
    {"char","SeatId"},
    {"char","GameStatus"},

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNGameStart, Msg_NMessage_DNGameStart_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNGameStart,Msg_NMessage_DNGameStart_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_NMessage_DNShowPokerReq_send, Msg_NMessage_DNShowPokerReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNShowPokerRes_ret, Msg_NMessage_DNShowPokerRes_ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNShowPokerRes_ret,Msg_NMessage_DNShowPokerRes_ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNStartBetShowRes, Msg_NMessage_DNStartBetShowRes_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNStartBetShowRes,Msg_NMessage_DNStartBetShowRes_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_NMessage_DNBetReq_send, Msg_NMessage_DNBetReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNBetRes_ret, Msg_NMessage_DNBetRes_ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNBetRes_ret,Msg_NMessage_DNBetRes_ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNGameOver, Msg_NMessage_DNGameOver_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNGameOver,Msg_NMessage_DNGameOver_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_NMessage_DNLobbyActionReq_send, Msg_NMessage_DNLobbyActionReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNInNorRoomRes, Msg_NMessage_DNInNorRoomRes_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNInNorRoomRes,Msg_NMessage_DNInNorRoomRes_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NMessage_DNNoticeInOutRes, Msg_NMessage_DNNoticeInOutRes_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NMessage_DNNoticeInOutRes,Msg_NMessage_DNNoticeInOutRes_Threadread())


end

return BullfightingMode
