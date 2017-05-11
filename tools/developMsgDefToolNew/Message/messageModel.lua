-------------------------------------------------------------------------
-- Desc:    消息公告模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local messageModel = class("messageModel")

messageModel.MSG_ID = {
    Msg_MsgListRequest_send         = 0x40101, -- 262401, 获取消息列表
    Msg_NoticeList_Ret              = 0x40103, -- 262403, 公告列表
    Msg_MsgContentRequest_send      = 0x40104, -- 262404, 获取消息内容 公告
    Msg_MsgContent_Ret              = 0x40105, -- 262405, 公告详细
    Msg_SendTalk_Ret                = 0x40401, -- 263169, 发送滚报消息
    Msg_UserMsgDataReq_send         = 0x40b01, -- 264961, 请求玩家消息箱数据
    Msg_MsgList_Ret                 = 0x40b02, -- 264962, 未读消息列表
};

function messageModel:ctor(target)
-- 0x40101 = 262401 = Msg_MsgListRequest_send
-- 获取消息列表
local Msg_MsgListRequest_send_write = function(sendTable)

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
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x40103 = 262403 = Msg_NoticeList_Ret
-- 公告列表
local Msg_NoticeList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local notices = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MsgID = netWWBuffer:readInt()
        t_row1.Owner = netWWBuffer:readChar()
        t_row1.OwnerID = netWWBuffer:readInt()
        t_row1.ModifiedTime = netWWBuffer:readLengthAndString()
        t_row1.Subject = netWWBuffer:readLengthAndString()
        table.insert(notices, t_row1)
    end
    t_result["notices"] = notices


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x40103 = 262403 = Msg_NoticeList_Ret
-- 公告列表线程函数解析关系注册
local Msg_NoticeList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","notices"},
          {"int","MsgID"},
          {"char","Owner"},
          {"int","OwnerID"},
          {"string","ModifiedTime"},
          {"string","Subject"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x40104 = 262404 = Msg_MsgContentRequest_send
-- 获取消息内容 公告
local Msg_MsgContentRequest_send_write = function(sendTable)

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

    return wb
end

-- 0x40105 = 262405 = Msg_MsgContent_Ret
-- 公告详细
local Msg_MsgContent_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Content = netWWBuffer:readLengthAndString()
    t_result.Response = netWWBuffer:readChar()
    t_result.haveNew = netWWBuffer:readChar()
    t_result.Msgid = netWWBuffer:readInt()
    t_result.Boxid = netWWBuffer:readChar()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x40105 = 262405 = Msg_MsgContent_Ret
-- 公告详细线程函数解析关系注册
local Msg_MsgContent_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"string","Content"},
    {"char","Response"},
    {"char","haveNew"},
    {"int","Msgid"},
    {"char","Boxid"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x40401 = 263169 = Msg_SendTalk_Ret
-- 发送滚报消息
local Msg_SendTalk_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.fromID = netWWBuffer:readInt()
    t_result.fromName = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readShort()
    local User2Users = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.fromUserID = netWWBuffer:readInt()
        t_row1.fromNickName = netWWBuffer:readLengthAndString()
        table.insert(User2Users, t_row1)
    end
    t_result["User2Users"] = User2Users

    t_result.rollType = netWWBuffer:readChar()
    t_result.EvenType = netWWBuffer:readInt()
    t_result.language = netWWBuffer:readChar()
    t_result.Content = netWWBuffer:readLengthAndString()
    t_result.DisplayInterval = netWWBuffer:readShort()
    local count = netWWBuffer:readShort()
    local flashinfos = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.moduleID = netWWBuffer:readInt()
        table.insert(flashinfos, t_row1)
    end
    t_result["flashinfos"] = flashinfos

    t_result.currDateTime = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x40401 = 263169 = Msg_SendTalk_Ret
-- 发送滚报消息线程函数解析关系注册
local Msg_SendTalk_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","fromID"},
    {"string","fromName"},
    {"loop",
          {"short","User2Users"},
          {"int","fromUserID"},
          {"string","fromNickName"},
    },
    {"char","rollType"},
    {"int","EvenType"},
    {"char","language"},
    {"string","Content"},
    {"short","DisplayInterval"},
    {"loop",
          {"short","flashinfos"},
          {"int","moduleID"},
    },
    {"string","currDateTime"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x40b01 = 264961 = Msg_UserMsgDataReq_send
-- 请求玩家消息箱数据
local Msg_UserMsgDataReq_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x40b02 = 264962 = Msg_MsgList_Ret
-- 未读消息列表
local Msg_MsgList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local messages = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MsgID = netWWBuffer:readLengthAndString()
        t_row1.FromWay = netWWBuffer:readInt()
        t_row1.MsgType = netWWBuffer:readChar()
        t_row1.MsgSubType = netWWBuffer:readShort()
        t_row1.CreateTime = netWWBuffer:readLengthAndString()
        t_row1.Content = netWWBuffer:readLengthAndString()
        local count2 = netWWBuffer:readShort()
        local rewards = {}
        for i=1, count2 do
            local t_row2 = {}
            t_row2.ReferType = netWWBuffer:readChar()
            t_row2.Refer1 = netWWBuffer:readInt()
            t_row2.Refer2 = netWWBuffer:readInt()
            t_row2.ReferDesc = netWWBuffer:readLengthAndString()
            table.insert(rewards, t_row2)
        end
        t_row1["rewards"] = rewards

        table.insert(messages, t_row1)
    end
    t_result["messages"] = messages

    local Subjects = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Subject = netWWBuffer:readLengthAndString()
        table.insert(Subjects, t_row1)
    end
    t_result["Subjects"] = Subjects


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x40b02 = 264962 = Msg_MsgList_Ret
-- 未读消息列表线程函数解析关系注册
local Msg_MsgList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","messages"},
          {"string","MsgID"},
          {"int","FromWay"},
          {"char","MsgType"},
          {"short","MsgSubType"},
          {"string","CreateTime"},
          {"string","Content"},
    {"loop",
          {"short","rewards"},
          {"char","ReferType"},
          {"int","Refer1"},
          {"int","Refer2"},
          {"string","ReferDesc"},
    },
    },
    {"loop",
          {"none","Subjects"},
          {"string","Subject"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_MsgListRequest_send, Msg_MsgListRequest_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_NoticeList_Ret, Msg_NoticeList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_NoticeList_Ret,Msg_NoticeList_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_MsgContentRequest_send, Msg_MsgContentRequest_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_MsgContent_Ret, Msg_MsgContent_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_MsgContent_Ret,Msg_MsgContent_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_SendTalk_Ret, Msg_SendTalk_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_SendTalk_Ret,Msg_SendTalk_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_UserMsgDataReq_send, Msg_UserMsgDataReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_MsgList_Ret, Msg_MsgList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_MsgList_Ret,Msg_MsgList_Ret_Threadread())


end

return messageModel
