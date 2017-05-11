-------------------------------------------------------------------------
-- Desc:    用户信息模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local userInfoModel = class("userInfoModel")

userInfoModel.MSG_ID = {
    Msg_ReqUserInfo_send            = 0x10101, -- 65793, 用户信息请求
    Msg_BindPhoneReq_send           = 0x10126, -- 65830, 手机绑定|解除绑定请求
    Msg_NewUpdateUserInfo_send      = 0x1012e, -- 65838, 更新用户信息
    Msg_unregisterReq_send          = 0x20103, -- 131331, 用户注销请求
    Msg_GDUserInfo_send             = 0x60804, -- 395268, 请求灌蛋玩家个人信息
    Msg_GDUserInfo_Ret              = 0x60806, -- 395270, 灌蛋玩家个人信息
    Msg_RUserGameScore_Ret          = 0x60807, -- 395271, 玩家游戏数据信息
    Msg_GDAwardNotify_Ret           = 0x60808, -- 395272, 平台奖励通知
    Msg_GDTaskList_Ret              = 0x6080a, -- 395274, 灌蛋的每日任务
};

function userInfoModel:ctor(target)
-- 0x10101 = 65793 = Msg_ReqUserInfo_send
-- 用户信息请求
local Msg_ReqUserInfo_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x10126 = 65830 = Msg_BindPhoneReq_send
-- 手机绑定|解除绑定请求
local Msg_BindPhoneReq_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x1012e = 65838 = Msg_NewUpdateUserInfo_send
-- 更新用户信息
local Msg_NewUpdateUserInfo_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x20103 = 131331 = Msg_unregisterReq_send
-- 用户注销请求
local Msg_unregisterReq_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60804 = 395268 = Msg_GDUserInfo_send
-- 请求灌蛋玩家个人信息
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

-- 0x60806 = 395270 = Msg_GDUserInfo_Ret
-- 灌蛋玩家个人信息
local Msg_GDUserInfo_Ret_read = function(reciveMsgId, netWWBuffer)

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
    t_result.Region = netWWBuffer:readLengthAndString()
    t_result.GameCash = netWWBuffer:readLengthAndString()
    t_result.Diamond = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60806 = 395270 = Msg_GDUserInfo_Ret
-- 灌蛋玩家个人信息线程函数解析关系注册
local Msg_GDUserInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"string","Nickname"},
    {"int","IconID"},
    {"short","VIP"},
    {"char","Gender"},
    {"string","Region"},
    {"string","GameCash"},
    {"string","Diamond"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x60807 = 395271 = Msg_RUserGameScore_Ret
-- 玩家游戏数据信息
local Msg_RUserGameScore_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.GameID = netWWBuffer:readShort()
    local count = netWWBuffer:readChar()
    local scoreList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.PlayType = netWWBuffer:readShort()
        t_row1.AllPlay = netWWBuffer:readInt()
        t_row1.AllWin = netWWBuffer:readInt()
        table.insert(scoreList, t_row1)
    end
    t_result["scoreList"] = scoreList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60807 = 395271 = Msg_RUserGameScore_Ret
-- 玩家游戏数据信息线程函数解析关系注册
local Msg_RUserGameScore_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"short","GameID"},
    {"loop",
          {"char","scoreList"},
          {"short","PlayType"},
          {"int","AllPlay"},
          {"int","AllWin"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x60808 = 395272 = Msg_GDAwardNotify_Ret
-- 平台奖励通知
local Msg_GDAwardNotify_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    local count = netWWBuffer:readChar()
    local awardList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.AwardType = netWWBuffer:readChar()
        t_row1.MagicID = netWWBuffer:readInt()
        t_row1.FID = netWWBuffer:readInt()
        t_row1.AwardData = netWWBuffer:readInt()
        table.insert(awardList, t_row1)
    end
    t_result["awardList"] = awardList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60808 = 395272 = Msg_GDAwardNotify_Ret
-- 平台奖励通知线程函数解析关系注册
local Msg_GDAwardNotify_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"loop",
          {"char","awardList"},
          {"char","AwardType"},
          {"int","MagicID"},
          {"int","FID"},
          {"int","AwardData"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x6080a = 395274 = Msg_GDTaskList_Ret
-- 灌蛋的每日任务
local Msg_GDTaskList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local TaskList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.TaskID = netWWBuffer:readInt()
        t_row1.TaskType = netWWBuffer:readChar()
        t_row1.FID = netWWBuffer:readInt()
        t_row1.TaskParam1 = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.Description = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.TargetValue = netWWBuffer:readInt()
        t_row1.MagicID = netWWBuffer:readInt()
        t_row1.Status = netWWBuffer:readChar()
        t_row1.FinishCount = netWWBuffer:readInt()
        table.insert(TaskList, t_row1)
    end
    t_result["TaskList"] = TaskList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x6080a = 395274 = Msg_GDTaskList_Ret
-- 灌蛋的每日任务线程函数解析关系注册
local Msg_GDTaskList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","TaskList"},
          {"int","TaskID"},
          {"char","TaskType"},
          {"int","FID"},
          {"int","TaskParam1"},
          {"string","Name"},
          {"string","Description"},
          {"int","IconID"},
          {"int","TargetValue"},
          {"int","MagicID"},
          {"char","Status"},
          {"int","FinishCount"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_ReqUserInfo_send, Msg_ReqUserInfo_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_BindPhoneReq_send, Msg_BindPhoneReq_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_NewUpdateUserInfo_send, Msg_NewUpdateUserInfo_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_unregisterReq_send, Msg_unregisterReq_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDUserInfo_send, Msg_GDUserInfo_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDUserInfo_Ret, Msg_GDUserInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDUserInfo_Ret,Msg_GDUserInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RUserGameScore_Ret, Msg_RUserGameScore_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RUserGameScore_Ret,Msg_RUserGameScore_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDAwardNotify_Ret, Msg_GDAwardNotify_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDAwardNotify_Ret,Msg_GDAwardNotify_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_GDTaskList_Ret, Msg_GDTaskList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_GDTaskList_Ret,Msg_GDTaskList_Ret_Threadread())


end

return userInfoModel
