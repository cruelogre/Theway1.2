-------------------------------------------------------------------------
-- Desc:    社交模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SocialContactModel = class("SocialContactModel")

SocialContactModel.MSG_ID = {
    Msg_RSCData_Req                 = 0x6081f, -- 395295, 请求社交数据
    Msg_RSCData_Ret                 = 0x6081f, -- 395295, 请求社交数据返回
    Msg_RSCBuddyList_Ret            = 0x60820, -- 395296, 好友列表
    Msg_RSCBuddyTalk_Req            = 0x60821, -- 395297, 好友聊天
    Msg_RSCBuddyTalk_Ret            = 0x60821, -- 395297, 好友聊天
    Msg_RSCBuddyTalkList_Ret        = 0x60822, -- 395298, 未读消息列表
};

function SocialContactModel:ctor(target)
-- 0x6081f = 395295 = Msg_RSCData_Req
-- 请求社交数据
local Msg_RSCData_Req_write = function(sendTable)

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
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x6081f = 395295 = Msg_RSCData_Ret
-- 请求社交数据返回
local Msg_RSCData_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.type = netWWBuffer:readChar()
    t_result.Param1 = netWWBuffer:readInt()
    t_result.Start = netWWBuffer:readShort()
    t_result.Count = netWWBuffer:readShort()
    t_result.StrParam1 = netWWBuffer:readLengthAndString()
    t_result.StrParam2 = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x6081f = 395295 = Msg_RSCData_Ret
-- 请求社交数据返回线程函数解析关系注册
local Msg_RSCData_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","type"},
    {"int","Param1"},
    {"short","Start"},
    {"short","Count"},
    {"string","StrParam1"},
    {"string","StrParam2"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x60820 = 395296 = Msg_RSCBuddyList_Ret
-- 好友列表
local Msg_RSCBuddyList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    local count = netWWBuffer:readShort()
    local friendList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Nickname = netWWBuffer:readLengthAndString()
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.Gender = netWWBuffer:readChar()
        t_row1.GameCash = netWWBuffer:readLengthAndString()
        t_row1.Diamond = netWWBuffer:readLengthAndString()
        t_row1.OnlineFlag = netWWBuffer:readChar()
        t_row1.Param1 = netWWBuffer:readInt()
        table.insert(friendList, t_row1)
    end
    t_result["friendList"] = friendList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60820 = 395296 = Msg_RSCBuddyList_Ret
-- 好友列表线程函数解析关系注册
local Msg_RSCBuddyList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"loop",
          {"short","friendList"},
          {"int","UserID"},
          {"string","Nickname"},
          {"int","IconID"},
          {"char","Gender"},
          {"string","GameCash"},
          {"string","Diamond"},
          {"char","OnlineFlag"},
          {"int","Param1"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x60821 = 395297 = Msg_RSCBuddyTalk_Req
-- 好友聊天
local Msg_RSCBuddyTalk_Req_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x60821 = 395297 = Msg_RSCBuddyTalk_Ret
-- 好友聊天
local Msg_RSCBuddyTalk_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.type = netWWBuffer:readShort()
    t_result.FromUserID = netWWBuffer:readInt()
    t_result.ToUserID = netWWBuffer:readInt()
    t_result.Content = netWWBuffer:readLengthAndString()
    t_result.TalkMsgID = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60821 = 395297 = Msg_RSCBuddyTalk_Ret
-- 好友聊天线程函数解析关系注册
local Msg_RSCBuddyTalk_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"short","type"},
    {"int","FromUserID"},
    {"int","ToUserID"},
    {"string","Content"},
    {"string","TalkMsgID"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x60822 = 395298 = Msg_RSCBuddyTalkList_Ret
-- 未读消息列表
local Msg_RSCBuddyTalkList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local msgList = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.TalkType = netWWBuffer:readShort()
        t_row1.FromUserID = netWWBuffer:readInt()
        t_row1.Content = netWWBuffer:readLengthAndString()
        t_row1.TalkMsgID = netWWBuffer:readLengthAndString()
        t_row1.CreateTime = netWWBuffer:readLengthAndString()
        table.insert(msgList, t_row1)
    end
    t_result["msgList"] = msgList


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x60822 = 395298 = Msg_RSCBuddyTalkList_Ret
-- 未读消息列表线程函数解析关系注册
local Msg_RSCBuddyTalkList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","msgList"},
          {"short","TalkType"},
          {"int","FromUserID"},
          {"string","Content"},
          {"string","TalkMsgID"},
          {"string","CreateTime"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_RSCData_Req, Msg_RSCData_Req_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RSCData_Ret, Msg_RSCData_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RSCData_Ret,Msg_RSCData_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RSCBuddyList_Ret, Msg_RSCBuddyList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RSCBuddyList_Ret,Msg_RSCBuddyList_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_RSCBuddyTalk_Req, Msg_RSCBuddyTalk_Req_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RSCBuddyTalk_Ret, Msg_RSCBuddyTalk_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RSCBuddyTalk_Ret,Msg_RSCBuddyTalk_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RSCBuddyTalkList_Ret, Msg_RSCBuddyTalkList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RSCBuddyTalkList_Ret,Msg_RSCBuddyTalkList_Ret_Threadread())


end

return SocialContactModel
