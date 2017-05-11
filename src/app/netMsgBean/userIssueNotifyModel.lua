-------------------------------------------------------------------------
-- Desc:    用户数据发放模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local userIssueNotifyModel = class("userIssueNotifyModel")

userIssueNotifyModel.MSG_ID = {
    Msg_RequestInfo_Send            = 0x10101, -- 65793, 用户信息请求
    Msg_ResultInfo_Ret              = 0x10108, -- 65800, 操作反馈消息
    Msg_IssueNotify_Ret             = 0x10137, -- 65847, 用户物品发放
};

function userIssueNotifyModel:ctor(target)
-- 0x10101 = 65793 = Msg_RequestInfo_Send
-- 用户信息请求
local Msg_RequestInfo_Send_write = function(sendTable)

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

-- 0x10108 = 65800 = Msg_ResultInfo_Ret
-- 操作反馈消息
local Msg_ResultInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.Type = netWWBuffer:readChar()
    t_result.Result = netWWBuffer:readChar()
    t_result.Description = netWWBuffer:readLengthAndString()
    t_result.Parameter = netWWBuffer:readInt()
    t_result.Parameter2 = netWWBuffer:readLengthAndString()
    t_result.Parameter3 = netWWBuffer:readLengthAndString()
    t_result.Parameter4 = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x10108 = 65800 = Msg_ResultInfo_Ret
-- 操作反馈消息线程函数解析关系注册
local Msg_ResultInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"char","Type"},
    {"char","Result"},
    {"string","Description"},
    {"int","Parameter"},
    {"string","Parameter2"},
    {"string","Parameter3"},
    {"string","Parameter4"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x10137 = 65847 = Msg_IssueNotify_Ret
-- 用户物品发放
local Msg_IssueNotify_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.userId = netWWBuffer:readInt()
    t_result.gameCash = netWWBuffer:readLengthAndString()
    t_result.issueType = netWWBuffer:readInt()
    t_result.notifyMsg = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readShort()
    local signArr = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.magicName = netWWBuffer:readLengthAndString()
        t_row1.magicId = netWWBuffer:readInt()
        t_row1.magicCount = netWWBuffer:readInt()
        t_row1.magicUnit = netWWBuffer:readLengthAndString()
        t_row1.magicFid = netWWBuffer:readInt()
        t_row1.magicFunType = netWWBuffer:readShort()
        table.insert(signArr, t_row1)
    end
    t_result["signArr"] = signArr

    t_result.result = netWWBuffer:readChar()
    t_result.magicIssueId = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x10137 = 65847 = Msg_IssueNotify_Ret
-- 用户物品发放线程函数解析关系注册
local Msg_IssueNotify_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","userId"},
    {"string","gameCash"},
    {"int","issueType"},
    {"string","notifyMsg"},
    {"loop",
          {"short","signArr"},
          {"string","magicName"},
          {"int","magicId"},
          {"int","magicCount"},
          {"string","magicUnit"},
          {"int","magicFid"},
          {"short","magicFunType"},
    },
    {"char","result"},
    {"int","magicIssueId"},

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_RequestInfo_Send, Msg_RequestInfo_Send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ResultInfo_Ret, Msg_ResultInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ResultInfo_Ret,Msg_ResultInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_IssueNotify_Ret, Msg_IssueNotify_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_IssueNotify_Ret,Msg_IssueNotify_Ret_Threadread())


end

return userIssueNotifyModel
